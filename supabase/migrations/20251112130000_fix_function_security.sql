/*
  # [SECURITY] Fix Function Search Path
  [This migration script hardens database security by explicitly setting the `search_path` for several functions. This mitigates the "Function Search Path Mutable" warnings by preventing potential search path hijacking vulnerabilities.]

  ## Query Description: [This operation modifies existing database functions to make them more secure. It is a non-destructive, safe operation that improves the security posture of the application. No data will be affected.]
  
  ## Metadata:
  - Schema-Category: ["Security", "Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [true]
  
  ## Structure Details:
  - Functions being modified:
    - public.get_organization_id()
    - public.handle_new_user()
    - public.get_visao_cobrancas(integer, integer)
  
  ## Security Implications:
  - RLS Status: [No Change]
  - Policy Changes: [No]
  - Auth Requirements: [None]
  
  ## Performance Impact:
  - Indexes: [No Change]
  - Triggers: [No Change]
  - Estimated Impact: [Negligible performance impact. Improves security.]
*/

-- Fix for get_organization_id function
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
EXCEPTION
  WHEN others THEN
    RETURN null;
END;
$$;

-- Fix for handle_new_user trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_organization_id uuid;
BEGIN
  -- Find the organization_id from the user_profiles table
  SELECT organization_id INTO v_organization_id
  FROM public.user_profiles
  WHERE user_id = NEW.id;

  -- If an organization_id is found, update the user's metadata
  IF v_organization_id IS NOT NULL THEN
    UPDATE auth.users
    SET raw_app_meta_data = raw_app_meta_data || jsonb_build_object('organization_id', v_organization_id)
    WHERE id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Fix for get_visao_cobrancas function
CREATE OR REPLACE FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer)
RETURNS TABLE(
    cliente_id uuid,
    cliente_nome text,
    cliente_telefone text,
    valor_total numeric,
    contratos_count bigint,
    data_vencimento date,
    status_integracao text
)
LANGUAGE plpgsql
STABLE
SET search_path = public
AS $$
DECLARE
    v_start_date date;
    v_end_date date;
BEGIN
    v_start_date := make_date(p_ano, p_mes, 1);
    v_end_date := v_start_date + interval '1 month';

    RETURN QUERY
    SELECT
        c.id AS cliente_id,
        c.nome AS cliente_nome,
        c.celular AS cliente_telefone,
        SUM(ct.valor) AS valor_total,
        COUNT(ct.id) AS contratos_count,
        -- Use o menor dia de vencimento para o cliente no mês, limitado a 28 para evitar erros em meses curtos
        make_date(p_ano, p_mes, LEAST(MIN(ct.dia_vencimento), 28)) AS data_vencimento,
        'pendente'::text AS status_integracao
    FROM
        public.clientes c
    JOIN
        public.contratos ct ON c.id = ct.cliente_id
    WHERE
        ct.situacao = 'ATIVO'
        AND NOT EXISTS (
            SELECT 1
            FROM public.contas_receber cr
            WHERE cr.contrato_id = ct.id
              AND date_trunc('month', cr.data_vencimento) = date_trunc('month', v_start_date)
        )
    GROUP BY
        c.id, c.nome, c.celular;
END;
$$;
