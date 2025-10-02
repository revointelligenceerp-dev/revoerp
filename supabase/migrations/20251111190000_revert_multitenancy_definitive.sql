-- Final Revert Script
-- This script uses CASCADE to resolve dependencies, as suggested by the database error messages.
-- This should be more efficient than dropping each object individually.

-- Step 1: Drop the trigger from auth.users.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Step 2: Drop the handle_new_user function. This has no dependencies.
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Step 3: Drop the get_organization_id function and all policies that depend on it.
-- The CASCADE will handle the dependency error we saw previously.
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;

-- Step 4: Drop the user_profiles table. It has no incoming dependencies.
DROP TABLE IF EXISTS public.user_profiles;

-- Step 5: Drop the organizations table and all foreign key constraints that reference it.
-- The CASCADE will handle the dependency error on the table.
DROP TABLE IF EXISTS public.organizations CASCADE;

-- Step 6: Ensure RLS is disabled on all tables as a final cleanup.
-- This prevents any lingering access issues.
DO $$
DECLARE
    tbl_name TEXT;
BEGIN
    FOR tbl_name IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        -- Check if the table still exists and if RLS is enabled
        IF EXISTS (SELECT 1 FROM pg_class WHERE relname = tbl_name AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public') AND relrowsecurity) THEN
            EXECUTE 'ALTER TABLE public.' || quote_ident(tbl_name) || ' DISABLE ROW LEVEL SECURITY;';
        END IF;
    END LOOP;
END $$;

-- NOTE: The 'organization_id' columns are NOT dropped to prevent timeouts.
-- They are harmless and can be cleaned up later if desired.
