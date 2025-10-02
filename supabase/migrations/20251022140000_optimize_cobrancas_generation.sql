/*
  # [Otimização de Geração de Cobranças]
  Cria uma função no banco de dados (RPC) para buscar de forma eficiente apenas os contratos que precisam ser faturados em uma determinada competência, evitando a sobrecarga de buscar e processar todos os contratos na aplicação.

  ## Query Description: [Cria a função `get_contratos_para_faturar` que seleciona contratos ativos que ainda não possuem uma conta a receber para o mês e ano especificados. Isso move a lógica de filtragem para o banco de dados, melhorando drasticamente a performance.]
  
  ## Metadata:
  - Schema-Category: ["Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [true]
  
  ## Structure Details:
  - Cria a função: `public.get_contratos_para_faturar(p_ano INT, p_mes INT)`
  
  ## Security Implications:
  - RLS Status: [N/A]
  - Policy Changes: [No]
  - Auth Requirements: [authenticated]
  
  ## Performance Impact:
  - Indexes: [N/A]
  - Triggers: [N/A]
  - Estimated Impact: [Alto. Reduz drasticamente a quantidade de dados transferidos e o processamento no lado do cliente ao gerar cobranças.]
*/

CREATE OR REPLACE FUNCTION get_contratos_para_faturar(p_ano INT, p_mes INT)
RETURNS SETOF contratos AS $$
BEGIN
  RETURN QUERY
  SELECT c.*
  FROM contratos c
  WHERE c.situacao = 'Ativo'
    AND NOT EXISTS (
      SELECT 1
      FROM contas_receber cr
      WHERE cr.contrato_id = c.id
        AND EXTRACT(YEAR FROM cr.data_vencimento) = p_ano
        AND EXTRACT(MONTH FROM cr.data_vencimento) = p_mes
    );
END;
$$ LANGUAGE plpgsql;
