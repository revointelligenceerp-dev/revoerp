/*
# [Criação da Estrutura de Backend para Clientes]
Este script cria a estrutura completa para a tabela 'clientes', incluindo tipos, colunas, chaves e políticas de segurança.

## Query Description: [Este script irá apagar a tabela 'clientes' e seus tipos relacionados ('cliente_status', 'tipo_cliente') se eles existirem, para garantir uma configuração limpa e livre de erros. Nenhuma perda de dados ocorrerá, pois a tabela ainda não foi populada com sucesso.]

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Medium"]
- Requires-Backup: [false]
- Reversible: [false]

## Structure Details:
- Tipos a serem criados: 'cliente_status', 'tipo_cliente'
- Tabela a ser criada: 'clientes'
- Políticas de RLS a serem criadas para permitir acesso público de leitura e escrita.

## Security Implications:
- RLS Status: [Enabled]
- Policy Changes: [Yes]
- Auth Requirements: [Nenhuma, as políticas permitem acesso anônimo para desenvolvimento.]

## Performance Impact:
- Indexes: [Primary Key e duas constraints UNIQUE serão criadas.]
- Triggers: [Nenhum]
- Estimated Impact: [Baixo]
*/

-- Passo 1: Limpar objetos antigos para garantir um estado limpo.
DROP TABLE IF EXISTS public.clientes;
DROP TYPE IF EXISTS public.cliente_status;
DROP TYPE IF EXISTS public.tipo_cliente;

-- Passo 2: Criar os tipos ENUM necessários para a tabela.
CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');

-- Passo 3: Criar a tabela 'clientes' com a estrutura correta.
CREATE TABLE public.clientes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    nome text NOT NULL,
    email text NOT NULL,
    telefone text,
    documento text,
    tipo public.tipo_cliente NOT NULL DEFAULT 'CLIENTE'::public.tipo_cliente,
    status public.cliente_status NOT NULL DEFAULT 'ATIVO'::public.cliente_status,
    endereco jsonb,
    CONSTRAINT clientes_pkey PRIMARY KEY (id),
    CONSTRAINT clientes_email_key UNIQUE (email),
    CONSTRAINT clientes_documento_key UNIQUE (documento)
);

-- Adicionar comentários para documentação do banco de dados.
COMMENT ON TABLE public.clientes IS 'Armazena informações de clientes e fornecedores.';
COMMENT ON COLUMN public.clientes.id IS 'Identificador único (UUID).';
COMMENT ON COLUMN public.clientes.email IS 'Endereço de e-mail único do cliente/fornecedor.';
COMMENT ON COLUMN public.clientes.documento IS 'CPF ou CNPJ único.';
COMMENT ON COLUMN public.clientes.endereco IS 'Objeto JSON com os detalhes do endereço.';

-- Passo 4: Habilitar a Segurança a Nível de Linha (RLS).
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Passo 5: Criar políticas de segurança permissivas para o ambiente de desenvolvimento.
-- AVISO: Estas regras permitem acesso total. Em produção, devem ser substituídas por políticas autenticadas.
CREATE POLICY "Allow public read access" ON public.clientes
AS PERMISSIVE FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow public write access" ON public.clientes
AS PERMISSIVE FOR ALL
TO public
USING (true)
WITH CHECK (true);
