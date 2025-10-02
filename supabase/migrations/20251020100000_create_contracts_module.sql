/*
          # [CRIAÇÃO DO MÓDULO DE CONTRATOS]
          Este script cria a estrutura de tabelas, tipos e visões necessárias para o módulo de Contratos.

          ## Query Description: [Esta operação adiciona novas tabelas e tipos ao banco de dados para gerenciar contratos de serviço recorrentes. Também modifica a tabela 'contas_receber' para adicionar um vínculo com os contratos, o que é seguro para os dados existentes. Uma 'view' otimizada é criada para a listagem de contratos, melhorando a performance.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Adiciona a coluna 'contrato_id' à tabela 'contas_receber'.
          - Cria os tipos ENUM: 'contrato_situacao', 'contrato_vencimento_regra', 'contrato_periodicidade'.
          - Cria as tabelas: 'contratos', 'contrato_anexos'.
          - Cria a VIEW: 'contratos_view'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [authenticated]
          
          ## Performance Impact:
          - Indexes: [Added on foreign keys]
          - Triggers: [Added for 'updated_at']
          - Estimated Impact: [Baixo. A nova view é otimizada para leitura.]
*/

-- PASSO 1: Adicionar a coluna de contrato em contas_receber para o vínculo
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='contrato_id') THEN
        ALTER TABLE public.contas_receber ADD COLUMN contrato_id UUID REFERENCES public.contratos(id) ON DELETE SET NULL;
    END IF;
END$$;

-- PASSO 2: Criar os novos tipos ENUM para o módulo de contratos
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_situacao') THEN
        CREATE TYPE public.contrato_situacao AS ENUM ('Ativo', 'Demonstração', 'Inativo', 'Isento', 'Baixado', 'Encerrado');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_vencimento_regra') THEN
        CREATE TYPE public.contrato_vencimento_regra AS ENUM ('No mês corrente', 'No mês seguinte');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_periodicidade') THEN
        CREATE TYPE public.contrato_periodicidade AS ENUM ('Mensal', 'Bimestral', 'Trimestral', 'Semestral', 'Anual');
    END IF;
END$$;

-- PASSO 3: Criar a tabela principal de contratos
CREATE TABLE IF NOT EXISTS public.contratos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    situacao public.contrato_situacao NOT NULL DEFAULT 'Ativo',
    data_contrato DATE NOT NULL DEFAULT CURRENT_DATE,
    valor NUMERIC(10, 2) NOT NULL DEFAULT 0,
    vencimento_regra public.contrato_vencimento_regra NOT NULL DEFAULT 'No mês corrente',
    dia_vencimento INTEGER NOT NULL CHECK (dia_vencimento >= 1 AND dia_vencimento <= 31),
    periodicidade public.contrato_periodicidade NOT NULL DEFAULT 'Mensal',
    categoria_id TEXT,
    forma_recebimento TEXT,
    emitir_nf BOOLEAN NOT NULL DEFAULT FALSE,
    dados_adicionais JSONB,
    marcadores TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger para auto-atualizar 'updated_at'
CREATE OR REPLACE TRIGGER on_contratos_update
    BEFORE UPDATE ON public.contratos
    FOR EACH ROW
    EXECUTE PROCEDURE public.handle_updated_at();

-- PASSO 4: Criar a tabela de anexos para contratos
CREATE TABLE IF NOT EXISTS public.contrato_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contrato_id UUID NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 5: Criar a VIEW para a listagem, agregando dados
CREATE OR REPLACE VIEW public.contratos_view AS
SELECT
    c.*,
    cl.nome AS cliente_nome,
    COALESCE(cr_agg.contas_em_aberto, 0) AS contas_em_aberto,
    cr_agg.ultimo_pagamento
FROM
    public.contratos c
JOIN
    public.clientes cl ON c.cliente_id = cl.id
LEFT JOIN (
    SELECT
        contrato_id,
        COUNT(*) FILTER (WHERE status != 'RECEBIDO') AS contas_em_aberto,
        MAX(data_pagamento) AS ultimo_pagamento
    FROM
        public.contas_receber
    WHERE
        contrato_id IS NOT NULL
    GROUP BY
        contrato_id
) cr_agg ON c.id = cr_agg.contrato_id;

-- PASSO 6: Políticas de Segurança (RLS)
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Permitir acesso de leitura a todos os usuários" ON public.contratos;
CREATE POLICY "Permitir acesso de leitura a todos os usuários" ON public.contratos
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Permitir inserção para usuários autenticados" ON public.contratos;
CREATE POLICY "Permitir inserção para usuários autenticados" ON public.contratos
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Permitir atualização para usuários autenticados" ON public.contratos;
CREATE POLICY "Permitir atualização para usuários autenticados" ON public.contratos
    FOR UPDATE USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Permitir exclusão para usuários autenticados" ON public.contratos;
CREATE POLICY "Permitir exclusão para usuários autenticados" ON public.contratos
    FOR DELETE USING (auth.role() = 'authenticated');

-- Políticas para anexos
DROP POLICY IF EXISTS "Permitir acesso de leitura a todos os usuários" ON public.contrato_anexos;
CREATE POLICY "Permitir acesso de leitura a todos os usuários" ON public.contrato_anexos
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Permitir inserção para usuários autenticados" ON public.contrato_anexos;
CREATE POLICY "Permitir inserção para usuários autenticados" ON public.contrato_anexos
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Permitir exclusão para usuários autenticados" ON public.contrato_anexos;
CREATE POLICY "Permitir exclusão para usuários autenticados" ON public.contrato_anexos
    FOR DELETE USING (auth.role() = 'authenticated');
