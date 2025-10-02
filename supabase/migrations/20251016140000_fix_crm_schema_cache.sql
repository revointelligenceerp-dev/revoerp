/*
          # [CORREÇÃO DE CACHE DE SCHEMA DO CRM]
          Este script força a atualização do cache do schema da API do Supabase para a tabela 'crm_oportunidades'.
          Ele faz isso alterando a coluna 'etapa' para garantir que seu valor padrão esteja definido, o que resolve o erro "Could not find the 'etapa' column".

          ## Query Description: [Esta operação é segura e não afeta seus dados. Ela apenas ajusta a configuração da coluna 'etapa' para forçar uma atualização no cache da API do Supabase, resolvendo o erro de "coluna não encontrada".]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabela: crm_oportunidades
          - Coluna: etapa
          
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

ALTER TABLE public.crm_oportunidades
ALTER COLUMN etapa SET DEFAULT 'Lead'::public.crm_etapa;
