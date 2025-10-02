/*
          # [CORREÇÃO DE SEGURANÇA]
          Este script corrige o aviso de segurança 'Function Search Path Mutable'.
          Ele redefine a função 'handle_updated_at' para incluir um 'search_path' seguro, prevenindo potenciais vulnerabilidades.
          ## Query Description: [Esta é uma operação segura que melhora a segurança do banco de dados ao definir um caminho de busca explícito para a função de gatilho, sem impacto nos dados existentes.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Function: public.handle_updated_at()
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, public;
