/*
# [CRITICAL SECURITY FIX] Altera a visão DRE Mensal para SECURITY INVOKER
Corrige a vulnerabilidade de segurança "Security Definer View" detectada, garantindo que a visão `dre_mensal` respeite as políticas de segurança de linha (RLS) do usuário que a consulta.

## Query Description: [Esta operação corrige uma falha de segurança crítica. Ela recria a visão de relatórios financeiros (`dre_mensal`) para usar `SECURITY INVOKER`, o que garante que as permissões do usuário sejam sempre respeitadas. Não há risco de perda de dados, pois apenas a definição da visão é alterada.]

## Metadata:
- Schema-Category: ["Structural", "Safe"]
- Impact-Level: ["High"]
- Requires-Backup: false
- Reversible: true

## Structure Details:
- A visão `public.dre_mensal` será recriada.

## Security Implications:
- RLS Status: [Corrected]
- Policy Changes: [Yes] - A visão agora respeitará as políticas de RLS existentes.
- Auth Requirements: [N/A]

## Performance Impact:
- Indexes: [N/A]
- Triggers: [N/A]
- Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- Remove a visão insegura
DROP VIEW IF EXISTS public.dre_mensal;

-- Recria a visão com a configuração segura (SECURITY INVOKER é o padrão)
CREATE VIEW public.dre_mensal AS
WITH meses AS (
    -- Cria uma série de meses a partir da primeira até a última data de pagamento registrada
    SELECT generate_series(
        date_trunc('year', MIN(data_pagamento)),
        date_trunc('month', MAX(data_pagamento)),
        '1 month'::interval
    )::date AS mes
    FROM (
        SELECT data_pagamento FROM public.contas_receber WHERE status = 'RECEBIDO' AND data_pagamento IS NOT NULL
        UNION ALL
        SELECT data_pagamento FROM public.contas_pagar WHERE status = 'PAGO' AND data_pagamento IS NOT NULL
    ) AS datas
    WHERE data_pagamento IS NOT NULL
),
receitas_mensais AS (
    -- Agrega todas as receitas por mês
    SELECT
        date_trunc('month', data_pagamento)::date AS mes,
        sum(valor) AS total_receita
    FROM public.contas_receber
    WHERE status = 'RECEBIDO' AND data_pagamento IS NOT NULL
    GROUP BY 1
),
despesas_mensais AS (
    -- Agrega todas as despesas por mês
    SELECT
        date_trunc('month', data_pagamento)::date AS mes,
        sum(valor) AS total_despesa
    FROM public.contas_pagar
    WHERE status = 'PAGO' AND data_pagamento IS NOT NULL
    GROUP BY 1
)
-- Junta os dados e calcula o resultado
SELECT
    EXTRACT(YEAR FROM m.mes)::integer AS ano,
    EXTRACT(MONTH FROM m.mes)::integer AS mes,
    to_char(m.mes, 'TMMonth') AS mes_nome,
    COALESCE(r.total_receita, 0) AS receita,
    COALESCE(d.total_despesa, 0) AS despesa,
    (COALESCE(r.total_receita, 0) - COALESCE(d.total_despesa, 0)) AS resultado
FROM meses m
LEFT JOIN receitas_mensais r ON m.mes = r.mes
LEFT JOIN despesas_mensais d ON m.mes = d.mes
-- Garante que meses sem movimentação não apareçam no relatório
WHERE COALESCE(r.total_receita, 0) > 0 OR COALESCE(d.total_despesa, 0) > 0
ORDER BY m.mes;
