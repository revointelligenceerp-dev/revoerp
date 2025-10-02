/*
          # [Criação do Módulo de Controle de Estoque]
          Cria a tabela `estoque_movimentos` para rastrear todas as movimentações e uma `view` otimizada para calcular o saldo atual dos produtos.

          ## Query Description: [Esta operação adiciona novas tabelas e uma view para gerenciar o estoque. É uma operação segura e não afeta os dados existentes. As novas estruturas são essenciais para o funcionamento do módulo de Controle de Estoque.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
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
          - Estimated Impact: [Baixo. A view otimiza a consulta de saldos de estoque.]
*/

-- Tabela para registrar todas as movimentações de estoque
CREATE TABLE public.estoque_movimentos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL, -- 'ENTRADA' ou 'SAIDA'
    quantidade NUMERIC NOT NULL,
    data TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    origem TEXT, -- Ex: 'Venda PV-123', 'Compra OC-456', 'Ajuste Manual'
    observacao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilita RLS e cria política de leitura
ALTER TABLE public.estoque_movimentos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow read access to all" ON public.estoque_movimentos FOR SELECT USING (true);
CREATE INDEX idx_estoque_movimentos_produto_id ON public.estoque_movimentos(produto_id);

-- View para calcular o estoque atual de forma eficiente
CREATE OR REPLACE VIEW public.produtos_com_estoque AS
SELECT
  p.id,
  p.nome,
  p.codigo,
  p.controlar_estoque,
  p.estoque_minimo,
  p.estoque_maximo,
  p.unidade,
  p.situacao,
  p.imagens,
  (
    p.estoque_inicial +
    COALESCE((SELECT SUM(em.quantidade) FROM public.estoque_movimentos em WHERE em.produto_id = p.id AND em.tipo = 'ENTRADA'), 0) -
    COALESCE((SELECT SUM(em.quantidade) FROM public.estoque_movimentos em WHERE em.produto_id = p.id AND em.tipo = 'SAIDA'), 0)
  ) AS estoque_atual
FROM
  public.produtos p;

-- Garante permissões na nova view
GRANT SELECT ON public.produtos_com_estoque TO anon, authenticated;
