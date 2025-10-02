/*
          # [CORREÇÃO DE SEGURANÇA DA FUNÇÃO]
          Este script corrige o aviso de segurança "Function Search Path Mutable".
          Ele define explicitamente o search_path para a função handle_updated_at, o que é uma boa prática de segurança recomendada pelo Supabase.
          ## Query Description: [Esta é uma operação segura que melhora a segurança do seu banco de dados, sem qualquer impacto nos dados ou na estrutura das tabelas. Ela define um caminho de busca explícito para uma função interna, prevenindo potenciais vulnerabilidades.]
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
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
ALTER FUNCTION public.handle_updated_at() SET search_path = public;
