/*
          # [Fix] Adicionar Coluna 'tempo_estimado'
          [Este script corrige a tabela 'servicos' adicionando a coluna 'tempo_estimado' que estava faltando.]

          ## Query Description: [Esta operação é segura e não afeta dados existentes. Ela apenas adiciona uma nova coluna 'tempo_estimado' do tipo integer à tabela 'servicos', alinhando a estrutura do banco de dados com a aplicação.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabela afetada: public.servicos
          - Coluna adicionada: tempo_estimado (integer)
          
          ## Security Implications:
          - RLS Status: [Não alterado]
          - Policy Changes: [Não]
          - Auth Requirements: [Não]
          
          ## Performance Impact:
          - Indexes: [Nenhum]
          - Triggers: [Nenhum]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
          */

ALTER TABLE public.servicos
ADD COLUMN IF NOT EXISTS tempo_estimado integer;
