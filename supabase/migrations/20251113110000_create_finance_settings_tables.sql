/*
  # [Operation] Create Finance Settings Tables
  [Description] This migration creates the `categorias_financeiras` and `formas_pagamento` tables, essential for financial configuration. It also enables Row Level Security (RLS) and sets a default permissive policy for authenticated users, ensuring data security from the start.

  ## Query Description:
  - Creates `categorias_financeiras` to classify revenues and expenses.
  - Creates `formas_pagamento` to manage payment methods.
  - Enables RLS on both tables to enforce security policies.
  - Adds a default `ALLOW ALL` policy for authenticated users, which is suitable for the current single-tenant setup but should be reviewed for multi-tenancy.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (by dropping the tables and policies)

  ## Structure Details:
  - Tables created: `categorias_financeiras`, `formas_pagamento`.
  - Columns added: `id`, `descricao`, `tipo`, `ativo`, `created_at`, `updated_at`.

  ## Security Implications:
  - RLS Status: Enabled on new tables.
  - Policy Changes: Yes, new permissive policies are added for authenticated users.
  - Auth Requirements: Policies are based on the `authenticated` role.

  ## Performance Impact:
  - Indexes: Primary key indexes are automatically created.
  - Triggers: None.
  - Estimated Impact: Negligible. These are small lookup tables.
*/

-- Tabela para Categorias Financeiras (Plano de Contas)
CREATE TABLE IF NOT EXISTS public.categorias_financeiras (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    descricao character varying NOT NULL,
    tipo character varying NOT NULL, -- 'RECEITA' ou 'DESPESA'
    ativo boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT categorias_financeiras_pkey PRIMARY KEY (id)
);

-- Tabela para Formas de Pagamento
CREATE TABLE IF NOT EXISTS public.formas_pagamento (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    descricao character varying NOT NULL,
    ativo boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT formas_pagamento_pkey PRIMARY KEY (id)
);

-- Habilitar RLS e criar políticas permissivas para as novas tabelas
ALTER TABLE public.categorias_financeiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.formas_pagamento ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all access to authenticated users" ON public.categorias_financeiras;
CREATE POLICY "Allow all access to authenticated users"
ON public.categorias_financeiras
FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Allow all access to authenticated users" ON public.formas_pagamento;
CREATE POLICY "Allow all access to authenticated users"
ON public.formas_pagamento
FOR ALL
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');
