/*
          # [CORREÇÃO DE SEGURANÇA NAS VIEWS]
          Altera as views 'ordens_servico_view' e 'dre_mensal' para usar 'SECURITY INVOKER'.
          Isso garante que as políticas de segurança de linha (RLS) do usuário que faz a consulta sejam respeitadas,
          corrigindo uma vulnerabilidade crítica de segurança.

          ## Query Description: [Esta operação ajusta as permissões de visualizações de dados para garantir que as regras de segurança sejam aplicadas corretamente. Não há risco de perda de dados. A mudança é essencial para a segurança do sistema.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Views afetadas: 'ordens_servico_view', 'dre_mensal'
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

ALTER VIEW public.ordens_servico_view SET (security_invoker = true);
ALTER VIEW public.dre_mensal SET (security_invoker = true);
