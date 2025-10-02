/*
  # [Fix and Seed Embalagens Table]
  [This script ensures the 'embalagens' table has a unique constraint on 'descricao' and populates it with initial sample data. This prevents duplicate entries and resolves the 'ON CONFLICT' error.]

  ## Query Description: [First, it adds a unique constraint to the 'descricao' column of the 'embalagens' table. Then, it inserts a set of standard packaging types, ignoring any that already exist based on their description. This makes the script safe to run multiple times.]
  
  ## Metadata:
  - Schema-Category: ["Structural", "Data"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
  
  ## Structure Details:
  - Table: public.embalagens
  - Constraint: Adds a UNIQUE constraint on the 'descricao' column.
  
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [No]
  - Auth Requirements: [Admin privileges]
*/

-- Step 1: Add a unique constraint to the 'descricao' column to enforce uniqueness.
-- This is necessary for the 'ON CONFLICT' clause to work correctly.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.embalagens'::regclass
        AND conname = 'embalagens_descricao_key'
        AND contype = 'u'
    ) THEN
        ALTER TABLE public.embalagens ADD CONSTRAINT embalagens_descricao_key UNIQUE (descricao);
    END IF;
END $$;

-- Step 2: Seed the table with sample data, ignoring duplicates.
INSERT INTO public.embalagens (descricao, tipo, largura_cm, altura_cm, comprimento_cm, diametro_cm, peso_kg)
VALUES
    ('Caixa Pequena (10x10x5 cm)', 'CAIXA', 10, 5, 10, NULL, 0.1),
    ('Caixa Média (20x20x10 cm)', 'CAIXA', 20, 10, 20, NULL, 0.25),
    ('Caixa Grande (40x30x20 cm)', 'CAIXA', 30, 20, 40, NULL, 0.5),
    ('Envelope A4 (32x24 cm)', 'ENVELOPE', 24, NULL, 32, NULL, 0.05),
    ('Envelope Ofício (25x12 cm)', 'ENVELOPE', 12, NULL, 25, NULL, 0.03),
    ('Cilindro/Tubo (50x10 cm)', 'CILINDRO', NULL, NULL, 50, 10, 0.3),
    ('Caixa para Caneca (12x12x12 cm)', 'CAIXA', 12, 12, 12, NULL, 0.15),
    ('Caixa para Livro (25x18x5 cm)', 'CAIXA', 18, 5, 25, NULL, 0.2),
    ('Envelope Bolha Pequeno (15x10 cm)', 'ENVELOPE', 10, NULL, 15, NULL, 0.02),
    ('Cilindro para Pôster (90x8 cm)', 'CILINDRO', NULL, NULL, 90, 8, 0.4)
ON CONFLICT (descricao) DO NOTHING;
