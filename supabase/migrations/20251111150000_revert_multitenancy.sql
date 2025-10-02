/*
  # Reversão da Estrutura Multi-Tenancy (Versão Segura)
  Este script reverte as alterações de multi-tenancy, removendo as políticas de segurança, funções, gatilhos e tabelas criadas.
  A operação é feita em cascata para garantir que todas as dependências sejam resolvidas de forma atômica.
  As colunas 'organization_id' não serão removidas para evitar timeouts, mas elas se tornarão inofensivas.
*/

-- Remove a função e todas as políticas de segurança que dependem dela.
-- Esta é a operação chave para resolver o erro de dependência.
DROP FUNCTION IF EXISTS public.get_organization_id() CASCADE;

-- Remove o gatilho que adicionava a organization_id ao JWT.
DROP TRIGGER IF EXISTS on_user_profile_created ON public.user_profiles;

-- Remove a tabela de perfis de usuário.
DROP TABLE IF EXISTS public.user_profiles;

-- Remove a tabela de organizações.
DROP TABLE IF EXISTS public.organizations;
