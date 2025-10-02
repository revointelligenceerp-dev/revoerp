-- =============================================
-- Migration: Correção Definitiva do Schema e RLS
-- Description: Este script é idempotente e robusto.
-- 1. Garante que todas as tabelas de anexos existam.
-- 2. Adiciona a coluna 'organization_id' onde for necessário.
-- 3. Habilita RLS e aplica políticas de segurança em todas as tabelas relevantes.
-- Isso resolve os erros "relation does not exist" e "RLS Disabled".
-- =============================================

DO $$
DECLARE
    -- Lista de todas as tabelas que devem ter RLS e organization_id
    tables_to_secure TEXT[] := ARRAY[
        'clientes', 'produtos', 'servicos', 'vendedores', 'embalagens',
        'ordens_servico', 'ordem_servico_itens', 'ordem_servico_anexos',
        'pedidos_venda', 'pedido_venda_itens', 'pedido_venda_anexos',
        'faturas_venda', 'contas_receber', 'contas_receber_anexos',
        'contas_pagar', 'contas_pagar_anexos', 'ordens_compra',
        'ordem_compra_itens', 'crm_oportunidades', 'contratos',
        'contrato_anexos', 'notas_entrada', 'nota_entrada_itens',
        'devolucoes_venda', 'devolucao_venda_itens', 'expedicoes',
        'expedicao_pedidos', 'user_profiles', 'estoque_movimentos',
        'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
        'pessoas_contato'
    ];
    tbl_name TEXT;
BEGIN
    -- Etapa 1: Garantir que as tabelas de anexos existam
    -- ===================================================

    CREATE TABLE IF NOT EXISTS public.cliente_anexos (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        cliente_id uuid REFERENCES public.clientes(id) ON DELETE CASCADE,
        organization_id uuid REFERENCES public.organizations(id) ON DELETE CASCADE,
        nome_arquivo text NOT NULL, path text NOT NULL, tamanho bigint NOT NULL, tipo text NOT NULL,
        created_at timestamp with time zone DEFAULT now() NOT NULL,
        updated_at timestamp with time zone DEFAULT now() NOT NULL
    );

    CREATE TABLE IF NOT EXISTS public.contrato_anexos (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        contrato_id uuid REFERENCES public.contratos(id) ON DELETE CASCADE,
        organization_id uuid REFERENCES public.organizations(id) ON DELETE CASCADE,
        nome_arquivo text NOT NULL, path text NOT NULL, tamanho bigint NOT NULL, tipo text NOT NULL,
        created_at timestamp with time zone DEFAULT now() NOT NULL,
        updated_at timestamp with time zone DEFAULT now() NOT NULL
    );

    CREATE TABLE IF NOT EXISTS public.contas_pagar_anexos (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        conta_pagar_id uuid REFERENCES public.contas_pagar(id) ON DELETE CASCADE,
        organization_id uuid REFERENCES public.organizations(id) ON DELETE CASCADE,
        nome_arquivo text NOT NULL, path text NOT NULL, tamanho bigint NOT NULL, tipo text NOT NULL,
        created_at timestamp with time zone DEFAULT now() NOT NULL,
        updated_at timestamp with time zone DEFAULT now() NOT NULL
    );

    CREATE TABLE IF NOT EXISTS public.contas_receber_anexos (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        conta_receber_id uuid REFERENCES public.contas_receber(id) ON DELETE CASCADE,
        organization_id uuid REFERENCES public.organizations(id) ON DELETE CASCADE,
        nome_arquivo text NOT NULL, path text NOT NULL, tamanho bigint NOT NULL, tipo text NOT NULL,
        created_at timestamp with time zone DEFAULT now() NOT NULL,
        updated_at timestamp with time zone DEFAULT now() NOT NULL
    );
    
    CREATE TABLE IF NOT EXISTS public.ordem_servico_anexos (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        ordem_servico_id uuid REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
        organization_id uuid REFERENCES public.organizations(id) ON DELETE CASCADE,
        nome_arquivo text NOT NULL, path text NOT NULL, tamanho bigint NOT NULL, tipo text NOT NULL,
        created_at timestamp with time zone DEFAULT now() NOT NULL,
        updated_at timestamp with time zone DEFAULT now() NOT NULL
    );

    CREATE TABLE IF NOT EXISTS public.pedido_venda_anexos (
        id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
        pedido_id uuid REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
        organization_id uuid REFERENCES public.organizations(id) ON DELETE CASCADE,
        nome_arquivo text NOT NULL, path text NOT NULL, tamanho bigint NOT NULL, tipo text NOT NULL,
        created_at timestamp with time zone DEFAULT now() NOT NULL,
        updated_at timestamp with time zone DEFAULT now() NOT NULL
    );

    -- Etapa 2: Garantir que a função de helper exista
    -- ===============================================
    CREATE OR REPLACE FUNCTION public.get_organization_id()
    RETURNS uuid
    LANGUAGE sql
    STABLE
    AS $$
      SELECT nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
    $$;

    -- Etapa 3: Adicionar coluna organization_id e aplicar RLS
    -- =======================================================
    FOREACH tbl_name IN ARRAY tables_to_secure
    LOOP
        -- Adiciona a coluna 'organization_id' se ela não existir
        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = tbl_name
            AND column_name = 'organization_id'
        ) THEN
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE', tbl_name);
        END IF;

        -- Ativa RLS na tabela
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl_name);

        -- Remove políticas antigas para evitar conflitos
        EXECUTE format('DROP POLICY IF EXISTS "Allow full access for organization members" ON public.%I', tbl_name);
        EXECUTE format('DROP POLICY IF EXISTS "Allow individual access" ON public.%I', tbl_name);

        -- Cria a nova política de acesso baseada na organization_id
        EXECUTE format('
            CREATE POLICY "Allow full access for organization members"
            ON public.%I
            FOR ALL
            USING (organization_id = public.get_organization_id())
            WITH CHECK (organization_id = public.get_organization_id());
        ', tbl_name);
    END LOOP;

    RAISE NOTICE 'Schema and RLS policies fixed successfully.';
END;
$$;
