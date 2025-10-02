/*
# Criação da Tabela de Clientes e Tipos Relacionados
Este script prepara o banco de dados para o gerenciamento de clientes, criando os tipos ENUM necessários e a tabela `clientes`.

## Descrição da Query:
- **Criação de Tipos ENUM:** Define os tipos `tipo_cliente` e `cliente_status` para garantir a consistência dos dados, permitindo apenas valores pré-definidos.
- **Criação da Tabela `clientes`:** Estrutura a tabela com colunas para armazenar informações detalhadas dos clientes, incluindo um campo `jsonb` para o endereço.
- **Constraints:** Define `id` como chave primária, `email` e `documento` como únicos para evitar duplicatas, e `created_at` com valor padrão.
- **Habilitação de RLS:** Ativa a segurança em nível de linha (Row Level Security) para proteger os dados.
- **Políticas de Acesso:** Cria políticas que permitem que usuários autenticados realizem todas as operações (CRUD) e que usuários anônimos (não logados) apenas leiam os dados.

## Metadados:
- Schema-Category: "Structural"
- Impact-Level: "Medium"
- Requires-Backup: false
- Reversible: true (com um script de `DROP`)

## Detalhes da Estrutura:
- **Tabelas Criadas:** `public.clientes`
- **Tipos Criados:** `public.tipo_cliente`, `public.cliente_status`
- **Colunas Principais:** `id`, `nome`, `email`, `documento`, `tipo`, `status`, `endereco`

## Implicações de Segurança:
- RLS Status: Habilitado
- Mudanças de Política: Sim. Políticas são criadas para os papéis `authenticated` e `anon`.
- Requisitos de Autenticação: As políticas diferenciam o acesso entre usuários logados e não logados.

## Impacto de Performance:
- Índices: Índices de chave primária e `UNIQUE` são criados, o que melhora a performance de buscas por `id`, `email` e `documento`.
- Triggers: Nenhum.
- Impacto Estimado: Baixo. A criação da tabela é uma operação rápida e não afeta dados existentes.
*/

-- Cria o tipo ENUM para o tipo de cliente
CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');

-- Cria o tipo ENUM para o status do cliente
CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');

-- Cria a tabela de clientes
CREATE TABLE public.clientes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    nome text NOT NULL,
    email text NOT NULL,
    telefone text NULL,
    documento text NULL,
    tipo public.tipo_cliente NOT NULL,
    status public.cliente_status NOT NULL,
    endereco jsonb NULL,
    CONSTRAINT clientes_pkey PRIMARY KEY (id),
    CONSTRAINT clientes_email_key UNIQUE (email),
    CONSTRAINT clientes_documento_key UNIQUE (documento)
);

-- Habilita a segurança em nível de linha
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Permite que usuários autenticados gerenciem todos os clientes
CREATE POLICY "Allow all access to authenticated users"
ON public.clientes
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Permite que usuários anônimos visualizem os clientes
CREATE POLICY "Allow read access for anon users"
ON public.clientes
FOR SELECT
TO anon
USING (true);
