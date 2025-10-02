/*
          # [FORÇAR ATUALIZAÇÃO DO CACHE DA API]
          Este script redefine uma função existente para forçar a API do Supabase a recarregar o esquema do banco de dados.
          Isso resolve erros de "coluna não encontrada" que ocorrem mesmo quando a coluna existe no banco.

          ## Query Description: [Operação segura que não altera dados. Apenas redefine uma função interna para corrigir problemas de cache da API do Supabase, resolvendo erros de "coluna não encontrada".]
          
          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Função: public.handle_updated_at()
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance. Apenas força a atualização do cache da API.]
*/
-- Redefinir a função para forçar o PostgREST a recarregar o schema.
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  -- Forçando a atualização do cache.
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
