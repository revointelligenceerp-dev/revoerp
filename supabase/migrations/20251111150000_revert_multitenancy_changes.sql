-- Revert Multi-tenancy Script (Granular)
-- This script undoes the changes made for the multi-tenancy setup.
-- It's designed to be run even if previous scripts failed.

-- Step 1: Drop triggers and functions
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.get_organization_id();

-- Step 2: Drop the tables created for multi-tenancy
DROP TABLE IF EXISTS public.user_profiles;
DROP TABLE IF EXISTS public.organizations;

-- Step 3: Drop the 'organization_id' column from all tables where it was added.
-- Using 'IF EXISTS' to prevent errors if the column is already gone.
ALTER TABLE public.clientes DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.produtos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.servicos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.vendedores DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.embalagens DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.ordens_servico DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.ordem_servico_itens DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.ordem_servico_anexos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.pedidos_venda DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.pedido_venda_itens DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.pedido_venda_anexos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.faturas_venda DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.contas_receber DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.contas_receber_anexos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.contas_pagar DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.contas_pagar_anexos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.fluxo_caixa DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.ordens_compra DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.ordem_compra_itens DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.estoque_movimentos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.crm_oportunidades DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.comissoes DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.devolucoes_venda DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.devolucao_venda_itens DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.contratos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.contrato_anexos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.notas_entrada DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.nota_entrada_itens DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.configuracoes DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.produto_imagens DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.produto_anuncios DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.produtos_fornecedores DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.expedicoes DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.expedicao_pedidos DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.pessoas_contato DROP COLUMN IF EXISTS organization_id;
ALTER TABLE public.cliente_anexos DROP COLUMN IF EXISTS organization_id;

-- Step 4: Disable RLS on all tables where it might have been enabled.
-- This ensures the application can access data again in a single-tenant model.
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendedores DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.embalagens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_servico_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_servico_anexos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos_venda DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_anexos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.faturas_venda DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber_anexos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar_anexos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fluxo_caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_compra DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_compra_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.estoque_movimentos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.crm_oportunidades DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.comissoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.devolucoes_venda DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.devolucao_venda_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contratos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notas_entrada DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.nota_entrada_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_imagens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_anuncios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos_fornecedores DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.expedicoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.expedicao_pedidos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pessoas_contato DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cliente_anexos DISABLE ROW LEVEL SECURITY;
