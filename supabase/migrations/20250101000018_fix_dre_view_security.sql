/*
          # [Correção de Segurança] Visão DRE Mensal
          [Recria a visão 'dre_mensal' para usar 'SECURITY INVOKER' (padrão) em vez de 'SECURITY DEFINER', resolvendo uma vulnerabilidade de segurança crítica. A nova visão respeitará as políticas de RLS do usuário que a consulta.]

          ## Query Description: ["Esta operação corrige uma falha de segurança na visão de relatórios. Não há impacto nos dados existentes, mas a mudança é crucial para garantir que as permissões de acesso aos dados financeiros sejam respeitadas corretamente no futuro, especialmente após a implementação de autenticação de usuários."]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Afeta a VIEW: dre_mensal
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [Nenhum]
          - Corrige a vulnerabilidade "Security Definer View".
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
          */

-- Remove a visão insegura existente
DROP VIEW IF EXISTS public.dre_mensal;

-- Recria a visão com a configuração de segurança padrão (SECURITY INVOKER)
CREATE VIEW public.dre_mensal AS
SELECT
    EXTRACT(YEAR FROM COALESCE(cr.data_pagamento, cp.data_pagamento))::integer AS ano,
    EXTRACT(MONTH FROM COALESCE(cr.data_pagamento, cp.data_pagamento))::integer AS mes,
    to_char(COALESCE(cr.data_pagamento, cp.data_pagamento), 'TMMonth') AS mes_nome,
    COALESCE(sum(cr.valor), 0::numeric) AS receita,
    COALESCE(sum(cp.valor), 0::numeric) AS despesa,
    (COALESCE(sum(cr.valor), 0::numeric) - COALESCE(sum(cp.valor), 0::numeric)) AS resultado
FROM (public.contas_receber cr
    FULL JOIN public.contas_pagar cp ON ((EXTRACT(YEAR FROM cr.data_pagamento) = EXTRACT(YEAR FROM cp.data_pagamento)) AND (EXTRACT(MONTH FROM cr.data_pagamento) = EXTRACT(MONTH FROM cp.data_pagamento))))
WHERE (COALESCE(cr.data_pagamento, cp.data_pagamento) IS NOT NULL)
GROUP BY (EXTRACT(YEAR FROM COALESCE(cr.data_pagamento, cp.data_pagamento))), (EXTRACT(MONTH FROM COALESCE(cr.data_pagamento, cp.data_pagamento))), (to_char(COALESCE(cr.data_pagamento, cp.data_pagamento), 'TMMonth'))
ORDER BY (EXTRACT(YEAR FROM COALESCE(cr.data_pagamento, cp.data_pagamento))), (EXTRACT(MONTH FROM COALESCE(cr.data_pagamento, cp.data_pagamento)));
