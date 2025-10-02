/*
          # [Operação de Correção e Seed]
          Este script corrige a estrutura da tabela 'embalagens' e insere os dados padrão.

          ## Query Description: 
          Esta operação é segura. Ela primeiro verifica a existência do tipo ENUM 'tipo_embalagem' e o cria se necessário. Em seguida, verifica a tabela 'embalagens' e adiciona todas as colunas que possam estar faltando ('tipo', 'largura_cm', 'altura_cm', 'comprimento_cm', 'diametro_cm', 'peso_kg'). Finalmente, insere os dados padrão das embalagens, ignorando duplicatas. Não há risco de perda de dados.
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: false
          
          ## Structure Details:
          - Tabela afetada: public.embalagens
          - Colunas adicionadas (se ausentes): tipo, largura_cm, altura_cm, comprimento_cm, diametro_cm, peso_kg
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (recria políticas padrão para garantir acesso)
          - Auth Requirements: authenticated
          
          ## Performance Impact:
          - Indexes: Nenhum índice novo adicionado.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo. A operação é rápida e afeta apenas a estrutura e os dados da tabela 'embalagens'.
          */
BEGIN;

-- 1. Cria o tipo ENUM 'tipo_embalagem' se ele não existir.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_embalagem') THEN
        CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');
    END IF;
END$$;

-- 2. Garante que a tabela 'embalagens' exista.
CREATE TABLE IF NOT EXISTS public.embalagens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    descricao TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 3. Adiciona todas as colunas necessárias à tabela 'embalagens' se elas não existirem.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='embalagens' AND column_name='tipo') THEN
        ALTER TABLE public.embalagens ADD COLUMN tipo public.tipo_embalagem;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='embalagens' AND column_name='largura_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN largura_cm NUMERIC(10, 1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='embalagens' AND column_name='altura_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN altura_cm NUMERIC(10, 1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='embalagens' AND column_name='comprimento_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN comprimento_cm NUMERIC(10, 1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='embalagens' AND column_name='diametro_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN diametro_cm NUMERIC(10, 1);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='embalagens' AND column_name='peso_kg') THEN
        ALTER TABLE public.embalagens ADD COLUMN peso_kg NUMERIC(10, 3);
    END IF;
END$$;

-- Garante que a coluna peso_kg seja NOT NULL
ALTER TABLE public.embalagens ALTER COLUMN peso_kg SET NOT NULL;

-- 4. Insere os dados das embalagens, evitando duplicatas pela descrição.
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

-- Habilita RLS na tabela se ainda não estiver habilitado
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;

-- Remove políticas antigas para evitar conflitos
DROP POLICY IF EXISTS "Enable read access for all users" ON public.embalagens;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.embalagens;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.embalagens;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.embalagens;

-- Cria políticas de RLS para permitir acesso total a usuários autenticados
CREATE POLICY "Enable read access for all users" ON public.embalagens
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for authenticated users" ON public.embalagens
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users" ON public.embalagens
    FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Enable delete for authenticated users" ON public.embalagens
    FOR DELETE TO authenticated USING (true);

COMMIT;
