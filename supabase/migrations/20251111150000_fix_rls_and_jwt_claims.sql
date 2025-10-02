-- 1. Helper function to get organization_id from JWT
-- This function is SECURITY DEFINER to access JWT claims securely.
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- This will return the organization_id from the custom claims of the JWT.
  -- It returns null if the claim is not present, which is handled by the RLS policies.
  RETURN nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
END;
$$;

-- Revoke execute from public and grant to authenticated users.
REVOKE ALL ON FUNCTION public.get_organization_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_organization_id() TO authenticated;


-- 2. Function to propagate organization_id to auth.users.raw_app_meta_data
-- This makes the organization_id available in the JWT claims.
CREATE OR REPLACE FUNCTION public.update_user_org_claim()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE auth.users
  SET raw_app_meta_data = raw_app_meta_data || jsonb_build_object('organization_id', NEW.organization_id)
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$;

-- 3. Trigger on user_profiles to update the claim when a profile is created or updated.
DROP TRIGGER IF EXISTS on_profile_update_update_org_claim ON public.user_profiles;
CREATE TRIGGER on_profile_update_update_org_claim
  AFTER INSERT OR UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_user_org_claim();


-- 4. Procedure to apply RLS policies safely
CREATE OR REPLACE PROCEDURE public.apply_rls_policies_safely()
LANGUAGE plpgsql
AS $$
DECLARE
  tbl_name TEXT;
BEGIN
  -- List of tables to apply RLS to
  FOREACH tbl_name IN ARRAY ARRAY[
    'organizations', 'user_profiles', 'clientes', 'cliente_anexos', 'pessoas_contato',
    'produtos', 'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
    'servicos', 'vendedores', 'embalagens', 'ordens_servico', 'ordem_servico_itens',
    'ordem_servico_anexos', 'pedidos_venda', 'pedido_venda_itens', 'pedido_venda_anexos',
    'faturas_venda', 'contas_receber', 'contas_receber_anexos', 'contas_pagar',
    'contas_pagar_anexos', 'ordens_compra', 'ordem_compra_itens', 'estoque_movimentos',
    'crm_oportunidades', 'contratos', 'contrato_anexos', 'devolucoes_venda',
    'devolucao_venda_itens', 'notas_entrada', 'nota_entrada_itens', 'expedicoes',
    'expedicao_pedidos', 'configuracoes'
  ]
  LOOP
    -- Check if the table exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = tbl_name) THEN
      RAISE NOTICE 'Processing table: %', tbl_name;

      -- Check if the organization_id column exists
      IF EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = tbl_name AND column_name = 'organization_id') THEN
        
        -- Enable RLS if not already enabled
        IF NOT (SELECT relrowsecurity FROM pg_class WHERE relname = tbl_name AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')) THEN
          EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl_name);
          RAISE NOTICE '  -> RLS enabled for %', tbl_name;
        END IF;

        -- Drop existing policies to ensure a clean state
        EXECUTE format('DROP POLICY IF EXISTS "Allow organization access" ON public.%I;', tbl_name);

        -- Create the new policy
        EXECUTE format('
          CREATE POLICY "Allow organization access"
          ON public.%I
          FOR ALL
          TO authenticated
          USING (organization_id = public.get_organization_id())
          WITH CHECK (organization_id = public.get_organization_id());
        ', tbl_name);
        RAISE NOTICE '  -> RLS policy created for %', tbl_name;

      ELSE
        RAISE WARNING '  -> Table % does not have an organization_id column. Skipping RLS.', tbl_name;
      END IF;
    ELSE
      RAISE WARNING 'Table % not found. Skipping RLS.', tbl_name;
    END IF;
  END LOOP;
END;
$$;

-- 5. Execute the procedure
CALL public.apply_rls_policies_safely();

-- 6. Clean up
DROP PROCEDURE public.apply_rls_policies_safely();
