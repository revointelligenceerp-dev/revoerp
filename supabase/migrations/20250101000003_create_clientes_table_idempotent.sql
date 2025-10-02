/*
# [Criação Idempotente da Tabela de Clientes]
Este script cria a estrutura completa para a tabela 'clientes', garantindo que a operação possa ser executada múltiplas vezes sem erros. Ele verifica a existência de tipos, tabelas e políticas de segurança antes de criá-los.

## Query Description: Este script é seguro para ser executado. Ele não alterará ou removerá dados existentes. Seu objetivo é apenas garantir que a tabela 'clientes' e seus componentes associados existam e estejam configurados corretamente para o funcionamento da aplicação.

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Low"]
- Requires-Backup: false
- Reversible: false

## Structure Details:
- Types: 'cliente_status', 'tipo_cliente'
- Table: 'clientes'
- Columns: id, created_at, updated_at, nome, email, telefone, documento, tipo, status, endereco
- Constraints: PRIMARY KEY(id), UNIQUE(email), UNIQUE(documento)
- RLS: Enabled
- Policies: SELECT, INSERT, UPDATE, DELETE para 'authenticated'

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes
- Auth Requirements: authenticated users

## Performance Impact:
- Indexes: Added (Primary Key, Unique constraints create indexes)
- Triggers: None
- Estimated Impact: Baixo. A criação inicial pode levar alguns segundos.
*/

-- 1. Criação dos Tipos (ENUMS) se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'cliente_status') THEN
        CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_cliente') THEN
        CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
    END IF;
END$$;

-- 2. Criação da Tabela 'clientes' se não existir
CREATE TABLE IF NOT EXISTS public.clientes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    nome text NOT NULL,
    email text NOT NULL,
    telefone text NOT NULL,
    documento text NOT NULL,
    tipo public.tipo_cliente NOT NULL,
    status public.cliente_status NOT NULL,
    endereco jsonb NOT NULL,
    CONSTRAINT clientes_pkey PRIMARY KEY (id),
    CONSTRAINT clientes_email_key UNIQUE (email),
    CONSTRAINT clientes_documento_key UNIQUE (documento)
);

-- 3. Habilitar Row Level Security (RLS) se não estiver habilitada
DO $$
DECLARE
    rls_enabled boolean;
BEGIN
    SELECT relrowsecurity INTO rls_enabled FROM pg_class WHERE oid = 'public.clientes'::regclass;
    IF NOT rls_enabled THEN
        ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
    END IF;
END$$;

-- 4. Remover políticas antigas para evitar conflitos e garantir um estado limpo
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.clientes;
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.clientes;
DROP POLICY IF EXISTS "Permitir acesso de leitura a todos os usuários" ON public.clientes;
DROP POLICY IF EXISTS "Permitir inserção para usuários autenticados" ON public.clientes;
DROP POLICY IF EXISTS "Permitir atualização para usuários autenticados" ON public.clientes;
DROP POLICY IF EXISTS "Permitir exclusão para usuários autenticados" ON public.clientes;


-- 5. Criar Política de Acesso Unificada
CREATE POLICY "Permitir acesso total para usuários autenticados"
ON public.clientes
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 6. Conceder permissões aos roles relevantes
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.clientes TO authenticated;
GRANT ALL ON TABLE public.clientes TO service_role;
