/*
# [Fix] Correção da Migração Multi-Tenancy

Este script corrige a migração anterior que falhou devido à ausência da tabela `pedido_venda_anexos`. Ele também foi aprimorado para ser idempotente, o que significa que pode ser executado várias vezes sem causar erros, mesmo que partes dele já tenham sido aplicadas.

## Query Description:
- **Criação de Estruturas Multi-Tenancy:** Cria a tabela `organizations` e `user_profiles` se elas não existirem. Adiciona a coluna `organization_id` aos perfis de usuário.
- **Criação de Tabela Faltante:** Cria a tabela `pedido_venda_anexos` se ela não existir, garantindo que a estrutura do banco de dados esteja completa.
- **Adição de Coluna `organization_id`:** Percorre todas as tabelas do esquema `public` e adiciona a coluna `organization_id` apenas se ela ainda não existir. Isso evita o erro de "coluna duplicada".
- **Habilitação de RLS e Políticas:** Habilita a Segurança em Nível de Linha (RLS) e cria as políticas de acesso para garantir que cada organização só possa ver seus próprios dados. As políticas são recriadas para garantir consistência.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Medium"
- Requires-Backup: true
- Reversible: false

## Structure Details:
- **Tabelas Criadas (se não existirem):** `organizations`, `user_profiles`, `pedido_venda_anexos`.
- **Tabelas Alteradas:** Todas as tabelas no esquema `public` terão a coluna `organization_id` e políticas de RLS.
- **Funções Criadas:** `get_my_organization_id()`.

## Security Implications:
- RLS Status: Habilitado para todas as tabelas no esquema `public`.
- Policy Changes: Sim. Políticas de `SELECT`, `INSERT`, `UPDATE`, `DELETE` são criadas para todas as tabelas, restringindo o acesso por `organization_id`.
- Auth Requirements: As operações dependerão do `organization_id` associado ao `auth.uid()` do usuário logado.

## Performance Impact:
- Indexes: Adiciona um índice na coluna `organization_id` em todas as tabelas afetadas para otimizar as consultas.
- Triggers: Nenhum.
- Estimated Impact: As consultas que não filtrarem por `organization_id` podem se tornar mais lentas. É crucial atualizar o frontend para incluir esse filtro.
*/

BEGIN;

-- 1. Criar a tabela de organizações se ela não existir
CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE public.organizations IS 'Armazena as informações de cada organização/empresa cliente (inquilino).';

-- 2. Criar a tabela de perfis de usuário se ela não existir
CREATE TABLE IF NOT EXISTS public.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    full_name TEXT,
    avatar_url TEXT
);
COMMENT ON TABLE public.user_profiles IS 'Armazena o perfil de cada usuário e sua associação a uma organização.';

-- 3. Adicionar a coluna organization_id em user_profiles se não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'user_profiles'
        AND column_name = 'organization_id'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 4. Criar a tabela `pedido_venda_anexos` se ela não existir
CREATE TABLE IF NOT EXISTS public.pedido_venda_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.pedido_venda_anexos IS 'Armazena os anexos dos pedidos de venda.';

-- 5. Criar função para obter o organization_id do usuário atual
CREATE OR REPLACE FUNCTION get_my_organization_id()
RETURNS UUID AS $$
DECLARE
    org_id UUID;
BEGIN
    SELECT organization_id INTO org_id
    FROM public.user_profiles
    WHERE user_id = auth.uid();
    RETURN org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 6. Loop para adicionar a coluna organization_id e RLS em todas as tabelas do schema public
DO $$
DECLARE
    tbl RECORD;
BEGIN
    FOR tbl IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
          AND table_name NOT IN ('organizations', 'user_profiles')
    LOOP
        -- Adicionar a coluna organization_id se não existir
        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = tbl.table_name
            AND column_name = 'organization_id'
        ) THEN
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;', tbl.table_name);
        END IF;

        -- Adicionar índice para performance
        EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_organization_id ON public.%I(organization_id);', replace(tbl.table_name, '-', '_'), tbl.table_name);

        -- Habilitar RLS
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl.table_name);

        -- Recriar políticas de RLS
        EXECUTE format('DROP POLICY IF EXISTS "Allow organization members to read" ON public.%I;', tbl.table_name);
        EXECUTE format('CREATE POLICY "Allow organization members to read" ON public.%I FOR SELECT USING (organization_id = get_my_organization_id());', tbl.table_name);

        EXECUTE format('DROP POLICY IF EXISTS "Allow organization members to insert" ON public.%I;', tbl.table_name);
        EXECUTE format('CREATE POLICY "Allow organization members to insert" ON public.%I FOR INSERT WITH CHECK (organization_id = get_my_organization_id());', tbl.table_name);

        EXECUTE format('DROP POLICY IF EXISTS "Allow organization members to update" ON public.%I;', tbl.table_name);
        EXECUTE format('CREATE POLICY "Allow organization members to update" ON public.%I FOR UPDATE USING (organization_id = get_my_organization_id());', tbl.table_name);

        EXECUTE format('DROP POLICY IF EXISTS "Allow organization members to delete" ON public.%I;', tbl.table_name);
        EXECUTE format('CREATE POLICY "Allow organization members to delete" ON public.%I FOR DELETE USING (organization_id = get_my_organization_id());', tbl.table_name);
    END LOOP;
END $$;

COMMIT;
