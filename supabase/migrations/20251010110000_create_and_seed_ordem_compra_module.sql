/*
          # [Operação Estrutural e de Dados]
          Cria o esquema completo para o módulo de Ordens de Compra e insere dados de exemplo.

          ## Query Description: [Esta operação cria as tabelas `ordens_compra`, `ordem_compra_itens`, e `ordem_compra_anexos`, além de tipos e políticas de segurança necessários. Em seguida, insere 5 ordens de compra de exemplo para testes. É uma operação segura para ser executada, pois verifica a existência dos objetos antes de criá-los.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Data"]
          - Impact-Level: ["Low"]
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Tabelas Criadas: `ordens_compra`, `ordem_compra_itens`, `ordem_compra_anexos`
          - Tipos Criados: `frete_por_conta_enum`, `status_ordem_compra`
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (criação de políticas de acesso para as novas tabelas)
          - Auth Requirements: `authenticated`
          
          ## Performance Impact:
          - Indexes: Adiciona chaves primárias e estrangeiras.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo.
          */

DO $$
BEGIN
    -- Criação do ENUM para FretePorConta se não existir
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

    -- Criação do ENUM para StatusOrdemCompra se não existir
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_ordem_compra') THEN
        CREATE TYPE public.status_ordem_compra AS ENUM (
            'ABERTA',
            'RECEBIDA',
            'CANCELADA'
        );
    END IF;

    -- Criação da tabela ordens_compra se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ordens_compra') THEN
        CREATE TABLE public.ordens_compra (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            numero text NOT NULL,
            fornecedor_id uuid REFERENCES public.clientes(id),
            total_produtos numeric(12, 2) DEFAULT 0,
            desconto text,
            frete numeric(12, 2) DEFAULT 0,
            total_ipi numeric(12, 2) DEFAULT 0,
            total_icms_st numeric(12, 2) DEFAULT 0,
            total_geral numeric(12, 2) DEFAULT 0,
            numero_no_fornecedor text,
            data_compra date NOT NULL,
            data_prevista date,
            condicao_pagamento text,
            categoria_id text,
            transportador_nome text,
            frete_por_conta public.frete_por_conta_enum,
            observacoes text,
            marcadores text[],
            observacoes_internas text,
            status public.status_ordem_compra NOT NULL DEFAULT 'ABERTA',
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            updated_at timestamp with time zone DEFAULT now() NOT NULL
        );
        ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
    END IF;

    -- Criação da tabela ordem_compra_itens se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ordem_compra_itens') THEN
        CREATE TABLE public.ordem_compra_itens (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            ordem_compra_id uuid NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
            produto_id uuid REFERENCES public.produtos(id),
            descricao text NOT NULL,
            codigo text,
            gtin_ean text,
            quantidade integer NOT NULL,
            unidade text,
            preco_unitario numeric(12, 2) NOT NULL,
            ipi numeric(5, 2),
            preco_total numeric(12, 2) NOT NULL,
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            updated_at timestamp with time zone DEFAULT now() NOT NULL
        );
        ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
    END IF;

    -- Criação da tabela ordem_compra_anexos se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ordem_compra_anexos') THEN
        CREATE TABLE public.ordem_compra_anexos (
            id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
            ordem_compra_id uuid NOT NULL REFERENCES public.ordens_compra(id) ON DELETE CASCADE,
            nome_arquivo text NOT NULL,
            path text NOT NULL,
            tamanho integer NOT NULL,
            tipo text,
            created_at timestamp with time zone DEFAULT now() NOT NULL
        );
        ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
    END IF;

    -- Criação de Políticas de Segurança (RLS) se não existirem
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Allow all access to authenticated users on ordens_compra') THEN
        CREATE POLICY "Allow all access to authenticated users on ordens_compra" ON public.ordens_compra FOR ALL TO authenticated USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Allow all access to authenticated users on ordem_compra_itens') THEN
        CREATE POLICY "Allow all access to authenticated users on ordem_compra_itens" ON public.ordem_compra_itens FOR ALL TO authenticated USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Allow all access to authenticated users on ordem_compra_anexos') THEN
        CREATE POLICY "Allow all access to authenticated users on ordem_compra_anexos" ON public.ordem_compra_anexos FOR ALL TO authenticated USING (true);
    END IF;

END $$;


-- Seed de dados
DO $$
DECLARE
    v_fornecedor_id UUID;
BEGIN
    -- Tenta encontrar um fornecedor existente
    SELECT id INTO v_fornecedor_id FROM public.clientes WHERE is_fornecedor = true LIMIT 1;

    -- Se não encontrar, cria um fornecedor de exemplo
    IF v_fornecedor_id IS NULL THEN
        INSERT INTO public.clientes (nome, is_fornecedor, tipo_pessoa, cpf_cnpj, email)
        VALUES ('Fornecedor de Exemplo', true, 'JURIDICA', '00.000.000/0001-91', 'fornecedor.seed@example.com')
        RETURNING id INTO v_fornecedor_id;
    END IF;

    -- Insere 5 ordens de compra de exemplo, apenas se a tabela estiver vazia
    IF (SELECT count(*) FROM public.ordens_compra) = 0 THEN
        INSERT INTO public.ordens_compra (fornecedor_id, numero, data_compra, total_geral, status)
        VALUES
            (v_fornecedor_id, 'OC-00001', NOW() - interval '5 days', 150.75, 'ABERTA'),
            (v_fornecedor_id, 'OC-00002', NOW() - interval '4 days', 89.90, 'ABERTA'),
            (v_fornecedor_id, 'OC-00003', NOW() - interval '3 days', 320.00, 'RECEBIDA'),
            (v_fornecedor_id, 'OC-00004', NOW() - interval '2 days', 45.50, 'ABERTA'),
            (v_fornecedor_id, 'OC-00005', NOW() - interval '1 day', 1200.00, 'CANCELADA');
    END IF;
END $$;
