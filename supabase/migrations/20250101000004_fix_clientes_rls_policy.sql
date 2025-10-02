/*
# [Update RLS Policies for `clientes` Table]
This script updates the Row Level Security (RLS) policies for the `clientes` table to allow full CRUD (Create, Read, Update, Delete) operations for all users, including anonymous ones. This is a temporary measure to enable development before an authentication system is implemented.

## Query Description: This operation modifies security rules. It removes the previous, more restrictive policies that required a logged-in user (auth.uid()) and replaces them with policies that grant access to everyone. This is suitable for early development but should be revised once user authentication is added.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Medium"
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Table: public.clientes
- Policies Affected:
  - "Allow individual insert access" (DROPPED)
  - "Allow individual update access" (DROPPED)
  - "Allow individual delete access" (DROPPED)
  - "Allow all insert access" (CREATED)
  - "Allow all update access" (CREATED)
  - "Allow all delete access" (CREATED)

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes. The policies are being relaxed to allow anonymous access for CUD operations. This is a temporary change for development purposes.
- Auth Requirements: None after this change.

## Performance Impact:
- Indexes: None
- Triggers: None
- Estimated Impact: Negligible.
*/

-- Drop existing restrictive policies if they exist
DROP POLICY IF EXISTS "Allow individual insert access" ON public.clientes;
DROP POLICY IF EXISTS "Allow individual update access" ON public.clientes;
DROP POLICY IF EXISTS "Allow individual delete access" ON public.clientes;

-- Drop and recreate permissive policies to ensure a clean state
DROP POLICY IF EXISTS "Allow all insert access" ON public.clientes;
DROP POLICY IF EXISTS "Allow all update access" ON public.clientes;
DROP POLICY IF EXISTS "Allow all delete access" ON public.clientes;

-- Create new permissive policies for development
-- This allows any user (including anonymous) to insert data.
CREATE POLICY "Allow all insert access" ON public.clientes FOR INSERT WITH CHECK (true);

-- This allows any user (including anonymous) to update data.
CREATE POLICY "Allow all update access" ON public.clientes FOR UPDATE USING (true) WITH CHECK (true);

-- This allows any user (including anonymous) to delete data.
CREATE POLICY "Allow all delete access" ON public.clientes FOR DELETE USING (true);
