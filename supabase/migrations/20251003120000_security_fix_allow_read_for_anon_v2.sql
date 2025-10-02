-- Habilita RLS para todas as tabelas no schema publico, se ainda não estiver habilitado.
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(t_name) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;
END $$;

-- Remove políticas antigas para garantir um estado limpo
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "Enable ALL for authenticated users" ON public.' || quote_ident(t_name) || ';';
        EXECUTE 'DROP POLICY IF EXISTS "Enable READ for anonymous users" ON public.' || quote_ident(t_name) || ';';
        EXECUTE 'DROP POLICY IF EXISTS "Enable READ for anon users" ON public.' || quote_ident(t_name) || ';';
        EXECUTE 'DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.' || quote_ident(t_name) || ';';
        EXECUTE 'DROP POLICY IF EXISTS "Permitir leitura para anônimos" ON public.' || quote_ident(t_name) || ';';
    END LOOP;
END $$;


-- Cria uma política de LEITURA para usuários anônimos (anon) em todas as tabelas.
-- Isso permite que a aplicação carregue os dados iniciais antes do login.
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
    LOOP
        EXECUTE 'CREATE POLICY "Permitir leitura para anônimos" ON public.' || quote_ident(t_name) || ' FOR SELECT TO anon USING (true);';
    END LOOP;
END $$;

-- Cria uma política de ACESSO TOTAL (SELECT, INSERT, UPDATE, DELETE) para usuários autenticados (authenticated) em todas as tabelas.
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
    LOOP
        EXECUTE 'CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.' || quote_ident(t_name) || ' FOR ALL TO authenticated USING (true) WITH CHECK (true);';
    END LOOP;
END $$;
