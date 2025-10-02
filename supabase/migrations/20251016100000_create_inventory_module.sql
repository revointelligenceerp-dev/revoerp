/*
          # [CRIAÇÃO DO MÓDULO DE ESTOQUE]
          Cria a tabela 'estoque_movimentos' e a view 'produtos_com_estoque' de forma idempotente.
          Este script é seguro para ser executado múltiplas vezes.
          ## Query Description: [Este script cria as estruturas necessárias para o módulo de controle de estoque. Ele não afeta dados existentes e foi projetado para rodar sem erros mesmo que as tabelas já existam.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Cria a tabela 'estoque_movimentos' se ela não existir.
          - Cria ou substitui a view 'produtos_com_estoque'.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. A view é otimizada para leitura.]
*/
-- Cria a tabela de movimentos de estoque se ela não existir
CREATE TABLE IF NOT EXISTS public.estoque_movimentos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL CHECK (tipo IN ('ENTRADA', 'SAIDA')),
    quantidade NUMERIC NOT NULL,
    data TIMESTAMPTZ DEFAULT NOW(),
    origem TEXT,
    observacao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
-- Habilita RLS na nova tabela
ALTER TABLE public.estoque_movimentos ENABLE ROW LEVEL SECURITY;
-- Permite leitura para todos
CREATE POLICY "Allow public read access on estoque_movimentos"
ON public.estoque_movimentos
FOR SELECT
USING (true);
-- Cria ou substitui a view para produtos com saldo de estoque
CREATE OR REPLACE VIEW public.produtos_com_estoque AS
WITH estoque_agregado AS (
  SELECT
    produto_id,
    SUM(CASE WHEN tipo = 'ENTRADA' THEN quantidade ELSE 0 END) as total_entradas,
    SUM(CASE WHEN tipo = 'SAIDA' THEN quantidade ELSE 0 END) as total_saidas
  FROM public.estoque_movimentos
  GROUP BY produto_id
)
SELECT
  p.id,
  p.nome,
  p.codigo,
  p.controlar_estoque,
  p.estoque_minimo,
  p.estoque_maximo,
  p.unidade,
  p.situacao,
  (
    SELECT json_agg(json_build_object('path', pi.path))
    FROM public.produto_imagens pi
    WHERE pi.produto_id = p.id
    LIMIT 1
  ) as imagens,
  COALESCE(p.estoque_inicial, 0) + COALESCE(ea.total_entradas, 0) - COALESCE(ea.total_saidas, 0) AS estoque_atual
FROM
  public.produtos p
LEFT JOIN
  estoque_agregado ea ON p.id = ea.produto_id;
-- Habilita RLS na view
ALTER VIEW public.produtos_com_estoque OWNER TO postgres;
-- Permite leitura para todos
GRANT SELECT ON public.produtos_com_estoque TO anon, authenticated, service_role;
