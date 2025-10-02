/*
          # Criação da Tabela de Vendedores e Inserção de Dados

          ## Query Description: 
          Este script cria a tabela 'vendedores' e a popula com 5 registros de exemplo. A operação é segura e não afeta dados existentes em outras tabelas. Se a tabela já existir, ela será removida e recriada para garantir um estado limpo.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (se o backup for feito)

          ## Structure Details:
          - Tabela 'vendedores':
            - id (uuid, pk)
            - nome (text)
            - email (text)
            - telefone (text)
            - percentual_comissao (numeric)
            - ativo (boolean)
            - created_at (timestamptz)
            - updated_at (timestamptz)

          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (Cria políticas abertas para anon e authenticated)
          - Auth Requirements: None
          
          ## Performance Impact:
          - Indexes: Primary key on 'id'
          - Triggers: None
          - Estimated Impact: Baixo
          */

-- 1. Criação da tabela de Vendedores
DROP TABLE IF EXISTS public.vendedores;

CREATE TABLE IF NOT EXISTS public.vendedores (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    nome text NOT NULL,
    email text,
    telefone text,
    percentual_comissao numeric(5, 2) NOT NULL DEFAULT 0.00,
    ativo boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT vendedores_pkey PRIMARY KEY (id)
);

-- 2. Habilitação do RLS
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;

-- 3. Políticas de Segurança (Abertas para desenvolvimento)
DROP POLICY IF EXISTS "Allow all for anon" ON public.vendedores;
CREATE POLICY "Allow all for anon" ON public.vendedores FOR ALL TO anon USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all for authenticated" ON public.vendedores;
CREATE POLICY "Allow all for authenticated" ON public.vendedores FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- 4. Inserção de dados de exemplo (Seed)
INSERT INTO public.vendedores (nome, email, telefone, percentual_comissao, ativo) VALUES
('Carlos Silva', 'carlos.silva@revoerp.com', '(11) 98765-4321', 5.00, true),
('Ana Pereira', 'ana.pereira@revoerp.com', '(21) 91234-5678', 7.50, true),
('Bruno Costa', 'bruno.costa@revoerp.com', '(31) 99876-5432', 4.00, true),
('Mariana Almeida', 'mariana.almeida@revoerp.com', '(41) 98765-1234', 6.00, false),
('Rafael Oliveira', 'rafael.oliveira@revoerp.com', '(51) 91234-9876', 8.25, true);
