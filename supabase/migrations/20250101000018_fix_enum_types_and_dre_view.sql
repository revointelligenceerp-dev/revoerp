-- Migration Script to fix missing ENUM types and update DRE view

/*
  # [Fix] Correção de Tipos de Status e Visão DRE
  [Este script corrige um erro de migração ao criar os tipos ENUM para os status de contas a pagar/receber,
  atualiza as tabelas existentes para usar esses novos tipos e recria a visão 'dre_mensal' de forma segura e correta.]

  ## Query Description: [Esta operação é estrutural e segura. Ela garante que os dados de status sejam consistentes e melhora a integridade do banco de dados. A visão de relatório DRE é recriada para usar os tipos corretos, resolvendo o erro de migração.]
  
  ## Metadata:
  - Schema-Category: ["Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
  
  ## Structure Details:
  - Creates ENUM types: status_conta_receber, status_conta_pagar.
  - Alters tables: contas_receber, contas_pagar (column 'status').
  - Recreates view: dre_mensal.
  
  ## Security Implications:
  - RLS Status: [Not Changed]
  - Policy Changes: [No]
  - Auth Requirements: [None]
  
  ## Performance Impact:
  - Indexes: [Not Changed]
  - Triggers: [Not Changed]
  - Estimated Impact: [Baixo. A alteração de tipo pode levar um momento em tabelas muito grandes, mas é esperado que seja rápido.]
*/

-- 1. Criar o tipo ENUM para status de contas a receber, se não existir
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
    CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
  END IF;
END$$;

-- 2. Criar o tipo ENUM para status de contas a pagar, se não existir
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
    CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
  END IF;
END$$;

-- 3. Alterar a coluna 'status' em 'contas_receber' para usar o novo tipo
DO $$
DECLARE
    col_type text;
BEGIN
    SELECT data_type INTO col_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'contas_receber'
    AND column_name = 'status';

    IF col_type = 'text' OR col_type = 'character varying' THEN
        ALTER TABLE public.contas_receber
        ALTER COLUMN status TYPE public.status_conta_receber
        USING status::text::public.status_conta_receber;
    END IF;
END $$;

-- 4. Alterar a coluna 'status' em 'contas_pagar' para usar o novo tipo
DO $$
DECLARE
    col_type text;
BEGIN
    SELECT data_type INTO col_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'contas_pagar'
    AND column_name = 'status';

    IF col_type = 'text' OR col_type = 'character varying' THEN
        ALTER TABLE public.contas_pagar
        ALTER COLUMN status TYPE public.status_conta_pagar
        USING status::text::public.status_conta_pagar;
    END IF;
END $$;


-- 5. Recriar a VIEW 'dre_mensal' de forma segura e correta
CREATE OR REPLACE VIEW public.dre_mensal
WITH (security_invoker = true)
AS
SELECT
  EXTRACT(YEAR FROM data_movimento)::integer AS ano,
  EXTRACT(MONTH FROM data_movimento)::integer AS mes,
  to_char(data_movimento, 'TMMonth') AS mes_nome,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE 0 END) AS receita,
  SUM(CASE WHEN tipo = 'SAIDA' THEN valor ELSE 0 END) AS despesa,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE -valor END) AS resultado
FROM (
  -- Seleciona as contas a receber liquidadas
  SELECT
    cr.data_pagamento AS data_movimento,
    'ENTRADA'::public.tipo_movimento_caixa AS tipo,
    cr.valor
  FROM
    public.contas_receber cr
  WHERE
    cr.status = 'RECEBIDO' AND cr.data_pagamento IS NOT NULL
  
  UNION ALL
  
  -- Seleciona as contas a pagar liquidadas
  SELECT
    cp.data_pagamento AS data_movimento,
    'SAIDA'::public.tipo_movimento_caixa AS tipo,
    cp.valor
  FROM
    public.contas_pagar cp
  WHERE
    cp.status = 'PAGO' AND cp.data_pagamento IS NOT NULL
) AS movimentacoes_financeiras
GROUP BY
  ano,
  mes,
  mes_nome
ORDER BY
  ano,
  mes;
