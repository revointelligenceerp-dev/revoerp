-- 1. Criar o ENUM para Frete por Conta, se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'frete_por_conta_enum') THEN
        CREATE TYPE public.frete_por_conta_enum AS ENUM (
            'CIF',
            'FOB',
            'TERCEIROS',
            'PROPRIO_REMETENTE',
            'PROPRIO_DESTINATARIO',
            'SEM_TRANSPORTE'
        );
    END IF;
END
$$;

-- 2. Criar o ENUM para Status da Ordem de Compra, se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_ordem_compra_enum') THEN
        CREATE TYPE public.status_ordem_compra_enum AS ENUM (
            'ABERTA',
            'RECEBIDA',
            'CANCELADA'
        );
    END IF;
END
$$;

-- 3. Criar a tabela principal de Ordens de Compra, se não existir
CREATE TABLE IF NOT EXISTS public.ordens_compra (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    numero text NOT NULL,
    fornecedor_id uuid NOT NULL,
    data_compra date NOT NULL,
    data_prevista date,
    total_produtos numeric(12, 2) DEFAULT 0,
    desconto text,
    frete numeric(12, 2) DEFAULT 0,
    total_ipi numeric(12, 2) DEFAULT 0,
    total_icms_st numeric(12, 2) DEFAULT 0,
    total_geral numeric(12, 2) NOT NULL,
    numero_no_fornecedor text,
    condicao_pagamento text,
    categoria_id uuid,
    transportador_nome text,
    frete_por_conta public.frete_por_conta_enum,
    observacoes text,
    marcadores text[],
    observacoes_internas text,
    status public.status_ordem_compra_enum NOT NULL,
    CONSTRAINT ordens_compra_pkey PRIMARY KEY (id),
    CONSTRAINT ordens_compra_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.clientes(id),
    CONSTRAINT ordens_compra_numero_key UNIQUE (numero)
);

-- Adicionar colunas faltantes, se a tabela já existir
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ordens_compra') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_compra' AND column_name = 'status') THEN
            ALTER TABLE public.ordens_compra ADD COLUMN status public.status_ordem_compra_enum NOT NULL DEFAULT 'ABERTA';
        END IF;
    END IF;
END
$$;


-- 4. Criar a tabela de Itens da Ordem de Compra, se não existir
CREATE TABLE IF NOT EXISTS public.ordem_compra_itens (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    ordem_compra_id uuid NOT NULL,
    produto_id uuid,
    descricao text NOT NULL,
    codigo text,
    gtin_ean text,
    quantidade numeric NOT NULL,
    unidade text,
    preco_unitario numeric(12, 2) NOT NULL,
    ipi numeric(5, 2),
    preco_total numeric(12, 2) NOT NULL,
    CONSTRAINT ordem_compra_itens_pkey PRIMARY KEY (id),
    CONSTRAINT ordem_compra_itens_ordem_compra_id_fkey FOREIGN KEY (ordem_compra_id) REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
    CONSTRAINT ordem_compra_itens_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id)
);

-- 5. Criar a tabela de Anexos da Ordem de Compra, se não existir
CREATE TABLE IF NOT EXISTS public.ordem_compra_anexos (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    ordem_compra_id uuid NOT NULL,
    nome_arquivo text NOT NULL,
    path text NOT NULL,
    tamanho bigint NOT NULL,
    tipo text NOT NULL,
    CONSTRAINT ordem_compra_anexos_pkey PRIMARY KEY (id),
    CONSTRAINT ordem_compra_anexos_ordem_compra_id_fkey FOREIGN KEY (ordem_compra_id) REFERENCES public.ordens_compra(id) ON DELETE CASCADE
);

-- 6. Habilitar RLS e criar políticas (de forma idempotente)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'ordens_compra' AND policyname = 'Permitir acesso total para usuários autenticados') THEN
        ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
        CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.ordens_compra FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'ordem_compra_itens' AND policyname = 'Permitir acesso total para usuários autenticados') THEN
        ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
        CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.ordem_compra_itens FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'ordem_compra_anexos' AND policyname = 'Permitir acesso total para usuários autenticados') THEN
        ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
        CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.ordem_compra_anexos FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
    END IF;
END
$$;

-- 7. Inserir dados de exemplo (seeding)
DO $$
DECLARE
    v_fornecedor_id uuid;
BEGIN
    -- Tenta encontrar um fornecedor existente. Se não encontrar, não insere os dados.
    SELECT id INTO v_fornecedor_id FROM public.clientes WHERE is_fornecedor = true LIMIT 1;

    IF v_fornecedor_id IS NOT NULL THEN
        -- Insere 5 ordens de compra de exemplo, somente se não existirem
        INSERT INTO public.ordens_compra (fornecedor_id, numero, data_compra, total_geral, status)
        VALUES
            (v_fornecedor_id, 'OC-00001', NOW() - interval '5 days', 150.75, 'ABERTA'),
            (v_fornecedor_id, 'OC-00002', NOW() - interval '4 days', 89.90, 'ABERTA'),
            (v_fornecedor_id, 'OC-00003', NOW() - interval '3 days', 320.00, 'RECEBIDA'),
            (v_fornecedor_id, 'OC-00004', NOW() - interval '2 days', 45.50, 'ABERTA'),
            (v_fornecedor_id, 'OC-00005', NOW() - interval '1 day', 1200.00, 'CANCELADA')
        ON CONFLICT (numero) DO NOTHING;
    ELSE
        RAISE NOTICE 'Nenhum fornecedor encontrado. Dados de exemplo para ordens_compra não foram inseridos.';
    END IF;
END
$$;
