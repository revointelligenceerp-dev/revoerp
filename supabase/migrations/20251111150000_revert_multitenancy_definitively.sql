/*
  SCRIPT DE REVERSÃO DEFINITIVA DO MULTI-TENANCY

  Este script foi projetado para reverter de forma segura todas as alterações
  relacionadas à arquitetura multi-tenancy, resolvendo os erros de timeout e
  dependência.

  O que ele faz:
  1. Desabilita a Segurança em Nível de Linha (RLS) em TODAS as tabelas,
     restaurando o acesso e a funcionalidade da aplicação imediatamente.
  2. Remove TODAS as políticas de segurança que foram criadas.
  3. Remove as funções e gatilhos associados ao multi-tenancy.
  4. Remove as tabelas `organizations` e `user_profiles`.
  5. Remove a coluna `organization_id` de todas as tabelas.

  Este script é seguro para ser executado múltiplas vezes.
*/

-- PASSO 1: Desabilitar a Segurança em Nível de Linha (RLS) em todas as tabelas.
DO $$
DECLARE
    tbl_name TEXT;
BEGIN
    RAISE NOTICE 'Iniciando desabilitação do RLS...';
    FOR tbl_name IN 
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(tbl_name) || ' DISABLE ROW LEVEL SECURITY;';
    END LOOP;
    RAISE NOTICE 'RLS desabilitado em todas as tabelas.';
END $$;

-- PASSO 2: Remover todas as políticas de segurança criadas.
DO $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE 'Iniciando remoção das políticas de segurança...';
    FOR rec IN 
        SELECT 'public.' || quote_ident(tablename) as fq_name, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(rec.policyname) || ' ON ' || rec.fq_name || ';';
    END LOOP;
    RAISE NOTICE 'Políticas de segurança removidas.';
END $$;

-- PASSO 3: Remover o gatilho e a função de criação de perfil.
RAISE NOTICE 'Removendo gatilho e função de criação de perfil...';
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- PASSO 4: Remover a função de obtenção do ID da organização.
RAISE NOTICE 'Removendo função get_organization_id...';
DROP FUNCTION IF EXISTS public.get_organization_id();

-- PASSO 5: Remover as tabelas de multi-tenancy.
RAISE NOTICE 'Removendo tabelas organizations e user_profiles...';
DROP TABLE IF EXISTS public.user_profiles;
DROP TABLE IF EXISTS public.organizations;

-- PASSO 6: Remover a coluna organization_id de todas as tabelas.
DO $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE 'Iniciando remoção da coluna organization_id...';
    FOR rec IN 
        SELECT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public' AND column_name = 'organization_id'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(rec.table_name) || ' DROP COLUMN IF EXISTS organization_id;';
    END LOOP;
    RAISE NOTICE 'Coluna organization_id removida.';
END $$;

RAISE NOTICE 'Script de reversão do multi-tenancy concluído com sucesso!';
