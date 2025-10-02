BEGIN;

-- Metadata for the migration
/*
  # [Migration] Correção de Tipos de Status e Relatórios
  [Corrige erros de migração relacionados a tipos de dados ENUM e recria as visões (views) de relatórios de forma segura e correta.]

  ## Query Description:
  - Cria os tipos ENUM 'status_conta_receber' e 'status_conta_pagar' se não existirem.
  - Altera as colunas 'status' nas tabelas 'contas_receber' and 'contas_pagar' para usar os novos tipos ENUM, convertendo os dados existentes.
  - Recria as visões 'dre_mensal' e 'comissoes_calculadas' com a sintaxe de segurança correta (SECURITY INVOKER) e corrigindo as comparações de tipo.
  - Garante que a coluna 'percentual_comissao' exista na tabela 'vendedores'.
  Esta operação é segura e não deve causar perda de dados.

  ## Metadata:
  - Schema-Category: ["Structural", "Safe"]
  - Impact-Level: ["Medium"]
  - Requires-Backup: false
  - Reversible: false
*/

-- 1. Criar os tipos ENUM se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
        CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
        CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
    END IF;
END
$$;

-- 2. Alterar as colunas de status, convertendo o tipo de forma segura
DO $$
BEGIN
    -- Altera contas_receber se a coluna não for do tipo correto
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contas_receber' AND column_name = 'status' AND udt_name != 'status_conta_receber'
    ) THEN
        ALTER TABLE public.contas_receber
        ALTER COLUMN status TYPE public.status_conta_receber
        USING status::text::public.status_conta_receber;
    END IF;

    -- Altera contas_pagar se a coluna não for do tipo correto
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contas_pagar' AND column_name = 'status' AND udt_name != 'status_conta_pagar'
    ) THEN
        ALTER TABLE public.contas_pagar
        ALTER COLUMN status TYPE public.status_conta_pagar
        USING status::text::public.status_conta_pagar;
    END IF;
END
$$;

-- 3. Garantir que a coluna de comissão exista em vendedores
ALTER TABLE public.vendedores
ADD COLUMN IF NOT EXISTS percentual_comissao numeric(5, 2) NOT NULL DEFAULT 5.0;

-- 4. Recriar a VIEW dre_mensal de forma segura
DROP VIEW IF EXISTS public.dre_mensal;
CREATE VIEW public.dre_mensal
WITH (security_invoker = true)
AS
SELECT
  EXTRACT(YEAR FROM data_liquidacao) AS ano,
  EXTRACT(MONTH FROM data_liquidacao) AS mes,
  to_char(data_liquidacao, 'TMMonth') AS mes_nome,
  SUM(CASE WHEN tipo = 'RECEITA' THEN valor ELSE 0 END) AS receita,
  SUM(CASE WHEN tipo = 'DESPESA' THEN valor ELSE 0 END) AS despesa,
  SUM(CASE WHEN tipo = 'RECEITA' THEN valor ELSE -valor END) AS resultado
FROM (
  SELECT
    cr.data_pagamento as data_liquidacao,
    'RECEITA' as tipo,
    cr.valor
  FROM public.contas_receber cr
  WHERE cr.status::text = 'RECEBIDO' AND cr.data_pagamento IS NOT NULL
  UNION ALL
  SELECT
    cp.data_pagamento as data_liquidacao,
    'DESPESA' as tipo,
    cp.valor
  FROM public.contas_pagar cp
  WHERE cp.status::text = 'PAGO' AND cp.data_pagamento IS NOT NULL
) AS movimentacoes
WHERE data_liquidacao IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY 1, 2;

-- 5. Recriar a VIEW comissoes_calculadas de forma segura
DROP VIEW IF EXISTS public.comissoes_calculadas;
CREATE VIEW public.comissoes_calculadas
WITH (security_invoker = true)
AS
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
FROM public.contas_receber cr
JOIN public.faturas_venda fv ON cr.fatura_id = fv.id
JOIN public.pedidos_venda pv ON fv.pedido_id = pv.id
JOIN public.vendedores v ON pv.vendedor_id = v.id
WHERE
  cr.status::text = 'RECEBIDO'
  AND cr.data_pagamento IS NOT NULL
  AND pv.vendedor_id IS NOT NULL;

COMMIT;
