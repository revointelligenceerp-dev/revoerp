-- Habilita a extensão pgcrypto se ainda não estiver habilitada, necessária para gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

/*
  # [SECURITY] Fix Insecure Security Definer Function
  Recreates the 'get_visao_cobrancas' function with 'SECURITY INVOKER' to mitigate security risks associated with SECURITY DEFINER.

  ## Query Description: [This operation modifies the 'get_visao_cobrancas' function to run with the permissions of the calling user ('SECURITY INVOKER') instead of the function owner. This is a critical security fix that prevents potential privilege escalation attacks, ensuring the function cannot access data the user isn't authorized to see.]
  
  ## Metadata:
  - Schema-Category: ["Security", "Structural"]
  - Impact-Level: ["High"]
  - Requires-Backup: false
  - Reversible: true
  
  ## Structure Details:
  - Function: public.get_visao_cobrancas(integer, integer)
  
  ## Security Implications:
  - RLS Status: N/A (Function security)
  - Policy Changes: No
  - Auth Requirements: The function will now respect the RLS policies of the calling user.
  
  ## Performance Impact:
  - Indexes: None
  - Triggers: None
  - Estimated Impact: Minimal, may be slightly slower if the calling user has complex RLS policies to evaluate.
*/
CREATE OR REPLACE FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer)
RETURNS TABLE(cliente_id uuid, cliente_nome text, cliente_telefone text, valor_total numeric, contratos_count bigint, data_vencimento date, status_integracao text)
LANGUAGE plpgsql
SECURITY INVOKER -- Changed from SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.id AS cliente_id,
    c.nome AS cliente_nome,
    c.celular AS cliente_telefone,
    SUM(cr.valor) AS valor_total,
    COUNT(cr.contrato_id)::bigint AS contratos_count,
    MIN(cr.data_vencimento)::date AS data_vencimento,
    'pendente'::text AS status_integracao
  FROM
    public.contas_receber cr
  JOIN
    public.clientes c ON cr.cliente_id = c.id
  WHERE
    cr.contrato_id IS NOT NULL
    AND EXTRACT(YEAR FROM cr.data_vencimento) = p_ano
    AND EXTRACT(MONTH FROM cr.data_vencimento) = p_mes
  GROUP BY
    c.id, c.nome, c.celular;
END;
$$;

/*
  # [SECURITY] Enable RLS and Create Policies
  This script enables Row Level Security (RLS) and creates baseline security policies for all application tables.

  ## Query Description: [This is a critical security operation that restricts data access across your application. It enables RLS on all tables and adds two default policies: one allowing any authenticated user to read data, and another granting full access to the 'service_role' for backend operations. Without these policies, all data would become inaccessible after enabling RLS.]
  
  ## Metadata:
  - Schema-Category: ["Security", "Structural"]
  - Impact-Level: ["High"]
  - Requires-Backup: false
  - Reversible: true
  
  ## Structure Details:
  - Affects all user-defined tables in the 'public' schema.
  
  ## Security Implications:
  - RLS Status: Enabled on all tables.
  - Policy Changes: Yes, adds read-only policies for authenticated users and full-access for service_role.
  - Auth Requirements: Authenticated users will have read-only access by default.
  
  ## Performance Impact:
  - Indexes: None
  - Triggers: None
  - Estimated Impact: Minor overhead on all queries to check RLS policies. This is a necessary trade-off for data security.
*/

-- List of all tables to apply RLS
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN 
        SELECT table_name FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
        AND table_name NOT LIKE 'pg_%' AND table_name NOT LIKE 'sql_%'
    LOOP
        -- Enable RLS
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t_name);

        -- Drop existing policies to ensure idempotency
        EXECUTE format('DROP POLICY IF EXISTS "Allow read-only for authenticated users" ON public.%I;', t_name);
        EXECUTE format('DROP POLICY IF EXISTS "Allow all for service_role" ON public.%I;', t_name);

        -- Create read-only policy for authenticated users
        EXECUTE format('
            CREATE POLICY "Allow read-only for authenticated users" ON public.%I
            FOR SELECT
            TO authenticated
            USING (true);
        ', t_name);

        -- Create full-access policy for service_role (for server-side logic, migrations, etc.)
        EXECUTE format('
            CREATE POLICY "Allow all for service_role" ON public.%I
            FOR ALL
            TO service_role
            USING (true);
        ', t_name);
    END LOOP;
END;
$$;
