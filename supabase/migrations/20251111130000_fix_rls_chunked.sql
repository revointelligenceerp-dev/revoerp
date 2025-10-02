/*
          # [SECURITY] Fix RLS Policies (Chunked)
          This migration enables Row Level Security (RLS) on all necessary tables and creates policies to enforce multi-tenancy. It is designed to be idempotent and run in smaller chunks to avoid connection timeouts.

          ## Query Description: [This operation secures the database by ensuring that users can only access data belonging to their own organization. It enables RLS on each table and applies specific policies for SELECT, INSERT, UPDATE, and DELETE operations. This is a critical security measure for a multi-tenant application.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Security"]
          - Impact-Level: ["High"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tables affected: all user data tables (clientes, produtos, pedidos_venda, etc.)
          - Operations: ALTER TABLE ... ENABLE ROW LEVEL SECURITY, CREATE POLICY
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [Requires authenticated user with a valid organization_id in user_profiles]
          
          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Slight overhead on queries to check RLS policies, which is necessary for security. The impact is generally low with proper indexing.]
          */

-- Helper function to get the organization_id for the current user
CREATE OR REPLACE FUNCTION auth.get_organization_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT organization_id
  FROM user_profiles
  WHERE user_id = auth.uid();
$$;

DO $$
DECLARE
  table_name TEXT;
  tables_to_secure TEXT[] := ARRAY[
    'clientes', 'produtos', 'servicos', 'vendedores', 'embalagens', 
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
    'configuracoes', 'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
    'user_profiles', 'organizations'
  ];
BEGIN
  FOREACH table_name IN ARRAY tables_to_secure
  LOOP
    -- Enable RLS for the table if not already enabled
    EXECUTE 'ALTER TABLE public.' || quote_ident(table_name) || ' ENABLE ROW LEVEL SECURITY;';

    -- Drop existing policies to ensure idempotency
    EXECUTE 'DROP POLICY IF EXISTS "Allow individual read access" ON public.' || quote_ident(table_name) || ';';
    EXECUTE 'DROP POLICY IF EXISTS "Allow individual access" ON public.' || quote_ident(table_name) || ';';
    EXECUTE 'DROP POLICY IF EXISTS "Allow full access for organization" ON public.' || quote_ident(table_name) || ';';

    -- Create SELECT policy
    EXECUTE 'CREATE POLICY "Allow individual read access" ON public.' || quote_ident(table_name) || 
            ' FOR SELECT USING (organization_id = auth.get_organization_id());';

    -- Create INSERT/UPDATE/DELETE policy
    EXECUTE 'CREATE POLICY "Allow individual access" ON public.' || quote_ident(table_name) || 
            ' FOR ALL USING (organization_id = auth.get_organization_id()) ' ||
            'WITH CHECK (organization_id = auth.get_organization_id());';
  END LOOP;
END $$;
