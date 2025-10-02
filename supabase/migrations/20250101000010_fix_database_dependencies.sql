-- Desativa temporariamente as dependências (views e triggers)
DROP VIEW IF EXISTS public.comissoes_calculadas;
DROP VIEW IF EXISTS public.dre_mensal;
DROP TRIGGER IF EXISTS on_conta_recebida ON public.contas_receber;
DROP TRIGGER IF EXISTS on_conta_paga ON public.contas_pagar;
DROP FUNCTION IF EXISTS public.handle_conta_recebida();
DROP FUNCTION IF EXISTS public.handle_conta_paga();

-- Garante que os tipos ENUM existam
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
        CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
        CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
    END IF;
END$$;

-- Altera as tabelas para usar os tipos ENUM, se necessário
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_attribute a
        JOIN pg_class c ON a.attrelid = c.oid JOIN pg_type t ON a.atttypid = t.oid
        WHERE c.relname = 'contas_receber' AND a.attname = 'status' AND t.typname = 'status_conta_receber'
    ) THEN
        ALTER TABLE public.contas_receber
        ALTER COLUMN status TYPE public.status_conta_receber
        USING status::text::public.status_conta_receber;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_attribute a
        JOIN pg_class c ON a.attrelid = c.oid JOIN pg_type t ON a.atttypid = t.oid
        WHERE c.relname = 'contas_pagar' AND a.attname = 'status' AND t.typname = 'status_conta_pagar'
    ) THEN
        ALTER TABLE public.contas_pagar
        ALTER COLUMN status TYPE public.status_conta_pagar
        USING status::text::public.status_conta_pagar;
    END IF;
END$$;

-- Garante que a coluna de comissão exista em vendedores
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema='public' AND table_name='vendedores' AND column_name='percentual_comissao') THEN
        ALTER TABLE public.vendedores ADD COLUMN percentual_comissao numeric(5,2) NOT NULL DEFAULT 5.0;
    END IF;
END$$;

-- Recria as funções de gatilho
CREATE OR REPLACE FUNCTION public.handle_conta_recebida()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.fluxo_caixa(data, descricao, valor, tipo, conta_receber_id)
    VALUES(NEW.data_pagamento, 'Recebimento: ' || COALESCE(NEW.descricao, 'Fatura ' || (SELECT f.numero_fatura FROM public.faturas_venda f WHERE f.id = NEW.fatura_id)), NEW.valor, 'ENTRADA', NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.handle_conta_paga()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.fluxo_caixa(data, descricao, valor, tipo, conta_pagar_id)
    VALUES(NEW.data_pagamento, 'Pagamento: ' || NEW.descricao, NEW.valor, 'SAIDA', NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recria os gatilhos
CREATE TRIGGER on_conta_recebida
AFTER UPDATE OF status ON public.contas_receber
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM 'RECEBIDO'::public.status_conta_receber AND NEW.status = 'RECEBIDO'::public.status_conta_receber AND NEW.data_pagamento IS NOT NULL)
EXECUTE FUNCTION public.handle_conta_recebida();

CREATE TRIGGER on_conta_paga
AFTER UPDATE OF status ON public.contas_pagar
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM 'PAGO'::public.status_conta_pagar AND NEW.status = 'PAGO'::public.status_conta_pagar AND NEW.data_pagamento IS NOT NULL)
EXECUTE FUNCTION public.handle_conta_paga();

-- Recria a VIEW DRE de forma segura
CREATE OR REPLACE VIEW public.dre_mensal
WITH (security_invoker = true)
AS
SELECT
  EXTRACT(YEAR FROM f.data) AS ano,
  EXTRACT(MONTH FROM f.data) AS mes,
  TO_CHAR(f.data, 'TMMonth') AS mes_nome,
  SUM(CASE WHEN f.tipo = 'ENTRADA' THEN f.valor ELSE 0 END) AS receita,
  SUM(CASE WHEN f.tipo = 'SAIDA' THEN f.valor ELSE 0 END) AS despesa,
  SUM(CASE WHEN f.tipo = 'ENTRADA' THEN f.valor ELSE -f.valor END) AS resultado
FROM public.fluxo_caixa f
GROUP BY 1, 2, 3
ORDER BY 1, 2;

-- Recria a VIEW de Comissões de forma segura
CREATE OR REPLACE VIEW public.comissoes_calculadas
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
WHERE cr.status = 'RECEBIDO'::public.status_conta_receber;
