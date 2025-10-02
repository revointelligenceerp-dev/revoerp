/*
          # [Refatoração Pedidos de Venda]
          Atualiza a estrutura das tabelas de pedidos de venda para suportar um formulário mais detalhado.

          ## Query Description: [Esta operação adicionará novas colunas às tabelas 'pedidos_venda' e 'pedido_venda_itens', e criará uma nova tabela 'pedido_venda_anexos'. As alterações são estruturais e não devem causar perda de dados existentes, pois apenas adicionam campos. É seguro de aplicar.]
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Tabela 'pedidos_venda': Adição de colunas para detalhes de operação, frete, pagamento, etc.
          - Tabela 'pedido_venda_itens': Adição de colunas para código, unidade e desconto.
          - Nova Tabela: 'pedido_venda_anexos' para gerenciar anexos.
          
          ## Security Implications:
          - RLS Status: Habilitado para a nova tabela 'pedido_venda_anexos'.
          - Policy Changes: Sim, adiciona políticas de acesso para a nova tabela.
          - Auth Requirements: Usuários autenticados.
          
          ## Performance Impact:
          - Indexes: Nenhum índice novo adicionado nesta migração.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo. A adição de colunas pode aumentar ligeiramente o tamanho das tabelas.
          */

-- Adiciona colunas a pedidos_venda se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='natureza_operacao') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN natureza_operacao TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='endereco_entrega_diferente') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN endereco_entrega_diferente BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='desconto_valor') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN desconto_valor NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='desconto_percentual') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN desconto_percentual NUMERIC(5, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='valor_frete_cliente') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN valor_frete_cliente NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='valor_frete_empresa') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN valor_frete_empresa NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='valor_despesas') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN valor_despesas NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='data_prevista_entrega') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN data_prevista_entrega DATE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='data_envio') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN data_envio TIMESTAMP WITH TIME ZONE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='data_maxima_despacho') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN data_maxima_despacho TIMESTAMP WITH TIME ZONE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='numero_pedido_ecommerce') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN numero_pedido_ecommerce TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='identificador_pedido_ecommerce') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN identificador_pedido_ecommerce TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='numero_pedido_canal_venda') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN numero_pedido_canal_venda TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='intermediador') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN intermediador TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='forma_recebimento') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN forma_recebimento TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='meio_pagamento') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN meio_pagamento TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='conta_bancaria_id') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN conta_bancaria_id UUID;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='categoria_financeira_id') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN categoria_financeira_id UUID;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='condicao_pagamento') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN condicao_pagamento TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='forma_envio') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN forma_envio TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='enviar_para_expedicao') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN enviar_para_expedicao BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='deposito_id') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN deposito_id UUID;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='observacoes_internas') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN observacoes_internas TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='marcadores') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN marcadores TEXT[];
    END IF;
END $$;

-- Adiciona colunas a pedido_venda_itens se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedido_venda_itens' AND column_name='codigo') THEN
        ALTER TABLE public.pedido_venda_itens ADD COLUMN codigo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedido_venda_itens' AND column_name='unidade') THEN
        ALTER TABLE public.pedido_venda_itens ADD COLUMN unidade TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedido_venda_itens' AND column_name='desconto_percentual') THEN
        ALTER TABLE public.pedido_venda_itens ADD COLUMN desconto_percentual NUMERIC(5, 2);
    END IF;
END $$;

-- Cria a tabela de anexos se não existir
CREATE TABLE IF NOT EXISTS public.pedido_venda_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilita RLS e cria políticas para a nova tabela
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated users to manage their attachments" ON public.pedido_venda_anexos;
CREATE POLICY "Allow authenticated users to manage their attachments"
ON public.pedido_venda_anexos
FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');
