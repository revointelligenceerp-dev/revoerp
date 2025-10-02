/*
          # [Final Security Hardening]
          This script provides a definitive fix for multi-tenancy security issues, including RLS (Row Level Security) and JWT claims. It is designed to be idempotent and can be run safely multiple times.

          ## Query Description: [This operation configures the core security of your application. It ensures that each organization's data is isolated and accessible only by its own users. It creates a trigger to inject the organization_id into user authentication tokens and applies strict access policies to all data tables.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Security"]
          - Impact-Level: ["High"]
          - Requires-Backup: [true]
          - Reversible: [false]
          
          ## Structure Details:
          - Creates a trigger `on_profile_created_add_claims` on the `user_profiles` table.
          - Creates a function `add_claims_to_jwt()` to modify user JWTs.
          - Recreates the function `get_organization_id()` with security best practices.
          - Creates a procedure `apply_rls_policies_to_all_tables()` to enable RLS and create policies on all relevant tables.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [This script is the foundation of the authentication/authorization security model.]
          
          ## Performance Impact:
          - Triggers: [Added]
          - Indexes: [None]
          - Estimated Impact: [Minimal performance impact on user profile creation. Significant security improvement.]
          */

-- Step 1: Create a function to add organization_id to the user's JWT claims upon profile creation.
-- This is the crucial step to make RLS work.
create or replace function public.add_claims_to_jwt()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update auth.users
  set raw_app_meta_data = raw_app_meta_data || jsonb_build_object('organization_id', new.organization_id)
  where id = new.user_id;
  
  return new;
end;
$$;

-- Step 2: Create a trigger that calls the function whenever a new user profile is created.
drop trigger if exists on_profile_created_add_claims on public.user_profiles;
create trigger on_profile_created_add_claims
  after insert on public.user_profiles
  for each row
  execute function public.add_claims_to_jwt();

-- Step 3: Recreate the helper function to securely get the organization_id from the JWT.
-- This function will be used in all RLS policies.
create or replace function public.get_organization_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select nullif(current_setting('request.jwt.claims', true)::jsonb->>'organization_id', '')::uuid;
$$;

-- Step 4: Create a procedure to apply RLS policies to all tables idempotently.
create or replace procedure public.apply_rls_policies_to_all_tables()
language plpgsql
as $$
declare
    tbl_name text;
    table_list text[] := array[
        'clientes', 'pessoas_contato', 'cliente_anexos',
        'produtos', 'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
        'servicos',
        'vendedores',
        'embalagens',
        'ordens_servico', 'ordem_servico_itens', 'ordem_servico_anexos',
        'pedidos_venda', 'pedido_venda_itens', 'pedido_venda_anexos',
        'faturas_venda', 'fatura_venda_itens',
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
        'configuracoes',
        'user_profiles'
    ];
begin
    -- First, handle the 'organizations' table separately.
    raise notice 'Applying RLS for table: organizations';
    alter table public.organizations enable row level security;
    alter table public.organizations force row level security;
    drop policy if exists "Allow organization members to read" on public.organizations;
    create policy "Allow organization members to read" on public.organizations for select
        using (id = get_organization_id());

    -- Loop through all other tables and apply standard organization-based policies.
    foreach tbl_name in array table_list
    loop
        if exists (select from pg_tables where schemaname = 'public' and tablename = tbl_name) then
            raise notice 'Applying RLS for table: %', tbl_name;
            execute format('alter table public.%I enable row level security;', tbl_name);
            execute format('alter table public.%I force row level security;', tbl_name);
            
            -- Drop old policies to prevent conflicts
            execute format('drop policy if exists "Enable all access for organization" on public.%I;', tbl_name);
            
            -- Create new, comprehensive policy
            execute format('
                create policy "Enable all access for organization" on public.%I
                for all
                using (organization_id = get_organization_id())
                with check (organization_id = get_organization_id());
            ', tbl_name);
        else
            raise notice 'Table public.% does not exist, skipping RLS.', tbl_name;
        end if;
    end loop;
end;
$$;

-- Step 5: Execute the procedure to apply all policies.
call public.apply_rls_policies_to_all_tables();
