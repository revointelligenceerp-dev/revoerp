/*
# [Fix Pedido de Venda Schema]
Este script verifica e corrige a estrutura das tabelas relacionadas ao Pedido de Venda, garantindo que todas as colunas e tabelas necessárias existam.

## Query Description:
- **Segurança:** Este script é seguro para ser executado múltiplas vezes. Ele usa `IF NOT EXISTS` para evitar erros ao tentar criar colunas ou tabelas que já existem.
- **Impacto:** Nenhum dado existente será perdido. Apenas adicionará as estruturas que estão faltando.
- **Ação:** Adiciona colunas à tabela `pedidos_venda` e cria as tabelas `pedido_venda_itens` e `pedido_venda_anexos` se elas não existirem.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: false
*/

DO $$
BEGIN
    -- Adicionar colunas à tabela pedidos_venda se não existirem
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='natureza_operacao') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN natureza_operacao TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='endereco_entrega_diferente') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN endereco_entrega_diferente BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='total_produtos') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN total_produtos NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='valor_ipi') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN valor_ipi NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='valor_icms_st') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN valor_icms_st NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='desconto') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN desconto TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='frete_cliente') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN frete_cliente NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='frete_empresa') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN frete_empresa NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='despesas') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN despesas NUMERIC(10, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='data_venda') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN data_venda TIMESTAMPTZ DEFAULT now();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='data_prevista_entrega') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN data_prevista_entrega TIMESTAMPTZ;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='data_envio') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN data_envio TIMESTAMPTZ;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='data_maxima_despacho') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN data_maxima_despacho TIMESTAMPTZ;
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
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='conta_bancaria') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN conta_bancaria TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='categoria_financeira') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN categoria_financeira TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='condicao_pagamento') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN condicao_pagamento TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='forma_envio') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN forma_envio TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='enviar_para_expedicao') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN enviar_para_expedicao BOOLEAN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='deposito') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN deposito TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='observacoes') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN observacoes TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='observacoes_internas') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN observacoes_internas TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='marcadores') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN marcadores TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='peso_bruto') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN peso_bruto NUMERIC(10, 3);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='peso_liquido') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN peso_liquido NUMERIC(10, 3);
    END IF;
END $$;

-- Criar tabela de itens se não existir
CREATE TABLE IF NOT EXISTS public.pedido_venda_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_venda_id UUID REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES public.produtos(id),
    servico_id UUID REFERENCES public.servicos(id),
    descricao TEXT NOT NULL,
    codigo TEXT,
    unidade TEXT,
    quantidade NUMERIC NOT NULL,
    valor_unitario NUMERIC NOT NULL,
    desconto_percentual NUMERIC,
    valor_total NUMERIC NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Criar tabela de anexos se não existir
CREATE TABLE IF NOT EXISTS public.pedido_venda_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_venda_id UUID REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Habilitar RLS nas novas tabelas se elas foram recém-criadas
DO $$
BEGIN
    IF to_regclass('public.pedido_venda_itens') IS NOT NULL THEN
        ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
        CREATE POLICY "Enable all access for authenticated users" ON public.pedido_venda_itens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
    END IF;
    IF to_regclass('public.pedido_venda_anexos') IS NOT NULL THEN
        ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
        CREATE POLICY "Enable all access for authenticated users" ON public.pedido_venda_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
    END IF;
END $$;
