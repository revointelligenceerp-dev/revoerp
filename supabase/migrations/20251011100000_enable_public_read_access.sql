DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
          AND tablename NOT LIKE 'pg_%' 
          AND tablename NOT LIKE 'sql_%'
          AND tablename NOT IN ('schema_migrations') -- Exclui a tabela de migrações do Supabase
    LOOP
        -- Habilita RLS na tabela se ainda não estiver habilitado
        EXECUTE 'ALTER TABLE public.' || quote_ident(table_name) || ' ENABLE ROW LEVEL SECURITY;';

        -- Remove políticas antigas para evitar conflitos
        EXECUTE 'DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.' || quote_ident(table_name) || ';';
        EXECUTE 'DROP POLICY IF EXISTS "Enable read access for all users" ON public.' || quote_ident(table_name) || ';';
        EXECUTE 'DROP POLICY IF EXISTS "Enable write access for authenticated users" ON public.' || quote_ident(table_name) || ';';

        -- Cria a política de LEITURA para TODOS os usuários (anônimos e autenticados)
        EXECUTE 'CREATE POLICY "Enable read access for all users" ON public.' || quote_ident(table_name) || 
                ' FOR SELECT USING (true);';

        -- Cria a política de ESCRITA (insert, update, delete) apenas para usuários AUTENTICADOS
        EXECUTE 'CREATE POLICY "Enable write access for authenticated users" ON public.' || quote_ident(table_name) || 
                ' FOR INSERT, UPDATE, DELETE USING (auth.role() = ''authenticated'');';
                
        RAISE NOTICE 'RLS policies updated for table: %', table_name;
    END LOOP;
END $$;
