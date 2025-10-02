/*
  # [SEED] Embalagens
  [Populates the 'embalagens' table with a predefined list of packaging options.]

  ## Query Description: [This script inserts a standard set of packaging options into the database. It uses an 'ON CONFLICT' clause to prevent duplicating entries if the script is run multiple times, ensuring idempotency. No existing data will be overwritten or deleted.]
  
  ## Metadata:
  - Schema-Category: ["Data"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
  
  ## Structure Details:
  - Table: public.embalagens
  
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [No]
  - Auth Requirements: [service_role]
  
  ## Performance Impact:
  - Indexes: [No change]
  - Triggers: [No change]
  - Estimated Impact: [Low, one-time data insertion.]
*/
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
