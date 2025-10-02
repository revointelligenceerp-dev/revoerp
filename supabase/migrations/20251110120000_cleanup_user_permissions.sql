/*
          # [DANGEROUS] Limpeza do Módulo de Permissões
          Este script remove completamente a tabela `user_permissions`. Esta ação é parte de um plano para reconstruir o módulo de permissões do zero e corrigir problemas de configuração.

          ## Query Description: [Esta operação removerá permanentemente a tabela 'user_permissions' e todos os dados de permissão de usuários nela contidos. Esta ação é necessária para uma reinicialização limpa do módulo. Não há como reverter esta ação a não ser restaurando um backup.]
          
          ## Metadata:
          - Schema-Category: "Dangerous"
          - Impact-Level: "High"
          - Requires-Backup: true
          - Reversible: false
          
          ## Structure Details:
          - Tabela removida: public.user_permissions
          
          ## Security Implications:
          - RLS Status: N/A
          - Policy Changes: No
          - Auth Requirements: N/A
          
          ## Performance Impact:
          - Indexes: Removidos com a tabela.
          - Triggers: N/A
          - Estimated Impact: Baixo. A remoção da tabela é uma operação rápida.
          */
DROP TABLE IF EXISTS public.user_permissions;
