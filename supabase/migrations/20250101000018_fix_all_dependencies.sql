-- Master Migration Script to fix all dependencies and inconsistencies

-- Step 1: Drop all dependent objects (views, triggers, functions)
-- We drop them in the correct order to avoid dependency errors.

DROP VIEW IF EXISTS public.comissoes_calculadas;
DROP VIEW IF EXISTS public.dre_mensal;

-- Drop triggers first, as they depend on functions
DROP TRIGGER IF EXISTS on_conta_recebida ON public.contas_receber;
DROP TRIGGER IF EXISTS on_conta_paga ON public.contas_pagar;
DROP TRIGGER IF EXISTS on_conta_recebida_create_fluxo_caixa ON public.contas_receber;
DROP TRIGGER IF EXISTS on_conta_paga_create_fluxo_caixa ON public.contas_pagar;

-- Drop functions now that triggers are gone
DROP FUNCTION IF EXISTS public.handle_conta_recebida();
DROP FUNCTION IF EXISTS public.handle_conta_paga();
DROP FUNCTION IF EXISTS public.handle_conta_recebida_create_fluxo_caixa();
DROP FUNCTION IF EXISTS public.handle_conta_paga_create_fluxo_caixa();


-- Step 2: Create custom ENUM types if they don't exist.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
    CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
    CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
  END IF;
END
$$;

-- Step 3: Alter table columns to use the new ENUM types.
DO $$
BEGIN
  -- Check if the column is not already the correct type before altering
  IF (SELECT data_type FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'status') <> 'status_conta_receber' THEN
    ALTER TABLE public.contas_receber
    ALTER COLUMN status TYPE public.status_conta_receber
    USING status::text::public.status_conta_receber;
  END IF;
  
  IF (SELECT data_type FROM information_schema.columns WHERE table_name = 'contas_pagar' AND column_name = 'status') <> 'status_conta_pagar' THEN
    ALTER TABLE public.contas_pagar
    ALTER COLUMN status TYPE public.status_conta_pagar
    USING status::text::public.status_conta_pagar;
  END IF;
END
$$;

-- Step 4: Ensure the 'percentual_comissao' column exists in 'vendedores'
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'percentual_comissao' AND NOT attisdropped) THEN
    ALTER TABLE public.vendedores ADD COLUMN percentual_comissao numeric(5, 2) NOT NULL DEFAULT 5.0;
  END IF;
END
$$;

-- Step 5: Recreate the functions for the triggers (Caixa automation)
CREATE OR REPLACE FUNCTION public.handle_conta_recebida_create_fluxo_caixa()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_receber_id)
  VALUES (
    NEW.data_pagamento,
    'Recebimento: ' || COALESCE(NEW.descricao, (SELECT 'Fatura ' || f.numero_fatura FROM public.faturas_venda f WHERE f.id = NEW.fatura_id), 'Recebimento avulso'),
    NEW.valor,
    'ENTRADA',
    NEW.id
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.handle_conta_paga_create_fluxo_caixa()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_pagar_id)
  VALUES (
    NEW.data_pagamento,
    'Pagamento: ' || NEW.descricao,
    NEW.valor,
    'SAIDA',
    NEW.id
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 6: Recreate the triggers with the corrected types
CREATE TRIGGER on_conta_recebida_create_fluxo_caixa
AFTER UPDATE ON public.contas_receber
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'RECEBIDO')
EXECUTE FUNCTION public.handle_conta_recebida_create_fluxo_caixa();

CREATE TRIGGER on_conta_paga_create_fluxo_caixa
AFTER UPDATE ON public.contas_pagar
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status AND NEW.status = 'PAGO')
EXECUTE FUNCTION public.handle_conta_paga_create_fluxo_caixa();

-- Step 7: Recreate the views (reports) correctly and securely
CREATE OR REPLACE VIEW public.dre_mensal
WITH (security_invoker = true) AS
SELECT
  EXTRACT(YEAR FROM data) AS ano,
  EXTRACT(MONTH FROM data) AS mes,
  TO_CHAR(data, 'TMMonth') AS mes_nome,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE 0 END) AS receita,
  SUM(CASE WHEN tipo = 'SAIDA' THEN valor ELSE 0 END) AS despesa,
  SUM(CASE WHEN tipo = 'ENTRADA' THEN valor ELSE -valor END) AS resultado
FROM public.fluxo_caixa
GROUP BY ano, mes, mes_nome;

CREATE OR REPLACE VIEW public.comissoes_calculadas
WITH (security_invoker = true) AS
SELECT
  cr.id,
  pv.vendedor_id AS "vendedorId",
  v.nome AS "vendedorNome",
  pv.id AS "pedidoId",
  pv.numero AS "pedidoNumero",
  pv.valor_total AS "valorPedido",
  v.percentual_comissao AS "percentualComissao",
  (pv.valor_total * v.percentual_comissao / 100) AS "valorComissao",
  cr.data_pagamento AS "dataPagamentoFatura"
FROM public.contas_receber cr
JOIN public.faturas_venda fv ON cr.fatura_id = fv.id
JOIN public.pedidos_venda pv ON fv.pedido_id = pv.id
JOIN public.vendedores v ON pv.vendedor_id = v.id
WHERE cr.status = 'RECEBIDO';
