/*
          # [CORREÇÃO E CRIAÇÃO DO MÓDULO DE ESTOQUE]
          Este script corrige a criação da view 'produtos_com_estoque' e garante que o módulo de estoque seja criado corretamente.
          ## Query Description: [Esta operação cria as tabelas e visões necessárias para o módulo de Controle de Estoque. A criação é idempotente, ou seja, só criará os objetos se eles não existirem, evitando erros em execuções repetidas. A 'view' de produtos com estoque é recriada para corrigir um erro de coluna e uma falha de segurança.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          ## Structure Details:
          - Tabela: estoque_movimentos
          - View: produtos_com_estoque
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. Adiciona uma tabela e uma view para novas funcionalidades.]
*/

-- Cria a tabela para movimentações de estoque, se ela não existir.
CREATE TABLE IF NOT EXISTS public.estoque_movimentos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL CHECK (tipo IN ('ENTRADA', 'SAIDA')),
    quantidade NUMERIC NOT NULL CHECK (quantidade > 0),
    data TIMESTAMPTZ DEFAULT NOW(),
    origem TEXT,
    observacao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cria um índice para otimizar a busca por produto.
CREATE INDEX IF NOT EXISTS idx_estoque_movimentos_produto_id ON public.estoque_movimentos(produto_id);

-- Recria a view para calcular o estoque atual, corrigindo o erro da coluna 'imagens' e a falha de segurança.
CREATE OR REPLACE VIEW public.produtos_com_estoque
WITH (security_invoker = true)
AS
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
    SELECT json_agg(pi.*)
    FROM public.produto_imagens pi
    WHERE pi.produto_id = p.id
  ) AS imagens,
  COALESCE(SUM(
    CASE
      WHEN sm.tipo = 'ENTRADA' THEN sm.quantidade
      WHEN sm.tipo = 'SAIDA' THEN -sm.quantidade
      ELSE 0
    END
  ), 0) + COALESCE(p.estoque_inicial, 0) AS estoque_atual
FROM
  public.produtos p
LEFT JOIN
  public.estoque_movimentos sm ON p.id = sm.produto_id
GROUP BY
  p.id;

-- Habilita RLS na nova tabela e cria política de leitura
ALTER TABLE public.estoque_movimentos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Permite leitura para todos" ON public.estoque_movimentos;
CREATE POLICY "Permite leitura para todos" ON public.estoque_movimentos FOR SELECT USING (true);

-- Garante que a view também tenha permissão de leitura
GRANT SELECT ON public.produtos_com_estoque TO anon, authenticated;
