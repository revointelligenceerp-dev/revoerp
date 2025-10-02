/*
  # [Seed Embalagens]
  Este script insere registros de exemplo na tabela `embalagens`, verificando antes se já existem para evitar duplicatas.

  ## Query Description: [Insere um conjunto de embalagens padrão (caixas, envelopes, cilindros) na tabela `public.embalagens`. A operação é segura e não sobrescreve dados existentes com a mesma descrição.]
  
  ## Metadata:
  - Schema-Category: ["Data"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
  
  ## Structure Details:
  - Tabela afetada: `public.embalagens`
  
  ## Security Implications:
  - RLS Status: [Habilitado]
  - Policy Changes: [Não]
  - Auth Requirements: [autenticado]
  
  ## Performance Impact:
  - Indexes: [Nenhum]
  - Triggers: [Nenhum]
  - Estimated Impact: [Baixo]
*/

-- Inserir dados de exemplo na tabela de embalagens, evitando duplicatas
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.embalagens WHERE descricao = 'Caixa Pequena (20x15x10cm)') THEN
    INSERT INTO public.embalagens (descricao, tipo, largura_cm, altura_cm, comprimento_cm, peso_kg)
    VALUES ('Caixa Pequena (20x15x10cm)', 'CAIXA', 20.0, 10.0, 15.0, 0.150);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.embalagens WHERE descricao = 'Caixa Média (30x25x15cm)') THEN
    INSERT INTO public.embalagens (descricao, tipo, largura_cm, altura_cm, comprimento_cm, peso_kg)
    VALUES ('Caixa Média (30x25x15cm)', 'CAIXA', 30.0, 15.0, 25.0, 0.300);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.embalagens WHERE descricao = 'Caixa Grande (50x40x30cm)') THEN
    INSERT INTO public.embalagens (descricao, tipo, largura_cm, altura_cm, comprimento_cm, peso_kg)
    VALUES ('Caixa Grande (50x40x30cm)', 'CAIXA', 50.0, 30.0, 40.0, 0.750);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.embalagens WHERE descricao = 'Envelope Saco (25x35cm)') THEN
    INSERT INTO public.embalagens (descricao, tipo, largura_cm, comprimento_cm, peso_kg)
    VALUES ('Envelope Saco (25x35cm)', 'ENVELOPE', 25.0, 35.0, 0.050);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.embalagens WHERE descricao = 'Envelope A4 (21x30cm)') THEN
    INSERT INTO public.embalagens (descricao, tipo, largura_cm, comprimento_cm, peso_kg)
    VALUES ('Envelope A4 (21x30cm)', 'ENVELOPE', 21.0, 30.0, 0.030);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.embalagens WHERE descricao = 'Rolo Plástico Bolha (50cm)') THEN
    INSERT INTO public.embalagens (descricao, tipo, comprimento_cm, diametro_cm, peso_kg)
    VALUES ('Rolo Plástico Bolha (50cm)', 'CILINDRO', 100.0, 50.0, 1.200);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.embalagens WHERE descricao = 'Tubo de Papelão (10x80cm)') THEN
    INSERT INTO public.embalagens (descricao, tipo, comprimento_cm, diametro_cm, peso_kg)
    VALUES ('Tubo de Papelão (10x80cm)', 'CILINDRO', 80.0, 10.0, 0.400);
  END IF;
END $$;
