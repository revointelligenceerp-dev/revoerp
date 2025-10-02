/*
  # [Fix] Corrige a função get_visao_cobrancas
  [Altera a função para converter o dia do vencimento para inteiro e garantir que o dia seja válido para o mês, resolvendo o erro de tipo de dado na função make_date.]

  ## Query Description: [Esta operação substitui a função existente 'get_visao_cobrancas' por uma versão corrigida. A mudança é segura e não afeta os dados existentes, apenas corrige um bug na lógica da função.]
  
  ## Metadata:
  - Schema-Category: ["Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
  
  ## Structure Details:
  [Função: public.get_visao_cobrancas]
  
  ## Security Implications:
  - RLS Status: [N/A]
  - Policy Changes: [No]
  - Auth Requirements: [N/A]
  
  ## Performance Impact:
  - Indexes: [N/A]
  - Triggers: [N/A]
  - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
CREATE OR REPLACE FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer)
RETURNS TABLE(cliente_id uuid, cliente_nome text, cliente_telefone text, valor_total numeric, contratos_count bigint, data_vencimento date, status_integracao text)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.cliente_id,
    cl.nome AS cliente_nome,
    cl.celular AS cliente_telefone,
    SUM(c.valor) AS valor_total,
    COUNT(c.id) AS contratos_count,
    -- Garante que o dia do vencimento não ultrapasse o último dia do mês
    make_date(p_ano, p_mes, LEAST(c.dia_vencimento, date_part('day', (date_trunc('month', make_date(p_ano, p_mes, 1)) + interval '1 month - 1 day')::date))::integer) AS data_vencimento,
    'pendente'::text AS status_integracao
  FROM
    contratos c
  JOIN
    clientes cl ON c.cliente_id = cl.id
  WHERE
    c.situacao = 'Ativo'
  GROUP BY
    c.cliente_id, cl.nome, cl.celular, c.dia_vencimento;
END;
$$;
