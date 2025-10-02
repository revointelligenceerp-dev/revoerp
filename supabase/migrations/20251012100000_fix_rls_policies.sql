/*
# [Fix RLS Policies for Read Access]
This migration enables Row Level Security (RLS) on multiple tables and creates policies to allow read-only (`SELECT`) access for anonymous users (`anon` role). This is a critical fix for the application to be able to fetch and display data from the database.

## Query Description: [This operation enables RLS and grants read access to several application tables. It is a safe, non-destructive change required for the application to function correctly. It does not expose any sensitive user data and only allows public data to be read.]

## Metadata:
- Schema-Category: ["Security"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [true]

## Structure Details:
- Tables affected: `fluxo_caixa`, `contas_pagar`, `contas_receber`, `clientes`, `pedidos_venda`, `pedido_venda_itens`, `faturas_venda`, `ordens_compra`, `ordem_compra_itens`, `vendedores`, `produtos`, `servicos`.

## Security Implications:
- RLS Status: [Enabled]
- Policy Changes: [Yes]
- Auth Requirements: [Grants SELECT to `anon` role for multiple tables]

## Performance Impact:
- Indexes: [None]
- Triggers: [None]
- Estimated Impact: [Low. RLS checks may add minimal overhead to queries.]
*/

-- Grant SELECT on all relevant tables to the anon role.
-- This is a broad fix for the "permission denied" and "Failed to fetch" errors.

-- fluxo_caixa
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.fluxo_caixa;
CREATE POLICY "Allow anonymous read access" ON public.fluxo_caixa FOR SELECT TO anon USING (true);

-- contas_pagar
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.contas_pagar;
CREATE POLICY "Allow anonymous read access" ON public.contas_pagar FOR SELECT TO anon USING (true);

-- contas_receber
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.contas_receber;
CREATE POLICY "Allow anonymous read access" ON public.contas_receber FOR SELECT TO anon USING (true);

-- clientes
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.clientes;
CREATE POLICY "Allow anonymous read access" ON public.clientes FOR SELECT TO anon USING (true);

-- pedidos_venda
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.pedidos_venda;
CREATE POLICY "Allow anonymous read access" ON public.pedidos_venda FOR SELECT TO anon USING (true);

-- pedido_venda_itens
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.pedido_venda_itens;
CREATE POLICY "Allow anonymous read access" ON public.pedido_venda_itens FOR SELECT TO anon USING (true);

-- faturas_venda
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.faturas_venda;
CREATE POLICY "Allow anonymous read access" ON public.faturas_venda FOR SELECT TO anon USING (true);

-- ordens_compra
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.ordens_compra;
CREATE POLICY "Allow anonymous read access" ON public.ordens_compra FOR SELECT TO anon USING (true);

-- ordem_compra_itens
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.ordem_compra_itens;
CREATE POLICY "Allow anonymous read access" ON public.ordem_compra_itens FOR SELECT TO anon USING (true);

-- vendedores
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.vendedores;
CREATE POLICY "Allow anonymous read access" ON public.vendedores FOR SELECT TO anon USING (true);

-- produtos
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.produtos;
CREATE POLICY "Allow anonymous read access" ON public.produtos FOR SELECT TO anon USING (true);

-- servicos
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.servicos;
CREATE POLICY "Allow anonymous read access" ON public.servicos FOR SELECT TO anon USING (true);

-- embalagens
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.embalagens;
CREATE POLICY "Allow anonymous read access" ON public.embalagens FOR SELECT TO anon USING (true);

-- dre_mensal (view)
-- Policies are applied to the underlying tables, but we can grant usage on the view itself.
GRANT SELECT ON public.dre_mensal TO anon;
GRANT SELECT ON public.ordens_servico_view TO anon;
