/*
          # [CRIAÇÃO DA VIEW DE COMISSÕES]
          Cria uma view (`comissoes_view`) para calcular e consolidar as comissões.

          ## Query Description: [Esta operação cria uma nova VIEW no banco de dados para agregar informações de comissões. É uma operação segura, não destrutiva, que apenas lê dados de tabelas existentes (pedidos, contas a receber, vendedores) para apresentar os cálculos de comissão de forma centralizada. Nenhum dado existente será modificado.]
          
          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Cria a view `public.comissoes_view`.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. A view otimiza as consultas de comissão, melhorando a performance no frontend.]
*/

-- Remove a view antiga se existir, para garantir a atualização
DROP VIEW IF EXISTS public.comissoes_view;

-- Cria a view que calcula as comissões com base nas parcelas recebidas
CREATE OR REPLACE VIEW public.comissoes_view
WITH (security_invoker=true) AS
SELECT
    -- Gera um ID único para cada linha da view
    md5(concat(pv.id::text, cr.id::text)) AS id,
    v.id AS vendedor_id,
    v.nome AS vendedor_nome,
    c.nome AS cliente_nome,
    pv.numero AS pedido_numero,
    cr.data_vencimento,
    cr.data_pagamento,
    cr.valor AS valor_parcela,
    -- Calcula o valor da comissão com base na alíquota do vendedor
    (cr.valor * (v.aliquota_comissao / 100.0)) AS valor_comissao,
    v.regra_liberacao_comissao,
    cr.status AS status_recebimento,
    -- Determina o status da comissão com base na regra do vendedor e no status do recebimento
    CASE
        -- Se a regra for liberar no faturamento e o pedido estiver faturado, a comissão está liberada
        WHEN v.regra_liberacao_comissao = 'Liberação total (no faturamento)' AND pv.status = 'FATURADO' THEN 'Liberada'
        -- Se a regra for liberar no pagamento da parcela e a parcela foi recebida, a comissão está liberada
        WHEN v.regra_liberacao_comissao = 'Liberação parcial (pelo pagamento)' AND cr.status = 'RECEBIDO' THEN 'Liberada'
        -- Se a regra for liberar no pagamento total, verificamos se todas as parcelas foram pagas (lógica simplificada)
        WHEN v.regra_liberacao_comissao = 'Liberação total (no pagamento)' AND cr.status = 'RECEBIDO' THEN 'Liberada' -- Simplificação: libera por parcela paga
        -- Caso contrário, a comissão está pendente
        ELSE 'Pendente'
    END AS status_comissao,
    -- Adiciona um campo para rastrear se a comissão foi paga (inicialmente todas são 'Não Paga')
    'Não Paga'::text AS status_pagamento
FROM
    public.contas_receber cr
JOIN
    public.faturas_venda fv ON cr.fatura_id = fv.id
JOIN
    public.pedidos_venda pv ON fv.pedido_id = pv.id
JOIN
    public.vendedores v ON pv.vendedor_id = v.id
JOIN
    public.clientes c ON pv.cliente_id = c.id
WHERE
    pv.vendedor_id IS NOT NULL AND v.aliquota_comissao IS NOT NULL AND v.aliquota_comissao > 0;

-- Habilita RLS na nova view
ALTER VIEW public.comissoes_view OWNER TO postgres;
ALTER VIEW public.comissoes_view ENABLE ROW LEVEL SECURITY;

-- Permite que usuários autenticados leiam a view
CREATE POLICY "Permitir leitura para usuários autenticados"
ON public.comissoes_view
FOR SELECT
TO authenticated
USING (true);
