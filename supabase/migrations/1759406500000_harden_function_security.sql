/*
# [SECURITY] Harden Function Security
Sets a secure search_path for all user-defined functions to mitigate risk of search path hijacking.

## Query Description:
This operation modifies existing database functions to explicitly set the `search_path`. This prevents malicious users from creating objects (e.g., tables or functions) in schemas they control (like `public`) that could intercept calls intended for objects in other schemas. It is a critical security best practice for multi-user environments. This change does not affect data but improves the security posture of the database.

## Metadata:
- Schema-Category: "Security"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (by altering the function again)

## Structure Details:
- Functions affected:
  - public.is_admin()
  - public.get_visao_cobrancas(integer, integer)
  - public.get_contratos_para_faturar(integer, integer)
  - public.get_dashboard_stats()
  - public.get_faturamento_ultimos_12_meses()
  - public.finalizar_nota_entrada(uuid)

## Security Implications:
- RLS Status: Not applicable
- Policy Changes: No
- Auth Requirements: Requires superuser/owner privileges to alter functions.

## Performance Impact:
- Indexes: None
- Triggers: None
- Estimated Impact: Negligible performance impact. Improves security.
*/

-- Harden is_admin function
ALTER FUNCTION public.is_admin() SET search_path = public, extensions;

-- Harden get_visao_cobrancas function
ALTER FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer) SET search_path = public, extensions;

-- Harden get_contratos_para_faturar function
ALTER FUNCTION public.get_contratos_para_faturar(p_ano integer, p_mes integer) SET search_path = public, extensions;

-- Harden get_dashboard_stats function
ALTER FUNCTION public.get_dashboard_stats() SET search_path = public, extensions;

-- Harden get_faturamento_ultimos_12_meses function
ALTER FUNCTION public.get_faturamento_ultimos_12_meses() SET search_path = public, extensions;

-- Harden finalizar_nota_entrada function
ALTER FUNCTION public.finalizar_nota_entrada(p_nota_id uuid) SET search_path = public, extensions;
