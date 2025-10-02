/*
          # [FIX PERMISSÕES DE LEITURA]
          Concede permissão de leitura direta para as roles 'anon' e 'authenticated'.
          
          ## Query Description: [Esta operação concede permissão de leitura (SELECT) em todas as tabelas do schema 'public' para os papéis 'anon' e 'authenticated'. Isso é uma solução direta para os erros de "permission denied" e visa desbloquear o desenvolvimento. Não afeta a estrutura dos dados, apenas as permissões de acesso. Recomenda-se revisar as políticas de segurança (RLS) antes de ir para produção.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Afecta as permissões de SELECT em todas as tabelas do schema 'public'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No] - Isso concede permissão além das políticas RLS existentes para leitura.
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance.]
*/

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;

-- Para garantir que futuras tabelas também tenham a permissão
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO authenticated;
