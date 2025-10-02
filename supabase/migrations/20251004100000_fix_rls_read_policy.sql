-- Habilita RLS em todas as tabelas, se ainda não estiver habilitado.
DO $$
DECLARE
    tbl_name TEXT;
BEGIN
    FOR tbl_name IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(tbl_name) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;
END $$;

-- Remove políticas antigas para garantir um estado limpo.
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public' AND policyname LIKE 'Allow public read access%'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(policy_record.policyname) || ' ON public.' || quote_ident(policy_record.tablename) || ';';
    END LOOP;
END $$;

-- Cria uma política de leitura pública em todas as tabelas.
DO $$
DECLARE
    tbl_name TEXT;
    policy_name TEXT;
BEGIN
    FOR tbl_name IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        policy_name := 'Allow public read access for ' || tbl_name;
        EXECUTE 'CREATE POLICY ' || quote_ident(policy_name) || ' ON public.' || quote_ident(tbl_name) || ' FOR SELECT TO anon USING (true);';
    END LOOP;
END $$;
