-- Migration to definitively revert all multi-tenancy changes and fix security advisories.

DO $$
DECLARE
  table_record RECORD;
  policy_record RECORD;
BEGIN
  -- Step 1 & 2: Drop all RLS policies and disable RLS for each table
  FOR table_record IN 
    SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    -- Drop policies for the current table
    FOR policy_record IN
      SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = table_record.tablename
    LOOP
      EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON public."' || table_record.tablename || '";';
    END LOOP;
    
    -- Disable RLS on the table
    EXECUTE 'ALTER TABLE public."' || table_record.tablename || '" DISABLE ROW LEVEL SECURITY;';
  END LOOP;

  -- Step 3: Drop functions and triggers
  DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
  DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;
  DROP FUNCTION IF EXISTS public.apply_rls_policy_to_all_tables() CASCADE;

  -- Step 4: Drop multi-tenancy tables
  DROP TABLE IF EXISTS public.user_profiles CASCADE;
  DROP TABLE IF EXISTS public.organizations CASCADE;

  -- Step 5: Remove the now-orphaned organization_id column from all tables
  FOR table_record IN 
    SELECT tablename FROM pg_tables WHERE schemaname = 'public'
  LOOP
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' AND table_name = table_record.tablename AND column_name = 'organization_id'
    ) THEN
      EXECUTE 'ALTER TABLE public."' || table_record.tablename || '" DROP COLUMN IF EXISTS organization_id;';
    END IF;
  END LOOP;
END;
$$;
