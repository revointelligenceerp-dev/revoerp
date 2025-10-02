/*
# [Fix] Permissões de Leitura Anônima
Este script de migração corrige os erros de "permission denied" ao garantir que todas as tabelas públicas possam ser lidas pelo role anônimo (`anon`).

## Query Description: 
Esta operação habilita a Segurança a Nível de Linha (RLS) para todas as tabelas relevantes e cria uma política que permite a qualquer usuário (anônimo ou autenticado) ler os dados. Isso é essencial para que a aplicação frontend possa exibir as informações. Não há risco de perda de dados, pois apenas as permissões de leitura são alteradas.

## Metadata:
- Schema-Category: "Security"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Habilita RLS em várias tabelas.
- Cria políticas de `SELECT` para o role `anon` em várias tabelas.

## Security Implications:
- RLS Status: Habilitado em todas as tabelas de dados.
- Policy Changes: Sim. Adiciona políticas de leitura para o role `anon`.
- Auth Requirements: Nenhuma. Permite leitura pública.

## Performance Impact:
- Indexes: Nenhum.
- Triggers: Nenhum.
- Estimated Impact: Mínimo. RLS adiciona uma pequena sobrecarga, mas a política `USING (true)` é muito eficiente.
*/

-- Habilita RLS e cria políticas de leitura para a role 'anon'

-- Tabela: clientes
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.clientes;
CREATE POLICY "Allow anonymous read access" ON public.clientes FOR SELECT TO anon USING (true);

-- Tabela: pessoas_contato
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.pessoas_contato;
CREATE POLICY "Allow anonymous read access" ON public.pessoas_contato FOR SELECT TO anon USING (true);

-- Tabela: cliente_anexos
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.cliente_anexos;
CREATE POLICY "Allow anonymous read access" ON public.cliente_anexos FOR SELECT TO anon USING (true);

-- Tabela: produtos
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.produtos;
CREATE POLICY "Allow anonymous read access" ON public.produtos FOR SELECT TO anon USING (true);

-- Tabela: produto_imagens
ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.produto_imagens;
CREATE POLICY "Allow anonymous read access" ON public.produto_imagens FOR SELECT TO anon USING (true);

-- Tabela: produto_anuncios
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.produto_anuncios;
CREATE POLICY "Allow anonymous read access" ON public.produto_anuncios FOR SELECT TO anon USING (true);

-- Tabela: produtos_fornecedores
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.produtos_fornecedores;
CREATE POLICY "Allow anonymous read access" ON public.produtos_fornecedores FOR SELECT TO anon USING (true);

-- Tabela: servicos
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.servicos;
CREATE POLICY "Allow anonymous read access" ON public.servicos FOR SELECT TO anon USING (true);

-- Tabela: vendedores
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.vendedores;
CREATE POLICY "Allow anonymous read access" ON public.vendedores FOR SELECT TO anon USING (true);

-- Tabela: embalagens
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.embalagens;
CREATE POLICY "Allow anonymous read access" ON public.embalagens FOR SELECT TO anon USING (true);

-- Tabela: ordens_servico
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.ordens_servico;
CREATE POLICY "Allow anonymous read access" ON public.ordens_servico FOR SELECT TO anon USING (true);

-- Tabela: ordem_servico_itens
ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.ordem_servico_itens;
CREATE POLICY "Allow anonymous read access" ON public.ordem_servico_itens FOR SELECT TO anon USING (true);

-- Tabela: ordem_servico_anexos
ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.ordem_servico_anexos;
CREATE POLICY "Allow anonymous read access" ON public.ordem_servico_anexos FOR SELECT TO anon USING (true);

-- Tabela: pedidos_venda
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.pedidos_venda;
CREATE POLICY "Allow anonymous read access" ON public.pedidos_venda FOR SELECT TO anon USING (true);

-- Tabela: pedido_venda_itens
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.pedido_venda_itens;
CREATE POLICY "Allow anonymous read access" ON public.pedido_venda_itens FOR SELECT TO anon USING (true);

-- Tabela: pedido_venda_anexos
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.pedido_venda_anexos;
CREATE POLICY "Allow anonymous read access" ON public.pedido_venda_anexos FOR SELECT TO anon USING (true);

-- Tabela: faturas_venda
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.faturas_venda;
CREATE POLICY "Allow anonymous read access" ON public.faturas_venda FOR SELECT TO anon USING (true);

-- Tabela: contas_receber
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.contas_receber;
CREATE POLICY "Allow anonymous read access" ON public.contas_receber FOR SELECT TO anon USING (true);

-- Tabela: contas_receber_anexos
ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.contas_receber_anexos;
CREATE POLICY "Allow anonymous read access" ON public.contas_receber_anexos FOR SELECT TO anon USING (true);

-- Tabela: contas_pagar
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.contas_pagar;
CREATE POLICY "Allow anonymous read access" ON public.contas_pagar FOR SELECT TO anon USING (true);

-- Tabela: contas_pagar_anexos
ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.contas_pagar_anexos;
CREATE POLICY "Allow anonymous read access" ON public.contas_pagar_anexos FOR SELECT TO anon USING (true);

-- Tabela: fluxo_caixa
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.fluxo_caixa;
CREATE POLICY "Allow anonymous read access" ON public.fluxo_caixa FOR SELECT TO anon USING (true);

-- Tabela: expedicoes
ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.expedicoes;
CREATE POLICY "Allow anonymous read access" ON public.expedicoes FOR SELECT TO anon USING (true);

-- Tabela: expedicao_pedidos
ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.expedicao_pedidos;
CREATE POLICY "Allow anonymous read access" ON public.expedicao_pedidos FOR SELECT TO anon USING (true);

-- Tabela: ordens_compra
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.ordens_compra;
CREATE POLICY "Allow anonymous read access" ON public.ordens_compra FOR SELECT TO anon USING (true);

-- Tabela: ordem_compra_itens
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.ordem_compra_itens;
CREATE POLICY "Allow anonymous read access" ON public.ordem_compra_itens FOR SELECT TO anon USING (true);
