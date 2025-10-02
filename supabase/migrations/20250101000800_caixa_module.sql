-- Habilita a extensão pgcrypto se ainda não estiver habilitada, para usar gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Criar o tipo ENUM para o movimento de caixa
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_movimento_caixa') THEN
        CREATE TYPE tipo_movimento_caixa AS ENUM ('ENTRADA', 'SAIDA');
    END IF;
END$$;

-- 2. Criar a tabela de fluxo_caixa
CREATE TABLE IF NOT EXISTS public.fluxo_caixa (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    data timestamp with time zone NOT NULL DEFAULT now(),
    descricao text NOT NULL,
    valor numeric(10, 2) NOT NULL,
    tipo tipo_movimento_caixa NOT NULL,
    conta_receber_id uuid REFERENCES public.contas_receber(id) ON DELETE SET NULL,
    conta_pagar_id uuid REFERENCES public.contas_pagar(id) ON DELETE SET NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Habilitar RLS e criar políticas para a tabela fluxo_caixa
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public access for all users" ON public.fluxo_caixa;
CREATE POLICY "Public access for all users" ON public.fluxo_caixa
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- 4. Função para criar entrada no caixa a partir de contas a receber
CREATE OR REPLACE FUNCTION public.handle_nova_entrada_caixa()
RETURNS TRIGGER AS $$
DECLARE
    cliente_nome TEXT;
BEGIN
    -- Busca o nome do cliente associado à fatura
    SELECT c.nome INTO cliente_nome
    FROM public.clientes c
    JOIN public.pedidos_venda pv ON c.id = pv.cliente_id
    JOIN public.faturas_venda fv ON pv.id = fv.pedido_id
    WHERE fv.id = NEW.fatura_id;

    -- Insere o registro no fluxo de caixa
    INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_receber_id)
    VALUES (NEW.data_pagamento, 'Recebimento de ' || COALESCE(cliente_nome, 'Cliente não identificado'), NEW.valor, 'ENTRADA', NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Trigger para a tabela contas_receber
DROP TRIGGER IF EXISTS on_conta_recebida_create_fluxo_caixa ON public.contas_receber;
CREATE TRIGGER on_conta_recebida_create_fluxo_caixa
    AFTER UPDATE ON public.contas_receber
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM 'RECEBIDO' AND NEW.status = 'RECEBIDO' AND NEW.data_pagamento IS NOT NULL)
    EXECUTE FUNCTION public.handle_nova_entrada_caixa();

-- 6. Função para criar saída no caixa a partir de contas a pagar
CREATE OR REPLACE FUNCTION public.handle_nova_saida_caixa()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_pagar_id)
    VALUES (NEW.data_pagamento, NEW.descricao, NEW.valor, 'SAIDA', NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Trigger para a tabela contas_pagar
DROP TRIGGER IF EXISTS on_conta_paga_create_fluxo_caixa ON public.contas_pagar;
CREATE TRIGGER on_conta_paga_create_fluxo_caixa
    AFTER UPDATE ON public.contas_pagar
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM 'PAGO' AND NEW.status = 'PAGO' AND NEW.data_pagamento IS NOT NULL)
    EXECUTE FUNCTION public.handle_nova_saida_caixa();

-- 8. Seed inicial: Popula o fluxo de caixa com dados históricos
-- Inserir entradas para contas a receber já pagas
INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_receber_id)
SELECT 
    cr.data_pagamento,
    'Recebimento de ' || COALESCE(c.nome, 'Cliente não identificado'),
    cr.valor,
    'ENTRADA'::tipo_movimento_caixa,
    cr.id
FROM public.contas_receber cr
JOIN public.faturas_venda fv ON cr.fatura_id = fv.id
JOIN public.pedidos_venda pv ON fv.pedido_id = pv.id
JOIN public.clientes c ON pv.cliente_id = c.id
WHERE cr.status = 'RECEBIDO' AND cr.data_pagamento IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM public.fluxo_caixa fc WHERE fc.conta_receber_id = cr.id
);

-- Inserir saídas para contas a pagar já pagas
INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo, conta_pagar_id)
SELECT 
    cp.data_pagamento,
    cp.descricao,
    cp.valor,
    'SAIDA'::tipo_movimento_caixa,
    cp.id
FROM public.contas_pagar cp
WHERE cp.status = 'PAGO' AND cp.data_pagamento IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM public.fluxo_caixa fc WHERE fc.conta_pagar_id = cp.id
);
