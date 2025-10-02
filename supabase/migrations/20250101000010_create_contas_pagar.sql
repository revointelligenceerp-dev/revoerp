/*
  ## Criação da Estrutura de Contas a Pagar

  Este script cria a tabela `contas_pagar` e os tipos de dados necessários para gerenciar as despesas da empresa.
  Ele também insere 5 registros de exemplo para popular a interface.

  **Estrutura:**
  - `contas_pagar`: Tabela principal para armazenar as contas a pagar.
  - `status_conta_pagar`: Tipo ENUM para os status ('A_PAGAR', 'PAGO', 'VENCIDO').

  **Segurança:**
  - Habilita RLS na tabela e cria políticas abertas para permitir todas as operações (SELECT, INSERT, UPDATE, DELETE) por qualquer usuário (anon, authenticated).
*/

-- 1. Criar o tipo de status para contas a pagar (se não existir)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
    CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
  END IF;
END$$;

-- 2. Criar a tabela de contas a pagar
CREATE TABLE IF NOT EXISTS public.contas_pagar (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  descricao text NOT NULL,
  valor numeric(10,2) NOT NULL,
  data_vencimento date NOT NULL,
  data_pagamento date NULL,
  status public.status_conta_pagar NOT NULL DEFAULT 'A_PAGAR'::status_conta_pagar,
  fornecedor_id uuid NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT contas_pagar_pkey PRIMARY KEY (id),
  CONSTRAINT contas_pagar_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.clientes(id) ON DELETE SET NULL
);

-- 3. Habilitar Row Level Security (RLS)
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas de acesso (abertas para desenvolvimento)
DROP POLICY IF EXISTS "Permitir acesso total a contas_pagar" ON public.contas_pagar;
CREATE POLICY "Permitir acesso total a contas_pagar"
ON public.contas_pagar
FOR ALL
USING (true)
WITH CHECK (true);

-- 5. Inserir 5 registros de exemplo
DO $$
DECLARE
  fornecedor_ids uuid[];
BEGIN
  -- Seleciona até 5 IDs de clientes que são fornecedores
  SELECT ARRAY(
    SELECT id FROM public.clientes 
    WHERE tipo = 'FORNECEDOR' OR tipo = 'AMBOS'
    LIMIT 5
  ) INTO fornecedor_ids;

  -- Se não houver fornecedores, insere sem vínculo
  IF array_length(fornecedor_ids, 1) IS NULL OR array_length(fornecedor_ids, 1) = 0 THEN
    INSERT INTO public.contas_pagar (descricao, valor, data_vencimento, status)
    VALUES
      ('Compra de material de escritório', 150.75, CURRENT_DATE + interval '10 days', 'A_PAGAR'),
      ('Manutenção do ar condicionado', 350.00, CURRENT_DATE + interval '15 days', 'A_PAGAR'),
      ('Serviços de contabilidade', 800.50, CURRENT_DATE - interval '5 days', 'VENCIDO'),
      ('Assinatura de software', 99.90, CURRENT_DATE + interval '20 days', 'A_PAGAR'),
      ('Pagamento de internet', 250.00, CURRENT_DATE, 'A_PAGAR');
  ELSE
    -- Insere contas vinculadas aos fornecedores encontrados
    INSERT INTO public.contas_pagar (descricao, valor, data_vencimento, status, fornecedor_id)
    VALUES
      ('Compra de matéria-prima', 1250.50, CURRENT_DATE + interval '12 days', 'A_PAGAR', fornecedor_ids[1]),
      ('Serviços de marketing digital', 2500.00, CURRENT_DATE + interval '25 days', 'A_PAGAR', fornecedor_ids[2]),
      ('Aluguel do escritório', 4500.00, CURRENT_DATE - interval '2 days', 'VENCIDO', fornecedor_ids[3]),
      ('Conta de energia elétrica', 450.80, CURRENT_DATE + interval '5 days', 'A_PAGAR', fornecedor_ids[4]),
      ('Pagamento de frete', 320.00, CURRENT_DATE + interval '18 days', 'A_PAGAR', fornecedor_ids[5]);
  END IF;
END $$;
