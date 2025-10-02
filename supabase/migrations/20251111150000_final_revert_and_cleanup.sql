DO $$
DECLARE
    table_record RECORD;
    policy_record RECORD;
BEGIN
    -- Lista de todas as tabelas no schema public
    FOR table_record IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        -- Remove todas as RLS policies da tabela
        FOR policy_record IN 
            SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = table_record.tablename
        LOOP
            EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON public."' || table_record.tablename || '";';
        END LOOP;

        -- Desabilita RLS na tabela
        EXECUTE 'ALTER TABLE public."' || table_record.tablename || '" DISABLE ROW LEVEL SECURITY;';
        RAISE NOTICE 'RLS desabilitado para a tabela: %', table_record.tablename;
    END LOOP;

    -- Remove funções e triggers relacionados ao multi-tenancy, se existirem
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    DROP FUNCTION IF EXISTS public.handle_new_user();
    DROP FUNCTION IF EXISTS public.get_organization_id();

    -- Remove as tabelas de multi-tenancy, se existirem
    DROP TABLE IF EXISTS public.user_profiles CASCADE;
    DROP TABLE IF EXISTS public.organizations CASCADE;

    RAISE NOTICE 'Limpeza e reversão do multi-tenancy concluídas.';
END $$;
