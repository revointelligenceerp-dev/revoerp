/*
  # [Seed Embalagens]
  Este script popula a tabela `embalagens` com uma variedade de registros de exemplo para facilitar testes e demonstrações.
  Inclui caixas, envelopes e cilindros de diferentes tamanhos.

  ## Query Description: [Insere 15 registros de embalagens fictícias na tabela `public.embalagens`. Utiliza `ON CONFLICT (descricao) DO NOTHING` para evitar duplicatas e garantir que o script possa ser executado várias vezes sem erros.]
  
  ## Metadata:
  - Schema-Category: ["Data"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [true]
  
  ## Structure Details:
  - Tabela afetada: `public.embalagens`
  
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [No]
  - Auth Requirements: [authenticated]
  
  ## Performance Impact:
  - Indexes: [N/A]
  - Triggers: [N/A]
  - Estimated Impact: [Baixo. Inserção de poucos registros.]
*/

INSERT INTO public.embalagens (descricao, tipo, largura_cm, altura_cm, comprimento_cm, peso_kg) VALUES
('Caixa Mini (16x11x6 cm)', 'CAIXA', 16, 6, 11, 0.100),
('Caixa Pequena (20x14x8 cm)', 'CAIXA', 20, 8, 14, 0.150),
('Caixa Padrão (30x20x12 cm)', 'CAIXA', 30, 12, 20, 0.250),
('Caixa Média (35x25x15 cm)', 'CAIXA', 35, 15, 25, 0.400),
('Caixa Grande (40x30x20 cm)', 'CAIXA', 40, 20, 30, 0.600),
('Caixa Extra Grande (50x40x30 cm)', 'CAIXA', 50, 30, 40, 1.100),
('Caixa para Calçados (34x20x12 cm)', 'CAIXA', 34, 12, 20, 0.350),
('Caixa para Notebook (45x35x10 cm)', 'CAIXA', 45, 10, 35, 0.800)
ON CONFLICT (descricao) DO NOTHING;

INSERT INTO public.embalagens (descricao, tipo, largura_cm, comprimento_cm, peso_kg) VALUES
('Envelope Plástico (20x30 cm)', 'ENVELOPE', 20, 30, 0.020),
('Envelope de Segurança (32x40 cm)', 'ENVELOPE', 32, 40, 0.050),
('Envelope A4 (24x34 cm)', 'ENVELOPE', 24, 34, 0.030)
ON CONFLICT (descricao) DO NOTHING;

INSERT INTO public.embalagens (descricao, tipo, comprimento_cm, diametro_cm, peso_kg) VALUES
('Tubo para Pôster (45x7 cm)', 'CILINDRO', 45, 7, 0.200),
('Tubo para Mapas (90x10 cm)', 'CILINDRO', 90, 10, 0.450),
('Cilindro para Tecidos (150x15 cm)', 'CILINDRO', 150, 15, 1.500),
('Rolo Pequeno (30x5 cm)', 'CILINDRO', 30, 5, 0.120)
ON CONFLICT (descricao) DO NOTHING;
