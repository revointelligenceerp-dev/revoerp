DO $$
BEGIN

-- =================================================================
-- PASSO 1: REMOVER OBJETOS DEPENDENTES (VIEWS, TRIGGERS, FUNCTIONS)
-- =================================================================

-- Remove as views que dependem das colunas de status
DROP VIEW IF EXISTS public.comissoes_calculadas;
DROP VIEW IF EXISTS public.dre_mensal;

-- Remove os triggers que dependem das colunas de status
DROP TRIGGER IF EXISTS on_conta_recebida_create_fluxo_caixa ON public.contas_receber;
DROP TRIGGER IF EXISTS on_conta_paga_create_fluxo_caixa ON public.contas_pagar;

-- Remove as funções dos triggers
DROP FUNCTION IF EXISTS public.handle_conta_recebida_create_fluxo_caixa();
DROP FUNCTION IF EXISTS public.handle_conta_paga_create_fluxo_caixa();

-- =================================================================
-- PASSO 2: CRIAR OS TIPOS ENUM (SE NÃO EXISTIREM)
-- =================================================================

IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_receber') THEN
    CREATE TYPE public.status_conta_receber AS ENUM ('A_RECEBER', 'RECEBIDO', 'VENCIDO');
END IF;

IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_conta_pagar') THEN
    CREATE TYPE public.status_conta_pagar AS ENUM ('A_PAGAR', 'PAGO', 'VENCIDO');
END IF;

-- =================================================================
-- PASSO 3: ALTERAR AS COLUNAS DAS TABELAS PARA USAR OS ENUMS
-- =================================================================

-- Altera a coluna 'status' em 'contas_receber' se ela não for do tipo correto
IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'contas_receber' AND column_name = 'status' AND udt_name = 'status_conta_receber'
) THEN
    ALTER TABLE public.contas_receber
    ALTER COLUMN status TYPE public.status_conta_receber
    USING status::text::public.status_conta_receber;
END IF;

-- Altera a coluna 'status' em 'contas_pagar' se ela não for do tipo correto
IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'contas_pagar' AND column_name = 'status' AND udt_name = 'status_conta_pagar'
) THEN
    ALTER TABLE public.contas_pagar
    ALTER COLUMN status TYPE public.status_conta_pagar
    USING status::text::public.status_conta_pagar;
END IF;

-- =================================================================
-- PASSO 4: RE-CRIAR AS FUNÇÕES E TRIGGERS DO FLUXO DE CAIXA
-- =================================================================

-- Função para Contas a Receber
CREATE OR REPLACE FUNCTION public.handle_conta_recebida_create_fluxo_caixa()
RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.status = 'RECEBIDO' AND OLD.status <> 'RECEBIDO' THEN
        INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_receber_id)
        VALUES (
            COALESCE(NEW.data_pagamento, NOW()),
            'Recebimento: ' || COALESCE(NEW.descricao, 'Fatura ' || (SELECT numero_fatura FROM public.faturas_venda WHERE id = NEW.fatura_id), 'Recebimento avulso'),
            NEW.valor,
            'ENTRADA',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;

-- Trigger para Contas a Receber
CREATE TRIGGER on_conta_recebida_create_fluxo_caixa
AFTER UPDATE ON public.contas_receber
FOR EACH ROW
EXECUTE FUNCTION public.handle_conta_recebida_create_fluxo_caixa();

-- Função para Contas a Pagar
CREATE OR REPLACE FUNCTION public.handle_conta_paga_create_fluxo_caixa()
RETURNS TRIGGER AS $function$
BEGIN
    IF NEW.status = 'PAGO' AND OLD.status <> 'PAGO' THEN
        INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_pagar_id)
        VALUES (
            COALESCE(NEW.data_pagamento, NOW()),
            'Pagamento: ' || NEW.descricao,
            NEW.valor,
            'SAIDA',
            NEW.id
        );
    END IF;
    RETURN NEW;
END;
$function$ LANGUAGE plpgsql;

-- Trigger para Contas a Pagar
CREATE TRIGGER on_conta_paga_create_fluxo_caixa
AFTER UPDATE ON public.contas_pagar
FOR EACH ROW
EXECUTE FUNCTION public.handle_conta_paga_create_fluxo_caixa();


-- =================================================================
-- PASSO 5: GARANTIR A ESTRUTURA PARA COMISSÕES
-- =================================================================

-- Adiciona a coluna de percentual de comissão se ela não existir
IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'vendedores' AND column_name = 'percentual_comissao'
) THEN
    ALTER TABLE public.vendedores ADD COLUMN percentual_comissao numeric(5,2) NOT NULL DEFAULT 5.0;
END IF;

-- =================================================================
-- PASSO 6: RE-CRIAR AS VIEWS DE RELATÓRIOS DE FORMA SEGURA
-- =================================================================

-- View para DRE Mensal
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
FROM
    public.fluxo_caixa f
GROUP BY
    EXTRACT(YEAR FROM f.data),
    EXTRACT(MONTH FROM f.data),
    TO_CHAR(f.data, 'TMMonth')
ORDER BY
    ano, mes;

-- View para Comissões Calculadas
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
    (pv.valor_total * v.percentual_comissao / 100.0) AS "valorComissao",
    cr.data_pagamento AS "dataPagamentoFatura"
FROM
    public.contas_receber cr
JOIN
    public.faturas_venda fv ON cr.fatura_id = fv.id
JOIN
    public.pedidos_venda pv ON fv.pedido_id = pv.id
JOIN
    public.vendedores v ON pv.vendedor_id = v.id
WHERE
    cr.status = 'RECEBIDO' AND cr.data_pagamento IS NOT NULL;

END $$;
