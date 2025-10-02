/*
          # [CORREÇÃO DE SEGURANÇA]
          Este script corrige o aviso de segurança "Function Search Path Mutable".
          Ele define explicitamente o search_path para a função handle_updated_at, prevenindo potenciais vulnerabilidades.
          ## Query Description: [Esta operação ajusta uma função interna do banco de dados para seguir as melhores práticas de segurança recomendadas pelo Supabase. Não há impacto nos dados ou na funcionalidade da aplicação.]
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
ALTER FUNCTION public.handle_updated_at() SET search_path = public;
