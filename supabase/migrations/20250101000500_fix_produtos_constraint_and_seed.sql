/*
# [Fix] Corrige a restrição de unicidade na tabela de produtos
Este script corrige o erro "there is no unique or exclusion constraint matching the ON CONFLICT specification" que ocorreu durante a criação da tabela de produtos. A correção envolve adicionar uma restrição `UNIQUE` na coluna `codigo_barras` e garantir que a inserção de dados de exemplo (seeding) use essa restrição corretamente.

## Query Description:
- **Criação da Tabela `produtos`:** Garante que a tabela `produtos` exista com a estrutura correta.
- **Adição de Restrição `UNIQUE`:** Adiciona uma restrição de unicidade na coluna `codigo_barras`. Isso é crucial para a integridade dos dados e para o funcionamento da cláusula `ON CONFLICT`.
- **Ativação de RLS e Políticas:** Configura a segurança em nível de linha (RLS) para a tabela, permitindo todas as operações por enquanto.
- **Inserção de Dados (Seeding):** Insere 5 produtos de exemplo, usando `ON CONFLICT (codigo_barras) DO NOTHING` para evitar duplicatas e garantir que o script possa ser executado várias vezes sem erros.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (a restrição pode ser removida)
*/

-- 1. Cria a tabela `produtos` se ela não existir.
CREATE TABLE IF NOT EXISTS public.produtos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  descricao text,
  categoria text,
  preco numeric(10, 2) NOT NULL DEFAULT 0,
  estoque integer NOT NULL DEFAULT 0,
  codigo_barras text,
  ativo boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- 2. Adiciona a restrição UNIQUE na coluna `codigo_barras` se não existir.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM   pg_constraint
    WHERE  conrelid = 'public.produtos'::regclass
    AND    conname = 'produtos_codigo_barras_key'
  ) THEN
    ALTER TABLE public.produtos ADD CONSTRAINT produtos_codigo_barras_key UNIQUE (codigo_barras);
  END IF;
END;
$$;


-- 3. Habilita a Segurança em Nível de Linha (RLS) se não estiver habilitada.
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;

-- 4. Remove políticas antigas para garantir um estado limpo.
DROP POLICY IF EXISTS "Permite acesso total a produtos" ON public.produtos;

-- 5. Cria uma política permissiva para permitir todas as operações por enquanto.
CREATE POLICY "Permite acesso total a produtos"
ON public.produtos
FOR ALL
USING (true)
WITH CHECK (true);

-- 6. Insere 5 produtos de exemplo, evitando duplicatas pelo código de barras.
INSERT INTO public.produtos (nome, descricao, categoria, preco, estoque, codigo_barras, ativo)
VALUES
  ('Smartphone Revo X1', 'O mais novo smartphone com tecnologia de ponta.', 'Eletrônicos', 2999.90, 50, '7890123456789', true),
  ('Notebook ProMax 15"', 'Notebook de alta performance para profissionais.', 'Informática', 7499.00, 25, '7890123456790', true),
  ('Fone de Ouvido BassBoost', 'Fones com cancelamento de ruído e som imersivo.', 'Acessórios', 499.50, 120, '7890123456791', true),
  ('Cadeira Gamer ErgoPro', 'Conforto e ergonomia para longas sessões de jogos.', 'Móveis', 1899.99, 40, '7890123456792', true),
  ('Teclado Mecânico RGB', 'Teclado com switches customizáveis e iluminação RGB.', 'Periféricos', 899.00, 75, '7890123456793', true)
ON CONFLICT (codigo_barras) DO NOTHING;
