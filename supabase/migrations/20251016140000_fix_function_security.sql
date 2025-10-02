/*
          # [CORREÇÃO DE SEGURANÇA DA FUNÇÃO]
          Este script ajusta a função 'handle_updated_at' para definir um search_path explícito.
          Isso resolve o aviso de segurança "Function Search Path Mutable" e aumenta a robustez do banco de dados.
          ## Query Description: [Esta operação é segura e não afeta os dados. Ela apenas melhora a segurança de uma função interna do banco de dados, conforme recomendado pelo Supabase.]
          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Função: public.handle_updated_at()
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
