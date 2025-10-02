/*
          # [CORREÇÃO DA VIEW DE CONTRATOS]
          Este script corrige a criação da view 'contratos_view', garantindo que ela seja removida antes de ser recriada para evitar conflitos de coluna. Também ajusta a lógica da view para maior precisão e segurança.

          ## Query Description: [Esta operação corrige a estrutura da 'view' de contratos no banco de dados. É uma operação segura que não afeta os dados existentes e resolve o erro de migração anterior, além de corrigir uma falha de segurança crítica.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - View afetada: public.contratos_view
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- Garante que os tipos ENUM existam antes de criar a view.
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
END
$$;

-- Garante que as tabelas existam antes de criar a view.
CREATE TABLE IF NOT EXISTS public.contratos (
    id uuid DEFAULT uuid_generate_v4() NOT NULL PRIMARY KEY,
    cliente_id uuid NOT NULL REFERENCES public.clientes(id),
    descricao text NOT NULL,
    situacao public.contrato_situacao NOT NULL,
    data_contrato date NOT NULL,
    valor numeric NOT NULL,
    vencimento_regra public.contrato_vencimento_regra NOT NULL,
    dia_vencimento integer NOT NULL,
    periodicidade public.contrato_periodicidade NOT NULL,
    categoria_id uuid,
    forma_recebimento text,
    emitir_nf boolean DEFAULT false NOT NULL,
    dados_adicionais jsonb,
    marcadores text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.contrato_anexos (
    id uuid DEFAULT uuid_generate_v4() NOT NULL PRIMARY KEY,
    contrato_id uuid NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
    nome_arquivo text NOT NULL,
    path text NOT NULL,
    tamanho integer NOT NULL,
    tipo text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Garante que a coluna de relacionamento em contas_receber exista.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='contas_receber' AND column_name='contrato_id'
    ) THEN
        ALTER TABLE public.contas_receber ADD COLUMN contrato_id uuid REFERENCES public.contratos(id) ON DELETE SET NULL;
    END IF;
END
$$;

-- Remove a view antiga antes de criar a nova para evitar erros de coluna.
DROP VIEW IF EXISTS public.contratos_view;

-- Recria a view com a estrutura correta e segura.
CREATE VIEW public.contratos_view
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
        c.cliente_id,
        cl.nome AS cliente_nome,
        (SELECT COUNT(*) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND (cr.status = 'A_RECEBER' OR cr.status = 'VENCIDO')) AS contas_em_aberto,
        (SELECT MAX(cr.data_pagamento) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status = 'RECEBIDO') AS ultimo_pagamento
    FROM
        public.contratos c
    LEFT JOIN
        public.clientes cl ON c.cliente_id = cl.id;

-- Garante que as políticas de segurança estejam aplicadas.
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read access for contratos" ON public.contratos;
CREATE POLICY "Public read access for contratos" ON public.contratos FOR SELECT USING (true);

ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read access for contrato_anexos" ON public.contrato_anexos;
CREATE POLICY "Public read access for contrato_anexos" ON public.contrato_anexos FOR SELECT USING (true);
