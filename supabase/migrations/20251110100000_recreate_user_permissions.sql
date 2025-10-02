/*
          # Recriação da Tabela de Permissões de Usuário
          Este script cria a tabela `user_permissions` para armazenar as permissões de cada usuário do sistema.

          ## Query Description: 
          - Cria a tabela `user_permissions` com uma coluna `user_id` que referencia `auth.users(id)` e uma coluna `permissions` do tipo JSONB.
          - Habilita a Segurança em Nível de Linha (RLS) na tabela.
          - Cria políticas de RLS que permitem que apenas usuários autenticados com a role `service_role` (usada pelas Edge Functions) possam ler e escrever na tabela. Isso garante que as permissões não possam ser manipuladas diretamente pelo navegador.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (DROP TABLE user_permissions)
          
          ## Structure Details:
          - Tabela afetada: `user_permissions` (criação)
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (criação de políticas de acesso restrito)
          - Auth Requirements: Acesso restrito à `service_role`.
          
          ## Performance Impact:
          - Indexes: Adiciona um índice na coluna `user_id`.
          - Triggers: Nenhum.
          - Estimated Impact: Nenhum impacto significativo na performance.
          */

-- Cria a tabela para armazenar as permissões dos usuários
CREATE TABLE IF NOT EXISTS public.user_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    permissions JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Adiciona um índice na coluna user_id para otimizar as buscas
CREATE INDEX IF NOT EXISTS idx_user_permissions_user_id ON public.user_permissions(user_id);

-- Habilita a Segurança em Nível de Linha
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- Remove políticas existentes para garantir um estado limpo
DROP POLICY IF EXISTS "Allow service_role to manage permissions" ON public.user_permissions;

-- Cria a política que permite que apenas a service_role (usada pelas Edge Functions) gerencie as permissões
CREATE POLICY "Allow service_role to manage permissions"
ON public.user_permissions
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- Adiciona um comentário na tabela para documentação
COMMENT ON TABLE public.user_permissions IS 'Armazena as permissões de acesso de cada usuário do sistema.';
