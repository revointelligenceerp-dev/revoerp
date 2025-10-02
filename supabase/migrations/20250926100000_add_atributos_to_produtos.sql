/*
# [Add Atributos to Produtos]
This migration adds a JSONB column named 'atributos' to the 'produtos' table to store a flexible list of attribute-value pairs for each product.

## Query Description: [This operation adds a new 'atributos' column to the 'produtos' table. Existing rows will have a default empty array value for this column. This change is non-destructive and fully reversible.]

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [true]

## Structure Details:
- Table: "produtos"
- Column Added: "atributos" (Type: JSONB, Default: '[]'::jsonb)

## Security Implications:
- RLS Status: [Enabled]
- Policy Changes: [No]
- Auth Requirements: [The existing RLS policies on the 'produtos' table will apply to this new column.]

## Performance Impact:
- Indexes: [None added in this migration. Consider adding a GIN index on 'atributos' if frequent querying on attributes is expected.]
- Triggers: [None]
- Estimated Impact: [Low. The operation is a metadata change and should be fast on most table sizes.]
*/

ALTER TABLE public.produtos
ADD COLUMN atributos JSONB NOT NULL DEFAULT '[]'::jsonb;
