DO $$
DECLARE
    rec RECORD;
    tbl_name TEXT;
BEGIN
    -- Remover todas as políticas RLS de todas as tabelas no schema public
    FOR rec IN 
        SELECT 
            tablename, 
            policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    LOOP
        tbl_name := quote_ident(rec.tablename);
        RAISE NOTICE 'Dropping policy % on table %', rec.policyname, tbl_name;
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(rec.policyname) || ' ON public.' || tbl_name || ';';
    END LOOP;

    -- Desativar RLS em todas as tabelas
    FOR rec IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        tbl_name := quote_ident(rec.tablename);
        RAISE NOTICE 'Disabling RLS on table %', tbl_name;
        EXECUTE 'ALTER TABLE public.' || tbl_name || ' DISABLE ROW LEVEL SECURITY;';
    END LOOP;

    -- Remover funções e triggers relacionados
    RAISE NOTICE 'Dropping trigger on auth.users...';
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

    RAISE NOTICE 'Dropping function handle_new_user...';
    DROP FUNCTION IF EXISTS public.handle_new_user();

    RAISE NOTICE 'Dropping function get_organization_id...';
    DROP FUNCTION IF EXISTS public.get_organization_id();

    RAISE NOTICE 'Dropping tables organizations and user_profiles...';
    DROP TABLE IF EXISTS public.user_profiles CASCADE;
    DROP TABLE IF EXISTS public.organizations CASCADE;

    RAISE NOTICE 'Reversion script completed.';
END $$;
