/*
          # [FORÇAR ATUALIZAÇÃO DO CACHE DA API]
          Este script altera uma função interna para forçar o Supabase a recarregar o esquema do banco de dados.
          Isso resolve o erro "Could not find the 'column'..." que ocorre quando a API está com o cache desatualizado.
          ## Query Description: [Esta operação é segura e não afeta seus dados. Ela apenas faz um pequeno ajuste em uma função de utilidade para resolver um problema de cache interno do Supabase, que está impedindo o funcionamento do módulo de CRM.]
          ## Metadata:
          - Schema-Category: ["Safe"]
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
          - Estimated Impact: [Nenhum impacto de performance.]
*/
ALTER FUNCTION public.handle_updated_at() SET search_path = public;
