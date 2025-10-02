-- Step 1: Disable RLS and Drop Policies for all tables to remove dependencies.
DO $$
DECLARE
    tbl_name TEXT;
BEGIN
    FOR tbl_name IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        -- Drop policies if they exist
        EXECUTE 'DROP POLICY IF EXISTS "Allow individual delete access" ON public.' || quote_ident(tbl_name);
        EXECUTE 'DROP POLICY IF EXISTS "Allow individual update access" ON public.' || quote_ident(tbl_name);
        EXECUTE 'DROP POLICY IF EXISTS "Allow individual insert access" ON public.' || quote_ident(tbl_name);
        EXECUTE 'DROP POLICY IF EXISTS "Allow individual read access" ON public.' || quote_ident(tbl_name);
        EXECUTE 'DROP POLICY IF EXISTS "allow_delete_for_organization_members" ON public.' || quote_ident(tbl_name);
        EXECUTE 'DROP POLICY IF EXISTS "allow_update_for_organization_members" ON public.' || quote_ident(tbl_name);
        EXECUTE 'DROP POLICY IF EXISTS "allow_insert_for_organization_members" ON public.' || quote_ident(tbl_name);
        EXECUTE 'DROP POLICY IF EXISTS "allow_select_for_organization_members" ON public.' || quote_ident(tbl_name);
        
        -- Disable RLS
        EXECUTE 'ALTER TABLE public.' || quote_ident(tbl_name) || ' DISABLE ROW LEVEL SECURITY';
    END LOOP;
END $$;

-- Step 2: Drop the trigger and its function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Step 3: Drop the main function and all its dependent policies in cascade
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;

-- Step 4: Drop foreign key constraints pointing to the organizations table
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT
            con.conname AS constraint_name,
            tbl.relname AS table_name
        FROM
            pg_constraint con
            JOIN pg_class tbl ON tbl.oid = con.conrelid
            JOIN pg_namespace nsp ON nsp.oid = tbl.relnamespace
            JOIN pg_class ftbl ON ftbl.oid = con.confrelid
        WHERE
            nsp.nspname = 'public'
            AND ftbl.relname = 'organizations'
            AND con.contype = 'f'
    ) LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.table_name) || ' DROP CONSTRAINT ' || quote_ident(r.constraint_name);
    END LOOP;
END $$;


-- Step 5: Drop the multi-tenancy tables
DROP TABLE IF EXISTS public.user_profiles;
DROP TABLE IF EXISTS public.organizations;

-- Step 6: Drop the procedure used in previous attempts
DROP PROCEDURE IF EXISTS apply_rls_policies();
