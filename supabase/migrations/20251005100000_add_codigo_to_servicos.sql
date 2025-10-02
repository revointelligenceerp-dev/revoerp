/*
          # [Operação de Correção] Adicionar Coluna 'codigo'
          [Este script adiciona a coluna 'codigo' à tabela 'servicos' se ela não existir, corrigindo uma inconsistência entre o código da aplicação e o esquema do banco de dados.]

          ## Query Description: [Esta operação é segura e não afeta dados existentes. Ela apenas adiciona uma nova coluna de texto à tabela de serviços, permitindo que o campo 'Código' seja salvo corretamente.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabela afetada: public.servicos
          - Coluna adicionada: codigo (TEXT)
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [authenticated]
          
          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
          */
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'servicos'
    AND column_name = 'codigo'
  ) THEN
    ALTER TABLE public.servicos ADD COLUMN codigo TEXT;
  END IF;
END;
$$;
