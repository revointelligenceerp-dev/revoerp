-- =============================================
-- MIGRATION: Reversão Completa de Multi-Tenancy e RLS
--
-- DESCRIÇÃO:
-- Este script realiza uma limpeza completa de todas as estruturas
-- de multi-tenancy e Row Level Security (RLS) que foram
-- introduzidas e falharam em ser revertidas anteriormente.
--
-- OPERAÇÕES:
-- 1. Remove todas as políticas de RLS de todas as tabelas no schema 'public'.
-- 2. Desabilita o RLS em todas as tabelas no schema 'public'.
-- 3. Remove as funções e triggers de multi-tenancy.
-- 4. Remove a tabela 'organizations' e 'user_profiles'.
--
-- Este script é seguro para ser executado múltiplas vezes (idempotente).
-- =============================================

DO $$
DECLARE
    table_record RECORD;
    policy_record RECORD;
BEGIN
    -- 1. Remover todas as políticas de RLS de todas as tabelas
    RAISE NOTICE 'Iniciando remoção de todas as políticas de RLS...';
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        FOR policy_record IN
            SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = table_record.tablename
        LOOP
            EXECUTE 'DROP POLICY IF EXISTS "' || policy_record.policyname || '" ON public."' || table_record.tablename || '";';
            RAISE NOTICE 'Política % removida da tabela %.', policy_record.policyname, table_record.tablename;
        END LOOP;
    END LOOP;
    RAISE NOTICE 'Remoção de políticas concluída.';

    -- 2. Desabilitar RLS em todas as tabelas
    RAISE NOTICE 'Iniciando desabilitação de RLS em todas as tabelas...';
    FOR table_record IN
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    LOOP
        EXECUTE 'ALTER TABLE public."' || table_record.tablename || '" DISABLE ROW LEVEL SECURITY;';
        RAISE NOTICE 'RLS desabilitado para a tabela %.', table_record.tablename;
    END LOOP;
    RAISE NOTICE 'Desabilitação de RLS concluída.';
END;
$$;

-- 3. Remover funções e triggers de multi-tenancy
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.get_organization_id();

-- 4. Remover tabelas de multi-tenancy (se existirem)
-- O CASCADE irá remover as foreign keys que ainda possam existir.
DROP TABLE IF EXISTS public.user_profiles CASCADE;
DROP TABLE IF EXISTS public.organizations CASCADE;

RAISE NOTICE 'Limpeza completa de Multi-Tenancy e RLS concluída com sucesso.';
