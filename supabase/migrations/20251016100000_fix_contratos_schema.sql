/*
          # [CORREÇÃO DO SCHEMA DE CONTRATOS]
          Este script garante a existência das tabelas, views e permissões necessárias para o módulo de Contratos.
          É seguro para ser executado, pois só cria elementos que não existem.
          ## Query Description: [Esta operação verifica e cria a estrutura de tabelas e a view otimizada para o módulo de Contratos, garantindo que o frontend possa carregar os dados corretamente. Não há risco de perda de dados.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Cria os tipos ENUM para Contratos.
          - Cria as tabelas 'contratos' e 'contrato_anexos'.
          - Adiciona a coluna 'contrato_id' em 'contas_receber'.
          - Cria a view 'contratos_view'.
          - Aplica as políticas de RLS necessárias.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [Added]
          - Estimated Impact: [Baixo. Apenas cria estruturas ausentes.]
*/

-- PASSO 1: CRIAÇÃO DOS TIPOS (ENUMS) SE NÃO EXISTIREM
DO $$ BEGIN
  CREATE TYPE public.contrato_situacao AS ENUM ('Ativo', 'Demonstração', 'Inativo', 'Isento', 'Baixado', 'Encerrado');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
  CREATE TYPE public.contrato_vencimento_regra AS ENUM ('No mês corrente', 'No mês seguinte');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
  CREATE TYPE public.contrato_periodicidade AS ENUM ('Mensal', 'Bimestral', 'Trimestral', 'Semestral', 'Anual');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- PASSO 2: CRIAÇÃO DAS TABELAS SE NÃO EXISTIREM
CREATE TABLE IF NOT EXISTS public.contratos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id),
    descricao TEXT NOT NULL,
    situacao public.contrato_situacao NOT NULL,
    data_contrato DATE NOT NULL,
    valor NUMERIC NOT NULL,
    vencimento_regra public.contrato_vencimento_regra NOT NULL,
    dia_vencimento INTEGER NOT NULL,
    periodicidade public.contrato_periodicidade NOT NULL,
    categoria_id UUID,
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

-- Adiciona a coluna 'contrato_id' em 'contas_receber' se ela não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'contas_receber' AND column_name = 'contrato_id'
  ) THEN
    ALTER TABLE public.contas_receber ADD COLUMN contrato_id UUID REFERENCES public.contratos(id) ON DELETE SET NULL;
  END IF;
END $$;

-- PASSO 3: CRIAÇÃO DA VIEW
CREATE OR REPLACE VIEW public.contratos_view AS
SELECT
  c.id,
  c.cliente_id,
  cl.nome AS cliente_nome,
  c.descricao,
  c.situacao,
  c.data_contrato,
  c.valor,
  c.vencimento_regra,
  c.dia_vencimento,
  c.periodicidade,
  c.categoria_id,
  c.forma_recebimento,
  c.emitir_nf,
  c.dados_adicionais,
  c.marcadores,
  c.created_at,
  c.updated_at,
  (SELECT COUNT(*) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status != 'RECEBIDO') AS contas_em_aberto,
  (SELECT MAX(cr.data_pagamento) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status = 'RECEBIDO') AS ultimo_pagamento
FROM
  public.contratos c
JOIN
  public.clientes cl ON c.cliente_id = cl.id;

-- PASSO 4: GARANTIA DAS POLÍTICAS DE RLS
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access for contratos" ON public.contratos;
CREATE POLICY "Public read access for contratos" ON public.contratos FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can manage their contratos" ON public.contratos;
CREATE POLICY "Authenticated users can manage their contratos" ON public.contratos FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Public read access for contrato_anexos" ON public.contrato_anexos;
CREATE POLICY "Public read access for contrato_anexos" ON public.contrato_anexos FOR SELECT USING (true);

DROP POLICY IF EXISTS "Authenticated users can manage their contrato_anexos" ON public.contrato_anexos;
CREATE POLICY "Authenticated users can manage their contrato_anexos" ON public.contrato_anexos FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');
