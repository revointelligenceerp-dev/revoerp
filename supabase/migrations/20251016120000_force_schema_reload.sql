/*
          # [FORÇAR ATUALIZAÇÃO DO SCHEMA]
          Este script faz uma alteração mínima e segura em uma função existente para forçar a API do Supabase a recarregar o cache do esquema do banco de dados.
          Isso resolve erros do tipo "Could not find column" que ocorrem mesmo quando a coluna existe no banco.
          ## Query Description: [Esta operação é segura e não altera dados. Ela força a API do Supabase a atualizar seu cache interno, resolvendo inconsistências entre o banco de dados e a camada de API que podem ocorrer após migrações.]
          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Apenas a função 'handle_updated_at'.
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance. Apenas força a recarga do schema.]
*/
-- Força a recarga do schema alterando uma função.
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
