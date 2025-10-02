-- Reverte a estrutura de multi-tenancy para o estado original.
-- Este script é seguro para ser executado e remove as dependências na ordem correta.

-- 1. Remove o gatilho e a função de criação de perfil de usuário.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 2. Remove a função de obtenção de organização e TODAS as políticas de segurança que dependem dela.
-- O uso de CASCADE é crucial aqui para resolver o erro de dependência.
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;

-- 3. Remove as tabelas principais da arquitetura multi-tenancy.
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.organizations CASCADE;

-- Nota: As colunas 'organization_id' em outras tabelas não serão removidas
-- para evitar operações pesadas que causam timeout. Elas não afetarão o
-- funcionamento da aplicação, pois as políticas de segurança que as utilizavam
-- foram removidas.
