-- STAGE 1: Disable RLS on all public tables to remove active dependencies.
DO $$
DECLARE
    tbl_name TEXT;
BEGIN
    FOR tbl_name IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(tbl_name) || ' DISABLE ROW LEVEL SECURITY;';
        RAISE NOTICE 'RLS disabled on table: %', tbl_name;
    END LOOP;
END $$;

-- STAGE 2: Drop all policies that might still exist.
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN
        SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(policy_record.policyname) || ' ON public.' || quote_ident(policy_record.tablename) || ';';
        RAISE NOTICE 'Dropped policy % on table %', policy_record.policyname, policy_record.tablename;
    END LOOP;
END $$;

-- STAGE 3: Drop the dependent functions and triggers. Now it's safe.
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user_profile() CASCADE;
-- The trigger on auth.users is dropped by `CASCADE` on the function.

-- STAGE 4: Drop the multi-tenancy tables.
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.organizations CASCADE;

-- STAGE 5: Restore basic permissions for authenticated users.
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

RAISE NOTICE 'Multi-tenancy structure successfully reverted.';
