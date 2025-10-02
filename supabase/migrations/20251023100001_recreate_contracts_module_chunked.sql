/*
# [Refatoração] Módulo de Contratos
Recria a estrutura do banco de dados para o módulo de Contratos, incluindo tabelas, relacionamentos, políticas de segurança (RLS) e uma view para consulta. Este script é uma nova tentativa após um timeout, garantindo a execução em um ambiente estável.

## Query Description: [Este script cria as tabelas `contratos` e `contrato_anexos`, e adiciona a referência de contrato na tabela `contas_receber`. Também configura políticas de segurança para garantir que apenas usuários autenticados possam acessar os dados. Nenhuma tabela existente é apagada, mas `contas_receber` é alterada para adicionar uma nova coluna. Recomenda-se verificar se não há conflitos antes de aplicar.]

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Medium"]
- Requires-Backup: [false]
- Reversible: [true]

## Structure Details:
- Tabelas Criadas: `contratos`, `contrato_anexos`
- Tabelas Alteradas: `contas_receber` (adiciona coluna `contrato_id` e FK)
- Views Criadas: `contratos_view`
- Enums Criados: `contrato_situacao`, `contrato_vencimento_regra`, `contrato_periodicidade`

## Security Implications:
- RLS Status: [Enabled]
- Policy Changes: [Yes]
- Auth Requirements: [authenticated]

## Performance Impact:
- Indexes: [Índices de chave primária e estrangeira são criados automaticamente.]
- Triggers: [Nenhum]
- Estimated Impact: [Baixo. A adição de uma coluna e a criação de novas tabelas não devem impactar significativamente o desempenho existente.]
*/

-- Step 1: Create ENUM types if they don't exist
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


-- Step 2: Create 'contratos' table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.contratos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    descricao TEXT NOT NULL,
    situacao public.contrato_situacao NOT NULL DEFAULT 'Ativo',
    data_contrato DATE NOT NULL DEFAULT CURRENT_DATE,
    valor NUMERIC(10, 2) NOT NULL,
    vencimento_regra public.contrato_vencimento_regra NOT NULL DEFAULT 'No mês corrente',
    dia_vencimento INT NOT NULL CHECK (dia_vencimento >= 1 AND dia_vencimento <= 31),
    periodicidade public.contrato_periodicidade NOT NULL DEFAULT 'Mensal',
    categoria_id UUID,
    forma_recebimento TEXT,
    emitir_nf BOOLEAN NOT NULL DEFAULT false,
    dados_adicionais JSONB,
    marcadores TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE public.contratos IS 'Armazena os contratos de serviço recorrente dos clientes.';


-- Step 3: Create 'contrato_anexos' table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.contrato_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_id UUID NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE public.contrato_anexos IS 'Armazena anexos relacionados aos contratos.';


-- Step 4: Add 'contrato_id' to 'contas_receber' if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'contas_receber' AND column_name = 'contrato_id'
    ) THEN
        ALTER TABLE public.contas_receber ADD COLUMN contrato_id UUID;
    END IF;
END$$;

-- Step 5: Add foreign key constraint if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'fk_contas_receber_contrato'
    ) THEN
        ALTER TABLE public.contas_receber ADD CONSTRAINT fk_contas_receber_contrato
            FOREIGN KEY (contrato_id) REFERENCES public.contratos(id) ON DELETE SET NULL;
    END IF;
END$$;


-- Step 6: Enable RLS on tables
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

-- Step 7: Drop existing policies to avoid conflicts, then recreate them
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.contratos;
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.contratos
FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.contrato_anexos;
CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.contrato_anexos
FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');


-- Step 8: Create or replace the view
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
    (SELECT COUNT(*) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status = 'A_RECEBER') AS contas_em_aberto,
    (SELECT MAX(cr.data_pagamento) FROM public.contas_receber cr WHERE cr.contrato_id = c.id AND cr.status = 'RECEBIDO') AS ultimo_pagamento
FROM
    public.contratos c
JOIN
    public.clientes cl ON c.cliente_id = cl.id;


-- Step 9: Set view owner and RLS policy
ALTER VIEW public.contratos_view OWNER TO postgres;

DROP POLICY IF EXISTS "Permitir leitura para usuários autenticados na view" ON public.contratos_view;
CREATE POLICY "Permitir leitura para usuários autenticados na view" ON public.contratos_view
FOR SELECT
USING (auth.role() = 'authenticated');
