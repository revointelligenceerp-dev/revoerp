-- Remove a view antiga, se existir, para garantir uma recriação limpa.
DROP VIEW IF EXISTS public.dre_mensal;

-- Recria a view com a opção de segurança correta (security_invoker=true).
-- Isso garante que as políticas de Row Level Security (RLS) do usuário que faz a consulta sejam aplicadas.
CREATE OR REPLACE VIEW public.dre_mensal
WITH (security_invoker = true) AS
SELECT
  EXTRACT(YEAR FROM COALESCE(cr.data_pagamento, cp.data_pagamento))::integer AS ano,
  EXTRACT(MONTH FROM COALESCE(cr.data_pagamento, cp.data_pagamento))::integer AS mes,
  to_char(COALESCE(cr.data_pagamento, cp.data_pagamento), 'TMMonth') AS mes_nome,
  sum(
    CASE
      WHEN cr.id IS NOT NULL THEN cr.valor
      ELSE 0::numeric
    END
  ) AS receita,
  sum(
    CASE
      WHEN cp.id IS NOT NULL THEN cp.valor
      ELSE 0::numeric
    END
  ) AS despesa,
  sum(
    CASE
      WHEN cr.id IS NOT NULL THEN cr.valor
      ELSE - cp.valor
    END
  ) AS resultado
FROM
  contas_receber cr
  FULL JOIN contas_pagar cp ON false
WHERE
  cr.status = 'RECEBIDO'::public.status_conta_receber OR cp.status = 'PAGO'::public.status_conta_pagar
GROUP BY
  (EXTRACT(YEAR FROM COALESCE(cr.data_pagamento, cp.data_pagamento))),
  (EXTRACT(MONTH FROM COALESCE(cr.data_pagamento, cp.data_pagamento))),
  (to_char(COALESCE(cr.data_pagamento, cp.data_pagamento), 'TMMonth'))
ORDER BY
  ano,
  mes;
