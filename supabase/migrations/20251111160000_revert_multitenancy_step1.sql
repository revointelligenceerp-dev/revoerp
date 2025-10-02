-- =================================================================
--  Reversão Multi-Tenancy - Parte 1 de 2: Remover Políticas e Funções
-- =================================================================
-- Este script remove as dependências de segurança (RLS policies) e as funções
-- que foram criadas para a arquitetura multi-tenancy.

-- Passo 1: Remover o gatilho da tabela auth.users.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Passo 2: Remover as funções de ajuda com CASCADE.
-- O uso de CASCADE é crucial aqui. Ele remove as funções e, em cascata,
-- todas as políticas de segurança (RLS policies) que dependem delas.
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;
