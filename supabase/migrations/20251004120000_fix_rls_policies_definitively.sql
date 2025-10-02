-- Este script habilita a Segurança em Nível de Linha (RLS) em todas as tabelas públicas
-- e configura as políticas de acesso para resolver os erros de "Failed to fetch".

-- 1. Habilita RLS em todas as tabelas do schema 'public' se ainda não estiver habilitado.
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;
END $$;

-- 2. Remove todas as políticas existentes para garantir um estado limpo.
-- É seguro executar isso várias vezes.
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON public.' || quote_ident(r.tablename) || ';';
    END LOOP;
END $$;

-- 3. Cria uma política de LEITURA (SELECT) para todos os usuários (anônimos e autenticados).
-- Isso permite que a aplicação carregue os dados iniciais sem erros.
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'CREATE POLICY "Permitir acesso de leitura a todos" ON public.' || quote_ident(r.tablename) || 
                ' FOR SELECT USING (true);';
    END LOOP;
END $$;

-- 4. Cria uma política de MODIFICAÇÃO (INSERT, UPDATE, DELETE) APENAS para usuários autenticados.
-- Isso protege seus dados, garantindo que apenas usuários logados possam fazer alterações.
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'CREATE POLICY "Permitir acesso total a usuários autenticados" ON public.' || quote_ident(r.tablename) || 
                ' FOR ALL USING (auth.role() = ''authenticated'') WITH CHECK (auth.role() = ''authenticated'');';
    END LOOP;
END $$;
