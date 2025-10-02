-- Habilita RLS em todas as tabelas do schema public, se ainda não estiver habilitado.
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;
END $$;

-- Remove políticas antigas para garantir um estado limpo
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.clientes;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.produtos;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.servicos;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.vendedores;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.embalagens;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.ordens_servico;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.pedidos_venda;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.faturas_venda;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.contas_receber;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.contas_pagar;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.fluxo_caixa;
DROP POLICY IF EXISTS "Permitir acesso de leitura para anônimos" ON public.expedicoes;
-- Adicione outras tabelas conforme necessário

-- Cria uma política que permite a leitura (SELECT) para usuários anônimos (anon) e autenticados (authenticated)
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.clientes FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.produtos FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.servicos FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.vendedores FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.embalagens FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.ordens_servico FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.pedidos_venda FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.faturas_venda FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.contas_receber FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.contas_pagar FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.fluxo_caixa FOR SELECT USING (true);
CREATE POLICY "Permitir acesso de leitura para anônimos" ON public.expedicoes FOR SELECT USING (true);
-- Adicione outras tabelas conforme necessário


-- Remove políticas antigas para escrita
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.clientes;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.produtos;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.servicos;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.vendedores;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.embalagens;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.ordens_servico;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.pedidos_venda;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.faturas_venda;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.contas_receber;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.contas_pagar;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.fluxo_caixa;
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.expedicoes;
-- Adicione outras tabelas conforme necessário

-- Cria uma política que permite todas as operações (INSERT, UPDATE, DELETE) apenas para usuários autenticados
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.clientes FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.produtos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.servicos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.vendedores FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.embalagens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.ordens_servico FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.pedidos_venda FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.faturas_venda FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.contas_receber FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.contas_pagar FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.fluxo_caixa FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.expedicoes FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
-- Adicione outras tabelas conforme necessário
