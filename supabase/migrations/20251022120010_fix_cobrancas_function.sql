/*
          # [Fix] Corrige a função de visualização de cobranças
          [Este script substitui a função get_visao_cobrancas por uma versão corrigida que lida corretamente com os tipos de dados de data, prevenindo o erro "function make_date does not exist". Também melhora a segurança ao definir explicitamente o search_path.]

          ## Query Description: [Esta operação substitui uma função existente no banco de dados. É uma operação segura que não afeta os dados armazenados, apenas a lógica de como eles são consultados. Nenhum dado será perdido ou alterado.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          
          ## Structure Details:
          [Afeta a função: public.get_visao_cobrancas]
          
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Melhora a performance e a estabilidade da consulta de cobranças, evitando erros de execução.]
          */
CREATE OR REPLACE FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer)
 RETURNS TABLE(cliente_id uuid, cliente_nome text, cliente_telefone text, valor_total numeric, contratos_count bigint, data_vencimento date, status_integracao text)
 LANGUAGE plpgsql
AS $function$
BEGIN
    SET search_path = public;
    RETURN QUERY
    SELECT
        cr.cliente_id,
        cl.nome AS cliente_nome,
        cl.celular AS cliente_telefone,
        SUM(cr.valor) AS valor_total,
        COUNT(cr.id) AS contratos_count,
        MIN(cr.data_vencimento) AS data_vencimento,
        'pendente'::text AS status_integracao
    FROM
        contas_receber cr
    JOIN
        clientes cl ON cr.cliente_id = cl.id
    WHERE
        EXTRACT(YEAR FROM cr.data_vencimento) = p_ano
        AND EXTRACT(MONTH FROM cr.data_vencimento) = p_mes
        AND cr.contrato_id IS NOT NULL
    GROUP BY
        cr.cliente_id, cl.nome, cl.celular;
END;
$function$;
