-- Criar o tipo ENUM para o status da conta a receber
CREATE TYPE public.contas_receber_status AS ENUM (
    'A_RECEBER',
    'RECEBIDO',
    'VENCIDO'
);

-- Criar a tabela contas_receber
CREATE TABLE IF NOT EXISTS public.contas_receber (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    fatura_id uuid NOT NULL,
    valor numeric NOT NULL,
    data_vencimento date NOT NULL,
    data_pagamento date NULL,
    status public.contas_receber_status NOT NULL,
    CONSTRAINT contas_receber_pkey PRIMARY KEY (id),
    CONSTRAINT contas_receber_fatura_id_fkey FOREIGN KEY (fatura_id) REFERENCES public.faturas_venda(id) ON DELETE CASCADE
);

-- Habilitar Row Level Security
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso
DROP POLICY IF EXISTS "Permite acesso total para usuários autenticados" ON public.contas_receber;
CREATE POLICY "Permite acesso total para usuários autenticados"
    ON public.contas_receber
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Inserir contas a receber para faturas existentes que ainda não têm uma
INSERT INTO public.contas_receber (fatura_id, valor, data_vencimento, status)
SELECT 
    f.id,
    f.valor_total,
    f.data_vencimento,
    'A_RECEBER'::public.contas_receber_status
FROM 
    public.faturas_venda f
LEFT JOIN 
    public.contas_receber cr ON f.id = cr.fatura_id
WHERE 
    cr.id IS NULL;
