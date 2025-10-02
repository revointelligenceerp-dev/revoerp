/*
          # [CORREÇÃO DE SEGURANÇA NA VIEW DE ESTOQUE]
          Recria a view 'produtos_com_estoque' com 'security_invoker=true' para resolver a vulnerabilidade crítica de 'Security Definer View'.
          Isso garante que as políticas de segurança (RLS) sejam sempre aplicadas ao consultar os dados de estoque.

          ## Query Description: [Esta operação corrige uma falha de segurança crítica, garantindo que as permissões de acesso aos dados de estoque sejam respeitadas. A operação é segura e não afeta os dados existentes.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
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

-- Remove a view antiga se ela existir
DROP VIEW IF EXISTS public.produtos_com_estoque;

-- Recria a view com a configuração de segurança correta (SECURITY INVOKER)
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
  COALESCE(em.estoque_atual, 0) AS estoque_atual,
  COALESCE(pi.imagens, '[]'::jsonb) AS imagens
FROM
  public.produtos p
LEFT JOIN (
  SELECT
    produto_id,
    SUM(CASE WHEN tipo = 'ENTRADA' THEN quantidade ELSE -quantidade END) AS estoque_atual
  FROM
    public.estoque_movimentos
  GROUP BY
    produto_id
) em ON p.id = em.produto_id
LEFT JOIN (
  SELECT
    produto_id,
    jsonb_agg(jsonb_build_object(
      'id', id,
      'path', path,
      'nome_arquivo', nome_arquivo,
      'tamanho', tamanho,
      'tipo', tipo,
      'created_at', created_at,
      'updated_at', updated_at
    ) ORDER BY created_at) AS imagens
  FROM
    public.produto_imagens
  GROUP BY
    produto_id
) pi ON p.id = pi.produto_id;

-- Garante que o usuário anônimo (anon) e autenticado (authenticated) possam ler da view
GRANT SELECT ON public.produtos_com_estoque TO anon;
GRANT SELECT ON public.produtos_com_estoque TO authenticated;
