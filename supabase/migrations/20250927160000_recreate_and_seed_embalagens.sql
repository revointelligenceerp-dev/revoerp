/*
  # [MIGRATION] Recriação e Seed da Tabela de Embalagens
  [Este script irá APAGAR a tabela 'embalagens' existente, que está corrompida, e recriá-la corretamente do zero, inserindo os dados iniciais.]

  ## Query Description: [ATENÇÃO: Este script irá DELETAR permanentemente a tabela 'embalagens' e todos os dados nela contidos antes de recriá-la. Isso é necessário para corrigir uma série de erros causados por uma estrutura de tabela corrompida. Prossiga apenas se você concorda em perder os dados existentes nesta tabela específica. O script então irá:
  1. Recriar o tipo ENUM 'tipo_embalagem'.
  2. Criar a tabela 'embalagens' com a estrutura correta.
  3. Habilitar a segurança (RLS) e criar as políticas de acesso.
  4. Inserir os dados de embalagens padrão fornecidos.]

  ## Metadata:
  - Schema-Category: ["Dangerous", "Structural", "Data"]
  - Impact-Level: ["High"]
  - Requires-Backup: true
  - Reversible: false

  ## Structure Details:
  - Tables affected: public.embalagens (será apagada e recriada)
  - Types affected: public.tipo_embalagem (será apagado e recriado)

  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [Yes, policies will be recreated]
  - Auth Requirements: [None]

  ## Performance Impact:
  - Indexes: [Primary key will be recreated]
  - Triggers: [None]
  - Estimated Impact: [Baixo, mas a operação de DROP pode ser bloqueante por um curto período.]
*/

BEGIN;

-- Apaga a tabela e o tipo existentes para garantir um estado limpo.
-- ATENÇÃO: ISSO APAGARÁ TODOS OS DADOS DA TABELA 'embalagens'.
DROP TABLE IF EXISTS public.embalagens;
DROP TYPE IF EXISTS public.tipo_embalagem;

-- 1. Criar o tipo ENUM
CREATE TYPE public.tipo_embalagem AS ENUM ('ENVELOPE', 'CAIXA', 'CILINDRO');

-- 2. Criar a tabela com a estrutura correta
CREATE TABLE public.embalagens (
    id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    descricao text NOT NULL UNIQUE,
    tipo public.tipo_embalagem NOT NULL,
    largura_cm numeric(10, 1),
    altura_cm numeric(10, 1),
    comprimento_cm numeric(10, 1),
    diametro_cm numeric(10, 1),
    peso_kg numeric(10, 3) NOT NULL
);

-- 3. Habilitar RLS e criar políticas
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read-only access" ON public.embalagens FOR SELECT USING (true);
CREATE POLICY "Allow authenticated users to insert" ON public.embalagens FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Allow authenticated users to update" ON public.embalagens FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Allow authenticated users to delete" ON public.embalagens FOR DELETE TO authenticated USING (true);

-- 4. Inserir dados (seeding)
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
('Envelope Cartonado Grande', 'ENVELOPE', 40.0, NULL, 28.0, NULL, 0.190);

COMMIT;
