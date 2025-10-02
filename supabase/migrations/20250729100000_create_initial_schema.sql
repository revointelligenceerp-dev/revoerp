/*
          # [Initial Schema Setup]
          This script completely resets and creates the initial database schema for the 'clientes' and 'ordens_servico' tables.

          ## Query Description: [This operation is DESTRUCTIVE. It will drop existing tables ('ordens_servico', 'clientes') and their associated types to ensure a clean setup. This is necessary to resolve previous migration issues and establish a stable schema. It is safe to run in a development environment where data can be re-seeded, but a backup is always recommended in production.]
          
          ## Metadata:
          - Schema-Category: ["Dangerous", "Structural"]
          - Impact-Level: ["High"]
          - Requires-Backup: true
          - Reversible: false
          
          ## Structure Details:
          - Drops: Tables 'ordens_servico', 'clientes'. Types 'cliente_status', 'tipo_cliente', 'os_status', 'os_prioridade'.
          - Creates: Types 'cliente_status', 'tipo_cliente', 'os_status', 'os_prioridade'. Tables 'clientes', 'ordens_servico' with foreign key relationship.
          
          ## Security Implications:
          - RLS Status: Enabled on both tables.
          - Policy Changes: Yes. Creates wide-open policies that allow all actions for all users (anonymous and authenticated). This is for development purposes and should be tightened in production.
          - Auth Requirements: None for now.
          
          ## Performance Impact:
          - Indexes: Primary keys are indexed automatically.
          - Triggers: None.
          - Estimated Impact: Low.
          */

-- 1. Limpeza: Remover estruturas existentes para garantir um recomeço limpo.
-- A ordem é importante para evitar erros de dependência.
DROP TABLE IF EXISTS public.ordens_servico;
DROP TABLE IF EXISTS public.clientes;
DROP TYPE IF EXISTS public.cliente_status;
DROP TYPE IF EXISTS public.tipo_cliente;
DROP TYPE IF EXISTS public.os_status;
DROP TYPE IF EXISTS public.os_prioridade;

-- 2. Criação dos Tipos (Enums)
CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
CREATE TYPE public.os_status AS ENUM ('ABERTA', 'EM_ANDAMENTO', 'FINALIZADA', 'CANCELADA');
CREATE TYPE public.os_prioridade AS ENUM ('BAIXA', 'MEDIA', 'ALTA', 'URGENTE');

-- 3. Criação da Tabela de Clientes
CREATE TABLE public.clientes (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    nome text NOT NULL,
    email text UNIQUE,
    telefone text,
    documento text UNIQUE,
    tipo public.tipo_cliente DEFAULT 'CLIENTE'::public.tipo_cliente NOT NULL,
    status public.cliente_status DEFAULT 'ATIVO'::public.cliente_status NOT NULL,
    endereco jsonb
);

-- Adicionar comentários para clareza
COMMENT ON TABLE public.clientes IS 'Armazena informações de clientes e fornecedores.';
COMMENT ON COLUMN public.clientes.endereco IS 'Armazena o endereço como um objeto JSONB.';

-- 4. Criação da Tabela de Ordens de Serviço
CREATE TABLE public.ordens_servico (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    numero text NOT NULL,
    cliente_id uuid REFERENCES public.clientes(id) ON DELETE SET NULL,
    descricao text,
    status public.os_status DEFAULT 'ABERTA'::public.os_status NOT NULL,
    prioridade public.os_prioridade DEFAULT 'MEDIA'::public.os_prioridade NOT NULL,
    data_inicio timestamp with time zone,
    data_previsao timestamp with time zone,
    data_finalizada timestamp with time zone,
    valor numeric,
    responsavel text
);

-- Adicionar comentários
COMMENT ON TABLE public.ordens_servico IS 'Armazena as ordens de serviço do sistema.';
COMMENT ON COLUMN public.ordens_servico.cliente_id IS 'Referencia o cliente associado à OS.';

-- 5. Habilitar Row Level Security (RLS)
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- 6. Criar Políticas de Segurança (Abertas para desenvolvimento)
-- Política para Clientes
CREATE POLICY "Enable all actions for all users on clientes"
ON public.clientes
FOR ALL
USING (true)
WITH CHECK (true);

-- Política para Ordens de Serviço
CREATE POLICY "Enable all actions for all users on ordens_servico"
ON public.ordens_servico
FOR ALL
USING (true)
WITH CHECK (true);
