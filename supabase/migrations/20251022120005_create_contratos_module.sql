/*
  # [Módulo de Contratos]
  Cria a estrutura completa para o módulo de Contratos, incluindo tabelas, enums, e políticas de segurança (RLS).

  ## Query Description: [Este script estabelece as tabelas `contratos` e `contrato_anexos`, define os tipos de dados necessários e aplica políticas de segurança para garantir que apenas usuários autenticados possam acessar e manipular os dados dos contratos. É uma operação estrutural segura.]
  
  ## Metadata:
  - Schema-Category: ["Structural"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [true]
  
  ## Structure Details:
  - Tabelas criadas: `contratos`, `contrato_anexos`
  - Tipos (ENUMs) criados: `contrato_situacao`, `contrato_vencimento_regra`, `contrato_periodicidade`
  - Políticas RLS: Habilitadas e criadas para ambas as tabelas.
  
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [Yes]
  - Auth Requirements: [requer usuário autenticado]
  
  ## Performance Impact:
  - Indexes: [Índices de chave primária e estrangeira são criados automaticamente.]
  - Triggers: [Nenhum]
  - Estimated Impact: [Baixo]
*/

-- Tipos ENUM para o módulo de Contratos
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

-- Tabela de Contratos
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
    marcadores text[],
    dados_adicionais jsonb,
    CONSTRAINT contratos_pkey PRIMARY KEY (id),
    CONSTRAINT contratos_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE RESTRICT,
    CONSTRAINT contratos_dia_vencimento_check CHECK (((dia_vencimento >= 1) AND (dia_vencimento <= 31)))
);

-- Tabela de Anexos de Contrato
CREATE TABLE IF NOT EXISTS public.contrato_anexos (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    contrato_id uuid NOT NULL,
    nome_arquivo text NOT NULL,
    path text NOT NULL,
    tamanho bigint NOT NULL,
    tipo text NOT NULL,
    CONSTRAINT contrato_anexos_pkey PRIMARY KEY (id),
    CONSTRAINT contrato_anexos_contrato_id_fkey FOREIGN KEY (contrato_id) REFERENCES public.contratos(id) ON DELETE CASCADE
);

-- Habilitar RLS
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;

-- Políticas de Segurança para Contratos
CREATE POLICY "Allow authenticated users to manage their contracts"
ON public.contratos
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Políticas de Segurança para Anexos de Contrato
CREATE POLICY "Allow authenticated users to manage contract attachments"
ON public.contrato_anexos
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
