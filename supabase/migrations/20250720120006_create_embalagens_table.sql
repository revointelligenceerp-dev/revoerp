/*
          # Criação da Tabela de Embalagens e Inserção de Dados

          ## Query Description: 
          Este script cria a tabela 'embalagens' para armazenar informações sobre as embalagens utilizadas.
          Ele também insere 5 registros de exemplo para popular a tabela inicialmente.
          A operação é segura e não afeta dados existentes em outras tabelas.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (a tabela pode ser removida)

          ## Structure Details:
          - Tabela 'embalagens' criada com colunas: id, created_at, updated_at, nome, descricao, custo, estoque, ativo.
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (cria políticas para permitir acesso geral por enquanto)
          - Auth Requirements: None
          
          ## Performance Impact:
          - Indexes: Primary key index on 'id'.
          - Triggers: None
          - Estimated Impact: Baixo.
          */

-- 1. Criação da tabela de embalagens
CREATE TABLE IF NOT EXISTS public.embalagens (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    nome text NOT NULL,
    descricao text,
    custo numeric(10, 2) DEFAULT 0.00,
    estoque integer DEFAULT 0,
    ativo boolean DEFAULT true,
    CONSTRAINT embalagens_pkey PRIMARY KEY (id)
);

-- 2. Habilita Row Level Security
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;

-- 3. Cria políticas de acesso (temporariamente abertas para desenvolvimento)
DROP POLICY IF EXISTS "Allow all for anon" ON public.embalagens;
CREATE POLICY "Allow all for anon" ON public.embalagens FOR ALL TO anon USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all for authenticated" ON public.embalagens;
CREATE POLICY "Allow all for authenticated" ON public.embalagens FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 4. Insere dados de exemplo se a tabela estiver vazia
DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM public.embalagens) THEN
      INSERT INTO public.embalagens (nome, descricao, custo, estoque) VALUES
      ('Caixa de Papelão Pequena', 'Caixa para pequenos produtos, 20x20x10cm', 1.50, 500),
      ('Caixa de Papelão Média', 'Caixa para produtos médios, 40x30x20cm', 2.75, 300),
      ('Envelope Bolha', 'Envelope para envio de itens frágeis', 0.80, 1000),
      ('Saco Plástico Transparente', 'Saco para embalagem interna de produtos', 0.25, 2500),
      ('Fita Adesiva Larga', 'Rolo de fita adesiva para fechamento de caixas', 5.50, 100);
   END IF;
END $$;
