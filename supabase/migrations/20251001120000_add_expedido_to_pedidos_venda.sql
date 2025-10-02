/*
# [Structural] Adiciona a coluna 'expedido' à tabela 'pedidos_venda'

## Query Description: 
Esta operação adiciona uma nova coluna `expedido` (do tipo booleano) à tabela `pedidos_venda`.
Esta coluna é essencial para o funcionamento do módulo de expedição, pois controla quais pedidos já foram incluídos em um lote de expedição.
A operação é segura e não afeta dados existentes, definindo o valor padrão como `FALSE` para todos os registros atuais.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (DROP COLUMN expedido)

## Structure Details:
- Tabela afetada: public.pedidos_venda
- Coluna adicionada: expedido (BOOLEAN, DEFAULT FALSE)

## Security Implications:
- RLS Status: A nova coluna herdará as políticas de RLS existentes na tabela.
- Policy Changes: No
- Auth Requirements: N/A

## Performance Impact:
- Indexes: Nenhum índice adicionado.
- Triggers: Nenhum trigger adicionado.
- Estimated Impact: Baixo. A adição de uma coluna com valor padrão pode levar algum tempo em tabelas muito grandes, mas geralmente é uma operação rápida.
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'pedidos_venda'
    AND column_name = 'expedido'
  ) THEN
    ALTER TABLE public.pedidos_venda
    ADD COLUMN expedido BOOLEAN DEFAULT FALSE;
  END IF;
END;
$$;
