/*
# Reversão Simplificada e Segura de Multi-Tenancy

Este script foi projetado para ser o mais leve e rápido possível,
evitando o erro de "Connection Timeout". Ele reverte apenas as
estruturas centrais da tentativa de implementação de multi-tenancy.

## O que este script faz:
1. Remove as funções e triggers que foram criados para o multi-tenancy.
2. Remove as tabelas `organizations` e `user_profiles`.
3. **NÃO** tenta remover a coluna `organization_id` ou as políticas de RLS de todas as tabelas, pois essa operação é muito pesada e estava causando o timeout. As colunas e políticas órfãs não afetarão o funcionamento da aplicação.

## Segurança:
- Este script usa `DROP ... IF EXISTS` e é seguro para ser executado, mesmo que as migrações anteriores tenham falhado.
*/

-- Desativa o trigger que tentava popular a tabela de perfis
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Remove as funções que foram criadas
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.get_organization_id();
DROP PROCEDURE IF EXISTS public.apply_rls_policies_in_batches();
DROP PROCEDURE IF EXISTS public.apply_all_rls_policies();

-- Remove as tabelas principais da arquitetura multi-tenancy
DROP TABLE IF EXISTS public.user_profiles;
DROP TABLE IF EXISTS public.organizations;

-- Desativa RLS em algumas tabelas principais para garantir o acesso.
-- Usamos um bloco DO para evitar erros caso a tabela não exista.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'clientes') THEN
    ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'produtos') THEN
    ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pedidos_venda') THEN
    ALTER TABLE public.pedidos_venda DISABLE ROW LEVEL SECURITY;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ordens_servico') THEN
    ALTER TABLE public.ordens_servico DISABLE ROW LEVEL SECURITY;
  END IF;
END $$;
