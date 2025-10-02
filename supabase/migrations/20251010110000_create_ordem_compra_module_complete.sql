-- Habilita a extensão pg_trgm se não existir (para buscas eficientes)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Cria o ENUM para Frete por Conta
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
END$$;

-- Cria a tabela principal de Ordens de Compra
CREATE TABLE IF NOT EXISTS public.ordens_compra (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    
    -- Cabeçalho
    fornecedor_id uuid NOT NULL,
    numero text NOT NULL,
    
    -- Totais
    total_produtos numeric(12, 2) DEFAULT 0,
    desconto text, -- '10%' ou '100.00'
    frete numeric(12, 2) DEFAULT 0,
    total_ipi numeric(12, 2) DEFAULT 0,
    total_icms_st numeric(12, 2) DEFAULT 0,
    total_geral numeric(12, 2) DEFAULT 0,
    
    -- Detalhes da Compra
    numero_no_fornecedor text,
    data_compra date NOT NULL DEFAULT now(),
    data_prevista date,
    
    -- Pagamento
    condicao_pagamento text,
    categoria_id uuid,
    
    -- Transportador
    transportador_nome text,
    frete_por_conta public.frete_por_conta_enum,
    
    -- Observações
    observacoes text,
    marcadores text[],
    observacoes_internas text,

    CONSTRAINT ordens_compra_pkey PRIMARY KEY (id),
    CONSTRAINT ordens_compra_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.clientes(id)
);

-- Habilita RLS na tabela de Ordens de Compra
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;

-- Cria a tabela de Itens da Ordem de Compra
CREATE TABLE IF NOT EXISTS public.ordem_compra_itens (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    
    ordem_compra_id uuid NOT NULL,
    produto_id uuid,
    descricao text NOT NULL,
    codigo text,
    gtin_ean text,
    quantidade numeric(10, 2) NOT NULL,
    unidade text,
    preco_unitario numeric(12, 2) NOT NULL,
    ipi_percentual numeric(5, 2),
    preco_total numeric(12, 2) NOT NULL,

    CONSTRAINT ordem_compra_itens_pkey PRIMARY KEY (id),
    CONSTRAINT ordem_compra_itens_ordem_compra_id_fkey FOREIGN KEY (ordem_compra_id) REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
    CONSTRAINT ordem_compra_itens_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id) ON DELETE SET NULL
);

-- Habilita RLS na tabela de Itens
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;

-- Cria a tabela de Anexos da Ordem de Compra
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

-- Habilita RLS na tabela de Anexos
ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;

-- Adiciona políticas de segurança básicas (permitir acesso a usuários autenticados)
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_name IN ('ordens_compra', 'ordem_compra_itens', 'ordem_compra_anexos')
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.%I;', t_name);
        EXECUTE format('CREATE POLICY "Enable all access for authenticated users" ON public.%I FOR ALL USING (auth.role() = ''authenticated'');', t_name);
    END LOOP;
END$$;
