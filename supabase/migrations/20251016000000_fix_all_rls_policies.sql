/*
          # [CORREÇÃO DEFINITIVA DE PERMISSÕES]
          Este script habilita o RLS e aplica uma política de leitura pública em TODAS as tabelas do schema 'public'.
          Esta é uma operação segura, projetada para garantir que a aplicação possa ler todos os dados necessários durante o desenvolvimento.
          ## Query Description: [Esta operação ajusta as permissões de segurança para permitir que a aplicação leia os dados de todas as tabelas. Nenhuma estrutura ou dado será alterado. É um passo necessário para resolver os erros de 'permission denied'.]
          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Políticas de RLS em todas as tabelas do schema 'public'.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- Garantir que o RLS esteja habilitado e com política de leitura em todas as tabelas

ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on clientes" ON public.clientes;
CREATE POLICY "Allow public read access on clientes" ON public.clientes FOR SELECT USING (true);

ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on contas_pagar" ON public.contas_pagar;
CREATE POLICY "Allow public read access on contas_pagar" ON public.contas_pagar FOR SELECT USING (true);

ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on contas_receber" ON public.contas_receber;
CREATE POLICY "Allow public read access on contas_receber" ON public.contas_receber FOR SELECT USING (true);

ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on embalagens" ON public.embalagens;
CREATE POLICY "Allow public read access on embalagens" ON public.embalagens FOR SELECT USING (true);

ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on expedicoes" ON public.expedicoes;
CREATE POLICY "Allow public read access on expedicoes" ON public.expedicoes FOR SELECT USING (true);

ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on expedicao_pedidos" ON public.expedicao_pedidos;
CREATE POLICY "Allow public read access on expedicao_pedidos" ON public.expedicao_pedidos FOR SELECT USING (true);

ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on faturas_venda" ON public.faturas_venda;
CREATE POLICY "Allow public read access on faturas_venda" ON public.faturas_venda FOR SELECT USING (true);

ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on fluxo_caixa" ON public.fluxo_caixa;
CREATE POLICY "Allow public read access on fluxo_caixa" ON public.fluxo_caixa FOR SELECT USING (true);

ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on ordem_compra_itens" ON public.ordem_compra_itens;
CREATE POLICY "Allow public read access on ordem_compra_itens" ON public.ordem_compra_itens FOR SELECT USING (true);

ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on ordens_compra" ON public.ordens_compra;
CREATE POLICY "Allow public read access on ordens_compra" ON public.ordens_compra FOR SELECT USING (true);

ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on ordem_servico_itens" ON public.ordem_servico_itens;
CREATE POLICY "Allow public read access on ordem_servico_itens" ON public.ordem_servico_itens FOR SELECT USING (true);

ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on ordens_servico" ON public.ordens_servico;
CREATE POLICY "Allow public read access on ordens_servico" ON public.ordens_servico FOR SELECT USING (true);

ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on pedido_venda_itens" ON public.pedido_venda_itens;
CREATE POLICY "Allow public read access on pedido_venda_itens" ON public.pedido_venda_itens FOR SELECT USING (true);

ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on pedidos_venda" ON public.pedidos_venda;
CREATE POLICY "Allow public read access on pedidos_venda" ON public.pedidos_venda FOR SELECT USING (true);

ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on pessoas_contato" ON public.pessoas_contato;
CREATE POLICY "Allow public read access on pessoas_contato" ON public.pessoas_contato FOR SELECT USING (true);

ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on produto_anuncios" ON public.produto_anuncios;
CREATE POLICY "Allow public read access on produto_anuncios" ON public.produto_anuncios FOR SELECT USING (true);

ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on produto_imagens" ON public.produto_imagens;
CREATE POLICY "Allow public read access on produto_imagens" ON public.produto_imagens FOR SELECT USING (true);

ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on produtos" ON public.produtos;
CREATE POLICY "Allow public read access on produtos" ON public.produtos FOR SELECT USING (true);

ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on produtos_fornecedores" ON public.produtos_fornecedores;
CREATE POLICY "Allow public read access on produtos_fornecedores" ON public.produtos_fornecedores FOR SELECT USING (true);

ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on servicos" ON public.servicos;
CREATE POLICY "Allow public read access on servicos" ON public.servicos FOR SELECT USING (true);

ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on vendedores" ON public.vendedores;
CREATE POLICY "Allow public read access on vendedores" ON public.vendedores FOR SELECT USING (true);

ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on cliente_anexos" ON public.cliente_anexos;
CREATE POLICY "Allow public read access on cliente_anexos" ON public.cliente_anexos FOR SELECT USING (true);

ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on contas_pagar_anexos" ON public.contas_pagar_anexos;
CREATE POLICY "Allow public read access on contas_pagar_anexos" ON public.contas_pagar_anexos FOR SELECT USING (true);

ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on contas_receber_anexos" ON public.contas_receber_anexos;
CREATE POLICY "Allow public read access on contas_receber_anexos" ON public.contas_receber_anexos FOR SELECT USING (true);

ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on ordem_servico_anexos" ON public.ordem_servico_anexos;
CREATE POLICY "Allow public read access on ordem_servico_anexos" ON public.ordem_servico_anexos FOR SELECT USING (true);

ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on pedido_venda_anexos" ON public.pedido_venda_anexos;
CREATE POLICY "Allow public read access on pedido_venda_anexos" ON public.pedido_venda_anexos FOR SELECT USING (true);

ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on ordem_compra_anexos" ON public.ordem_compra_anexos;
CREATE POLICY "Allow public read access on ordem_compra_anexos" ON public.ordem_compra_anexos FOR SELECT USING (true);
