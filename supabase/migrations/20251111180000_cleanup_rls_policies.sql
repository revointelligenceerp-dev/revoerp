DO $$
DECLARE
    table_record RECORD;
    policy_record RECORD;
BEGIN
    -- Loop through all tables in the public schema
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        -- Drop all policies on the current table
        FOR policy_record IN
            SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = table_record.tablename
        LOOP
            EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON public."' || table_record.tablename || '";';
        END LOOP;

        -- Disable RLS on the table
        EXECUTE 'ALTER TABLE public."' || table_record.tablename || '" DISABLE ROW LEVEL SECURITY;';
    END LOOP;

    -- Drop functions left over from multi-tenancy attempts
    DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

    RAISE NOTICE 'RLS cleanup and multi-tenancy reversion complete.';
END;
$$;
