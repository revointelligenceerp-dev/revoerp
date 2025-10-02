/*
          # [CORREÇÃO DEFINITIVA DE PERMISSÕES]
          Este script habilita a Segurança a Nível de Linha (RLS) e cria uma política de leitura (SELECT) para TODAS as tabelas no schema 'public'.
          Isso garante que a aplicação possa ler os dados necessários para funcionar, resolvendo os erros de "permission denied".
          ## Query Description: [Esta operação ajusta as permissões de segurança do seu banco de dados para permitir que a aplicação leia os dados de todas as tabelas. É uma etapa segura e necessária para o funcionamento do frontend, sem risco de perda de dados.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Políticas de RLS para todas as tabelas no schema 'public'.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo. A verificação de políticas RLS pode adicionar uma pequena sobrecarga, mas é otimizada pelo PostgreSQL.]
*/
DO $$
DECLARE
    tbl_name TEXT;
BEGIN
    FOR tbl_name IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        -- Habilita RLS na tabela
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl_name);
        
        -- Remove a política de seleção antiga, se existir, para evitar conflitos
        EXECUTE format('DROP POLICY IF EXISTS "Public Read Access on %I" ON public.%I;', tbl_name, tbl_name);
        
        -- Cria uma nova política que permite SELECT para todos (anon e authenticated)
        EXECUTE format('CREATE POLICY "Public Read Access on %I" ON public.%I FOR SELECT USING (true);', tbl_name, tbl_name);
    END LOOP;
END;
$$;
