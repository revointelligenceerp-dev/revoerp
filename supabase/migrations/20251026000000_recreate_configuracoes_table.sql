/*
  # Operation: Drop Table 'configuracoes'
  [This operation will completely remove the 'configuracoes' table and all its data. This is a destructive action.]

  ## Query Description:
  - Impact: All existing settings will be permanently deleted.
  - Risks: High risk of data loss if the table contains important configuration data.
  - Precautions: Ensure you have a backup or can easily recreate the settings.

  ## Metadata:
  - Schema-Category: "Dangerous"
  - Impact-Level: "High"
  - Requires-Backup: true
  - Reversible: false
*/
DROP TABLE IF EXISTS public.configuracoes;


/*
  # Operation: Create Table 'configuracoes'
  [This operation creates a new table to store application-wide settings as key-value pairs.]

  ## Query Description:
  - Impact: Creates a new, empty table for configurations.
  - Risks: Low. Does not affect existing data.
  - Precautions: None.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (by dropping the table)

  ## Structure Details:
  - Table: public.configuracoes
  - Columns:
    - id: uuid (Primary Key)
    - key: text (Unique, Not Null)
    - value: jsonb
    - description: text
    - created_at: timestamptz
    - updated_at: timestamptz
*/
CREATE TABLE public.configuracoes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL UNIQUE,
    value jsonb,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT configuracoes_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE public.configuracoes IS 'Stores application-wide settings and configurations.';
COMMENT ON COLUMN public.configuracoes.key IS 'The unique identifier for the setting (e.g., "email_smtp_host").';
COMMENT ON COLUMN public.configuracoes.value IS 'The value of the setting, stored in JSONB format to be flexible.';
COMMENT ON COLUMN public.configuracoes.description IS 'A user-friendly description of what the setting does.';


/*
  # Operation: Enable RLS and Create Policies for 'configuracoes'
  [This operation secures the new 'configuracoes' table by enabling Row Level Security and defining access policies.]

  ## Security Implications:
  - RLS Status: Enabled
  - Policy Changes: Yes, new policies are created.
  - Auth Requirements: Authenticated users can read settings. Only service_role can modify them.
*/
ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read settings"
ON public.configuracoes
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow service_role to manage settings"
ON public.configuracoes
FOR ALL
TO service_role
USING (true);
