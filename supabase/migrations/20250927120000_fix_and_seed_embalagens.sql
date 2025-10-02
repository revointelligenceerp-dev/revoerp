/*
# [Fix and Seed Embalagens Table]
This script corrects the 'embalagens' table by adding the missing 'tipo' column and then populates it with standard packaging data.

## Query Description: [This operation modifies the structure of the 'embalagens' table by adding a new column and inserts a predefined set of data. It is designed to be safe and will not run if the column already exists or if the data is already present.]

## Metadata:
- Schema-Category: ["Structural", "Data"]
- Impact-Level: ["Low"]
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Adds column 'tipo' of type 'public.tipo_embalagem' to the 'public.embalagens' table.
- Adds a UNIQUE constraint on the 'descricao' column to prevent duplicate entries.

## Security Implications:
- RLS Status: [Not Changed]
- Policy Changes: [No]
- Auth Requirements: [None]

## Performance Impact:
- Indexes: [Adds a unique index on 'descricao']
- Triggers: [None]
- Estimated Impact: [Low, the operation is fast on tables of small to medium size.]
*/

-- Step 1: Create the ENUM type for 'tipo_embalagem' if it doesn't already exist.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_embalagem') THEN
        CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');
    END IF;
END$$;

-- Step 2: Add the 'tipo' column to the 'embalagens' table if it's missing.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'embalagens'
        AND column_name = 'tipo'
    ) THEN
        ALTER TABLE public.embalagens ADD COLUMN tipo public.tipo_embalagem;
    END IF;
END$$;

-- Step 3: Add a unique constraint on 'descricao' to make seeding idempotent and safe.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.embalagens'::regclass
        AND conname = 'embalagens_descricao_key'
        AND contype = 'u'
    ) THEN
        -- Before adding the constraint, we clean up any potential duplicates.
        DELETE FROM public.embalagens a
        USING public.embalagens b
        WHERE a.id > b.id AND a.descricao = b.descricao;
        
        ALTER TABLE public.embalagens ADD CONSTRAINT embalagens_descricao_key UNIQUE (descricao);
    END IF;
END$$;

-- Step 4: Insert the seed data for 'CAIXA' type.
INSERT INTO public.embalagens (descricao, tipo, largura_cm, altura_cm, comprimento_cm, peso_kg) VALUES
  ('Caixa de Encomenda Flex — 1 cm', 'CAIXA', 26.0, 1.0, 21.0, 0.090),
  ('Caixa de Encomenda Flex — 2 cm', 'CAIXA', 26.0, 2.0, 21.0, 0.180),
  ('Caixa de Encomenda Flex — 3 cm', 'CAIXA', 26.0, 3.0, 21.0, 0.270),
  ('Caixa de Encomenda Flex — 4 cm', 'CAIXA', 26.0, 4.0, 21.0, 0.360),
  ('Caixa de Encomenda Flex — 5 cm', 'CAIXA', 26.0, 5.0, 21.0, 0.460),
  ('Caixa de Encomenda Flex — 6 cm', 'CAIXA', 26.0, 6.0, 21.0, 0.550),
  ('Caixa de Encomenda CE – 01', 'CAIXA', 18.0, 9.0, 13.5, 0.360),
  ('Caixa de Encomenda CE – 02', 'CAIXA', 27.0, 9.0, 18.0, 0.730),
  ('Caixa de Encomenda CE – 03', 'CAIXA', 27.0, 13.5, 22.5, 1.370),
  ('Caixa de Encomenda CE – 07', 'CAIXA', 36.0, 4.0, 28.0, 0.670),
  ('Caixa de Encomenda 5B', 'CAIXA', 54.0, 27.0, 36.0, 8.750),
  ('Caixa de Encomenda 6B', 'CAIXA', 27.0, 36.0, 27.0, 4.370),
  ('Caixa de Encomenda Vai e Vem', 'CAIXA', 18.0, 9.0, 13.5, 0.360),
  ('Caixa de Encomenda B', 'CAIXA', 16.0, 6.0, 11.0, 0.180),
  ('Caixa de Encomenda 2B', 'CAIXA', 27.0, 9.0, 18.0, 0.730),
  ('Caixa de Encomenda 4B', 'CAIXA', 27.0, 18.0, 27.0, 2.190),
  ('Caixa de Encomenda Temática 01', 'CAIXA', 18.0, 9.0, 13.5, 0.360),
  ('Caixa de Encomenda Temática 02', 'CAIXA', 27.0, 9.0, 18.0, 0.730),
  ('Caixa de Encomenda Temática 03', 'CAIXA', 27.0, 13.5, 22.5, 1.370)
ON CONFLICT (descricao) DO NOTHING;

-- Step 5: Insert the seed data for 'ENVELOPE' type.
INSERT INTO public.embalagens (descricao, tipo, largura_cm, comprimento_cm, peso_kg) VALUES
  ('Envelope Básico RPC (Papel)', 'ENVELOPE', 16.2, 11.4, 0.030),
  ('Envelope Básico Médio (Plástico)', 'ENVELOPE', 35.3, 25.0, 0.150),
  ('Envelope Básico Grande (Plástico)', 'ENVELOPE', 40.0, 28.0, 0.190),
  ('Envelope Convencional Médio (Plástico)', 'ENVELOPE', 35.3, 25.0, 0.150),
  ('Envelope Convencional Grande (Plástico)', 'ENVELOPE', 40.0, 28.0, 0.190),
  ('Envelope Convencional CD (Plástico)', 'ENVELOPE', 21.0, 18.0, 0.060),
  ('Envelope Convencional DVD (Plástico)', 'ENVELOPE', 21.0, 18.0, 0.060),
  ('Envelope Convencional Tipo Saco II (Papel)', 'ENVELOPE', 25.0, 35.3, 0.150),
  ('Envelope Temático Tipo Saco I (Papel)', 'ENVELOPE', 16.0, 23.0, 0.060),
  ('Envelope Temático Tipo Saco II (Papel)', 'ENVELOPE', 25.0, 35.3, 0.150),
  ('Envelope Temático Ofício (Papel)', 'ENVELOPE', 22.9, 11.4, 0.040),
  ('Envelope Temático Médio (Cartão)', 'ENVELOPE', 35.3, 25.0, 0.150),
  ('Envelope Temático Grande (Cartão)', 'ENVELOPE', 40.0, 28.0, 0.190),
  ('Envelope Tipo Saco I', 'ENVELOPE', 16.0, 23.0, 0.060),
  ('Envelope Tipo Saco II', 'ENVELOPE', 25.0, 35.3, 0.150),
  ('Envelope Ofício', 'ENVELOPE', 22.9, 11.4, 0.040),
  ('Envelope Cartonado Médio', 'ENVELOPE', 35.3, 25.0, 0.150),
  ('Envelope Cartonado Grande', 'ENVELOPE', 40.0, 28.0, 0.190)
ON CONFLICT (descricao) DO NOTHING;
