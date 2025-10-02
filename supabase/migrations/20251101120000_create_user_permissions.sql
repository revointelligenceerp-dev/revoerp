/*
# [Feature] User Permissions Management
This migration creates the necessary infrastructure to manage user-specific permissions within the application.

## Query Description: [This operation creates a new table `user_permissions` to store permissions as a JSONB object, linked to each user. It also sets up Row Level Security to ensure that only authorized roles can access or modify these permissions. This change is structural and does not affect existing data.]

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Creates table `public.user_permissions` with columns: `id`, `user_id`, `permissions`, `created_at`, `updated_at`.
- Adds a foreign key from `user_permissions.user_id` to `auth.users.id`.
- Creates a trigger `on_user_permissions_updated` to automatically update the `updated_at` timestamp.

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes. Creates a policy that allows service roles to manage all permissions.
- Auth Requirements: Management requires service-level privileges via Edge Functions.

## Performance Impact:
- Indexes: Adds a primary key index and a foreign key index.
- Triggers: Adds an `updated_at` trigger.
- Estimated Impact: Low. The table will grow with the number of users, but queries are indexed.
*/

-- Create the user_permissions table
CREATE TABLE IF NOT EXISTS public.user_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    permissions JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Add comments to the table and columns for clarity
COMMENT ON TABLE public.user_permissions IS 'Stores user-specific application permissions.';
COMMENT ON COLUMN public.user_permissions.user_id IS 'Foreign key to the user in auth.users.';
COMMENT ON COLUMN public.user_permissions.permissions IS 'JSONB object storing permission keys and boolean values.';

-- Enable Row Level Security
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- By default, no one can access the table. We will rely on service_role access via Edge Functions.
CREATE POLICY "Allow service_role full access"
ON public.user_permissions
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- Create trigger to automatically update 'updated_at'
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_user_permissions_updated
BEFORE UPDATE ON public.user_permissions
FOR EACH ROW
EXECUTE PROCEDURE public.handle_updated_at();
