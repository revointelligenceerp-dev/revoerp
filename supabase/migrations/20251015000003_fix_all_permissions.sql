/*
          # [CORREÇÃO FINAL DE PERMISSÕES E SEGURANÇA]
          Este script aplica as políticas de segurança (RLS) corretas para todas as tabelas, permitindo o acesso de leitura, e corrige os avisos de segurança pendentes.
          É uma operação segura que não afeta os dados existentes.
          ## Query Description: [Esta operação ajustará as permissões de acesso do seu banco de dados para permitir que a aplicação leia os dados necessários. Também aplicará correções de segurança recomendadas pelo Supabase. Nenhum dado será perdido.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Políticas de RLS em todas as tabelas.
          - Schema 'extensions'.
          - Função 'handle_updated_at'.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
-- PASSO 1: CORRIGIR AVISOS DE SEGURANÇA
-- Cria o schema para as extensões, se não existir.
CREATE SCHEMA IF NOT EXISTS extensions;
-- Move as extensões para o schema dedicado.
ALTER EXTENSION pg_trgm SET SCHEMA extensions;
ALTER EXTENSION "uuid-ossp" SET SCHEMA extensions;
-- Define um search_path seguro para a função.
ALTER FUNCTION public.handle_updated_at() SET search_path = public;
-- PASSO 2: HABILITAR RLS E CRIAR POLÍTICAS DE LEITURA
-- Lista de todas as tabelas do schema public
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN 
        SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    LOOP
        -- Habilita RLS na tabela
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t_name);
        -- Remove políticas antigas para evitar duplicatas
        EXECUTE format('DROP POLICY IF EXISTS "Allow anonymous read access" ON public.%I;', t_name);
        -- Cria a política de leitura para o role 'anon'
        EXECUTE format('CREATE POLICY "Allow anonymous read access" ON public.%I FOR SELECT TO anon USING (true);', t_name);
        -- Cria políticas permissivas para 'authenticated' (CRUD completo)
        EXECUTE format('DROP POLICY IF EXISTS "Allow authenticated CRUD" ON public.%I;', t_name);
        EXECUTE format('CREATE POLICY "Allow authenticated CRUD" ON public.%I FOR ALL TO authenticated USING (true) WITH CHECK (true);', t_name);
    END LOOP;
END;
$$;
-- PASSO 3: GARANTIR PERMISSÕES EM VIEWS
GRANT SELECT ON public.ordens_servico_view TO anon, authenticated;
GRANT SELECT ON public.dre_mensal TO anon, authenticated;
