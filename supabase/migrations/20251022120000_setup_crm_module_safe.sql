/*
          # [CONFIGURAÇÃO DO MÓDULO CRM - CORREÇÃO]
          Este script cria as tabelas e tipos necessários para o módulo de CRM de forma segura.
          Ele é 'idempotente', o que significa que pode ser executado várias vezes sem causar erros.
          Ele apenas criará os elementos se eles ainda não existirem.

          ## Query Description: [Operação segura que prepara o banco de dados para o módulo de CRM, criando tabelas e tipos apenas se eles não existirem. Não há risco de perda de dados.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          
          ## Structure Details:
          - Cria o tipo 'crm_etapa'.
          - Cria as tabelas 'crm_oportunidades' e 'crm_interacoes'.
          - Adiciona chaves estrangeiras e habilita RLS.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [Added]
          - Estimated Impact: [Baixo. Apenas adiciona novas estruturas.]
*/

-- Cria o tipo ENUM para as etapas do CRM, somente se ele não existir.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'crm_etapa') THEN
        CREATE TYPE public.crm_etapa AS ENUM (
            'Lead',
            'Prospecção',
            'Negociação',
            'Ganho',
            'Perdido'
        );
    END IF;
END$$;

-- Cria a tabela de oportunidades, somente se ela não existir.
CREATE TABLE IF NOT EXISTS public.crm_oportunidades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome TEXT NOT NULL,
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE SET NULL,
    vendedor_id UUID REFERENCES public.vendedores(id) ON DELETE SET NULL,
    valor_estimado NUMERIC,
    etapa public.crm_etapa NOT NULL DEFAULT 'Lead',
    data_fechamento_prevista DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cria a tabela de interações, somente se ela não existir.
CREATE TABLE IF NOT EXISTS public.crm_interacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    oportunidade_id UUID NOT NULL REFERENCES public.crm_oportunidades(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL,
    descricao TEXT NOT NULL,
    data TIMESTAMPTZ DEFAULT NOW(),
    vendedor_id UUID REFERENCES public.vendedores(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Garante que a coluna 'etapa' exista, caso a tabela tenha sido criada parcialmente.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'crm_oportunidades'
        AND column_name = 'etapa'
    ) THEN
        ALTER TABLE public.crm_oportunidades ADD COLUMN etapa public.crm_etapa NOT NULL DEFAULT 'Lead';
    END IF;
END$$;

-- Habilita RLS e cria políticas de acesso de forma segura.
ALTER TABLE public.crm_oportunidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crm_interacoes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public access for crm_oportunidades" ON public.crm_oportunidades;
CREATE POLICY "Public access for crm_oportunidades" ON public.crm_oportunidades FOR ALL USING (true);

DROP POLICY IF EXISTS "Public access for crm_interacoes" ON public.crm_interacoes;
CREATE POLICY "Public access for crm_interacoes" ON public.crm_interacoes FOR ALL USING (true);

-- Garante que os triggers de timestamp existam.
DROP TRIGGER IF EXISTS on_crm_oportunidades_update ON public.crm_oportunidades;
CREATE TRIGGER on_crm_oportunidades_update
  BEFORE UPDATE ON public.crm_oportunidades
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();

DROP TRIGGER IF EXISTS on_crm_interacoes_update ON public.crm_interacoes;
CREATE TRIGGER on_crm_interacoes_update
  BEFORE UPDATE ON public.crm_interacoes
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_updated_at();
