/*
          # [CORREÇÃO DE SEGURANÇA E ORGANIZAÇÃO DE EXTENSÕES]
          Este script corrige os avisos de segurança relacionados ao `search_path` das funções e move as extensões para um schema dedicado ('extensions'), como recomendado pelo Supabase.

          ## Query Description:
          Esta é uma operação segura que melhora a organização e a segurança do seu banco de dados. Não afeta os dados existentes. Move as extensões 'pg_trgm' e 'uuid-ossp' para um schema 'extensions' e define um `search_path` seguro para as funções do banco de dados.

          ## Metadata:
          - Schema-Category: ["Structural", "Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true] (manualmente)

          ## Structure Details:
          - Cria o schema 'extensions'.
          - Move as extensões 'pg_trgm' e 'uuid-ossp' para o schema 'extensions'.
          - Altera a função 'handle_updated_at' para definir um `search_path` seguro.

          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]

          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- PASSO 1: Criar um schema dedicado para as extensões, se ainda não existir.
CREATE SCHEMA IF NOT EXISTS extensions;

-- PASSO 2: Mover as extensões para o novo schema.
-- A sintaxe "IF EXISTS" não é suportada aqui, então foi removida.
ALTER EXTENSION pg_trgm SET SCHEMA extensions;
ALTER EXTENSION "uuid-ossp" SET SCHEMA extensions;

-- PASSO 3: Corrigir o aviso de segurança do search_path na função.
-- Define explicitamente o search_path para evitar vulnerabilidades de "hijacking".
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
