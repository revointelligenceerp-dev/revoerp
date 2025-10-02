/*
          # [RECONSTRUÇÃO E SEED DO MÓDULO DE CONTRATOS]
          Este script apaga e recria toda a estrutura do módulo de Contratos para resolver inconsistências.
          Dados existentes nas tabelas 'contratos' e 'contrato_anexos' serão perdidos.
          ## Query Description: [Esta operação irá resetar completamente o módulo de Contratos, apagando e recriando as tabelas e visões relacionadas. Isso é necessário para corrigir erros de esquema persistentes e garantir a consistência dos dados. As mudanças são irreversíveis para este módulo.]
          ## Metadata:
          - Schema-Category: ["Dangerous"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [true]
          - Reversible: [false]
          ## Structure Details:
          - Tables: contratos, contrato_anexos
          - Views: contratos_view
          - Types: contrato_situacao, contrato_vencimento_regra, contrato_periodicidade
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [Re-created]
          - Triggers: [N/A]
          - Estimated Impact: [Reset do módulo, seguido por performance otimizada.]
*/

-- PASSO 1: LIMPEZA COMPLETA DO MÓDULO DE CONTRATOS
DROP VIEW IF EXISTS public.contratos_view;
ALTER TABLE public.contas_receber DROP CONSTRAINT IF EXISTS contas_receber_contrato_id_fkey;
ALTER TABLE public.contas_receber DROP COLUMN IF EXISTS contrato_id;
DROP TABLE IF EXISTS public.contrato_anexos;
DROP TABLE IF EXISTS public.contratos;
DROP TYPE IF EXISTS public.contrato_situacao;
DROP TYPE IF EXISTS public.contrato_vencimento_regra;
DROP TYPE IF EXISTS public.contrato_periodicidade;

-- PASSO 2: CRIAÇÃO DOS TIPOS (ENUMS)
CREATE TYPE public.contrato_situacao AS ENUM ('Ativo', 'Demonstração', 'Inativo', 'Isento', 'Baixado', 'Encerrado');
CREATE TYPE public.contrato_vencimento_regra AS ENUM ('No mês corrente', 'No mês seguinte');
CREATE TYPE public.contrato_periodicidade AS ENUM ('Mensal', 'Bimestral', 'Trimestral', 'Semestral', 'Anual');

-- PASSO 3: CRIAÇÃO DAS TABELAS
CREATE TABLE public.contratos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id),
    descricao TEXT NOT NULL,
    situacao contrato_situacao NOT NULL,
    data_contrato DATE NOT NULL,
    valor NUMERIC NOT NULL,
    vencimento_regra contrato_vencimento_regra NOT NULL,
    dia_vencimento INTEGER NOT NULL,
    periodicidade contrato_periodicidade NOT NULL,
    categoria_id TEXT,
    forma_recebimento TEXT,
    emitir_nf BOOLEAN DEFAULT FALSE NOT NULL,
    dados_adicionais JSONB,
    marcadores TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.contrato_anexos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    contrato_id UUID NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 4: ADIÇÃO DA CHAVE ESTRANGEIRA EM 'contas_receber'
ALTER TABLE public.contas_receber
ADD COLUMN contrato_id UUID REFERENCES public.contratos(id) ON DELETE SET NULL;

-- PASSO 5: CRIAÇÃO DA VIEW COM SEGURANÇA
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
    (SELECT COUNT(*) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND (cr.status = 'A_RECEBER' OR cr.status = 'VENCIDO')) AS contas_em_aberto,
    (SELECT MAX(cr.data_pagamento) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status = 'RECEBIDO') AS ultimo_pagamento
FROM
    public.contratos c
JOIN
    public.clientes cl ON c.cliente_id = cl.id;

-- PASSO 6: HABILITAÇÃO DO RLS E POLÍTICAS
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read access for contratos" ON public.contratos;
CREATE POLICY "Public read access for contratos" ON public.contratos FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow all for authenticated users on contratos" ON public.contratos;
CREATE POLICY "Allow all for authenticated users on contratos" ON public.contratos FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Public read access for contrato_anexos" ON public.contrato_anexos;
CREATE POLICY "Public read access for contrato_anexos" ON public.contrato_anexos FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow all for authenticated users on contrato_anexos" ON public.contrato_anexos;
CREATE POLICY "Allow all for authenticated users on contrato_anexos" ON public.contrato_anexos FOR ALL USING (auth.role() = 'authenticated');

-- PASSO 7: INSERÇÃO DE DADOS DE EXEMPLO
DO $$
DECLARE
    cliente1_id UUID;
    cliente2_id UUID;
BEGIN
    SELECT id INTO cliente1_id FROM public.clientes WHERE nome = 'Empresa de Tecnologia Visionária' LIMIT 1;
    SELECT id INTO cliente2_id FROM public.clientes WHERE nome = 'Soluções Criativas Ltda' LIMIT 1;

    IF cliente1_id IS NOT NULL AND cliente2_id IS NOT NULL THEN
        INSERT INTO public.contratos (cliente_id, descricao, situacao, data_contrato, valor, vencimento_regra, dia_vencimento, periodicidade)
        VALUES
            (cliente1_id, 'Contrato de Suporte Técnico Nível 1', 'Ativo', '2024-01-15', 1500.00, 'No mês corrente', 10, 'Mensal'),
            (cliente2_id, 'Manutenção Preventiva de Servidores', 'Ativo', '2024-03-01', 2500.00, 'No mês seguinte', 15, 'Trimestral'),
            (cliente1_id, 'Licenciamento de Software ERP (Anual)', 'Isento', '2024-02-20', 12000.00, 'No mês corrente', 25, 'Anual'),
            (cliente2_id, 'Consultoria de Segurança da Informação', 'Encerrado', '2023-05-10', 8000.00, 'No mês corrente', 5, 'Mensal');
    END IF;
END $$;
