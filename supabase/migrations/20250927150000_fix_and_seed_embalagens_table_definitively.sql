/*
# [FIX & SEED] Correção e Inserção de Dados na Tabela de Embalagens
Este script garante que a tabela 'embalagens' tenha a estrutura correta e insere os dados padrão.

## Query Description: [Este script é seguro para ser executado múltiplas vezes. Ele primeiro verifica e cria o tipo ENUM 'tipo_embalagem' se ele não existir. Em seguida, verifica e adiciona cada uma das colunas necessárias ('tipo', 'largura_cm', 'altura_cm', 'comprimento_cm', 'diametro_cm', 'peso_kg') à tabela 'embalagens' se elas estiverem faltando. Finalmente, ele insere os dados padrão das embalagens, ignorando quaisquer registros que já existam para evitar duplicatas. Não há risco de perda de dados.]

## Metadata:
- Schema-Category: ["Structural", "Data"]
- Impact-Level: ["Low"]
- Requires-Backup: false
- Reversible: false

## Structure Details:
- Tipo: public.tipo_embalagem
- Tabela: public.embalagens
- Colunas Adicionadas (se ausentes): tipo, largura_cm, altura_cm, comprimento_cm, diametro_cm, peso_kg

## Security Implications:
- RLS Status: [Mantido]
- Policy Changes: [Não]
- Auth Requirements: [admin]

## Performance Impact:
- Indexes: [Nenhum]
- Triggers: [Nenhum]
- Estimated Impact: [Baixo]
*/

-- Etapa 1: Garantir que o tipo ENUM 'tipo_embalagem' exista.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_embalagem') THEN
        CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');
    END IF;
END$$;

-- Etapa 2: Adicionar todas as colunas que possam estar faltando na tabela 'embalagens'.
DO $$
BEGIN
    -- Adiciona a coluna 'tipo' se ela não existir.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='embalagens' AND column_name='tipo') THEN
        ALTER TABLE public.embalagens ADD COLUMN tipo public.tipo_embalagem;
    END IF;

    -- Adiciona a coluna 'largura_cm' se ela não existir.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='embalagens' AND column_name='largura_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN largura_cm numeric(10,1);
    END IF;

    -- Adiciona a coluna 'altura_cm' se ela não existir.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='embalagens' AND column_name='altura_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN altura_cm numeric(10,1);
    END IF;

    -- Adiciona a coluna 'comprimento_cm' se ela não existir.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='embalagens' AND column_name='comprimento_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN comprimento_cm numeric(10,1);
    END IF;

    -- Adiciona a coluna 'diametro_cm' se ela não existir.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='embalagens' AND column_name='diametro_cm') THEN
        ALTER TABLE public.embalagens ADD COLUMN diametro_cm numeric(10,1);
    END IF;

    -- Adiciona a coluna 'peso_kg' se ela não existir.
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name='embalagens' AND column_name='peso_kg') THEN
        ALTER TABLE public.embalagens ADD COLUMN peso_kg numeric(10,3);
    END IF;
END$$;

-- Etapa 3: Adicionar uma restrição UNIQUE na descrição para permitir o ON CONFLICT.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'embalagens_descricao_unique' AND conrelid = 'public.embalagens'::regclass
    ) THEN
        ALTER TABLE public.embalagens ADD CONSTRAINT embalagens_descricao_unique UNIQUE (descricao);
    END IF;
END$$;

-- Etapa 4: Inserir os dados das embalagens, ignorando duplicatas.
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
