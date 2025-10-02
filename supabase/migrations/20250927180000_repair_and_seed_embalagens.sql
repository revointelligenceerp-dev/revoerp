/*
          # [REPAIR] Reparo e Seed da Tabela de Embalagens
          Este script foi projetado para ser executado com segurança, corrigindo o estado inconsistente da tabela 'embalagens' e populando-a com os dados iniciais.

          ## Query Description: ["Este script corrige a estrutura da tabela 'embalagens', garantindo que todas as colunas necessárias existam. Ele limpa valores nulos em colunas obrigatórias, aplica as restrições corretas e, finalmente, insere os dados padrão de embalagens, evitando duplicatas. É seguro executá-lo múltiplas vezes."]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Data"]
          - Impact-Level: ["Low"]
          - Requires-Backup: false
          - Reversible: false
          
          ## Structure Details:
          - Tabela afetada: public.embalagens
          - Colunas adicionadas (se ausentes): tipo, largura_cm, altura_cm, comprimento_cm, diametro_cm, peso_kg
          - Tipos criados (se ausentes): public.tipo_embalagem (ENUM)
          - Restrições aplicadas: NOT NULL, UNIQUE
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [admin]
          
          ## Performance Impact:
          - Indexes: [Added (UNIQUE constraint)]
          - Triggers: [None]
          - Estimated Impact: [Baixo, a operação é rápida e afeta uma tabela de lookup.]
          */
BEGIN;

-- Step 1: Create the ENUM type if it doesn't exist.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_embalagem') THEN
        CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');
    END IF;
END
$$;

-- Step 2: Ensure all required columns exist.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='descricao') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='nome') THEN
            ALTER TABLE public.embalagens RENAME COLUMN nome TO descricao;
        ELSE
            ALTER TABLE public.embalagens ADD COLUMN descricao text;
        END IF;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='tipo') THEN
        ALTER TABLE public.embalagens ADD COLUMN tipo public.tipo_embalagem;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='largura_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN largura_cm numeric(10,1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='altura_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN altura_cm numeric(10,1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='comprimento_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN comprimento_cm numeric(10,1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='diametro_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN diametro_cm numeric(10,1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='embalagens' AND column_name='peso_kg') THEN
        ALTER TABLE public.embalagens ADD COLUMN peso_kg numeric(10,3);
    END IF;
END
$$;

-- Step 3: Clean up NULL values in columns that will become NOT NULL.
UPDATE public.embalagens SET peso_kg = 0.000 WHERE peso_kg IS NULL;
UPDATE public.embalagens SET descricao = 'Descrição Padrão' WHERE descricao IS NULL OR descricao = '';
UPDATE public.embalagens SET tipo = 'CAIXA' WHERE tipo IS NULL;

-- Step 4: Apply the NOT NULL constraints.
ALTER TABLE public.embalagens ALTER COLUMN descricao SET NOT NULL;
ALTER TABLE public.embalagens ALTER COLUMN tipo SET NOT NULL;
ALTER TABLE public.embalagens ALTER COLUMN peso_kg SET NOT NULL;

-- Step 5: Add a unique constraint to 'descricao' for conflict resolution.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'embalagens_descricao_key' AND conrelid = 'public.embalagens'::regclass
    ) THEN
        ALTER TABLE public.embalagens ADD CONSTRAINT embalagens_descricao_key UNIQUE (descricao);
    END IF;
END
$$;

