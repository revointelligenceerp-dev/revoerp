/*
          # [CORREÇÃO DEFINITIVA DE PERMISSÕES]
          Este script habilita a Segurança a Nível de Linha (RLS) em todas as tabelas e cria políticas que permitem o acesso de leitura (SELECT) para a role 'anon'. Isso é necessário para que a aplicação possa buscar dados sem um usuário autenticado, resolvendo os erros de 'permission denied'.

          ## Query Description: [Esta operação ajusta as políticas de segurança do banco de dados para permitir a leitura de dados pela aplicação. Não há risco de perda de dados, mas é um passo crucial para corrigir os erros de acesso que você está enfrentando.]
          
          ## Metadata:
          - Schema-Category: ["Security"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Políticas de RLS para todas as tabelas no schema 'public'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [Permite leitura para usuários não autenticados (anon).]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo. A verificação de políticas de RLS pode adicionar uma sobrecarga muito pequena às consultas.]
*/

-- Habilita RLS e cria políticas de leitura para cada tabela.

-- Tabela clientes
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on clientes" ON public.clientes;
CREATE POLICY "Allow anon read access on clientes" ON public.clientes FOR SELECT TO anon USING (true);

-- Tabela vendedores
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on vendedores" ON public.vendedores;
CREATE POLICY "Allow anon read access on vendedores" ON public.vendedores FOR SELECT TO anon USING (true);

-- Tabela produtos
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on produtos" ON public.produtos;
CREATE POLICY "Allow anon read access on produtos" ON public.produtos FOR SELECT TO anon USING (true);

-- Tabela servicos
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on servicos" ON public.servicos;
CREATE POLICY "Allow anon read access on servicos" ON public.servicos FOR SELECT TO anon USING (true);

-- Tabela embalagens
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on embalagens" ON public.embalagens;
CREATE POLICY "Allow anon read access on embalagens" ON public.embalagens FOR SELECT TO anon USING (true);

-- Tabela pedidos_venda
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on pedidos_venda" ON public.pedidos_venda;
CREATE POLICY "Allow anon read access on pedidos_venda" ON public.pedidos_venda FOR SELECT TO anon USING (true);

-- Tabela pedido_venda_itens
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on pedido_venda_itens" ON public.pedido_venda_itens;
CREATE POLICY "Allow anon read access on pedido_venda_itens" ON public.pedido_venda_itens FOR SELECT TO anon USING (true);

-- Tabela faturas_venda
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on faturas_venda" ON public.faturas_venda;
CREATE POLICY "Allow anon read access on faturas_venda" ON public.faturas_venda FOR SELECT TO anon USING (true);

-- Tabela contas_receber
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on contas_receber" ON public.contas_receber;
CREATE POLICY "Allow anon read access on contas_receber" ON public.contas_receber FOR SELECT TO anon USING (true);

-- Tabela contas_pagar
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on contas_pagar" ON public.contas_pagar;
CREATE POLICY "Allow anon read access on contas_pagar" ON public.contas_pagar FOR SELECT TO anon USING (true);

-- Tabela fluxo_caixa
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on fluxo_caixa" ON public.fluxo_caixa;
CREATE POLICY "Allow anon read access on fluxo_caixa" ON public.fluxo_caixa FOR SELECT TO anon USING (true);

-- Tabela ordens_servico
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on ordens_servico" ON public.ordens_servico;
CREATE POLICY "Allow anon read access on ordens_servico" ON public.ordens_servico FOR SELECT TO anon USING (true);

-- Tabela ordem_servico_itens
ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on ordem_servico_itens" ON public.ordem_servico_itens;
CREATE POLICY "Allow anon read access on ordem_servico_itens" ON public.ordem_servico_itens FOR SELECT TO anon USING (true);

-- Tabela ordens_compra
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on ordens_compra" ON public.ordens_compra;
CREATE POLICY "Allow anon read access on ordens_compra" ON public.ordens_compra FOR SELECT TO anon USING (true);

-- Tabela ordem_compra_itens
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on ordem_compra_itens" ON public.ordem_compra_itens;
CREATE POLICY "Allow anon read access on ordem_compra_itens" ON public.ordem_compra_itens FOR SELECT TO anon USING (true);

-- Tabela expedicoes
ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on expedicoes" ON public.expedicoes;
CREATE POLICY "Allow anon read access on expedicoes" ON public.expedicoes FOR SELECT TO anon USING (true);

-- Tabela expedicao_pedidos
ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on expedicao_pedidos" ON public.expedicao_pedidos;
CREATE POLICY "Allow anon read access on expedicao_pedidos" ON public.expedicao_pedidos FOR SELECT TO anon USING (true);

-- Tabela pessoas_contato
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on pessoas_contato" ON public.pessoas_contato;
CREATE POLICY "Allow anon read access on pessoas_contato" ON public.pessoas_contato FOR SELECT TO anon USING (true);

-- Tabela cliente_anexos
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on cliente_anexos" ON public.cliente_anexos;
CREATE POLICY "Allow anon read access on cliente_anexos" ON public.cliente_anexos FOR SELECT TO anon USING (true);

-- Tabela produto_imagens
ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on produto_imagens" ON public.produto_imagens;
CREATE POLICY "Allow anon read access on produto_imagens" ON public.produto_imagens FOR SELECT TO anon USING (true);

-- Tabela produto_anuncios
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on produto_anuncios" ON public.produto_anuncios;
CREATE POLICY "Allow anon read access on produto_anuncios" ON public.produto_anuncios FOR SELECT TO anon USING (true);

-- Tabela produtos_fornecedores
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on produtos_fornecedores" ON public.produtos_fornecedores;
CREATE POLICY "Allow anon read access on produtos_fornecedores" ON public.produtos_fornecedores FOR SELECT TO anon USING (true);

-- Tabela contas_pagar_anexos
ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on contas_pagar_anexos" ON public.contas_pagar_anexos;
CREATE POLICY "Allow anon read access on contas_pagar_anexos" ON public.contas_pagar_anexos FOR SELECT TO anon USING (true);

-- Tabela contas_receber_anexos
ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on contas_receber_anexos" ON public.contas_receber_anexos;
CREATE POLICY "Allow anon read access on contas_receber_anexos" ON public.contas_receber_anexos FOR SELECT TO anon USING (true);

-- Tabela ordem_servico_anexos
ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on ordem_servico_anexos" ON public.ordem_servico_anexos;
CREATE POLICY "Allow anon read access on ordem_servico_anexos" ON public.ordem_servico_anexos FOR SELECT TO anon USING (true);

-- Tabela pedido_venda_anexos
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on pedido_venda_anexos" ON public.pedido_venda_anexos;
CREATE POLICY "Allow anon read access on pedido_venda_anexos" ON public.pedido_venda_anexos FOR SELECT TO anon USING (true);

-- Tabela ordem_compra_anexos
ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anon read access on ordem_compra_anexos" ON public.ordem_compra_anexos;
CREATE POLICY "Allow anon read access on ordem_compra_anexos" ON public.ordem_compra_anexos FOR SELECT TO anon USING (true);
