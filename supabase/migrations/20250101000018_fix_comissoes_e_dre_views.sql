-- Garante que a coluna de comissão exista antes de criar a view
ALTER TABLE public.vendedores
ADD COLUMN IF NOT EXISTS percentual_comissao numeric(5, 2) NOT NULL DEFAULT 5.0;

-- Garante que os tipos ENUM para status existam
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
    CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
    CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
  END IF;
END$$;

-- Altera as colunas de status para usar os tipos ENUM, se ainda não estiverem usando
DO $$
BEGIN
  IF (SELECT data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'contas_receber' AND column_name = 'status') <> 'user-defined' THEN
    ALTER TABLE public.contas_receber
    ALTER COLUMN status TYPE public.status_conta_receber USING status::public.status_conta_receber;
  END IF;
  IF (SELECT data_type FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'contas_pagar' AND column_name = 'status') <> 'user-defined' THEN
    ALTER TABLE public.contas_pagar
    ALTER COLUMN status TYPE public.status_conta_pagar USING status::public.status_conta_pagar;
  END IF;
END$$;

-- Remove as views antigas para garantir que a recriação funcione
DROP VIEW IF EXISTS public.comissoes_calculadas;
DROP VIEW IF EXISTS public.dre_mensal;

-- Recria a view DRE Mensal com a sintaxe correta e segura
CREATE OR REPLACE VIEW public.dre_mensal
WITH (security_invoker = true)
AS
SELECT
  EXTRACT(YEAR FROM f.data)::integer AS ano,
  EXTRACT(MONTH FROM f.data)::integer AS mes,
  to_char(f.data, 'TMMonth') AS mes_nome,
  sum(CASE WHEN f.tipo = 'ENTRADA' THEN f.valor ELSE 0 END) AS receita,
  sum(CASE WHEN f.tipo = 'SAIDA' THEN f.valor ELSE 0 END) AS despesa,
  sum(CASE WHEN f.tipo = 'ENTRADA' THEN f.valor ELSE -f.valor END) AS resultado
FROM
  fluxo_caixa f
GROUP BY
  ano, mes, mes_nome;

-- Recria a view de Comissões com a sintaxe correta e segura
CREATE OR REPLACE VIEW public.comissoes_calculadas
WITH (security_invoker = true)
AS
SELECT
  cr.id,
  pv.vendedor_id AS "vendedorId",
  v.nome AS "vendedorNome",
  fv.pedido_id AS "pedidoId",
  pv.numero AS "pedidoNumero",
  pv.valor_total AS "valorPedido",
  v.percentual_comissao AS "percentualComissao",
  (pv.valor_total * v.percentual_comissao / 100.0) AS "valorComissao",
  cr.data_pagamento AS "dataPagamentoFatura"
FROM
  contas_receber cr
JOIN
  faturas_venda fv ON cr.fatura_id = fv.id
JOIN
  pedidos_venda pv ON fv.pedido_id = pv.id
JOIN
  vendedores v ON pv.vendedor_id = v.id
WHERE
  cr.status = 'RECEBIDO'::public.status_conta_receber;
