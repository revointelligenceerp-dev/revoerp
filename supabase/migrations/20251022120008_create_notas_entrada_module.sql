/*
  # [Módulo de Notas de Entrada]
  Cria a estrutura de tabelas, políticas de segurança e dados iniciais para o módulo de Notas de Entrada.

  ## Query Description: [Este script é seguro para ser executado. Ele cria novas tabelas e insere dados de exemplo sem afetar as estruturas existentes. Verifica a existência de tipos e tabelas antes de criá-los para evitar erros em reexecuções.]
  
  ## Metadata:
  - Schema-Category: ["Structural", "Data"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
  
  ## Structure Details:
  - Cria o tipo ENUM `status_nota_entrada`.
  - Cria a tabela `notas_entrada` para armazenar os cabeçalhos das notas.
  - Cria a tabela `nota_entrada_itens` para os itens de cada nota.
  - Adiciona políticas de RLS para ambas as tabelas.
  - Insere 5 notas de entrada de exemplo com itens aleatórios.
  
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [Yes]
  - Auth Requirements: [authenticated users for write, anon for read]
  
  ## Performance Impact:
  - Indexes: [Added on primary and foreign keys]
  - Triggers: [None]
  - Estimated Impact: [Baixo. Apenas cria novas tabelas e insere poucos dados.]
*/

-- 1. Criação do ENUM para o status da nota
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_nota_entrada') THEN
    CREATE TYPE public.status_nota_entrada AS ENUM (
      'PENDENTE',
      'PROCESSADA',
      'CANCELADA'
    );
  END IF;
END$$;

-- 2. Tabela de Notas de Entrada
CREATE TABLE IF NOT EXISTS public.notas_entrada (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  numero TEXT NOT NULL,
  fornecedor_id UUID REFERENCES public.clientes(id) ON DELETE SET NULL,
  data_emissao DATE NOT NULL,
  data_entrada DATE NOT NULL DEFAULT CURRENT_DATE,
  valor_total NUMERIC(15, 2) NOT NULL,
  chave_acesso TEXT UNIQUE,
  status public.status_nota_entrada NOT NULL DEFAULT 'PENDENTE',
  observacoes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Tabela de Itens da Nota de Entrada
CREATE TABLE IF NOT EXISTS public.nota_entrada_itens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nota_entrada_id UUID NOT NULL REFERENCES public.notas_entrada(id) ON DELETE CASCADE,
  produto_id UUID REFERENCES public.produtos(id) ON DELETE SET NULL,
  descricao TEXT NOT NULL,
  quantidade NUMERIC(15, 4) NOT NULL,
  valor_unitario NUMERIC(15, 4) NOT NULL,
  valor_total NUMERIC(15, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. Habilitar RLS
ALTER TABLE public.notas_entrada ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nota_entrada_itens ENABLE ROW LEVEL SECURITY;

-- 5. Políticas de RLS
DROP POLICY IF EXISTS "Allow all access to authenticated users" ON public.notas_entrada;
CREATE POLICY "Allow all access to authenticated users" ON public.notas_entrada
  FOR ALL
  TO authenticated
  USING (TRUE)
  WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Allow read access to anon users" ON public.notas_entrada;
CREATE POLICY "Allow read access to anon users" ON public.notas_entrada
  FOR SELECT
  TO anon
  USING (TRUE);

DROP POLICY IF EXISTS "Allow all access to authenticated users" ON public.nota_entrada_itens;
CREATE POLICY "Allow all access to authenticated users" ON public.nota_entrada_itens
  FOR ALL
  TO authenticated
  USING (TRUE)
  WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Allow read access to anon users" ON public.nota_entrada_itens;
CREATE POLICY "Allow read access to anon users" ON public.nota_entrada_itens
  FOR SELECT
  TO anon
  USING (TRUE);

-- 6. Função para popular dados (seeding)
CREATE OR REPLACE FUNCTION public.seed_notas_entrada()
RETURNS void AS $$
DECLARE
  fornecedor_ids UUID[];
  produto_ids UUID[];
  nota_id UUID;
  i INT;
  j INT;
  random_fornecedor_id UUID;
  random_produto_id UUID;
  random_produto_nome TEXT;
  random_produto_preco NUMERIC;
  qtd NUMERIC;
  valor_item NUMERIC;
  valor_total_nota NUMERIC;
BEGIN
  -- Limpa dados antigos para evitar duplicatas se a função for chamada novamente
  DELETE FROM public.nota_entrada_itens;
  DELETE FROM public.notas_entrada;

  -- Pega IDs de fornecedores e produtos existentes
  SELECT array_agg(id) INTO fornecedor_ids FROM public.clientes WHERE is_fornecedor = TRUE;
  SELECT array_agg(id) INTO produto_ids FROM public.produtos WHERE situacao = 'Ativo';

  -- Verifica se temos dados suficientes para popular
  IF array_length(fornecedor_ids, 1) IS NULL OR array_length(produto_ids, 1) IS NULL THEN
    RAISE NOTICE 'Não há fornecedores ou produtos suficientes para popular as notas de entrada.';
    RETURN;
  END IF;

  -- Cria 5 notas de entrada
  FOR i IN 1..5 LOOP
    -- Seleciona um fornecedor aleatório
    random_fornecedor_id := fornecedor_ids[1 + floor(random() * array_length(fornecedor_ids, 1))];
    valor_total_nota := 0;

    -- Insere a nota de entrada
    INSERT INTO public.notas_entrada (numero, fornecedor_id, data_emissao, valor_total, status)
    VALUES (
      'NE' || (1000 + i)::TEXT,
      random_fornecedor_id,
      CURRENT_DATE - (floor(random() * 30) || ' days')::interval,
      0, -- Valor temporário
      (ARRAY['PENDENTE', 'PROCESSADA', 'CANCELADA'])[1 + floor(random() * 3)]::status_nota_entrada
    ) RETURNING id INTO nota_id;

    -- Adiciona de 2 a 5 itens por nota
    FOR j IN 1..(2 + floor(random() * 4)) LOOP
      -- Seleciona um produto aleatório
      random_produto_id := produto_ids[1 + floor(random() * array_length(produto_ids, 1))];
      
      -- Pega detalhes do produto
      SELECT nome, preco_venda INTO random_produto_nome, random_produto_preco FROM public.produtos WHERE id = random_produto_id;
      
      qtd := 1 + floor(random() * 10);
      valor_item := qtd * (random_produto_preco * (0.5 + random() * 0.4)); -- Custo entre 50% e 90% do preço de venda

      INSERT INTO public.nota_entrada_itens (nota_entrada_id, produto_id, descricao, quantidade, valor_unitario, valor_total)
      VALUES (
        nota_id,
        random_produto_id,
        random_produto_nome,
        qtd,
        valor_item / qtd,
        valor_item
      );
      
      valor_total_nota := valor_total_nota + valor_item;
    END LOOP;

    -- Atualiza o valor total da nota
    UPDATE public.notas_entrada SET valor_total = valor_total_nota WHERE id = nota_id;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 7. Executa a função de seeding
SELECT public.seed_notas_entrada();
