/*
  # [SCHEMA CORRECTION] Adiciona a coluna 'percentual_comissao' na tabela 'vendedores'

  ## Query Description:
  Esta operação corrige a estrutura da tabela 'vendedores' adicionando a coluna 'percentual_comissao' que estava faltando. A ausência desta coluna estava causando um erro ao tentar criar ou atualizar um vendedor, pois a aplicação tentava enviar um dado para um campo que não existia no banco de dados. A operação é segura e não afeta os dados existentes.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (DROP COLUMN)

  ## Structure Details:
  - Tabela afetada: 'vendedores'
  - Coluna adicionada: 'percentual_comissao' (NUMERIC(5, 2))

  ## Security Implications:
  - RLS Status: Inalterado
  - Policy Changes: Não
  - Auth Requirements: Não

  ## Performance Impact:
  - Indexes: Nenhum
  - Triggers: Nenhum
  - Estimated Impact: Mínimo, a alteração de esquema é rápida em tabelas com poucos dados.
*/
ALTER TABLE public.vendedores
ADD COLUMN IF NOT EXISTS percentual_comissao NUMERIC(5, 2) NOT NULL DEFAULT 0 CHECK (percentual_comissao >= 0 AND percentual_comissao <= 100);
