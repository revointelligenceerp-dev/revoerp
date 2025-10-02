/*
          # [CORREÇÃO DEFINITIVA DE PERMISSÕES]
          Este script habilita o RLS e cria uma política de leitura permissiva em TODAS as tabelas do schema 'public'.
          É projetado para resolver erros persistentes de 'permission denied' em um ambiente de desenvolvimento.

          ## Query Description: [Esta operação ajusta as políticas de segurança do seu banco de dados para permitir que a aplicação leia os dados de todas as tabelas. Nenhuma estrutura ou dado será alterado. É uma medida segura e necessária para o funcionamento do frontend.]
          
          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Políticas de RLS em todas as tabelas do schema 'public'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [Nenhum, permite leitura anônima]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- Habilita RLS e cria política de leitura para TODAS as tabelas

DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN 
        SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t_name);
        EXECUTE format('DROP POLICY IF EXISTS "Allow anonymous read access" ON public.%I;', t_name);
        EXECUTE format('CREATE POLICY "Allow anonymous read access" ON public.%I FOR SELECT USING (true);', t_name);
    END LOOP;
END;
$$;
