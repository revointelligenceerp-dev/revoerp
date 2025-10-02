/*
  ## Criação da Tabela de Faturas de Venda

  Este script cria a tabela `faturas_venda` para armazenar as informações das faturas geradas a partir dos pedidos de venda.
  - Adiciona um novo tipo `status_fatura` para controlar o ciclo de vida da fatura.
  - Cria a tabela `faturas_venda` com relacionamento para `pedidos_venda`.
  - Habilita a segurança em nível de linha (RLS) e define políticas permissivas para desenvolvimento.
*/

-- 1. Criar o tipo ENUM para o status da fatura, se não existir
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_fatura') THEN
    CREATE TYPE public.status_fatura AS ENUM (
      'EMITIDA',
      'PAGA',
      'VENCIDA',
      'CANCELADA'
    );
  END IF;
END$$;

-- 2. Criar a tabela de faturas de venda, se não existir
CREATE TABLE IF NOT EXISTS public.faturas_venda (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  pedido_id uuid NOT NULL,
  numero_fatura text NOT NULL,
  data_emissao date NOT NULL,
  data_vencimento date NOT NULL,
  valor_total numeric(10, 2) NOT NULL,
  status public.status_fatura NOT NULL DEFAULT 'EMITIDA'::public.status_fatura,
  CONSTRAINT faturas_venda_pkey PRIMARY KEY (id),
  CONSTRAINT faturas_venda_numero_fatura_key UNIQUE (numero_fatura),
  CONSTRAINT faturas_venda_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos_venda(id)
);

-- 3. Habilitar a Segurança em Nível de Linha (RLS)
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas de RLS permissivas para desenvolvimento
-- Permite todas as operações para usuários anônimos e autenticados.
-- ATENÇÃO: Em produção, estas regras devem ser substituídas por políticas restritivas.
DROP POLICY IF EXISTS "Permite acesso total para desenvolvimento (anon)" ON public.faturas_venda;
CREATE POLICY "Permite acesso total para desenvolvimento (anon)"
  ON public.faturas_venda
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Permite acesso total para desenvolvimento (authenticated)" ON public.faturas_venda;
CREATE POLICY "Permite acesso total para desenvolvimento (authenticated)"
  ON public.faturas_venda
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Adicionar comentário na tabela
COMMENT ON TABLE public.faturas_venda IS 'Armazena as faturas geradas a partir dos pedidos de venda.';
