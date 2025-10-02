/*
          # [ATUALIZAÇÃO DO CACHE DO BANCO DE DADOS]
          Este script força uma atualização do cache da API do Supabase.

          ## Query Description: [Esta é uma operação segura que não altera seus dados. Ela foi projetada para resolver um problema de cache que está impedindo a aplicação de reconhecer colunas recém-criadas, como a coluna 'nome' no módulo de CRM. Ao recriar uma função interna, forçamos a API a recarregar o esquema do banco de dados, resolvendo o erro "Could not find the column".]

          ## Metadata:
          - Schema-Category: ["Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]

          ## Structure Details:
          - Recria a função 'handle_updated_at'.

          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]

          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Nenhum impacto de performance. Apenas resolve um problema de cache.]
*/

-- Recria a função para forçar o Supabase a recarregar o schema
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
