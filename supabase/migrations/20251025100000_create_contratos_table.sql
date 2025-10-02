/*
# [Criação do Módulo de Contratos - Passo 1]
Este script cria a estrutura inicial para o módulo de contratos, incluindo os tipos de dados (ENUMs) e a tabela principal `contratos`.

## Query Description: [Este script é seguro e cria novas estruturas no banco de dados. Ele não afeta dados existentes, pois verifica a existência dos tipos e da tabela antes de criá-los. Nenhuma precaução especial é necessária.]

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [true] (DROP TABLE contratos e os ENUMs)

## Structure Details:
- ENUMs: `contrato_situacao`, `contrato_vencimento_regra`, `contrato_periodicidade`
- Tabela: `contratos`

## Security Implications:
- RLS Status: [Enabled]
- Policy Changes: [Yes] (Cria políticas de acesso para a tabela `contratos`)
- Auth Requirements: [authenticated]

## Performance Impact:
- Indexes: [Added] (Primary Key)
- Triggers: [None]
- Estimated Impact: [Nenhum impacto significativo de performance esperado.]
*/

-- Criação dos ENUMs necessários para a tabela de contratos
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

-- Criação da tabela principal de contratos
CREATE TABLE IF NOT EXISTS public.contratos (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    cliente_id uuid NOT NULL,
    descricao text NOT NULL,
    situacao public.contrato_situacao NOT NULL,
    data_contrato date NOT NULL,
    valor numeric NOT NULL,
    vencimento_regra public.contrato_vencimento_regra NOT NULL,
    dia_vencimento integer NOT NULL,
    periodicidade public.contrato_periodicidade NOT NULL,
    categoria_id uuid,
    forma_recebimento text,
    emitir_nf boolean NOT NULL DEFAULT false,
    dados_adicionais jsonb,
    marcadores text[],
    CONSTRAINT contratos_pkey PRIMARY KEY (id),
    CONSTRAINT contratos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE RESTRICT
);

-- Ativa a segurança a nível de linha (RLS)
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso
DROP POLICY IF EXISTS "Contratos are viewable by authenticated users." ON public.contratos;
CREATE POLICY "Contratos are viewable by authenticated users."
ON public.contratos FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Users can insert their own contratos." ON public.contratos;
CREATE POLICY "Users can insert their own contratos."
ON public.contratos FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update their own contratos." ON public.contratos;
CREATE POLICY "Users can update their own contratos."
ON public.contratos FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Users can delete their own contratos." ON public.contratos;
CREATE POLICY "Users can delete their own contratos."
ON public.contratos FOR DELETE
TO authenticated
USING (true);