-- Step 6: Seed the data, ignoring duplicates.
INSERT INTO public.embalagens (descricao, tipo, largura_cm, altura_cm, comprimento_cm, diametro_cm, peso_kg) VALUES
('Caixa de Encomenda Flex — 1 cm', 'CAIXA', 26.0, 1.0, 21.0, NULL, 0.090),
('Caixa de Encomenda Flex — 2 cm', 'CAIXA', 26.0, 2.0, 21.0, NULL, 0.180),
('Caixa de Encomenda Flex — 3 cm', 'CAIXA', 26.0, 3.0, 21.0, NULL, 0.270),
('Caixa de Encomenda Flex — 4 cm', 'CAIXA', 26.0, 4.0, 21.0, NULL, 0.360),
('Caixa de Encomenda Flex — 5 cm', 'CAIXA', 26.0, 5.0, 21.0, NULL, 0.460),
('Caixa de Encomenda Flex — 6 cm', 'CAIXA', 26.0, 6.0, 21.0, NULL, 0.550),
('Caixa de Encomenda CE – 01', 'CAIXA', 18.0, 9.0, 13.5, NULL, 0.360),
('Caixa de Encomenda CE – 02', 'CAIXA', 27.0, 9.0, 18.0, NULL, 0.730),
('Caixa de Encomenda CE – 03', 'CAIXA', 27.0, 13.5, 22.5, NULL, 1.370),
('Caixa de Encomenda CE – 07', 'CAIXA', 36.0, 4.0, 28.0, NULL, 0.670),
('Caixa de Encomenda 5B', 'CAIXA', 54.0, 27.0, 36.0, NULL, 8.750),
('Caixa de Encomenda 6B', 'CAIXA', 27.0, 36.0, 27.0, NULL, 4.370),
('Caixa de Encomenda Vai e Vem', 'CAIXA', 18.0, 9.0, 13.5, NULL, 0.360),
('Caixa de Encomenda B', 'CAIXA', 16.0, 6.0, 11.0, NULL, 0.180),
('Caixa de Encomenda 2B', 'CAIXA', 27.0, 9.0, 18.0, NULL, 0.730),
('Caixa de Encomenda 4B', 'CAIXA', 27.0, 18.0, 27.0, NULL, 2.190),
('Caixa de Encomenda Temática 01', 'CAIXA', 18.0, 9.0, 13.5, NULL, 0.360),
('Caixa de Encomenda Temática 02', 'CAIXA', 27.0, 9.0, 18.0, NULL, 0.730),
('Caixa de Encomenda Temática 03', 'CAIXA', 27.0, 13.5, 22.5, NULL, 1.370),
('Envelope Básico RPC (Papel)', 'ENVELOPE', 16.2, NULL, 11.4, NULL, 0.030),
('Envelope Básico Médio (Plástico)', 'ENVELOPE', 35.3, NULL, 25.0, NULL, 0.150),
('Envelope Básico Grande (Plástico)', 'ENVELOPE', 40.0, NULL, 28.0, NULL, 0.190),
('Envelope Convencional Médio (Plástico)', 'ENVELOPE', 35.3, NULL, 25.0, NULL, 0.150),
('Envelope Convencional Grande (Plástico)', 'ENVELOPE', 40.0, NULL, 28.0, NULL, 0.190),
('Envelope Convencional CD (Plástico)', 'ENVELOPE', 21.0, NULL, 18.0, NULL, 0.060),
('Envelope Convencional DVD (Plástico)', 'ENVELOPE', 21.0, NULL, 18.0, NULL, 0.060),
('Envelope Convencional Tipo Saco II (Papel)', 'ENVELOPE', 25.0, NULL, 35.3, NULL, 0.150),
('Envelope Temático Tipo Saco I (Papel)', 'ENVELOPE', 16.0, NULL, 23.0, NULL, 0.060),
('Envelope Temático Tipo Saco II (Papel)', 'ENVELOPE', 25.0, NULL, 35.3, NULL, 0.150),
('Envelope Temático Ofício (Papel)', 'ENVELOPE', 22.9, NULL, 11.4, NULL, 0.040),
('Envelope Temático Médio (Cartão)', 'ENVELOPE', 35.3, NULL, 25.0, NULL, 0.150),
('Envelope Temático Grande (Cartão)', 'ENVELOPE', 40.0, NULL, 28.0, NULL, 0.190),
('Envelope Tipo Saco I', 'ENVELOPE', 16.0, NULL, 23.0, NULL, 0.060),
('Envelope Tipo Saco II', 'ENVELOPE', 25.0, NULL, 35.3, NULL, 0.150),
('Envelope Ofício', 'ENVELOPE', 22.9, NULL, 11.4, NULL, 0.040),
('Envelope Cartonado Médio', 'ENVELOPE', 35.3, NULL, 25.0, NULL, 0.150),
('Envelope Cartonado Grande', 'ENVELOPE', 40.0, NULL, 28.0, NULL, 0.190)
ON CONFLICT (descricao) DO NOTHING;

COMMIT;
