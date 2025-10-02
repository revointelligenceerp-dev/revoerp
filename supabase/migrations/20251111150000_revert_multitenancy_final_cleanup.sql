DO $$
DECLARE
    table_record RECORD;
    policy_record RECORD;
BEGIN
    RAISE NOTICE 'Iniciando limpeza de políticas de RLS...';

    -- Loop through all tables in the 'public' schema to drop policies
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        -- Loop through all policies on the current table
        FOR policy_record IN
            SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = table_record.tablename
        LOOP
            -- Drop the policy
            EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON public."' || table_record.tablename || '";';
            RAISE NOTICE 'Dropped policy % on table %', policy_record.policyname, table_record.tablename;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Políticas de RLS removidas. Desabilitando RLS nas tabelas...';

    -- Loop through all tables again to disable RLS
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        -- Disable RLS on the table
        EXECUTE 'ALTER TABLE public."' || table_record.tablename || '" DISABLE ROW LEVEL SECURITY;';
        RAISE NOTICE 'Disabled RLS on table %', table_record.tablename;
    END LOOP;

    RAISE NOTICE 'RLS desabilitado. Removendo funções e gatilhos...';

    -- Drop the trigger on auth.users
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    RAISE NOTICE 'Trigger "on_auth_user_created" dropped.';

    -- Now, drop the functions that were causing dependency issues
    DROP FUNCTION IF EXISTS public.get_organization_id();
    RAISE NOTICE 'Function get_organization_id dropped.';
    DROP FUNCTION IF EXISTS public.handle_new_user();
    RAISE NOTICE 'Function handle_new_user dropped.';

    RAISE NOTICE 'Limpeza de segurança concluída.';
END $$;
