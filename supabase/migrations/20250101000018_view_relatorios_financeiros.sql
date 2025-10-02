/*
  # [View] dre_mensal
  Cria uma VIEW (tabela virtual) para consolidar o Demonstrativo de Resultados do Exercício (DRE) mensal.

  ## Query Description:
  - Esta operação é segura e não afeta dados existentes.
  - Ela cria uma view que agrega dados das tabelas `contas_receber` e `contas_pagar` para calcular receita, despesa e resultado por mês.
  - A view melhora significativamente a performance dos relatórios, pois os cálculos são feitos no banco de dados.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (pode ser removida com `DROP VIEW dre_mensal;`)

  ## Structure Details:
  - View Name: `dre_mensal`
  - Columns: `ano`, `mes`, `mes_nome`, `receita`, `despesa`, `resultado`
  - Source Tables: `contas_receber`, `contas_pagar`

  ## Security Implications:
  - RLS Status: A view herda as políticas de RLS das tabelas base.
  - Policy Changes: No
  - Auth Requirements: Acesso de leitura às tabelas `contas_receber` e `contas_pagar`.

  ## Performance Impact:
  - Indexes: Não aplicável para a criação da view.
  - Triggers: Não aplicável.
  - Estimated Impact: Positivo. Reduz a carga de processamento no frontend para relatórios.
*/

-- Cria ou substitui a VIEW dre_mensal
CREATE OR REPLACE VIEW dre_mensal AS
WITH movimentacoes_mensais AS (
  -- Agrega as receitas mensais
  SELECT
    date_part('year', data_pagamento) AS ano,
    date_part('month', data_pagamento) AS mes,
    sum(valor) AS receita,
    0::numeric AS despesa
  FROM contas_receber
  WHERE status = 'RECEBIDO' AND data_pagamento IS NOT NULL
  GROUP BY 1, 2

  UNION ALL

  -- Agrega as despesas mensais
  SELECT
    date_part('year', data_pagamento) AS ano,
    date_part('month', data_pagamento) AS mes,
    0::numeric AS receita,
    sum(valor) AS despesa
  FROM contas_pagar
  WHERE status = 'PAGO' AND data_pagamento IS NOT NULL
  GROUP BY 1, 2
)
-- Consolida os resultados
SELECT
  ano::integer,
  mes::integer,
  to_char(make_date(ano::integer, mes::integer, 1), 'TMMonth') AS mes_nome,
  sum(receita) AS receita,
  sum(despesa) AS despesa,
  sum(receita) - sum(despesa) AS resultado
FROM movimentacoes_mensais
GROUP BY 1, 2
ORDER BY 1, 2;
