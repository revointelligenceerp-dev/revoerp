/*
          # [CRIAÇÃO DO MÓDULO DE CONTRATOS]
          Este script cria as tabelas, tipos e views necessários para o módulo de gestão de contratos.
          Ele é idempotente, ou seja, pode ser executado várias vezes sem causar erros.
          ## Query Description: [Esta operação adiciona novas tabelas e uma view para o módulo de contratos. Não há risco de perda de dados existentes. A view 'contratos_view' é criada com 'SECURITY INVOKER' para garantir que as políticas de segurança de linha (RLS) sejam respeitadas.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Tabelas: contratos, contrato_anexos
          - Views: contratos_view
          - Types: contrato_situacao, contrato_vencimento_regra, contrato_periodicidade
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. A view é otimizada para leitura.]
*/
DO $$
BEGIN
    -- CRIAÇÃO DOS TIPOS (ENUMS)
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_situacao') THEN
        CREATE TYPE public.contrato_situacao AS ENUM ('Ativo', 'Demonstração', 'Inativo', 'Isento', 'Baixado', 'Encerrado');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_vencimento_regra') THEN
        CREATE TYPE public.contrato_vencimento_regra AS ENUM ('No mês corrente', 'No mês seguinte');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_periodicidade') THEN
        CREATE TYPE public.contrato_periodicidade AS ENUM ('Mensal', 'Bimestral', 'Trimestral', 'Semestral', 'Anual');
    END IF;

    -- CRIAÇÃO DAS TABELAS
    CREATE TABLE IF NOT EXISTS public.contratos (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        cliente_id UUID NOT NULL REFERENCES public.clientes(id),
        descricao TEXT NOT NULL,
        situacao public.contrato_situacao NOT NULL,
        data_contrato DATE NOT NULL,
        valor NUMERIC(10, 2) NOT NULL,
        vencimento_regra public.contrato_vencimento_regra NOT NULL,
        dia_vencimento INTEGER NOT NULL,
        periodicidade public.contrato_periodicidade NOT NULL,
        categoria_id TEXT,
        forma_recebimento TEXT,
        emitir_nf BOOLEAN DEFAULT FALSE,
        dados_adicionais JSONB,
        marcadores TEXT[],
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS public.contrato_anexos (
        id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
        contrato_id UUID NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
        nome_arquivo TEXT NOT NULL,
        path TEXT NOT NULL,
        tamanho BIGINT NOT NULL,
        tipo TEXT NOT NULL,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    -- Adiciona a coluna de vínculo em contas_receber, se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='contrato_id') THEN
        ALTER TABLE public.contas_receber ADD COLUMN contrato_id UUID REFERENCES public.contratos(id) ON DELETE SET NULL;
    END IF;

    -- CRIAÇÃO DA VIEW OTIMIZADA
    CREATE OR REPLACE VIEW public.contratos_view
    WITH (security_invoker = true) AS
    SELECT
        c.id,
        c.descricao,
        c.situacao,
        c.data_contrato,
        c.valor,
        c.dia_vencimento,
        c.periodicidade,
        c.marcadores,
        c.created_at,
        c.updated_at,
        cl.id AS cliente_id,
        cl.nome AS cliente_nome,
        (SELECT COUNT(*) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status = 'A_RECEBER' OR cr.status = 'VENCIDO') AS contas_em_aberto,
        (SELECT MAX(cr.data_pagamento) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status = 'RECEBIDO') AS ultimo_pagamento
    FROM
        public.contratos c
    JOIN
        public.clientes cl ON c.cliente_id = cl.id;

    -- HABILITA RLS E CRIA POLÍTICAS
    ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

    DROP POLICY IF EXISTS "Public read access for contratos" ON public.contratos;
    CREATE POLICY "Public read access for contratos" ON public.contratos FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public write access for contratos" ON public.contratos;
    CREATE POLICY "Public write access for contratos" ON public.contratos FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public read access for contrato_anexos" ON public.contrato_anexos;
    CREATE POLICY "Public read access for contrato_anexos" ON public.contrato_anexos FOR SELECT USING (true);
    DROP POLICY IF EXISTS "Public write access for contrato_anexos" ON public.contrato_anexos;
    CREATE POLICY "Public write access for contrato_anexos" ON public.contrato_anexos FOR ALL USING (true) WITH CHECK (true);
END $$;
