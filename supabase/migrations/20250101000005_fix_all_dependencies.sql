-- Desativa temporariamente os gatilhos para permitir a alteração das tabelas.
DROP TRIGGER IF EXISTS on_conta_recebida ON public.contas_receber;
DROP TRIGGER IF EXISTS on_conta_paga ON public.contas_pagar;
DROP TRIGGER IF EXISTS on_conta_recebida_create_fluxo_caixa ON public.contas_receber;
DROP TRIGGER IF EXISTS on_conta_paga_create_fluxo_caixa ON public.contas_pagar;

-- Remove as funções antigas que dependem dos tipos de dados que serão alterados.
DROP FUNCTION IF EXISTS public.handle_conta_recebida();
DROP FUNCTION IF EXISTS public.handle_conta_paga();
DROP FUNCTION IF EXISTS public.handle_conta_recebida_create_fluxo_caixa();
DROP FUNCTION IF EXISTS public.handle_conta_paga_create_fluxo_caixa();

-- Garante a criação dos tipos ENUM para os status das contas.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
        CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
        CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
    END IF;
END$$;

-- Altera as colunas de status para usar os novos tipos ENUM, com a conversão correta.
DO $$
BEGIN
    -- Verifica se a coluna 'status' em 'contas_receber' não é do tipo ENUM e a converte.
    IF (SELECT data_type FROM information_schema.columns WHERE table_name = 'contas_receber' AND column_name = 'status') != 'user-defined' THEN
        ALTER TABLE public.contas_receber
        ALTER COLUMN status TYPE public.status_conta_receber
        USING status::text::public.status_conta_receber;
    END IF;

    -- Verifica se a coluna 'status' em 'contas_pagar' não é do tipo ENUM e a converte.
    IF (SELECT data_type FROM information_schema.columns WHERE table_name = 'contas_pagar' AND column_name = 'status') != 'user-defined' THEN
        ALTER TABLE public.contas_pagar
        ALTER COLUMN status TYPE public.status_conta_pagar
        USING status::text::public.status_conta_pagar;
    END IF;
END$$;

-- Recria as funções para os gatilhos do Caixa, agora usando os tipos ENUM corretos.
CREATE OR REPLACE FUNCTION public.handle_conta_recebida_create_fluxo_caixa()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'RECEBIDO' AND OLD.status != 'RECEBIDO' THEN
        INSERT INTO public.fluxo_caixa(data, descricao, valor, tipo, conta_receber_id)
        VALUES(
            COALESCE(NEW.data_pagamento, NOW()),
            COALESCE(NEW.descricao, 'Recebimento de Fatura #' || (SELECT f.numero_fatura FROM public.faturas_venda f WHERE f.id = NEW.fatura_id)),
            NEW.valor,
            'ENTRADA',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.handle_conta_paga_create_fluxo_caixa()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'PAGO' AND OLD.status != 'PAGO' THEN
        INSERT INTO public.fluxo_caixa(data, descricao, valor, tipo, conta_pagar_id)
        VALUES(
            COALESCE(NEW.data_pagamento, NOW()),
            NEW.descricao,
            NEW.valor,
            'SAIDA',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recria os gatilhos do Caixa.
CREATE TRIGGER on_conta_recebida_create_fluxo_caixa
AFTER UPDATE ON public.contas_receber
FOR EACH ROW
EXECUTE FUNCTION public.handle_conta_recebida_create_fluxo_caixa();

CREATE TRIGGER on_conta_paga_create_fluxo_caixa
AFTER UPDATE ON public.contas_pagar
FOR EACH ROW
EXECUTE FUNCTION public.handle_conta_paga_create_fluxo_caixa();

-- Garante que a coluna de comissão exista na tabela de vendedores.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='vendedores' AND column_name='percentual_comissao') THEN
        ALTER TABLE public.vendedores ADD COLUMN percentual_comissao numeric(5,2) NOT NULL DEFAULT 5.0;
    END IF;
END$$;

-- Recria a VIEW de DRE de forma segura e com a conversão de tipo correta.
DROP VIEW IF EXISTS public.dre_mensal;
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
GROUP BY EXTRACT(YEAR FROM f.data), EXTRACT(MONTH FROM f.data), TO_CHAR(f.data, 'TMMonth');

-- Recria a VIEW de Comissões de forma segura e com a conversão de tipo correta.
DROP VIEW IF EXISTS public.comissoes_calculadas;
CREATE OR REPLACE VIEW public.comissoes_calculadas
WITH (security_invoker = true)
AS
SELECT
  cr.id,
  pv.vendedor_id AS "vendedorId",
  v.nome AS "vendedorNome",
  fv.pedido_id AS "pedidoId",
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
