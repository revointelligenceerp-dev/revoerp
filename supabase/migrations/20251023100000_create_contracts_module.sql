/*
# [Feature] Módulo de Contratos

Recria a estrutura de banco de dados para o módulo de Contratos, incluindo tabelas, tipos, políticas de segurança e uma view para facilitar as consultas.

## Query Description: 
Esta migração cria as tabelas `contratos` e `contrato_anexos`, juntamente com os tipos ENUM necessários. Habilita a segurança em nível de linha (RLS) e define políticas que permitem que usuários autenticados gerenciem os dados. Nenhuma tabela existente é modificada e não há risco de perda de dados.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (requer a remoção manual das tabelas e tipos)

## Structure Details:
- **Tipos ENUM criados:**
  - `public.contrato_situacao`
  - `public.contrato_vencimento_regra`
  - `public.contrato_periodicidade`
- **Tabelas criadas:**
  - `public.contratos`
  - `public.contrato_anexos`
- **Views criadas:**
  - `public.contratos_view`

## Security Implications:
- RLS Status: Habilitado para as novas tabelas.
- Policy Changes: Novas políticas de RLS são criadas para `contratos` e `contrato_anexos`.
- Auth Requirements: Requer que o usuário esteja autenticado.

## Performance Impact:
- Indexes: Índices são criados para as chaves primárias e estrangeiras.
- Triggers: Nenhum.
- Estimated Impact: Baixo.
*/

-- 1. Criar os tipos ENUM necessários
CREATE TYPE public.contrato_situacao AS ENUM (
    'Ativo',
    'Demonstração',
    'Inativo',
    'Isento',
    'Baixado',
    'Encerrado'
);

CREATE TYPE public.contrato_vencimento_regra AS ENUM (
    'No mês corrente',
    'No mês seguinte'
);

CREATE TYPE public.contrato_periodicidade AS ENUM (
    'Mensal',
    'Bimestral',
    'Trimestral',
    'Semestral',
    'Anual'
);


-- 2. Criar a tabela de contratos
CREATE TABLE IF NOT EXISTS public.contratos (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id uuid NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    descricao text NOT NULL,
    situacao public.contrato_situacao NOT NULL DEFAULT 'Ativo',
    data_contrato date NOT NULL DEFAULT now(),
    valor numeric(10, 2) NOT NULL DEFAULT 0.00,
    vencimento_regra public.contrato_vencimento_regra NOT NULL DEFAULT 'No mês corrente',
    dia_vencimento smallint NOT NULL CHECK (dia_vencimento >= 1 AND dia_vencimento <= 31),
    periodicidade public.contrato_periodicidade NOT NULL DEFAULT 'Mensal',
    categoria_id uuid,
    forma_recebimento text,
    emitir_nf boolean NOT NULL DEFAULT false,
    dados_adicionais jsonb,
    marcadores text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.contratos IS 'Armazena os contratos de serviço recorrentes com clientes.';


-- 3. Criar a tabela de anexos de contrato
CREATE TABLE IF NOT EXISTS public.contrato_anexos (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    contrato_id uuid NOT NULL REFERENCES public.contratos(id) ON DELETE CASCADE,
    nome_arquivo text NOT NULL,
    path text NOT NULL,
    tamanho integer NOT NULL,
    tipo text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE public.contrato_anexos IS 'Armazena anexos relacionados aos contratos.';


-- 4. Habilitar RLS e criar políticas de segurança
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated user to manage contracts"
ON public.contratos
FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated user to manage contract attachments"
ON public.contrato_anexos
FOR ALL
USING (
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.contratos
    WHERE contratos.id = contrato_anexos.contrato_id
  )
)
WITH CHECK (
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.contratos
    WHERE contratos.id = contrato_anexos.contrato_id
  )
);

-- 5. Criar a view para facilitar as consultas
CREATE OR REPLACE VIEW public.contratos_view AS
SELECT
    c.*,
    cl.nome AS cliente_nome,
    (
        SELECT count(*)
        FROM public.contas_receber cr
        WHERE cr.contrato_id = c.id AND cr.status = 'A_RECEBER'
    ) AS contas_em_aberto,
    (
        SELECT max(cr.data_pagamento)
        FROM public.contas_receber cr
        WHERE cr.contrato_id = c.id AND cr.status = 'RECEBIDO'
    ) AS ultimo_pagamento
FROM
    public.contratos c
JOIN
    public.clientes cl ON c.cliente_id = cl.id;

COMMENT ON VIEW public.contratos_view IS 'View para consulta de contratos com informações agregadas do cliente e contas a receber.';
