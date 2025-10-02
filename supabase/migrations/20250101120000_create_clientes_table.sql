/*
# [Structural] Criação da Tabela de Clientes
Este script cria a tabela `clientes` e os tipos de dados necessários para o seu funcionamento. Ele é idempotente, o que significa que pode ser executado várias vezes sem causar erros.

## Query Description: [Este script é seguro para ser executado. Ele cria a estrutura da tabela `clientes` se ela ainda não existir, incluindo tipos de dados personalizados, colunas, chaves e constraints. Nenhuma data existente será afetada, pois ele só age se a tabela estiver ausente.]

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: false

## Structure Details:
- Tables affected: `public.clientes`
- Types created: `cliente_status`, `tipo_cliente`
- Columns: `id`, `created_at`, `updated_at`, `nome`, `email`, `telefone`, `documento`, `tipo`, `status`, `endereco`
- Constraints: `PRIMARY KEY`, `UNIQUE (email)`, `UNIQUE (documento)`

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes
- Auth Requirements: authenticated

## Performance Impact:
- Indexes: Added (Primary Key, Unique)
- Triggers: None
- Estimated Impact: Baixo. A criação inicial da tabela não impacta a performance de queries existentes.
*/

-- Criação dos tipos ENUM se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'cliente_status') THEN
        CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_cliente') THEN
        CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
    END IF;
END$$;

-- Criação da tabela de clientes se não existir
CREATE TABLE IF NOT EXISTS public.clientes (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    nome text NOT NULL,
    email text NOT NULL UNIQUE,
    telefone text,
    documento text UNIQUE,
    tipo public.tipo_cliente NOT NULL,
    status public.cliente_status NOT NULL,
    endereco jsonb
);

-- Adicionar comentários às colunas para melhor entendimento do schema
COMMENT ON TABLE public.clientes IS 'Armazena informações sobre clientes e fornecedores.';
COMMENT ON COLUMN public.clientes.nome IS 'Nome completo ou razão social do cliente/fornecedor.';
COMMENT ON COLUMN public.clientes.email IS 'Email principal para contato, deve ser único.';
COMMENT ON COLUMN public.clientes.documento IS 'CPF ou CNPJ do cliente/fornecedor, deve ser único.';
COMMENT ON COLUMN public.clientes.tipo IS 'Define se o registro é um CLIENTE, FORNECEDOR ou AMBOS.';
COMMENT ON COLUMN public.clientes.status IS 'Status do cliente: ATIVO, INATIVO ou SUSPENSO.';
COMMENT ON COLUMN public.clientes.endereco IS 'Objeto JSON contendo os dados de endereço.';


-- Habilitar Row Level Security (RLS)
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas para garantir um estado limpo
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.clientes;

-- Criar política de RLS
-- Esta política permite que qualquer usuário autenticado realize todas as operações.
-- Em um cenário real, você poderia restringir isso com base em `auth.uid()` se houvesse uma coluna de `user_id`.
CREATE POLICY "Permitir acesso total para usuários autenticados"
ON public.clientes
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
