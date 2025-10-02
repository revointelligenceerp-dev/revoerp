/*
          # [CORREÇÃO DE SEGURANÇA NA VIEW DE ESTOQUE]
          Recria a view 'produtos_com_estoque' com 'security_invoker=true' para corrigir uma vulnerabilidade crítica.
          Isso garante que as políticas de segurança a nível de linha (RLS) sejam sempre respeitadas.
          ## Query Description: [Esta operação corrige uma falha de segurança na forma como os dados de estoque são visualizados, garantindo que as permissões de acesso sejam sempre aplicadas corretamente. Não há risco de perda de dados.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - View: public.produtos_com_estoque
          ## Security Implications:
          - RLS Status: [Enforced]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

DROP VIEW IF EXISTS public.produtos_com_estoque;

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
  (
    SELECT json_agg(json_build_object('id', pi.id, 'path', pi.path, 'nomeArquivo', pi.nome_arquivo))
    FROM public.produto_imagens pi
    WHERE pi.produto_id = p.id
  ) AS imagens,
  COALESCE(
    (
      SELECT SUM(
        CASE
          WHEN em.tipo = 'ENTRADA' THEN em.quantidade
          WHEN em.tipo = 'SAIDA' THEN -em.quantidade
          ELSE 0
        END
      )
      FROM public.estoque_movimentos em
      WHERE em.produto_id = p.id
    ), 0
  ) + COALESCE(p.estoque_inicial, 0) AS estoque_atual
FROM
  public.produtos p;
