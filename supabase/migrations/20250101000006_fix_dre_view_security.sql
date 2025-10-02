-- Remove a view insegura
DROP VIEW IF EXISTS public.dre_mensal;

-- Recria a view de forma segura (SECURITY INVOKER é o padrão)
CREATE OR REPLACE VIEW public.dre_mensal AS
WITH meses AS (
  SELECT generate_series(
    date_trunc('year', MIN(data_pagamento)),
    date_trunc('year', MAX(data_pagamento)) + interval '1 year' - interval '1 day',
    '1 month'
  )::date AS mes
  FROM (
    SELECT data_pagamento FROM contas_receber WHERE data_pagamento IS NOT NULL
    UNION ALL
    SELECT data_pagamento FROM contas_pagar WHERE data_pagamento IS NOT NULL
  ) AS datas
),
receitas AS (
  SELECT
    date_trunc('month', data_pagamento)::date AS mes,
    sum(valor) AS total
  FROM contas_receber
  WHERE status = 'RECEBIDO' AND data_pagamento IS NOT NULL
  GROUP BY 1
),
despesas AS (
  SELECT
    date_trunc('month', data_pagamento)::date AS mes,
    sum(valor) AS total
  FROM contas_pagar
  WHERE status = 'PAGO' AND data_pagamento IS NOT NULL
  GROUP BY 1
)
SELECT
  EXTRACT(YEAR FROM m.mes)::int AS ano,
  EXTRACT(MONTH FROM m.mes)::int AS mes,
  to_char(m.mes, 'TMMon') AS mes_nome,
  COALESCE(r.total, 0) AS receita,
  COALESCE(d.total, 0) AS despesa,
  COALESCE(r.total, 0) - COALESCE(d.total, 0) AS resultado
FROM meses m
LEFT JOIN receitas r ON m.mes = r.mes
LEFT JOIN despesas d ON m.mes = d.mes
WHERE COALESCE(r.total, 0) > 0 OR COALESCE(d.total, 0) > 0
ORDER BY 1, 2;
