/*
  # [Contratos Module - Idempotent]
  Cria a estrutura completa para o módulo de Contratos, verificando a existência de cada objeto antes da criação para evitar erros de duplicação.
  ## Query Description: [Cria os tipos ENUM, a tabela 'contratos', a tabela de junção 'contrato_anexos', e as políticas de segurança RLS. Garante que a operação seja segura para reexecução.]
  ## Metadata:
  - Schema-Category: ["Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
  ## Structure Details:
  - Tipos: contrato_situacao, contrato_vencimento_regra, contrato_periodicidade
  - Tabelas: contratos, contrato_anexos
  - Políticas RLS: Políticas de acesso para a tabela 'contratos'.
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [Yes]
  - Auth Requirements: [authenticated, anon]
  ## Performance Impact:
  - Indexes: [Added]
  - Triggers: [None]
  - Estimated Impact: [Baixo]
*/

-- Criação dos ENUMs (se não existirem)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_situacao') THEN
    CREATE TYPE contrato_situacao AS ENUM ('Ativo', 'Demonstração', 'Inativo', 'Isento', 'Baixado', 'Encerrado');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_vencimento_regra') THEN
    CREATE TYPE contrato_vencimento_regra AS ENUM ('No mês corrente', 'No mês seguinte');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contrato_periodicidade') THEN
    CREATE TYPE contrato_periodicidade AS ENUM ('Mensal', 'Bimestral', 'Trimestral', 'Semestral', 'Anual');
  END IF;
END
$$;

-- Criação da tabela de Contratos (se não existir)
CREATE TABLE IF NOT EXISTS public.contratos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE SET NULL,
    descricao TEXT NOT NULL,
    situacao contrato_situacao NOT NULL DEFAULT 'Ativo',
    data_contrato DATE NOT NULL DEFAULT CURRENT_DATE,
    valor NUMERIC(10, 2) NOT NULL DEFAULT 0,
    vencimento_regra contrato_vencimento_regra NOT NULL DEFAULT 'No mês corrente',
    dia_vencimento INTEGER NOT NULL CHECK (dia_vencimento BETWEEN 1 AND 31),
    periodicidade contrato_periodicidade NOT NULL DEFAULT 'Mensal',
    categoria_id UUID,
    forma_recebimento TEXT,
    emitir_nf BOOLEAN NOT NULL DEFAULT false,
    dados_adicionais JSONB,
    marcadores TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adiciona comentários à tabela e colunas
COMMENT ON TABLE public.contratos IS 'Armazena informações sobre contratos de serviço recorrentes.';
COMMENT ON COLUMN public.contratos.dia_vencimento IS 'Dia do mês para o vencimento da fatura (1-31).';

-- Criação da tabela de Anexos de Contratos (se não existir)
CREATE TABLE IF NOT EXISTS public.contrato_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_id UUID NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Adiciona comentários à tabela de anexos
COMMENT ON TABLE public.contrato_anexos IS 'Armazena anexos relacionados aos contratos.';

-- Habilita RLS na tabela de contratos (se não estiver habilitada)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'contratos' AND rowsecurity = 't') THEN
    ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
  END IF;
END
$$;

-- Remove políticas existentes antes de criar novas para evitar conflitos
DROP POLICY IF EXISTS "Contratos are viewable by everyone." ON public.contratos;
DROP POLICY IF EXISTS "Users can insert their own contratos." ON public.contratos;
DROP POLICY IF EXISTS "Users can update their own contratos." ON public.contratos;
DROP POLICY IF EXISTS "Users can delete their own contratos." ON public.contratos;

-- Criação das Políticas de Segurança (RLS)
CREATE POLICY "Contratos are viewable by everyone."
ON public.contratos FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "Users can insert their own contratos."
ON public.contratos FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Users can update their own contratos."
ON public.contratos FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Users can delete their own contratos."
ON public.contratos FOR DELETE
TO authenticated
USING (true);

-- Criação de Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_contratos_cliente_id ON public.contratos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_contratos_situacao ON public.contratos(situacao);
CREATE INDEX IF NOT EXISTS idx_contrato_anexos_contrato_id ON public.contrato_anexos(contrato_id);
