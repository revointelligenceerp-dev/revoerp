-- Reverts the multi-tenancy setup by dropping dependent objects in cascade.
-- This script is designed to be fast and avoid timeouts.

-- Step 1: Drop the trigger on the auth.users table.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Step 2: Drop the function that the trigger calls.
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Step 3: Drop the main function and all dependent RLS policies in cascade.
-- This is the most critical step to resolve dependencies.
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;

-- Step 4: Drop the tables created for multi-tenancy.
DROP TABLE IF EXISTS public.user_profiles;
DROP TABLE IF EXISTS public.organizations;

-- NOTE: The 'organization_id' columns in other tables are intentionally
-- not being dropped to prevent timeouts. They are harmless and can be
-- cleaned up later if needed.
