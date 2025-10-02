/*
          # [CORREÇÃO] Relatório de Comissões e DRE

          [Este script corrige um erro de tipo de dados (ENUM) na criação da VIEW de comissões e aplica uma melhoria proativa na VIEW do DRE para garantir a robustez do sistema.]

          ## Query Description: ["Este script corrige as visualizações (views) de relatórios no banco de dados. Ele não afeta dados existentes, apenas a forma como os relatórios são calculados, garantindo que funcionem corretamente. Nenhum backup é necessário."]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Views Afetadas: `comissoes_calculadas`, `dre_mensal`
          - Tabelas Afetadas: `vendedores` (garante a existência da coluna `percentual_comissao`)
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [None]
          
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
          */

-- 1. Garantir que a coluna de comissão existe na tabela de vendedores
ALTER TABLE public.vendedores
ADD COLUMN IF NOT EXISTS percentual_comissao numeric(5, 2) NOT NULL DEFAULT 5.0;

-- 2. Recriar a VIEW de comissões com a comparação de status corrigida
-- A correção usa a conversão para TEXT (::text) para evitar erros de tipo de ENUM.
CREATE OR REPLACE VIEW public.comissoes_calculadas AS
SELECT
  cr.id,
  pv.vendedor_id AS "vendedorId",
  v.nome AS "vendedorNome",
  pv.id AS "pedidoId",
  pv.numero AS "pedidoNumero",
  pv.valor_total AS "valorPedido",
  v.percentual_comissao AS "percentualComissao",
  (pv.valor_total * v.percentual_comissao / 100) AS "valorComissao",
  cr.data_pagamento AS "dataPagamentoFatura"
FROM
  public.contas_receber cr
JOIN
  public.faturas_venda fv ON cr.fatura_id = fv.id
JOIN
  public.pedidos_venda pv ON fv.pedido_id = pv.id
JOIN
  public.vendedores v ON pv.vendedor_id = v.id
WHERE
  cr.status::text = 'RECEBIDO'; -- CORREÇÃO APLICADA AQUI

-- 3. (Manutenção Proativa) Recriar a VIEW de DRE com a mesma correção para consistência
CREATE OR REPLACE VIEW public.dre_mensal
SECURITY INVOKER
AS
SELECT
  EXTRACT(YEAR FROM data_liquidacao)::integer AS ano,
  EXTRACT(MONTH FROM data_liquidacao)::integer AS mes,
  to_char(data_liquidacao, 'TMMonth') AS mes_nome,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE 0 END) AS receita,
  SUM(CASE WHEN tipo = 'SAIDA' THEN valor ELSE 0 END) AS despesa,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE -valor END) AS resultado
FROM (
  SELECT
    cr.data_pagamento AS data_liquidacao,
    cr.valor,
    'ENTRADA' AS tipo
  FROM
    public.contas_receber cr
  WHERE
    cr.status::text = 'RECEBIDO' -- CORREÇÃO APLICADA AQUI
  UNION ALL
  SELECT
    cp.data_pagamento AS data_liquidacao,
    cp.valor,
    'SAIDA' AS tipo
  FROM
    public.contas_pagar cp
  WHERE
    cp.status::text = 'PAGO' -- CORREÇÃO APLICADA AQUI
) AS movimentacoes_liquidadas
WHERE data_liquidacao IS NOT NULL
GROUP BY
  ano, mes, mes_nome
ORDER BY
  ano, mes;
