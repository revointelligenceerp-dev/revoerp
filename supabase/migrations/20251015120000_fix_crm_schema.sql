/*
          # [CORREÇÃO E GARANTIA DO SCHEMA CRM]
          Este script verifica a existência das tabelas e colunas do módulo de CRM e as cria apenas se não existirem.
          É uma operação segura, projetada para corrigir inconsistências no banco de dados sem perda de dados.
          ## Query Description: [Esta operação irá verificar e corrigir a estrutura das tabelas do CRM. Se a tabela 'crm_oportunidades' existir mas a coluna 'etapa' estiver faltando, ela será adicionada. É uma operação segura e não destrutiva.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          ## Structure Details:
          - Tabela: crm_oportunidades, crm_interacoes
          - Coluna: etapa
          - Tipo: crm_etapa
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo, apenas verifica e corrige a estrutura.]
*/

-- PASSO 1: Garante a existência do tipo ENUM
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'crm_etapa') THEN
        CREATE TYPE public.crm_etapa AS ENUM ('Lead', 'Prospecção', 'Negociação', 'Ganho', 'Perdido');
    END IF;
END$$;

-- PASSO 2: Garante a existência da tabela de oportunidades
CREATE TABLE IF NOT EXISTS public.crm_oportunidades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome TEXT NOT NULL,
    cliente_id UUID REFERENCES public.clientes(id),
    vendedor_id UUID REFERENCES public.vendedores(id),
    valor_estimado NUMERIC,
    data_fechamento_prevista DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 3: Garante a existência da coluna 'etapa'
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'crm_oportunidades'
        AND column_name = 'etapa'
    ) THEN
        ALTER TABLE public.crm_oportunidades
        ADD COLUMN etapa public.crm_etapa NOT NULL DEFAULT 'Lead'::public.crm_etapa;
    END IF;
END$$;

-- PASSO 4: Garante a existência da tabela de interações
CREATE TABLE IF NOT EXISTS public.crm_interacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    oportunidade_id UUID NOT NULL REFERENCES public.crm_oportunidades(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL,
    descricao TEXT NOT NULL,
    data TIMESTAMPTZ DEFAULT NOW(),
    vendedor_id UUID REFERENCES public.vendedores(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 5: Garante que RLS e políticas de leitura estejam ativas
ALTER TABLE public.crm_oportunidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crm_interacoes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access for crm_oportunidades" ON public.crm_oportunidades;
CREATE POLICY "Public read access for crm_oportunidades" ON public.crm_oportunidades FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read access for crm_interacoes" ON public.crm_interacoes;
CREATE POLICY "Public read access for crm_interacoes" ON public.crm_interacoes FOR SELECT USING (true);

-- PASSO 6: Adiciona o trigger de timestamp para a tabela de oportunidades
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'handle_crm_oportunidades_updated_at'
    ) THEN
        CREATE TRIGGER handle_crm_oportunidades_updated_at
        BEFORE UPDATE ON public.crm_oportunidades
        FOR EACH ROW
        EXECUTE FUNCTION public.handle_updated_at();
    END IF;
END$$;

-- PASSO 7: Adiciona o trigger de timestamp para a tabela de interações
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname = 'handle_crm_interacoes_updated_at'
    ) THEN
        CREATE TRIGGER handle_crm_interacoes_updated_at
        BEFORE UPDATE ON public.crm_interacoes
        FOR EACH ROW
        EXECUTE FUNCTION public.handle_updated_at();
    END IF;
END$$;
