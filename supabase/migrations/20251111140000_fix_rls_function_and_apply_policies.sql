-- Habilita a extensão pgcrypto se ainda não estiver habilitada, para usar gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

-- Recria a função para obter o organization_id do JWT com a sintaxe correta e segurança aprimorada
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- A sintaxe correta é usar RETURN em vez de SELECT dentro de uma função plpgsql
  RETURN nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
END;
$$;

-- Função auxiliar para aplicar políticas de RLS de forma idempotente
CREATE OR REPLACE PROCEDURE public.apply_rls_policy(table_name text)
LANGUAGE plpgsql
AS $$
DECLARE
  policy_name_select text := 'allow_select_for_organization_members';
  policy_name_insert text := 'allow_insert_for_organization_members';
  policy_name_update text := 'allow_update_for_organization_members';
  policy_name_delete text := 'allow_delete_for_organization_members';
BEGIN
  -- Verifica se a tabela existe antes de tentar alterar
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = table_name) THEN
    -- Habilita RLS na tabela
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_name);
    
    -- Política de SELECT
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', policy_name_select, table_name);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR SELECT USING (organization_id = get_organization_id());', policy_name_select, table_name);
    
    -- Política de INSERT
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', policy_name_insert, table_name);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR INSERT WITH CHECK (organization_id = get_organization_id());', policy_name_insert, table_name);
    
    -- Política de UPDATE
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', policy_name_update, table_name);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR UPDATE USING (organization_id = get_organization_id());', policy_name_update, table_name);
    
    -- Política de DELETE
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', policy_name_delete, table_name);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR DELETE USING (organization_id = get_organization_id());', policy_name_delete, table_name);
  ELSE
    RAISE NOTICE 'Tabela %.% não encontrada, pulando aplicação de RLS.', 'public', table_name;
  END IF;
END;
$$;

-- Lista de todas as tabelas que precisam de RLS
DO $$
DECLARE
  tables_to_secure text[] := array[
    'clientes', 'pessoas_contato', 'cliente_anexos',
    'produtos', 'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
    'servicos',
    'vendedores',
    'embalagens',
    'ordens_servico', 'ordem_servico_itens', 'ordem_servico_anexos',
    'pedidos_venda', 'pedido_venda_itens', 'pedido_venda_anexos',
    'faturas_venda',
    'contas_receber', 'contas_receber_anexos',
    'contas_pagar', 'contas_pagar_anexos',
    'fluxo_caixa',
    'ordens_compra', 'ordem_compra_itens',
    'estoque_movimentos',
    'crm_oportunidades', 'crm_interacoes',
    'devolucoes_venda', 'devolucao_venda_itens',
    'contratos', 'contrato_anexos',
    'notas_entrada', 'nota_entrada_itens',
    'expedicoes', 'expedicao_pedidos',
    'configuracoes'
  ];
  table_name text;
BEGIN
  FOREACH table_name IN ARRAY tables_to_secure
  LOOP
    CALL public.apply_rls_policy(table_name);
  END LOOP;
END;
$$;

-- Garante que a tabela user_profiles também tenha RLS
CALL public.apply_rls_policy('user_profiles');
