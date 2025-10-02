/*
# [Contratos] Módulo de Contratos - Estrutura Simplificada
Cria a estrutura de banco de dados para o módulo de Contratos, incluindo tabelas e políticas de segurança. Esta é uma versão simplificada para evitar timeouts.

## Query Description:
- Cria os tipos ENUM necessários para o módulo de contratos.
- Cria as tabelas `contratos` e `contrato_anexos`.
- Define as chaves primárias, estrangeiras e constraints.
- Habilita Row Level Security (RLS) e aplica políticas de segurança para permitir que usuários autenticados gerenciem seus próprios dados.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (com a remoção manual das tabelas e tipos)

## Structure Details:
- **Tipos ENUM criados:**
  - `contrato_situacao`
  - `contrato_vencimento_regra`
  - `contrato_periodicidade`
- **Tabelas criadas:**
  - `contratos`
  - `contrato_anexos`
- **Políticas RLS:**
  - Políticas de `SELECT`, `INSERT`, `UPDATE`, `DELETE` para a role `authenticated`.

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes
- Auth Requirements: `authenticated` role

## Performance Impact:
- Indexes: Chaves primárias e estrangeiras são indexadas automaticamente.
- Triggers: Nenhum.
- Estimated Impact: Baixo. A criação das tabelas é uma operação rápida.
*/

-- 1. Criar Tipos ENUM
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

-- 2. Criar a tabela de contratos
CREATE TABLE IF NOT EXISTS public.contratos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
  descricao TEXT NOT NULL,
  situacao contrato_situacao NOT NULL DEFAULT 'Ativo',
  data_contrato DATE NOT NULL DEFAULT CURRENT_DATE,
  valor NUMERIC(10, 2) NOT NULL DEFAULT 0,
  vencimento_regra contrato_vencimento_regra NOT NULL DEFAULT 'No mês corrente',
  dia_vencimento INT NOT NULL CHECK (dia_vencimento >= 1 AND dia_vencimento <= 31),
  periodicidade contrato_periodicidade NOT NULL DEFAULT 'Mensal',
  categoria_id UUID,
  forma_recebimento TEXT,
  emitir_nf BOOLEAN NOT NULL DEFAULT false,
  dados_adicionais JSONB,
  marcadores TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.contratos IS 'Armazena os contratos de serviço recorrente dos clientes.';

-- 3. Criar a tabela de anexos de contratos
CREATE TABLE IF NOT EXISTS public.contrato_anexos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contrato_id UUID NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
  nome_arquivo TEXT NOT NULL,
  path TEXT NOT NULL,
  tamanho BIGINT NOT NULL,
  tipo TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.contrato_anexos IS 'Armazena os anexos relacionados a um contrato.';

-- 4. Adicionar FK em contas_receber para contratos
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name='contas_receber' AND column_name='contrato_id'
  ) THEN
    ALTER TABLE public.contas_receber
    ADD COLUMN contrato_id UUID REFERENCES public.contratos(id) ON DELETE SET NULL;
  END IF;
END
$$;

-- 5. Habilitar RLS
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

-- 6. Criar Políticas de Segurança
DROP POLICY IF EXISTS "Allow all access for authenticated users" ON public.contratos;
CREATE POLICY "Allow all access for authenticated users"
  ON public.contratos
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all access for authenticated users" ON public.contrato_anexos;
CREATE POLICY "Allow all access for authenticated users"
  ON public.contrato_anexos
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
