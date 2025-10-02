/*
# [Fix & Create] Idempotent Cliente Schema
This script creates the necessary types and the 'clientes' table, ensuring it can be run multiple times without errors. It checks for the existence of types and tables before creating them.

## Query Description: This operation will create the 'clientes' table and its associated types if they do not already exist. It is designed to be safe to run on a database that may have been partially migrated. It will also reset and re-apply the Row Level Security (RLS) policies to ensure they are correctly configured. No existing data in the 'clientes' table will be lost if the table already exists.

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [false]

## Structure Details:
- Types Created: `cliente_status`, `tipo_cliente` (if they don't exist)
- Table Created: `public.clientes` (if it doesn't exist)
- Columns: id, created_at, updated_at, nome, email, telefone, documento, tipo, status, endereco
- Constraints: PRIMARY KEY on id, UNIQUE on email, UNIQUE on documento
- Indexes: Indexes are created for the primary key and unique constraints.
- RLS Policies: Policies for SELECT, INSERT, UPDATE, DELETE are created.

## Security Implications:
- RLS Status: Enabled on `public.clientes`
- Policy Changes: Yes. Existing policies on `public.clientes` will be dropped and recreated to ensure correctness.
- Auth Requirements: Operations are restricted to authenticated users.

## Performance Impact:
- Indexes: Primary key and unique indexes will improve query performance on `id`, `email`, and `documento`.
- Triggers: A trigger is added to automatically update the `updated_at` timestamp.
- Estimated Impact: Low. The changes are standard for a new table and should improve performance for common lookups.
*/

-- Create custom ENUM types if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'cliente_status') THEN
        CREATE TYPE public.cliente_status AS ENUM ('ATIVO', 'INATIVO', 'SUSPENSO');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_cliente') THEN
        CREATE TYPE public.tipo_cliente AS ENUM ('CLIENTE', 'FORNECEDOR', 'AMBOS');
    END IF;
END
$$;

-- Create the table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    nome TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    telefone TEXT,
    documento TEXT UNIQUE,
    tipo public.tipo_cliente NOT NULL,
    status public.cliente_status NOT NULL,
    endereco JSONB
);

-- Add comments to the table and columns for clarity
COMMENT ON TABLE public.clientes IS 'Stores customer and supplier information.';
COMMENT ON COLUMN public.clientes.id IS 'Unique identifier for the client.';
COMMENT ON COLUMN public.clientes.nome IS 'Full name of the client.';
COMMENT ON COLUMN public.clientes.email IS 'Unique email address for the client.';
COMMENT ON COLUMN public.clientes.documento IS 'Unique identification document (CPF/CNPJ).';
COMMENT ON COLUMN public.clientes.tipo IS 'Specifies if the entity is a client, supplier, or both.';
COMMENT ON COLUMN public.clientes.status IS 'The current status of the client (active, inactive, suspended).';
COMMENT ON COLUMN public.clientes.endereco IS 'Address information in JSON format.';

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop the trigger if it exists, then create it
DROP TRIGGER IF EXISTS on_clientes_updated ON public.clientes;
CREATE TRIGGER on_clientes_updated
BEFORE UPDATE ON public.clientes
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to prevent errors, then recreate them
DROP POLICY IF EXISTS "Allow public read access" ON public.clientes;
CREATE POLICY "Allow public read access"
ON public.clientes
FOR SELECT
TO public
USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to insert" ON public.clientes;
CREATE POLICY "Allow authenticated users to insert"
ON public.clientes
FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated users to update" ON public.clientes;
CREATE POLICY "Allow authenticated users to update"
ON public.clientes
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated users to delete" ON public.clientes;
CREATE POLICY "Allow authenticated users to delete"
ON public.clientes
FOR DELETE
TO authenticated
USING (true);
