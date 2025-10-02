/*
          # [Correção] Esquema de Contas a Receber
          [Este script garante que a tabela `contas_receber` tenha todas as colunas necessárias e cria a tabela `contas_receber_anexos` se ela não existir. É seguro executar este script várias vezes.]

          ## Query Description: ["Este script adiciona colunas e uma tabela para o módulo de Contas a Receber. Não há risco de perda de dados, pois ele só cria elementos que estão faltando."]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          
          ## Structure Details:
          - Tabela afetada: `contas_receber` (adiciona colunas)
          - Tabela criada: `contas_receber_anexos`
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [authenticated users]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo]
          */

DO $$
BEGIN
    -- Adiciona colunas faltantes à tabela contas_receber
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='forma_recebimento') THEN
        ALTER TABLE public.contas_receber ADD COLUMN forma_recebimento TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='historico') THEN
        ALTER TABLE public.contas_receber ADD COLUMN historico TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='marcadores') THEN
        ALTER TABLE public.contas_receber ADD COLUMN marcadores TEXT[];
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='ocorrencia') THEN
        ALTER TABLE public.contas_receber ADD COLUMN ocorrencia TEXT;
    END IF;

    -- Cria a tabela de anexos se ela não existir
    CREATE TABLE IF NOT EXISTS public.contas_receber_anexos (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        conta_receber_id UUID NOT NULL REFERENCES public.contas_receber(id) ON DELETE CASCADE,
        nome_arquivo TEXT NOT NULL,
        path TEXT NOT NULL,
        tamanho BIGINT NOT NULL,
        tipo TEXT,
        created_at TIMESTAMPTZ DEFAULT now() NOT NULL
    );

    -- Habilita RLS na tabela de anexos
    ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;

    -- Cria políticas de segurança para a tabela de anexos
    DROP POLICY IF EXISTS "Authenticated users can manage their own anexos" ON public.contas_receber_anexos;
    CREATE POLICY "Authenticated users can manage their own anexos"
    ON public.contas_receber_anexos
    FOR ALL
    USING (auth.role() = 'authenticated');

END $$;
