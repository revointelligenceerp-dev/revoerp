/*
          # Recriar Módulo de Gerenciamento de Usuários
          Cria a tabela `user_permissions` para armazenar as permissões de cada usuário.

          ## Query Description:
          - Cria a tabela `user_permissions` que armazena um objeto JSON com as permissões.
          - Define a RLS (Row Level Security) para garantir que usuários só possam ler suas próprias permissões.
          - A modificação de permissões será feita de forma segura através de Edge Functions com privilégios de administrador.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true

          ## Structure Details:
          - Tabela: `public.user_permissions`
          - Colunas: `user_id`, `permissions`, `created_at`, `updated_at`

          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes
          - Auth Requirements: Usuários autenticados podem ler suas próprias permissões.
          
          ## Performance Impact:
          - Indexes: Chave primária em `user_id`.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo.
          */

-- 1. Criar a tabela para armazenar as permissões dos usuários
CREATE TABLE IF NOT EXISTS public.user_permissions (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    permissions JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Habilitar a Segurança em Nível de Linha (RLS)
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- 3. Criar uma política para permitir que usuários leiam suas próprias permissões
-- A modificação será feita apenas por funções de administrador (service_role)
DROP POLICY IF EXISTS "Allow individual read access" ON public.user_permissions;
CREATE POLICY "Allow individual read access"
ON public.user_permissions
FOR SELECT
USING (auth.uid() = user_id);

-- 4. Adicionar um comentário para a tabela
COMMENT ON TABLE public.user_permissions IS 'Armazena as permissões de acesso de cada usuário do sistema.';
