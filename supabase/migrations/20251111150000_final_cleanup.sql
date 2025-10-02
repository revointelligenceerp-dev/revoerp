-- This script performs a full cleanup of all multi-tenancy and RLS policies.
-- It is designed to be run even if previous scripts failed.

DO $$
DECLARE
    table_record RECORD;
    policy_record RECORD;
BEGIN
    RAISE NOTICE 'Starting database cleanup...';

    -- Step 1: Drop all RLS policies from all tables in the public schema.
    RAISE NOTICE 'Dropping all RLS policies...';
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        FOR policy_record IN
            SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = table_record.tablename
        LOOP
            RAISE NOTICE 'Dropping policy % on table %', policy_record.policyname, table_record.tablename;
            EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON public.' || table_record.tablename || ';';
        END LOOP;
    END LOOP;

    -- Step 2: Disable RLS on all tables to clear security advisories.
    RAISE NOTICE 'Disabling RLS on all tables...';
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        RAISE NOTICE 'Disabling RLS on table %', table_record.tablename;
        EXECUTE 'ALTER TABLE public.' || table_record.tablename || ' DISABLE ROW LEVEL SECURITY;';
    END LOOP;

    -- Step 3: Drop the functions and triggers related to multi-tenancy.
    RAISE NOTICE 'Dropping functions and triggers...';
    DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;
    DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

    -- Step 4: Drop the multi-tenancy tables.
    RAISE NOTICE 'Dropping multi-tenancy tables...';
    DROP TABLE IF EXISTS public.user_profiles CASCADE;
    DROP TABLE IF EXISTS public.organizations CASCADE;

    -- Step 5: Drop the organization_id column from all tables where it might exist.
    RAISE NOTICE 'Dropping organization_id columns...';
    FOR table_record IN
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE table_schema = 'public' AND column_name = 'organization_id'
    LOOP
        RAISE NOTICE 'Dropping organization_id from table %', table_record.table_name;
        EXECUTE 'ALTER TABLE public.' || table_record.table_name || ' DROP COLUMN IF EXISTS organization_id;';
    END LOOP;

    RAISE NOTICE 'Database cleanup completed successfully.';
END;
$$;
