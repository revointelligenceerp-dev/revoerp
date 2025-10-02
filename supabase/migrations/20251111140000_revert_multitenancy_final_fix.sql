DO $$
DECLARE
    policy_record RECORD;
    table_record RECORD;
    constraint_record RECORD;
BEGIN
    -- Step 1: Drop all RLS policies on public tables to remove dependencies
    FOR policy_record IN
        SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I;', policy_record.policyname, policy_record.tablename);
    END LOOP;

    -- Step 2: Disable RLS on all public tables
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE format('ALTER TABLE public.%I DISABLE ROW LEVEL SECURITY;', table_record.tablename);
    END LOOP;

    -- Step 3: Drop foreign key constraints pointing to 'organizations' table
    FOR constraint_record IN
        SELECT con.conname, rel.relname
        FROM pg_catalog.pg_constraint con
        INNER JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid
        INNER JOIN pg_catalog.pg_namespace nsp ON nsp.oid = con.connamespace
        WHERE nsp.nspname = 'public' AND con.confrelid = (SELECT oid FROM pg_class WHERE relname = 'organizations' LIMIT 1)
    LOOP
        EXECUTE format('ALTER TABLE public.%I DROP CONSTRAINT IF EXISTS %I;', constraint_record.relname, constraint_record.conname);
    END LOOP;

    -- Step 4: Drop functions and triggers
    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    DROP FUNCTION IF EXISTS public.handle_new_user();
    DROP FUNCTION IF EXISTS public.get_organization_id();

    -- Step 5: Drop the multi-tenancy tables
    DROP TABLE IF EXISTS public.user_profiles;
    DROP TABLE IF EXISTS public.organizations;

    -- Step 6: Drop the 'organization_id' column from all tables that have it
    FOR table_record IN
        SELECT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public' AND column_name = 'organization_id'
    LOOP
        EXECUTE format('ALTER TABLE public.%I DROP COLUMN IF EXISTS organization_id;', table_record.table_name);
    END LOOP;
END $$;
