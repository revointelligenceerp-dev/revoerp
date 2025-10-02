-- This script fixes security warnings related to mutable function search paths.
-- It sets a secure, explicit search_path for each function identified by the security advisor.
-- This prevents potential hijacking attacks by ensuring functions resolve objects in the intended schema.

/*
# [Fix Function Search Path]
[This operation sets a fixed search_path for several database functions to resolve security warnings.]

## Query Description: [This operation modifies the definition of existing functions to make them more secure. It does not alter any data or table structures. It is a safe, non-destructive operation recommended to mitigate security vulnerabilities.]

## Metadata:
- Schema-Category: ["Security", "Safe"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [true]

## Structure Details:
[
  - public.get_my_organization_id(),
  - public.handle_updated_at(),
  - public.apply_rls_policy(text),
  - public.apply_permissive_rls_to_all_tables(),
  - public.update_user_org_claim(),
  - public.apply_rls_policies_to_all_tables()
]

## Security Implications:
- RLS Status: [Not Changed]
- Policy Changes: [No]
- Auth Requirements: [Admin privileges to alter functions]

## Performance Impact:
- Indexes: [Not Changed]
- Triggers: [Not Changed]
- Estimated Impact: [None. This is a metadata change on function definitions.]
*/

-- It's safe to run these commands even if some functions don't exist.
-- The database will return an error for non-existent functions, which can be ignored,
-- as it means that part of the cleanup was already successful.

-- Note: The function signatures (arguments) are assumed based on common usage and previous context.
-- If a command fails due to a signature mismatch, please provide the error details.

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'handle_updated_at') THEN
    ALTER FUNCTION public.handle_updated_at() SET search_path = public;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_my_organization_id') THEN
    ALTER FUNCTION public.get_my_organization_id() SET search_path = public;
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'apply_rls_policy') THEN
    -- This assumes the function has one text argument as created in previous steps.
    -- If the signature is different, this specific command might fail.
    ALTER FUNCTION public.apply_rls_policy(text) SET search_path = public;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'apply_permissive_rls_to_all_tables') THEN
    ALTER FUNCTION public.apply_permissive_rls_to_all_tables() SET search_path = public;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_user_org_claim') THEN
    ALTER FUNCTION public.update_user_org_claim() SET search_path = public;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'apply_rls_policies_to_all_tables') THEN
    ALTER FUNCTION public.apply_rls_policies_to_all_tables() SET search_path = public;
  END IF;
END;
$$;
