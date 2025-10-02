/*
  # [Feature] User Permissions Management
  Creates the necessary table to store granular user permissions.

  ## Query Description:
  This script introduces a new table `user_permissions` to store a JSONB object containing all specific permissions for each user. It links directly to the `auth.users` table and is secured with Row Level Security (RLS), initially only allowing access via the `service_role`. This is a safe setup, ensuring that permission management must be handled through secure backend functions (like Supabase Edge Functions) rather than directly from the client. No existing data is affected.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true

  ## Structure Details:
  - Creates table `public.user_permissions`.
  - Columns: `id`, `user_id`, `permissions`, `created_at`, `updated_at`.
  - Foreign Key: `user_permissions.user_id` references `auth.users.id`.

  ## Security Implications:
  - RLS Status: Enabled on `user_permissions`.
  - Policy Changes: Yes, a new policy is created.
  - Auth Requirements: Operations are restricted to `service_role`.

  ## Performance Impact:
  - Indexes: Adds a primary key index on `id` and a foreign key index on `user_id`.
  - Triggers: None.
  - Estimated Impact: Low. Negligible impact on performance for general app usage.
*/

create table public.user_permissions (
    id uuid not null default gen_random_uuid() primary key,
    user_id uuid not null unique references auth.users(id) on delete cascade,
    permissions jsonb not null default '{}'::jsonb,
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone not null default now()
);

comment on table public.user_permissions is 'Stores granular permissions for each user.';
comment on column public.user_permissions.user_id is 'Links to the authenticated user.';
comment on column public.user_permissions.permissions is 'JSON object containing key-value pairs of permissions.';

-- Enable Row Level Security
alter table public.user_permissions enable row level security;

-- Allow service_role to manage all permissions.
-- This is the safest default, forcing permission changes through secure backend functions.
create policy "Allow service_role to manage all"
on public.user_permissions for all
to service_role
using (true)
with check (true);
