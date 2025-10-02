-- Habilita a extensão para buscas otimizadas em texto, se não existir
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Cria os tipos ENUM para status e frete, se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_ordem_compra') THEN
        CREATE TYPE public.status_ordem_compra AS ENUM ('ABERTA', 'RECEBIDA', 'CANCELADA');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'frete_por_conta') THEN
        CREATE TYPE public.frete_por_conta AS ENUM ('CIF', 'FOB', 'TERCEIROS', 'PROPRIO_REMETENTE', 'PROPRIO_DESTINATARIO', 'SEM_TRANSPORTE');
    END IF;
END$$;

-- Cria a tabela principal de ordens de compra, se não existir
CREATE TABLE IF NOT EXISTS public.ordens_compra (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    fornecedor_id uuid REFERENCES public.clientes(id) ON DELETE SET NULL,
    numero character varying NOT NULL UNIQUE,
    data_compra timestamp with time zone DEFAULT now() NOT NULL,
    data_prevista timestamp with time zone,
    total_produtos numeric DEFAULT 0,
    desconto character varying,
    frete numeric DEFAULT 0,
    total_ipi numeric DEFAULT 0,
    total_icms_st numeric DEFAULT 0,
    total_geral numeric DEFAULT 0 NOT NULL,
    status public.status_ordem_compra DEFAULT 'ABERTA'::public.status_ordem_compra,
    numero_no_fornecedor character varying,
    condicao_pagamento character varying,
    categoria_id uuid,
    transportador_nome character varying,
    frete_por_conta public.frete_por_conta DEFAULT 'CIF'::public.frete_por_conta,
    observacoes text,
    observacoes_internas text,
    marcadores text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Cria a tabela de itens da ordem de compra, se não existir
CREATE TABLE IF NOT EXISTS public.ordem_compra_itens (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    ordem_compra_id uuid NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
    produto_id uuid REFERENCES public.produtos(id) ON DELETE SET NULL,
    descricao character varying NOT NULL,
    codigo character varying,
    gtin_ean character varying,
    unidade character varying,
    quantidade numeric NOT NULL,
    preco_unitario numeric NOT NULL,
    ipi numeric DEFAULT 0,
    preco_total numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Cria a tabela de anexos da ordem de compra, se não existir
CREATE TABLE IF NOT EXISTS public.ordem_compra_anexos (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    ordem_compra_id uuid NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
    nome_arquivo character varying NOT NULL,
    path character varying NOT NULL,
    tamanho bigint NOT NULL,
    tipo character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Habilita RLS (segurança) nas novas tabelas
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;

-- Cria políticas de acesso (permite leitura para todos, escrita apenas para logados)
DROP POLICY IF EXISTS "Permite acesso de leitura a anon" ON public.ordens_compra;
CREATE POLICY "Permite acesso de leitura a anon" ON public.ordens_compra FOR SELECT TO anon USING (true);
DROP POLICY IF EXISTS "Permite acesso total a authenticated" ON public.ordens_compra;
CREATE POLICY "Permite acesso total a authenticated" ON public.ordens_compra FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS "Permite acesso de leitura a anon" ON public.ordem_compra_itens;
CREATE POLICY "Permite acesso de leitura a anon" ON public.ordem_compra_itens FOR SELECT TO anon USING (true);
DROP POLICY IF EXISTS "Permite acesso total a authenticated" ON public.ordem_compra_itens;
CREATE POLICY "Permite acesso total a authenticated" ON public.ordem_compra_itens FOR ALL TO authenticated USING (true);

DROP POLICY IF EXISTS "Permite acesso de leitura a anon" ON public.ordem_compra_anexos;
CREATE POLICY "Permite acesso de leitura a anon" ON public.ordem_compra_anexos FOR SELECT TO anon USING (true);
DROP POLICY IF EXISTS "Permite acesso total a authenticated" ON public.ordem_compra_anexos;
CREATE POLICY "Permite acesso total a authenticated" ON public.ordem_compra_anexos FOR ALL TO authenticated USING (true);

-- Insere 5 registros de exemplo, se não existirem
DO $$
DECLARE
    v_fornecedor_id uuid;
BEGIN
    -- Tenta encontrar um fornecedor existente
    SELECT id INTO v_fornecedor_id FROM public.clientes WHERE is_fornecedor = true LIMIT 1;

    -- Se não encontrar, insere um fornecedor de exemplo
    IF v_fornecedor_id IS NULL THEN
        INSERT INTO public.clientes (nome, is_fornecedor, email, tipo_pessoa) 
        VALUES ('Fornecedor Padrão', true, 'contato@fornecedorpadao.com', 'JURIDICA') 
        RETURNING id INTO v_fornecedor_id;
    END IF;

    -- Insere as ordens de compra, evitando duplicatas pelo número
    INSERT INTO public.ordens_compra (fornecedor_id, numero, data_compra, total_geral, status)
    VALUES
        (v_fornecedor_id, 'OC-00001', NOW() - interval '5 days', 150.75, 'ABERTA'),
        (v_fornecedor_id, 'OC-00002', NOW() - interval '4 days', 89.90, 'ABERTA'),
        (v_fornecedor_id, 'OC-00003', NOW() - interval '3 days', 320.00, 'RECEBIDA'),
        (v_fornecedor_id, 'OC-00004', NOW() - interval '2 days', 45.50, 'ABERTA'),
        (v_fornecedor_id, 'OC-00005', NOW() - interval '1 day', 1200.00, 'CANCELADA')
    ON CONFLICT (numero) DO NOTHING;
END $$;
