/*
# [SECURITY] Harden Function Search Paths
[Description: This migration sets a secure `search_path` for existing database functions to mitigate potential security risks.]

## Query Description: [This operation modifies the configuration of several database functions to enhance security. By explicitly setting the `search_path`, it prevents a class of vulnerabilities where a malicious user could temporarily create objects (like tables or functions) in a public schema that would be executed instead of the intended ones. This change does not affect existing data and is a recommended security best practice.]

## Metadata:
- Schema-Category: ["Security"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [true]

## Structure Details:
- Functions affected:
  - `get_organization_id()`
  - `handle_new_user()`
  - `get_visao_cobrancas(integer, integer)`
  - `get_contratos_para_faturar(integer, integer)`

## Security Implications:
- RLS Status: [Not Changed]
- Policy Changes: [No]
- Auth Requirements: [Admin privileges to alter functions]
- Mitigates: `search_path` hijacking vulnerabilities.

## Performance Impact:
- Indexes: [Not Changed]
- Triggers: [Not Changed]
- Estimated Impact: [Negligible performance impact. Improves security.]
*/

-- Set a secure search path for all functions to mitigate CVE-2018-1058
-- This prevents malicious users from creating objects in public schemas that could be executed by functions.

DO $$
BEGIN
  -- Fix for get_organization_id
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_organization_id') THEN
    ALTER FUNCTION public.get_organization_id() SET search_path = public;
    RAISE NOTICE 'Updated search_path for get_organization_id';
  END IF;

  -- Fix for handle_new_user (trigger function)
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'handle_new_user') THEN
    ALTER FUNCTION public.handle_new_user() SET search_path = public;
    RAISE NOTICE 'Updated search_path for handle_new_user';
  END IF;

  -- Fix for get_visao_cobrancas
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_visao_cobrancas') THEN
    -- Assuming the signature from previous context
    ALTER FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer) SET search_path = public;
    RAISE NOTICE 'Updated search_path for get_visao_cobrancas';
  END IF;

  -- Fix for get_contratos_para_faturar
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_contratos_para_faturar') THEN
    -- Assuming the signature from previous context
    ALTER FUNCTION public.get_contratos_para_faturar(p_ano integer, p_mes integer) SET search_path = public;
    RAISE NOTICE 'Updated search_path for get_contratos_para_faturar';
  END IF;
END;
$$;
