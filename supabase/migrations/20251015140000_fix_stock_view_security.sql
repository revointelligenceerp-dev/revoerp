/*
          # [Correção de Segurança da View de Estoque]
          Altera a view 'produtos_com_estoque' para usar SECURITY INVOKER em vez de SECURITY DEFINER.
          Isso resolve uma vulnerabilidade crítica, garantindo que a view respeite as políticas de segurança a nível de linha (RLS) do usuário que a consulta.

          ## Query Description: [Esta operação corrige uma falha de segurança na forma como os dados de estoque são visualizados, sem alterar nenhum dado. A mudança garante que as regras de permissão sejam sempre aplicadas corretamente.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - View: public.produtos_com_estoque
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [A view passará a respeitar as políticas de RLS existentes.]
          
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- Remove a view antiga se ela existir
DROP VIEW IF EXISTS public.produtos_com_estoque;

-- Recria a view com a propriedade de segurança correta (security_invoker = true)
CREATE OR REPLACE VIEW public.produtos_com_estoque
WITH (security_invoker = true) AS
SELECT
  p.id,
  p.nome,
  p.codigo,
  p.unidade,
  p.situacao,
  p.controlar_estoque,
  p.estoque_minimo,
  p.estoque_maximo,
  p.imagens,
  COALESCE(
    (
      SELECT SUM(
        CASE
          WHEN sm.tipo = 'ENTRADA' THEN sm.quantidade
          WHEN sm.tipo = 'SAIDA' THEN -sm.quantidade
          ELSE 0
        END
      )
      FROM public.estoque_movimentos sm
      WHERE sm.produto_id = p.id
    ), 0
  ) + COALESCE(p.estoque_inicial, 0) AS estoque_atual
FROM
  public.produtos p;
