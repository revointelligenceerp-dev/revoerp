/*
# [Structural] Adiciona a coluna de comissão à tabela de vendedores
[Este script adiciona a coluna 'percentual_comissao' à tabela 'vendedores' para armazenar o percentual de comissão de cada vendedor.]

## Query Description: [Esta operação é segura e não afeta dados existentes. Ela apenas adiciona uma nova coluna com um valor padrão de 0, garantindo que a funcionalidade de cadastro de vendedores funcione corretamente.]

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Low"]
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Table: vendedores
- Column Added: percentual_comissao (numeric(5, 2))

## Security Implications:
- RLS Status: [Enabled]
- Policy Changes: [No]
- Auth Requirements: [None]

## Performance Impact:
- Indexes: [None]
- Triggers: [None]
- Estimated Impact: [Nenhum impacto significativo de performance esperado.]
*/
ALTER TABLE public.vendedores
ADD COLUMN IF NOT EXISTS percentual_comissao NUMERIC(5, 2) NOT NULL DEFAULT 0;
