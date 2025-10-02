-- Adiciona a coluna de comissão na tabela de vendedores, se não existir
ALTER TABLE public.vendedores
ADD COLUMN IF NOT EXISTS percentual_comissao NUMERIC(5, 2) NOT NULL DEFAULT 5.00;

-- Cria a VIEW para calcular as comissões
CREATE OR REPLACE VIEW public.comissoes_calculadas AS
SELECT
  cr.id,
  v.id AS vendedor_id,
  v.nome AS vendedor_nome,
  pv.id AS pedido_id,
  pv.numero AS pedido_numero,
  pv.valor_total AS valor_pedido,
  v.percentual_comissao,
  (pv.valor_total * (v.percentual_comissao / 100.0)) AS valor_comissao,
  cr.data_pagamento AS data_pagamento_fatura
FROM
  contas_receber cr
JOIN
  faturas_venda fv ON cr.fatura_id = fv.id
JOIN
  pedidos_venda pv ON fv.pedido_id = pv.id
JOIN
  vendedores v ON pv.vendedor_id = v.id
WHERE
  cr.status = 'RECEBIDO'::public.status_conta_receber
  AND pv.vendedor_id IS NOT NULL;
