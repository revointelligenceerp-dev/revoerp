-- Revert Multi-Tenancy Script (Cascade Fix)

-- 1. Drop the function and all dependent policies in cascade.
-- This is the most direct and effective way to resolve the dependency error.
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;

-- 2. Drop the trigger that adds the organization_id to the JWT.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 3. Drop the function associated with the trigger.
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 4. Drop the user_profiles table.
DROP TABLE IF EXISTS public.user_profiles;

-- 5. Drop the organizations table.
DROP TABLE IF EXISTS public.organizations;

-- NOTE: The 'organization_id' columns on other tables are intentionally left
-- to avoid long-running ALTER TABLE operations that cause timeouts.
-- They are harmless "orphans" now that the related logic is removed.
