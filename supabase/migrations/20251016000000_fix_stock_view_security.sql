/*
          # [CORREÇÃO DE SEGURANÇA NA VIEW DE ESTOQUE]
          Este script corrige uma vulnerabilidade de segurança na view `produtos_com_estoque`.
          Ele altera a definição da view de `SECURITY DEFINER` para `SECURITY INVOKER`, garantindo que as políticas de segurança a nível de linha (RLS) do usuário que faz a consulta sejam sempre respeitadas.

          ## Query Description: [Esta operação corrige uma falha de segurança crítica na visualização de dados de estoque. A alteração é segura, não afeta os dados existentes e garante que as regras de permissão do seu banco de dados sejam aplicadas corretamente, protegendo suas informações.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - View afetada: `produtos_com_estoque`
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
-- Recria a view com SECURITY INVOKER para corrigir a falha de segurança
CREATE OR REPLACE VIEW public.produtos_com_estoque
WITH (security_invoker = true) AS
SELECT
  p.id,
  p.nome,
  p.codigo,
  p.unidade,
  p.controlar_estoque,
  p.estoque_minimo,
  p.estoque_maximo,
  p.situacao,
  COALESCE(
    (
      SELECT SUM(
        CASE
          WHEN m.tipo = 'ENTRADA' THEN m.quantidade
          ELSE -m.quantidade
        END
      )
      FROM public.estoque_movimentos m
      WHERE m.produto_id = p.id
    ), 0
  ) AS estoque_atual,
  (
    SELECT json_agg(json_build_object('id', pi.id, 'path', pi.path, 'nome_arquivo', pi.nome_arquivo))
    FROM public.produto_imagens pi
    WHERE pi.produto_id = p.id
  ) AS imagens
FROM
  public.produtos p
WHERE
  p.situacao = 'Ativo';
