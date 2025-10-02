/*
          # Criação da Estrutura de Pedidos de Venda
          Este script cria as tabelas para gerenciar pedidos de venda e seus itens, estabelecendo a base para o módulo de vendas.

          ## Query Description: 
          - Cria um novo tipo ENUM `status_pedido_venda`.
          - Cria a tabela `pedidos_venda` para armazenar os cabeçalhos dos pedidos.
          - Cria a tabela `pedido_venda_itens` para armazenar os itens de cada pedido.
          - Adiciona chaves estrangeiras para garantir a integridade relacional com clientes, vendedores, produtos e serviços.
          - Habilita Row Level Security (RLS) e define políticas abertas para permitir operações de CRUD.
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (com a remoção manual das tabelas e tipo)
          
          ## Structure Details:
          - Tabelas criadas: `pedidos_venda`, `pedido_venda_itens`
          - Tipos criados: `status_pedido_venda`
          - Colunas afetadas: N/A (criação)
          - Chaves estrangeiras: `pedidos_venda.cliente_id`, `pedidos_venda.vendedor_id`, `pedido_venda_itens.pedido_id`, `pedido_venda_itens.produto_id`, `pedido_venda_itens.servico_id`
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (criação de políticas `public_access` para as novas tabelas)
          - Auth Requirements: N/A (políticas abertas para `public`)
          
          ## Performance Impact:
          - Indexes: Adicionados automaticamente para chaves primárias e estrangeiras.
          - Triggers: Nenhum.
          - Estimated Impact: Nenhum impacto em tabelas existentes.
          */

-- Criação do tipo para status do pedido de venda
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_pedido_venda') THEN
        CREATE TYPE status_pedido_venda AS ENUM ('ABERTO', 'FATURADO', 'CANCELADO');
    END IF;
END$$;

-- Tabela de Pedidos de Venda
CREATE TABLE IF NOT EXISTS public.pedidos_venda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero TEXT NOT NULL UNIQUE,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id),
    vendedor_id UUID REFERENCES public.vendedores(id),
    status status_pedido_venda NOT NULL DEFAULT 'ABERTO',
    data_emissao TIMESTAMPTZ NOT NULL DEFAULT now(),
    valor_total NUMERIC(10, 2) NOT NULL DEFAULT 0,
    observacoes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Tabela de Itens do Pedido de Venda
CREATE TABLE IF NOT EXISTS public.pedido_venda_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES public.produtos(id),
    servico_id UUID REFERENCES public.servicos(id),
    descricao TEXT NOT NULL,
    quantidade NUMERIC(10, 2) NOT NULL,
    valor_unitario NUMERIC(10, 2) NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_item_type CHECK (produto_id IS NOT NULL OR servico_id IS NOT NULL)
);

-- Habilitar Row Level Security
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;

-- Políticas de Acesso (Abertas por enquanto)
DROP POLICY IF EXISTS public_access ON public.pedidos_venda;
CREATE POLICY public_access ON public.pedidos_venda FOR ALL
TO public
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS public_access ON public.pedido_venda_itens;
CREATE POLICY public_access ON public.pedido_venda_itens FOR ALL
TO public
USING (true)
WITH CHECK (true);
