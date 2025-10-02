DO $$
DECLARE
    table_record RECORD;
    policy_name_select TEXT;
    policy_name_insert TEXT;
    policy_name_update TEXT;
    policy_name_delete TEXT;
BEGIN
    -- Itera sobre todas as tabelas no schema 'public'
    FOR table_record IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        -- Habilita RLS na tabela se ainda não estiver habilitado
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_record.tablename);

        -- Política de SELECT: Permite leitura para todos (anônimos e autenticados)
        policy_name_select := 'allow_read_for_all_users_on_' || table_record.tablename;
        EXECUTE format('
            DROP POLICY IF EXISTS %I ON public.%I;
            CREATE POLICY %I ON public.%I
            FOR SELECT
            USING (true);',
            policy_name_select, table_record.tablename,
            policy_name_select, table_record.tablename
        );

        -- Política de INSERT: Permite inserção apenas para usuários autenticados
        policy_name_insert := 'allow_insert_for_authenticated_users_on_' || table_record.tablename;
        EXECUTE format('
            DROP POLICY IF EXISTS %I ON public.%I;
            CREATE POLICY %I ON public.%I
            FOR INSERT
            WITH CHECK (auth.role() = ''authenticated'');',
            policy_name_insert, table_record.tablename,
            policy_name_insert, table_record.tablename
        );

        -- Política de UPDATE: Permite atualização apenas para usuários autenticados
        policy_name_update := 'allow_update_for_authenticated_users_on_' || table_record.tablename;
        EXECUTE format('
            DROP POLICY IF EXISTS %I ON public.%I;
            CREATE POLICY %I ON public.%I
            FOR UPDATE
            USING (auth.role() = ''authenticated'');',
            policy_name_update, table_record.tablename,
            policy_name_update, table_record.tablename
        );

        -- Política de DELETE: Permite exclusão apenas para usuários autenticados
        policy_name_delete := 'allow_delete_for_authenticated_users_on_' || table_record.tablename;
        EXECUTE format('
            DROP POLICY IF EXISTS %I ON public.%I;
            CREATE POLICY %I ON public.%I
            FOR DELETE
            USING (auth.role() = ''authenticated'');',
            policy_name_delete, table_record.tablename,
            policy_name_delete, table_record.tablename
        );
    END LOOP;
END $$;
