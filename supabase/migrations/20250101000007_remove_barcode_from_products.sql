/*
# [Structural] Remove Barcode from Products
Removes the barcode column and its unique constraint from the products table.

## Query Description:
This operation will permanently delete the `codigo_barras` column from the `produtos` table, including all data stored within it. This action is not reversible.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Medium"
- Requires-Backup: false
- Reversible: false

## Structure Details:
- Table `produtos`:
  - Removes unique constraint `produtos_codigo_barras_key`
  - Removes column `codigo_barras`

## Security Implications:
- RLS Status: Unchanged
- Policy Changes: No
- Auth Requirements: None

## Performance Impact:
- Indexes: Removes the unique index associated with the constraint.
- Triggers: None
- Estimated Impact: Low. A brief table lock may occur during the alteration.
*/

-- Drop the unique constraint first if it exists
ALTER TABLE public.produtos
DROP CONSTRAINT IF EXISTS produtos_codigo_barras_key;

-- Drop the column if it exists
ALTER TABLE public.produtos
DROP COLUMN IF EXISTS codigo_barras;
