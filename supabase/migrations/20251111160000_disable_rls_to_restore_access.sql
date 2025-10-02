-- Desativa a Segurança em Nível de Linha (RLS) de todas as tabelas afetadas
-- para restaurar o comportamento original de tenant único.

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
ALTER TABLE public.ordens_compra DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_compra_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.devolucoes_venda DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.devolucao_venda_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contratos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.notas_entrada DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.nota_entrada_itens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.crm_oportunidades DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.estoque_movimentos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fluxo_caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_permissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produto_imagens DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.propostas_comerciais DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.proposta_comercial_itens DISABLE ROW LEVEL SECURITY;

-- Garante que as funções restantes não tenham problemas de segurança
ALTER FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer) SET search_path = public;
ALTER FUNCTION public.get_contratos_para_faturar(p_ano integer, p_mes integer) SET search_path = public;
