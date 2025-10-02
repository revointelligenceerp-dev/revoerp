/*
          # [CORREÇÃO DEFINITIVA DE PERMISSÕES]
          Este script habilita a Segurança a Nível de Linha (RLS) para todas as tabelas e cria políticas que permitem o acesso de leitura (SELECT) para o role 'anon', que é usado por usuários não autenticados.
          Isso é necessário para que a aplicação possa buscar e exibir os dados durante o desenvolvimento sem a necessidade de login.
          ## Query Description: [Esta operação ajusta as políticas de segurança do seu banco de dados para permitir que a aplicação leia os dados. Não há risco de perda de dados. Esta é uma etapa crucial para resolver os erros de 'permission denied'.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Todas as tabelas no schema 'public'.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Mínimo. A habilitação de RLS pode ter um pequeno overhead, mas é essencial para a segurança.]
*/
-- Habilitar RLS e criar políticas de leitura para todas as tabelas
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.clientes;
CREATE POLICY "Allow anon read" ON public.clientes FOR SELECT TO anon USING (true);

ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.vendedores;
CREATE POLICY "Allow anon read" ON public.vendedores FOR SELECT TO anon USING (true);

ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.produtos;
CREATE POLICY "Allow anon read" ON public.produtos FOR SELECT TO anon USING (true);

ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.servicos;
CREATE POLICY "Allow anon read" ON public.servicos FOR SELECT TO anon USING (true);

ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.embalagens;
CREATE POLICY "Allow anon read" ON public.embalagens FOR SELECT TO anon USING (true);

ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.pedidos_venda;
CREATE POLICY "Allow anon read" ON public.pedidos_venda FOR SELECT TO anon USING (true);

ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.pedido_venda_itens;
CREATE POLICY "Allow anon read" ON public.pedido_venda_itens FOR SELECT TO anon USING (true);

ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.faturas_venda;
CREATE POLICY "Allow anon read" ON public.faturas_venda FOR SELECT TO anon USING (true);

ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.contas_receber;
CREATE POLICY "Allow anon read" ON public.contas_receber FOR SELECT TO anon USING (true);

ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.contas_pagar;
CREATE POLICY "Allow anon read" ON public.contas_pagar FOR SELECT TO anon USING (true);

ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.fluxo_caixa;
CREATE POLICY "Allow anon read" ON public.fluxo_caixa FOR SELECT TO anon USING (true);

ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.ordens_servico;
CREATE POLICY "Allow anon read" ON public.ordens_servico FOR SELECT TO anon USING (true);

ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.ordem_servico_itens;
CREATE POLICY "Allow anon read" ON public.ordem_servico_itens FOR SELECT TO anon USING (true);

ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.ordens_compra;
CREATE POLICY "Allow anon read" ON public.ordens_compra FOR SELECT TO anon USING (true);

ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.ordem_compra_itens;
CREATE POLICY "Allow anon read" ON public.ordem_compra_itens FOR SELECT TO anon USING (true);

ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.expedicoes;
CREATE POLICY "Allow anon read" ON public.expedicoes FOR SELECT TO anon USING (true);

ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.expedicao_pedidos;
CREATE POLICY "Allow anon read" ON public.expedicao_pedidos FOR SELECT TO anon USING (true);

ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.pessoas_contato;
CREATE POLICY "Allow anon read" ON public.pessoas_contato FOR SELECT TO anon USING (true);

ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.cliente_anexos;
CREATE POLICY "Allow anon read" ON public.cliente_anexos FOR SELECT TO anon USING (true);

ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.produto_imagens;
CREATE POLICY "Allow anon read" ON public.produto_imagens FOR SELECT TO anon USING (true);

ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.produto_anuncios;
CREATE POLICY "Allow anon read" ON public.produto_anuncios FOR SELECT TO anon USING (true);

ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.produtos_fornecedores;
CREATE POLICY "Allow anon read" ON public.produtos_fornecedores FOR SELECT TO anon USING (true);

ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.ordem_servico_anexos;
CREATE POLICY "Allow anon read" ON public.ordem_servico_anexos FOR SELECT TO anon USING (true);

ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.pedido_venda_anexos;
CREATE POLICY "Allow anon read" ON public.pedido_venda_anexos FOR SELECT TO anon USING (true);

ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.contas_receber_anexos;
CREATE POLICY "Allow anon read" ON public.contas_receber_anexos FOR SELECT TO anon USING (true);

ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.contas_pagar_anexos;
CREATE POLICY "Allow anon read" ON public.contas_pagar_anexos FOR SELECT TO anon USING (true);

ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read" ON public.ordem_compra_anexos;
CREATE POLICY "Allow anon read" ON public.ordem_compra_anexos FOR SELECT TO anon USING (true);
