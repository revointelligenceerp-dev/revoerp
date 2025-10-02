/*
          # [SECURITY] Correção da Ativação de RLS e Políticas
          [Este script corrige o erro de timeout anterior aplicando as políticas de segurança (RLS) de forma incremental, tabela por tabela. Ele garante que cada organização só possa acessar seus próprios dados.]

          ## Query Description: [Ativa a segurança em nível de linha (RLS) e cria as políticas de acesso para todas as tabelas que contêm dados de organização. Esta operação é segura e não afeta os dados existentes, apenas restringe o acesso futuro com base no usuário autenticado.]
          
          ## Metadata:
          - Schema-Category: ["Security"]
          - Impact-Level: ["High"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          [Afeta as políticas de segurança das tabelas: user_profiles, clientes, produtos, servicos, vendedores, embalagens, ordens_servico, ordem_servico_itens, pedido_venda_itens, pedidos_venda, faturas_venda, contas_receber, contas_pagar, ordens_compra, ordem_compra_itens, crm_oportunidades, devolucoes_venda, devolucoes_venda_itens, contratos, notas_entrada, nota_entrada_itens, e tabelas de anexos relacionadas.]
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [As políticas dependem do `auth.uid()` do usuário logado.]
          
          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Leve impacto no desempenho das consultas devido à verificação de RLS, o que é esperado e necessário para a segurança.]
          */

-- Helper function to get the organization ID of the current user
CREATE OR REPLACE FUNCTION get_organization_id()
RETURNS UUID AS $$
DECLARE
  org_id UUID;
BEGIN
  SELECT organization_id INTO org_id
  FROM public.user_profiles
  WHERE user_id = auth.uid()
  LIMIT 1;
  RETURN org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function to authenticated users
GRANT EXECUTE ON FUNCTION public.get_organization_id() TO authenticated;

-- Function to apply RLS policies idempotently
CREATE OR REPLACE FUNCTION apply_rls_policy(table_name TEXT)
RETURNS void AS $$
BEGIN
    -- Enable RLS
    EXECUTE 'ALTER TABLE public.' || quote_ident(table_name) || ' ENABLE ROW LEVEL SECURITY;';

    -- Drop existing policy if it exists
    EXECUTE 'DROP POLICY IF EXISTS "Organization access policy" ON public.' || quote_ident(table_name) || ';';

    -- Create new policy
    EXECUTE 'CREATE POLICY "Organization access policy" ON public.' || quote_ident(table_name) || 
            ' FOR ALL USING (organization_id = get_organization_id());';
END;
$$ LANGUAGE plpgsql;

-- Apply policies table by table to avoid timeout
SELECT apply_rls_policy('user_profiles');
SELECT apply_rls_policy('clientes');
SELECT apply_rls_policy('produtos');
SELECT apply_rls_policy('servicos');
SELECT apply_rls_policy('vendedores');
SELECT apply_rls_policy('embalagens');
SELECT apply_rls_policy('ordens_servico');
SELECT apply_rls_policy('ordem_servico_itens');
SELECT apply_rls_policy('ordem_servico_anexos');
SELECT apply_rls_policy('pedidos_venda');
SELECT apply_rls_policy('pedido_venda_itens');
SELECT apply_rls_policy('pedido_venda_anexos');
SELECT apply_rls_policy('faturas_venda');
SELECT apply_rls_policy('contas_receber');
SELECT apply_rls_policy('contas_receber_anexos');
SELECT apply_rls_policy('contas_pagar');
SELECT apply_rls_policy('contas_pagar_anexos');
SELECT apply_rls_policy('ordens_compra');
SELECT apply_rls_policy('ordem_compra_itens');
SELECT apply_rls_policy('crm_oportunidades');
SELECT apply_rls_policy('devolucoes_venda');
SELECT apply_rls_policy('devolucao_venda_itens');
SELECT apply_rls_policy('contratos');
SELECT apply_rls_policy('contrato_anexos');
SELECT apply_rls_policy('notas_entrada');
SELECT apply_rls_policy('nota_entrada_itens');
SELECT apply_rls_policy('produto_imagens');
SELECT apply_rls_policy('produto_anuncios');
SELECT apply_rls_policy('produtos_fornecedores');
SELECT apply_rls_policy('pessoas_contato');
SELECT apply_rls_policy('cliente_anexos');
SELECT apply_rls_policy('configuracoes');

-- Drop the helper function as it's no longer needed after applying policies
DROP FUNCTION apply_rls_policy(TEXT);
