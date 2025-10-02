/*
          # [CORREÇÃO E CRIAÇÃO DO MÓDULO DE ESTOQUE]
          Este script corrige a criação da view 'produtos_com_estoque' e garante a existência da tabela 'estoque_movimentos'.
          Ele primeiro remove a view antiga para evitar erros de recriação e depois a cria com a estrutura correta e segura.
          ## Query Description: [Esta operação é segura e não resultará em perda de dados. Ela corrige um erro de sintaxe na definição da view de estoque, garantindo que o módulo de Controle de Estoque funcione corretamente.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Tabela afetada: estoque_movimentos (criação idempotente)
          - View afetada: produtos_com_estoque (recriação)
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo. Apenas recria uma view para corrigir a estrutura.]
*/

-- PASSO 1: Garante a existência da tabela de movimentos de estoque
CREATE TABLE IF NOT EXISTS public.estoque_movimentos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL CHECK (tipo IN ('ENTRADA', 'SAIDA')),
    quantidade NUMERIC NOT NULL CHECK (quantidade >= 0),
    data TIMESTAMPTZ DEFAULT NOW(),
    origem TEXT,
    observacao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Garante que o trigger exista apenas se a tabela foi recém-criada ou se o trigger não existe
DO $$
BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM pg_trigger
      WHERE tgname = 'handle_updated_at_estoque_movimentos'
   ) THEN
      CREATE TRIGGER handle_updated_at_estoque_movimentos
      BEFORE UPDATE ON public.estoque_movimentos
      FOR EACH ROW
      EXECUTE PROCEDURE public.handle_updated_at();
   END IF;
END;
$$;


-- PASSO 2: Remove a view antiga para evitar conflitos
DROP VIEW IF EXISTS public.produtos_com_estoque;

-- PASSO 3: Recria a view com a estrutura correta e segura
CREATE VIEW public.produtos_com_estoque
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
      SELECT json_agg(json_build_object('id', pi.id, 'path', pi.path, 'nome_arquivo', pi.nome_arquivo, 'tamanho', pi.tamanho, 'tipo', pi.tipo, 'created_at', pi.created_at))
      FROM public.produto_imagens pi
      WHERE pi.produto_id = p.id
    ),
    '[]'::json
  ) AS imagens,
  (COALESCE(p.estoque_inicial, 0) + COALESCE(SUM(
    CASE
      WHEN em.tipo = 'ENTRADA' THEN em.quantidade
      WHEN em.tipo = 'SAIDA' THEN -em.quantidade
      ELSE 0
    END
  ), 0)) AS estoque_atual
FROM
  public.produtos p
LEFT JOIN
  public.estoque_movimentos em ON p.id = em.produto_id
GROUP BY
  p.id;

-- PASSO 4: Define o proprietário e as permissões da view
ALTER VIEW public.produtos_com_estoque OWNER TO postgres;
GRANT ALL ON TABLE public.produtos_com_estoque TO postgres;
GRANT SELECT ON TABLE public.produtos_com_estoque TO authenticated;
GRANT SELECT ON TABLE public.produtos_com_estoque TO service_role;
GRANT SELECT ON TABLE public.produtos_com_estoque TO anon;
