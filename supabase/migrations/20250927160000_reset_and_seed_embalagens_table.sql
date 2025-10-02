-- Resets the embalagens table to a clean state and seeds it with data.

-- Step 1: Drop existing objects to ensure a clean slate.
-- This is safe because the table is new and only contains data from previous failed seeds.
DROP TABLE IF EXISTS public.embalagens;
DROP TYPE IF EXISTS public.tipo_embalagem;

-- Step 2: Create the ENUM type for tipo_embalagem.
CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');

-- Step 3: Create the embalagens table with the correct and complete schema.
CREATE TABLE public.embalagens (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    descricao text NOT NULL,
    tipo public.tipo_embalagem NOT NULL,
    largura_cm numeric(10, 1),
    altura_cm numeric(10, 1),
    comprimento_cm numeric(10, 1),
    diametro_cm numeric(10, 1),
    peso_kg numeric(10, 3) NOT NULL
);

-- Step 4: Add primary key constraint and enable RLS.
ALTER TABLE ONLY public.embalagens ADD CONSTRAINT embalagens_pkey PRIMARY KEY (id);
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;

-- Step 5: Create RLS policies for authenticated users.
CREATE POLICY "Allow all access to authenticated users"
ON public.embalagens
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Step 6: Insert the seed data for 'CAIXA' type.
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
('Caixa de Encomenda Temática 03', 'CAIXA', 27.0, 13.5, 22.5, 1.370);

-- Step 7: Insert the seed data for 'ENVELOPE' type.
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
('Envelope Cartonado Grande', 'ENVELOPE', 40.0, 28.0, 0.190);
