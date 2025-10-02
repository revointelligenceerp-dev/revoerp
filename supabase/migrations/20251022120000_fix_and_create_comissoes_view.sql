/*
  # [CORREÇÃO E CRIAÇÃO DA VIEW DE COMISSÕES]
  Este script corrige a migração anterior e cria a 'comissoes_view' de forma segura.
  - Remove a tentativa de aplicar RLS em uma view.
  - Cria a view com 'security_invoker=true' para respeitar as permissões do usuário.

  ## Query Description: [Operação segura que cria uma nova 'view' (visão de dados) para calcular comissões. Não altera ou apaga dados existentes. Se a view já existir, ela será substituída pela versão correta.]
  
  ## Metadata:
  - Schema-Category: ["Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [true] (pode ser removida com DROP VIEW)
*/

CREATE OR REPLACE VIEW public.comissoes_view
WITH (security_invoker = true) AS
SELECT
    pv.id,
    pv.numero as pedido_numero,
    pv.data_venda,
    pv.valor_total as valor_venda,
    c.id as cliente_id,
    c.nome as cliente_nome,
    v.id as vendedor_id,
    v.nome as vendedor_nome,
    v.aliquota_comissao,
    -- Calcula o valor da comissão
    (pv.valor_total * (v.aliquota_comissao / 100.0)) as valor_comissao,
    -- Determina o status da comissão
    CASE
        WHEN cr.status = 'RECEBIDO' THEN 'Liberada'::text
        ELSE 'Pendente'::text
    END as status_comissao,
    cr.data_pagamento as data_liberacao
FROM
    public.pedidos_venda pv
JOIN
    public.clientes c ON pv.cliente_id = c.id
JOIN
    public.vendedores v ON pv.vendedor_id = v.id
LEFT JOIN
    -- Encontra a fatura relacionada ao pedido
    public.faturas_venda fv ON pv.id = fv.pedido_id
LEFT JOIN
    -- Encontra a conta a receber relacionada à fatura
    public.contas_receber cr ON fv.id = cr.fatura_id
WHERE
    pv.vendedor_id IS NOT NULL AND v.aliquota_comissao IS NOT NULL AND v.aliquota_comissao > 0;

-- Garante que o role anon (e outros) possam ler da view
-- As permissões nas tabelas base já foram concedidas.
GRANT SELECT ON public.comissoes_view TO anon, authenticated, service_role;
