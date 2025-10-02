/*
          # [CORREÇÃO DE PERMISSÕES GLOBAIS]
          Este script aplica uma política de leitura pública a todas as tabelas do schema 'public'.
          É uma medida para garantir que a aplicação, em modo de desenvolvimento e sem autenticação, consiga ler todos os dados necessários.

          ## Query Description: [Esta operação ajusta as políticas de segurança (RLS) para permitir que a aplicação leia dados de todas as tabelas. Não há risco de perda de dados. Esta é uma configuração segura para o ambiente de desenvolvimento atual.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Políticas de RLS em todas as tabelas do schema 'public'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [Nenhum, permite acesso anônimo de leitura]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN 
        SELECT t.table_name 
        FROM information_schema.tables t
        WHERE t.table_schema = 'public' AND t.table_type = 'BASE TABLE'
          AND t.table_name NOT LIKE 'pg_%'
          AND t.table_name NOT LIKE 'sql_%'
    LOOP
        -- Habilita RLS na tabela
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_name);

        -- Remove a política antiga, se existir, para evitar conflitos
        EXECUTE format('DROP POLICY IF EXISTS "Allow public read access" ON public.%I;', table_name);

        -- Cria a nova política de leitura pública
        EXECUTE format('CREATE POLICY "Allow public read access" ON public.%I FOR SELECT TO anon USING (true);', table_name);
    END LOOP;
END $$;
