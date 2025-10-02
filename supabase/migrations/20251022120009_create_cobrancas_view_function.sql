/*
  # [Otimização da Visualização de Cobranças]
  Cria uma função `get_visao_cobrancas` que busca e agrupa os dados para a tela de cobranças de forma performática.
  Isso evita que o frontend precise buscar todos os contratos e fazer os cálculos, transferindo a carga para o banco de dados, que é muito mais eficiente.

  ## Query Description: [Cria uma função SQL que retorna uma visão agregada dos contratos ativos para um determinado mês e ano, calculando o valor total e a contagem de contratos por cliente. Isso melhora drasticamente a performance da tela de cobranças.]
  
  ## Metadata:
  - Schema-Category: ["Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [true]
  
  ## Structure Details:
  - Cria a função `get_visao_cobrancas(p_ano INT, p_mes INT)`.
  
  ## Security Implications:
  - RLS Status: [N/A - a função usa a segurança do usuário que a chama]
  - Policy Changes: [No]
  - Auth Requirements: [authenticated]
  - Adiciona `SET search_path = public` para mitigar o aviso de segurança "Function Search Path Mutable".
  
  ## Performance Impact:
  - Indexes: [N/A]
  - Triggers: [N/A]
  - Estimated Impact: [Alto impacto positivo na performance da tela de Cobranças.]
*/

CREATE OR REPLACE FUNCTION get_visao_cobrancas(p_ano INT, p_mes INT)
RETURNS TABLE(
    cliente_id UUID,
    cliente_nome TEXT,
    cliente_telefone TEXT,
    valor_total NUMERIC,
    contratos_count BIGINT,
    data_vencimento DATE,
    status_integracao TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id AS cliente_id,
        c.nome AS cliente_nome,
        c.celular AS cliente_telefone,
        SUM(ct.valor) AS valor_total,
        COUNT(ct.id) AS contratos_count,
        (make_date(p_ano, p_mes, LEAST(ct.dia_vencimento, extract(day from (date_trunc('MONTH', make_date(p_ano, p_mes, 1)) + interval '1 MONTH - 1 day')::date)) ))::date AS data_vencimento,
        'pendente'::text as status_integracao -- Placeholder
    FROM
        contratos ct
    JOIN
        clientes c ON ct.cliente_id = c.id
    WHERE
        ct.situacao = 'Ativo'
    GROUP BY
        c.id, c.nome, c.celular, ct.dia_vencimento;
END;
$$ LANGUAGE plpgsql;

-- Corrige o aviso de segurança sobre o search_path
ALTER FUNCTION get_visao_cobrancas(p_ano INT, p_mes INT) SET search_path = public;
