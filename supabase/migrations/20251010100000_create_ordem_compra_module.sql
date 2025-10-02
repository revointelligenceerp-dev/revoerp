DO $$
BEGIN
    -- Cria o ENUM para o tipo de frete, se não existir
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

    -- Cria o ENUM para o status da ordem de compra, se não existir
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_ordem_compra') THEN
        CREATE TYPE public.status_ordem_compra AS ENUM (
            'ABERTA',
            'RECEBIDA',
            'CANCELADA'
        );
    END IF;

    -- Cria a tabela principal de Ordens de Compra, se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ordens_compra') THEN
        CREATE TABLE public.ordens_compra (
            id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            updated_at timestamp with time zone DEFAULT now() NOT NULL,
            fornecedor_id uuid REFERENCES public.clientes(id),
            numero text,
            data_compra date,
            data_prevista date,
            total_produtos numeric(10,2),
            desconto text,
            frete numeric(10,2),
            total_ipi numeric(10,2),
            total_icms_st numeric(10,2),
            total_geral numeric(10,2),
            numero_no_fornecedor text,
            condicao_pagamento text,
            categoria_id text,
            transportador_nome text,
            frete_por_conta public.frete_por_conta_enum,
            observacoes text,
            marcadores text[],
            observacoes_internas text,
            status public.status_ordem_compra
        );
        ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
    END IF;
    
    -- Adiciona a coluna 'status' se ela não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_compra' AND column_name='status') THEN
        ALTER TABLE public.ordens_compra ADD COLUMN status public.status_ordem_compra;
    END IF;

    -- Cria a tabela de itens da Ordem de Compra, se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ordem_compra_itens') THEN
        CREATE TABLE public.ordem_compra_itens (
            id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            updated_at timestamp with time zone DEFAULT now() NOT NULL,
            ordem_compra_id uuid REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
            produto_id uuid REFERENCES public.produtos(id),
            descricao text,
            codigo text,
            gtin_ean text,
            quantidade integer,
            unidade text,
            preco_unitario numeric(10,2),
            ipi numeric(5,2),
            preco_total numeric(10,2)
        );
        ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
    END IF;

    -- Cria a tabela de anexos da Ordem de Compra, se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ordem_compra_anexos') THEN
        CREATE TABLE public.ordem_compra_anexos (
            id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            ordem_compra_id uuid REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
            nome_arquivo text,
            path text,
            tamanho integer,
            tipo text
        );
        ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
    END IF;
    
    -- Insere dados de exemplo se a tabela estiver vazia
    IF (SELECT count(*) FROM public.ordens_compra) = 0 THEN
        DECLARE
            v_fornecedor_id uuid;
        BEGIN
            -- Pega o primeiro cliente que também é fornecedor para usar como exemplo
            SELECT id INTO v_fornecedor_id FROM public.clientes WHERE is_fornecedor = true LIMIT 1;
            
            IF v_fornecedor_id IS NOT NULL THEN
                INSERT INTO public.ordens_compra (fornecedor_id, numero, data_compra, total_geral, status)
                VALUES
                    (v_fornecedor_id, 'OC-00001', NOW() - interval '5 days', 150.75, 'ABERTA'),
                    (v_fornecedor_id, 'OC-00002', NOW() - interval '4 days', 89.90, 'ABERTA'),
                    (v_fornecedor_id, 'OC-00003', NOW() - interval '3 days', 320.00, 'RECEBIDA'),
                    (v_fornecedor_id, 'OC-00004', NOW() - interval '2 days', 45.50, 'ABERTA'),
                    (v_fornecedor_id, 'OC-00005', NOW() - interval '1 day', 1200.00, 'CANCELADA');
            END IF;
        END;
    END IF;

END $$;
