/*
          # [CORREÇÃO DE SEGURANÇA DA FUNÇÃO]
          Este script corrige o aviso de segurança 'Function Search Path Mutable' ajustando a função 'handle_updated_at'.

          ## Query Description: [Esta operação segura ajusta uma função interna do banco de dados para seguir as melhores práticas de segurança recomendadas pelo Supabase. Não há impacto nos dados ou na estrutura das tabelas.]
          
          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Function: public.handle_updated_at()
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance.]
*/
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';
