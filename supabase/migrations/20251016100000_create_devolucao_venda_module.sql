/*
          # [CRIAÇÃO DO MÓDULO DE DEVOLUÇÃO DE VENDA]
          Este script cria as tabelas e tipos necessários para o módulo de devolução de vendas.
          
          ## Query Description: [Esta operação adiciona novas tabelas ('devolucoes_venda', 'devolucao_venda_itens') e um novo tipo ('status_devolucao') ao banco de dados. É uma operação segura que não afeta dados existentes e é essencial para a nova funcionalidade.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabelas: public.devolucoes_venda, public.devolucao_venda_itens
          - Tipos: public.status_devolucao
          - Relacionamentos: Chaves estrangeiras para 'pedidos_venda', 'clientes', 'produtos'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. Apenas adiciona novas estruturas.]
*/

-- PASSO 1: CRIAÇÃO DO TIPO (ENUM)
CREATE TYPE public.status_devolucao AS ENUM ('PROCESSANDO', 'FINALIZADA', 'CANCELADA');

-- PASSO 2: CRIAÇÃO DA TABELA PRINCIPAL DE DEVOLUÇÕES
CREATE TABLE IF NOT EXISTS public.devolucoes_venda (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    numero TEXT NOT NULL UNIQUE,
    pedido_venda_id UUID NOT NULL REFERENCES public.pedidos_venda(id),
    cliente_id UUID NOT NULL REFERENCES public.clientes(id),
    data_devolucao DATE NOT NULL DEFAULT CURRENT_DATE,
    valor_total_devolvido NUMERIC NOT NULL,
    observacoes TEXT,
    status public.status_devolucao NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 3: CRIAÇÃO DA TABELA DE ITENS DA DEVOLUÇÃO
CREATE TABLE IF NOT EXISTS public.devolucao_venda_itens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    devolucao_id UUID NOT NULL REFERENCES public.devolucoes_venda(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES public.produtos(id),
    servico_id UUID REFERENCES public.servicos(id),
    descricao TEXT NOT NULL,
    quantidade_devolvida NUMERIC NOT NULL,
    valor_unitario NUMERIC NOT NULL,
    valor_total NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 4: TRIGGERS E POLÍTICAS DE SEGURANÇA
-- Trigger para auto-atualizar 'updated_at'
CREATE TRIGGER handle_devolucoes_venda_updated_at
BEFORE UPDATE ON public.devolucoes_venda
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_devolucao_venda_itens_updated_at
BEFORE UPDATE ON public.devolucao_venda_itens
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Habilitar RLS e criar políticas
ALTER TABLE public.devolucoes_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.devolucao_venda_itens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to devolucoes_venda" ON public.devolucoes_venda FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage devolucoes_venda" ON public.devolucoes_venda FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow public read access to devolucao_venda_itens" ON public.devolucao_venda_itens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to manage devolucao_venda_itens" ON public.devolucao_venda_itens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- PASSO 5: ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_devolucoes_venda_pedido_id ON public.devolucoes_venda(pedido_venda_id);
CREATE INDEX IF NOT EXISTS idx_devolucao_venda_itens_devolucao_id ON public.devolucao_venda_itens(devolucao_id);
