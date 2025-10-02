/*
# [Function] public.get_visao_cobrancas
Creates or replaces the function to get a summarized view of billings for a given month and year. This is necessary to fix a missing function error from a previous migration.

## Query Description:
This function aggregates data for active contracts, grouping by client. It calculates the total value and count of contracts per client, determines the due date for the specified billing period, and sets a default integration status. This is a read-only operation and does not modify any data.

## Metadata:
- Schema-Category: ["Function", "Safe"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [true]

## Structure Details:
- Function: public.get_visao_cobrancas(p_ano integer, p_mes integer)
- Returns: TABLE(cliente_id uuid, cliente_nome text, cliente_telefone text, valor_total numeric, contratos_count bigint, data_vencimento date, status_integracao text)

## Security Implications:
- RLS Status: Not applicable to the function directly, but it queries tables that may have RLS policies.
- Policy Changes: No
- Auth Requirements: The function executes with the permissions of the calling user (SECURITY INVOKER).
- Search Path: Explicitly set to 'public' to prevent search path hijacking.

## Performance Impact:
- Indexes: Relies on indexes on `contratos(cliente_id)`, `contratos(situacao)`, and `clientes(id)`.
- Triggers: None
- Estimated Impact: Low to Medium, depending on the number of active contracts.
*/

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
LANGUAGE 'plpgsql'
STABLE
SECURITY INVOKER
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
        c.id as cliente_id,
        c.nome as cliente_nome,
        c.celular as cliente_telefone,
        SUM(ct.valor) as valor_total,
        COUNT(ct.id) as contratos_count,
        -- Use a case statement to handle day of month correctly, ensuring it doesn't exceed the last day of the month.
        make_date(p_ano, p_mes, LEAST(ct.dia_vencimento, EXTRACT(DAY FROM (v_end_date - interval '1 day'))::integer)) as data_vencimento,
        'pendente'::text as status_integracao
    FROM
        public.contratos ct
    JOIN
        public.clientes c ON ct.cliente_id = c.id
    WHERE
        ct.situacao = 'Ativo' AND
        -- Ensure the contract is active during the billing month
        ct.data_contrato < v_end_date
    GROUP BY
        c.id, ct.dia_vencimento;
END;
$$;
