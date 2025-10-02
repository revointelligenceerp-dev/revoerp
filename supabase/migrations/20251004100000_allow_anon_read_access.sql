/*
          # [SECURITY] Allow Anonymous Read Access
          This migration creates read-only (SELECT) policies for the `anon` role on all public tables. This is a critical step to allow the application to fetch and display data for unauthenticated users, which is necessary until a full login system is implemented. Write operations (INSERT, UPDATE, DELETE) remain protected and will require an authenticated user.

          ## Query Description:
          - This operation does not alter or delete any data.
          - It modifies security policies, making data publicly readable. This is a controlled and necessary step for the current phase of development.
          - Once user authentication is implemented, these policies can be made stricter.
          
          ## Metadata:
          - Schema-Category: ["Security"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Affects RLS policies on all tables in the `public` schema.
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes. Adds a new SELECT policy for the `anon` role.
          - Auth Requirements: This policy specifically targets unauthenticated (`anon`) access.
          
          ## Performance Impact:
          - Indexes: None
          - Triggers: None
          - Estimated Impact: Negligible. RLS policy checks have a very low overhead.
          */

-- This script adds read-only access policies for anonymous users to all tables.
-- This is necessary for the application to load data before a login system is implemented.
-- Write operations (INSERT, UPDATE, DELETE) remain protected and require an authenticated user.

CREATE POLICY "Enable read access for all users" ON public.clientes FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.pessoas_contato FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.cliente_anexos FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.produtos FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.produto_imagens FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.produto_anuncios FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.produtos_fornecedores FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.servicos FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.vendedores FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.embalagens FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.ordens_servico FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.ordem_servico_itens FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.ordem_servico_anexos FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.pedidos_venda FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.pedido_venda_itens FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.pedido_venda_anexos FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.faturas_venda FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.contas_receber FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.contas_receber_anexos FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.contas_pagar FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.contas_pagar_anexos FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.fluxo_caixa FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.expedicoes FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON public.expedicao_pedidos FOR SELECT USING (true);
