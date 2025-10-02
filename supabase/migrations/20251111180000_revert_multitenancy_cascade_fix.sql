-- Reversão Definitiva e Atômica do Multi-Tenancy
-- Este script usa CASCADE para remover todas as dependências de uma só vez.

-- 1. Remove a função e todas as políticas de segurança que dependem dela.
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;

-- 2. Remove o gatilho da tabela de autenticação.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 3. Remove a função do gatilho.
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 4. Remove a tabela de perfis de usuário.
DROP TABLE IF EXISTS public.user_profiles CASCADE;

-- 5. Remove a tabela de organizações e TODAS as chaves estrangeiras que apontam para ela.
-- Este é o comando crucial que resolve o erro de dependência.
DROP TABLE IF EXISTS public.organizations CASCADE;
