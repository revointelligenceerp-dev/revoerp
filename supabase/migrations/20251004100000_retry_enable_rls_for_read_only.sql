DO $$
DECLARE
    table_name TEXT;
BEGIN
    -- Habilita RLS para todas as tabelas no schema 'public' que ainda não o têm
    FOR table_name IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
          AND tablename NOT LIKE 'pg_%' 
          AND tablename NOT LIKE 'sql_%'
          AND NOT EXISTS (
              SELECT 1 
              FROM pg_class c 
              JOIN pg_namespace n ON n.oid = c.relnamespace
              WHERE c.relname = table_name 
                AND n.nspname = 'public'
                AND c.relrowsecurity = 't'
          )
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(table_name) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;

    -- Remove políticas antigas (se existirem) para evitar conflitos
    FOR table_name IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        -- Remove política de leitura para anônimos, se existir
        IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = table_name AND policyname = 'Allow anonymous read access') THEN
            EXECUTE 'DROP POLICY "Allow anonymous read access" ON public.' || quote_ident(table_name) || ';';
        END IF;

        -- Remove política de acesso total para autenticados, se existir
        IF EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = table_name AND policyname = 'Allow full access to authenticated users') THEN
            EXECUTE 'DROP POLICY "Allow full access to authenticated users" ON public.' || quote_ident(table_name) || ';';
        END IF;
    END LOOP;

    -- Cria as novas políticas
    FOR table_name IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        -- Política 1: Permite que usuários anônimos (a aplicação antes do login) possam APENAS LER os dados.
        EXECUTE 'CREATE POLICY "Allow anonymous read access" ON public.' || quote_ident(table_name) || 
                ' FOR SELECT TO anon USING (true);';

        -- Política 2: Permite que usuários autenticados (logados) tenham acesso total (criar, ler, atualizar, apagar).
        EXECUTE 'CREATE POLICY "Allow full access to authenticated users" ON public.' || quote_ident(table_name) || 
                ' FOR ALL TO authenticated USING (true);';
    END LOOP;
END $$;
