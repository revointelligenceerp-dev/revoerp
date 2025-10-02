/*
          # [CORREÇÃO DE SEGURANÇA E ORGANIZAÇÃO]
          Este script organiza as extensões do banco de dados em um schema dedicado ('extensions')
          e ajusta o search_path das funções para aumentar a segurança, resolvendo os avisos
          reportados.
          ## Query Description: [Esta é uma operação segura que melhora a organização e a segurança do seu banco de dados, alinhando-o com as melhores práticas recomendadas pelo Supabase. Não afeta seus dados ou a estrutura das tabelas existentes.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Cria o schema 'extensions'.
          - Move as extensões 'pg_trgm' e 'uuid-ossp' para o schema 'extensions'.
          - Altera o 'search_path' de funções no schema 'public'.
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
-- PASSO 1: CRIAR O SCHEMA PARA EXTENSÕES
CREATE SCHEMA IF NOT EXISTS extensions;
-- PASSO 2: MOVER EXTENSÕES PARA O NOVO SCHEMA
ALTER EXTENSION pg_trgm SET SCHEMA extensions;
ALTER EXTENSION "uuid-ossp" SET SCHEMA extensions;
-- PASSO 3: ATUALIZAR O SEARCH_PATH DA FUNÇÃO EXISTENTE
ALTER FUNCTION public.handle_updated_at() SET search_path = extensions, public;
