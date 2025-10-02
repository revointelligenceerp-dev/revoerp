/*
          # [CORREÇÃO DE SEGURANÇA E EXTENSÕES]
          Este script corrige avisos de segurança movendo extensões para um schema dedicado e definindo um search_path seguro para as funções.
          Esta é uma operação segura e não afeta dados ou a estrutura das tabelas.
          ## Query Description: [Esta operação ajusta as configurações de segurança do seu banco de dados, movendo extensões para um schema 'extensions' e travando o search_path de funções. Não há impacto em dados existentes. É uma melhoria de segurança recomendada.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Cria o schema 'extensions'.
          - Move as extensões 'pg_trgm' e 'uuid-ossp'.
          - Altera a função 'handle_updated_at'.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- PASSO 1: CRIAR O SCHEMA PARA EXTENSÕES
CREATE SCHEMA IF NOT EXISTS extensions;
COMMENT ON SCHEMA extensions IS 'Schema para agrupar extensões do PostgreSQL.';

-- PASSO 2: MOVER EXTENSÕES PARA O NOVO SCHEMA
-- A sintaxe "IF EXISTS" não é válida para ALTER EXTENSION, então alteramos diretamente.
-- A criação das extensões já foi feita no script anterior.
ALTER EXTENSION pg_trgm SET SCHEMA extensions;
ALTER EXTENSION "uuid-ossp" SET SCHEMA extensions;

-- PASSO 3: AJUSTAR A FUNÇÃO DE TIMESTAMP PARA SEGURANÇA
-- Define um search_path explícito para evitar vulnerabilidades.
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- PASSO 4: APLICAR O TRIGGER NOVAMENTE ÀS TABELAS (GARANTIA DE CONSISTÊNCIA)
-- Lista de todas as tabelas que possuem a coluna 'updated_at'
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_type = 'BASE TABLE'
          AND table_name NOT LIKE 'pg_%'
          AND table_name NOT LIKE 'sql_%'
    LOOP
        IF EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
              AND table_name = t_name 
              AND column_name = 'updated_at'
        ) THEN
            EXECUTE format('DROP TRIGGER IF EXISTS on_%s_updated_at ON public.%I;', t_name, t_name);
            EXECUTE format('CREATE TRIGGER on_%s_updated_at BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();', t_name, t_name);
        END IF;
    END LOOP;
END;
$$;
