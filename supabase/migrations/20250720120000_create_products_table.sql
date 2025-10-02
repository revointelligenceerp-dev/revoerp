/*
          # Criação da Tabela de Produtos e Inserção de Dados
          Este script cria a tabela 'produtos' e a popula com 5 registros de exemplo.

          ## Query Description: 
          - Cria a tabela 'produtos' se ela não existir.
          - Habilita a segurança em nível de linha (RLS) para a tabela.
          - Define políticas de RLS permissivas para permitir todas as operações (SELECT, INSERT, UPDATE, DELETE) por qualquer usuário (anônimo ou autenticado). Isso é ideal para o estágio atual de desenvolvimento.
          - Insere 5 produtos de exemplo na tabela.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (pode ser revertido com um script DROP TABLE)
          
          ## Structure Details:
          - Tabela afetada: public.produtos
          - Colunas: id, nome, descricao, categoria, preco, estoque, codigo_barras, ativo, created_at, updated_at
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes (cria políticas permissivas)
          - Auth Requirements: Nenhuma (permite acesso anônimo)
          
          ## Performance Impact:
          - Indexes: Adiciona um índice de chave primária na coluna 'id'.
          - Triggers: Nenhum.
          - Estimated Impact: Mínimo.
          */

-- Cria a tabela 'produtos'
CREATE TABLE IF NOT EXISTS public.produtos (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nome text NOT NULL,
    descricao text,
    categoria text,
    preco numeric(10, 2) NOT NULL DEFAULT 0,
    estoque integer NOT NULL DEFAULT 0,
    codigo_barras text,
    ativo boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilita a segurança em nível de linha
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;

-- Remove políticas antigas se existirem, para evitar conflitos
DROP POLICY IF EXISTS "Allow all users to select products" ON public.produtos;
DROP POLICY IF EXISTS "Allow all users to insert products" ON public.produtos;
DROP POLICY IF EXISTS "Allow all users to update products" ON public.produtos;
DROP POLICY IF EXISTS "Allow all users to delete products" ON public.produtos;

-- Cria políticas permissivas para o desenvolvimento
CREATE POLICY "Allow all users to select products" ON public.produtos
    FOR SELECT USING (true);

CREATE POLICY "Allow all users to insert products" ON public.produtos
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all users to update products" ON public.produtos
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow all users to delete products" ON public.produtos
    FOR DELETE USING (true);

-- Insere 5 registros de exemplo (seeding)
INSERT INTO public.produtos (nome, descricao, categoria, preco, estoque, codigo_barras, ativo)
VALUES
    ('Laptop Pro X15', 'Laptop de alta performance com 16GB RAM e SSD de 512GB.', 'Eletrônicos', 7500.00, 25, '7890123456789', true),
    ('Mouse Óptico Sem Fio', 'Mouse ergonômico com conexão Bluetooth e bateria de longa duração.', 'Acessórios', 150.50, 150, '7890123456790', true),
    ('Teclado Mecânico Gamer', 'Teclado com switches Cherry MX Red, RGB e layout ABNT2.', 'Periféricos', 499.90, 75, '7890123456791', true),
    ('Monitor Ultrawide 34"', 'Monitor com resolução 4K, 144Hz e painel IPS.', 'Monitores', 3200.00, 40, '7890123456792', true),
    ('Cadeira Gamer Ergonômica', 'Cadeira com suporte lombar ajustável e material respirável.', 'Móveis', 1200.00, 60, '7890123456793', false)
ON CONFLICT (nome) DO NOTHING; -- Evita duplicatas se o script for executado novamente
