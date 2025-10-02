-- Comprehensive migration to fix dependency issues and align the database schema.

DO $$
BEGIN

-- 1. Drop dependent objects (triggers and functions) in the correct order.
-- The trigger depends on the function, so we drop the trigger first.
DROP TRIGGER IF EXISTS on_conta_recebida_create_fluxo_caixa ON public.contas_receber;
DROP TRIGGER IF EXISTS on_conta_paga_create_fluxo_caixa ON public.contas_pagar;

-- Now, drop the functions.
DROP FUNCTION IF EXISTS public.handle_conta_recebida_create_fluxo_caixa();
DROP FUNCTION IF EXISTS public.handle_conta_paga_create_fluxo_caixa();

-- 2. Create ENUM types if they do not exist.
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
    CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
END IF;

IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
    CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
END IF;

-- 3. Alter column types using the correct casting method.
-- This was the source of the "cannot alter type" error.
ALTER TABLE public.contas_receber
    ALTER COLUMN status TYPE public.status_conta_receber
    USING status::text::public.status_conta_receber;

ALTER TABLE public.contas_pagar
    ALTER COLUMN status TYPE public.status_conta_pagar
    USING status::text::public.status_conta_pagar;

-- 4. Recreate the functions for Caixa automation with the correct ENUM types.
CREATE OR REPLACE FUNCTION public.handle_conta_recebida_create_fluxo_caixa()
RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.status = 'RECEBIDO' AND OLD.status <> 'RECEBIDO' THEN
        INSERT INTO public.fluxo_caixa(data, descricao, valor, tipo, conta_receber_id)
        VALUES(
            COALESCE(NEW.data_pagamento, NOW()),
            'Recebimento: ' || COALESCE(NEW.descricao, 'Fatura ' || (SELECT numero_fatura FROM faturas_venda WHERE id = NEW.fatura_id), 'Recebimento Avulso'),
            NEW.valor,
            'ENTRADA',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_conta_paga_create_fluxo_caixa()
RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.status = 'PAGO' AND OLD.status <> 'PAGO' THEN
        INSERT INTO public.fluxo_caixa(data, descricao, valor, tipo, conta_pagar_id)
        VALUES(
            COALESCE(NEW.data_pagamento, NOW()),
            'Pagamento: ' || NEW.descricao,
            NEW.valor,
            'SAIDA',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Recreate the triggers.
CREATE TRIGGER on_conta_recebida_create_fluxo_caixa
AFTER UPDATE ON public.contas_receber
FOR EACH ROW
EXECUTE FUNCTION public.handle_conta_recebida_create_fluxo_caixa();

CREATE TRIGGER on_conta_paga_create_fluxo_caixa
AFTER UPDATE ON public.contas_pagar
FOR EACH ROW
EXECUTE FUNCTION public.handle_conta_paga_create_fluxo_caixa();

-- 6. Ensure the commission column exists on the vendors table.
IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendedores' AND column_name='percentual_comissao') THEN
    ALTER TABLE public.vendedores ADD COLUMN percentual_comissao numeric(5,2) NOT NULL DEFAULT 5.0;
END IF;

-- 7. Recreate the report VIEWS securely and correctly.
-- DRE Mensal View
DROP VIEW IF EXISTS public.dre_mensal;
CREATE VIEW public.dre_mensal
WITH (security_invoker = true)
AS
SELECT
  EXTRACT(YEAR FROM fc.data)::integer AS ano,
  EXTRACT(MONTH FROM fc.data)::integer AS mes,
  TO_CHAR(fc.data, 'TMMonth') AS mes_nome,
  SUM(CASE WHEN fc.tipo = 'ENTRADA' THEN fc.valor ELSE 0 END) AS receita,
  SUM(CASE WHEN fc.tipo = 'SAIDA' THEN fc.valor ELSE 0 END) AS despesa,
  SUM(CASE WHEN fc.tipo = 'ENTRADA' THEN fc.valor ELSE -fc.valor END) AS resultado
FROM public.fluxo_caixa fc
GROUP BY ano, mes, mes_nome
ORDER BY ano, mes;

-- Comissões Calculadas View
DROP VIEW IF EXISTS public.comissoes_calculadas;
CREATE VIEW public.comissoes_calculadas
WITH (security_invoker = true)
AS
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

END $$;
