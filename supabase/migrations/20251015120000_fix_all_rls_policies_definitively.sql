/*
          # [CORREÇÃO DEFINITIVA DE PERMISSÕES RLS]
          Este script habilita o RLS e cria uma política de leitura pública em TODAS as tabelas do schema 'public'.

          ## Query Description: [Esta operação garante que a aplicação tenha permissão para ler os dados de todas as tabelas, resolvendo os erros de 'permission denied'. É uma operação segura que não afeta os dados existentes.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Políticas de RLS de todas as tabelas no schema 'public'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo, apenas na verificação de políticas durante as consultas.]
*/

-- Habilita RLS e cria políticas de leitura para todas as tabelas

-- Tabela clientes
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.clientes;
CREATE POLICY "Allow public read access" ON public.clientes FOR SELECT USING (true);

-- Tabela vendedores
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.vendedores;
CREATE POLICY "Allow public read access" ON public.vendedores FOR SELECT USING (true);

-- Tabela produtos
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.produtos;
CREATE POLICY "Allow public read access" ON public.produtos FOR SELECT USING (true);

-- Tabela servicos
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.servicos;
CREATE POLICY "Allow public read access" ON public.servicos FOR SELECT USING (true);

-- Tabela embalagens
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.embalagens;
CREATE POLICY "Allow public read access" ON public.embalagens FOR SELECT USING (true);

-- Tabela pedidos_venda
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.pedidos_venda;
CREATE POLICY "Allow public read access" ON public.pedidos_venda FOR SELECT USING (true);

-- Tabela pedido_venda_itens
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.pedido_venda_itens;
CREATE POLICY "Allow public read access" ON public.pedido_venda_itens FOR SELECT USING (true);

-- Tabela faturas_venda
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.faturas_venda;
CREATE POLICY "Allow public read access" ON public.faturas_venda FOR SELECT USING (true);

-- Tabela contas_receber
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.contas_receber;
CREATE POLICY "Allow public read access" ON public.contas_receber FOR SELECT USING (true);

-- Tabela contas_pagar
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.contas_pagar;
CREATE POLICY "Allow public read access" ON public.contas_pagar FOR SELECT USING (true);

-- Tabela fluxo_caixa
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.fluxo_caixa;
CREATE POLICY "Allow public read access" ON public.fluxo_caixa FOR SELECT USING (true);

-- Tabela ordens_servico
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.ordens_servico;
CREATE POLICY "Allow public read access" ON public.ordens_servico FOR SELECT USING (true);

-- Tabela ordem_servico_itens
ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.ordem_servico_itens;
CREATE POLICY "Allow public read access" ON public.ordem_servico_itens FOR SELECT USING (true);

-- Tabela ordens_compra
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.ordens_compra;
CREATE POLICY "Allow public read access" ON public.ordens_compra FOR SELECT USING (true);

-- Tabela ordem_compra_itens
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.ordem_compra_itens;
CREATE POLICY "Allow public read access" ON public.ordem_compra_itens FOR SELECT USING (true);

-- Tabela expedicoes
ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.expedicoes;
CREATE POLICY "Allow public read access" ON public.expedicoes FOR SELECT USING (true);

-- Tabela expedicao_pedidos
ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.expedicao_pedidos;
CREATE POLICY "Allow public read access" ON public.expedicao_pedidos FOR SELECT USING (true);

-- Tabela pessoas_contato
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.pessoas_contato;
CREATE POLICY "Allow public read access" ON public.pessoas_contato FOR SELECT USING (true);

-- Tabela cliente_anexos
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.cliente_anexos;
CREATE POLICY "Allow public read access" ON public.cliente_anexos FOR SELECT USING (true);

-- Tabela produto_imagens
ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.produto_imagens;
CREATE POLICY "Allow public read access" ON public.produto_imagens FOR SELECT USING (true);

-- Tabela produto_anuncios
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.produto_anuncios;
CREATE POLICY "Allow public read access" ON public.produto_anuncios FOR SELECT USING (true);

-- Tabela produtos_fornecedores
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.produtos_fornecedores;
CREATE POLICY "Allow public read access" ON public.produtos_fornecedores FOR SELECT USING (true);

-- Tabela contas_pagar_anexos
ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.contas_pagar_anexos;
CREATE POLICY "Allow public read access" ON public.contas_pagar_anexos FOR SELECT USING (true);

-- Tabela contas_receber_anexos
ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.contas_receber_anexos;
CREATE POLICY "Allow public read access" ON public.contas_receber_anexos FOR SELECT USING (true);

-- Tabela ordem_servico_anexos
ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.ordem_servico_anexos;
CREATE POLICY "Allow public read access" ON public.ordem_servico_anexos FOR SELECT USING (true);

-- Tabela pedido_venda_anexos
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.pedido_venda_anexos;
CREATE POLICY "Allow public read access" ON public.pedido_venda_anexos FOR SELECT USING (true);

-- Tabela ordem_compra_anexos
ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access" ON public.ordem_compra_anexos;
CREATE POLICY "Allow public read access" ON public.ordem_compra_anexos FOR SELECT USING (true);
