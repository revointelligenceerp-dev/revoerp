/*
          # [CORREÇÃO DEFINITIVA DAS POLÍTICAS DE ACESSO]
          Este script habilita o RLS e cria uma política de leitura pública em TODAS as tabelas do schema 'public'.
          Esta é a solução definitiva para os erros de "permission denied" no ambiente de desenvolvimento.

          ## Query Description: [Esta operação ajusta as políticas de segurança (RLS) para permitir que a aplicação leia os dados de todas as tabelas. É uma operação segura para os dados existentes e essencial para o funcionamento do frontend no estado atual.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Políticas de RLS para todas as tabelas no schema 'public'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [Nenhum, permite leitura anônima]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo, a verificação de políticas simples tem baixo custo.]
*/
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
    LOOP
        -- Habilita RLS se ainda não estiver habilitado
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t_name);

        -- Remove a política antiga para evitar conflitos, se existir
        EXECUTE format('DROP POLICY IF EXISTS "Public Read Access on %s" ON public.%I;', t_name, t_name);

        -- Cria uma nova política que permite leitura pública (SELECT)
        EXECUTE format('CREATE POLICY "Public Read Access on %s" ON public.%I FOR SELECT USING (true);', t_name, t_name);
    END LOOP;
END;
$$;
