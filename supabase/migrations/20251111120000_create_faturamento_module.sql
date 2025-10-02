/*
          # [Operation Name]
          Criação do Módulo de Faturamento

          ## Query Description: [Cria as tabelas `faturas_venda` e `fatura_venda_itens` e adiciona a chave estrangeira `fatura_id` na tabela `contas_receber`. Isso estabelece a base para o fluxo de faturamento, conectando Pedidos de Venda a Faturas e Contas a Receber, um passo essencial para a integridade do ciclo financeiro.]
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Cria a tabela `faturas_venda`.
          - Cria a tabela `fatura_venda_itens`.
          - Adiciona a coluna e a constraint `fatura_id` em `contas_receber`.
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes
          - Auth Requirements: authenticated
          
          ## Performance Impact:
          - Indexes: Adiciona índices em chaves primárias e estrangeiras.
          - Triggers: Nenhum.
          - Estimated Impact: Baixo impacto, são criações de novas tabelas.
          */

-- Tabela de Faturas de Venda
CREATE TABLE IF NOT EXISTS public.faturas_venda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID REFERENCES public.pedidos_venda(id) ON DELETE SET NULL,
    numero_fatura TEXT NOT NULL,
    data_emissao TIMESTAMPTZ NOT NULL DEFAULT now(),
    data_vencimento TIMESTAMPTZ NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Habilita RLS para a tabela de faturas
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para faturas_venda
DROP POLICY IF EXISTS "Allow all access to authenticated users" ON public.faturas_venda;
CREATE POLICY "Allow all access to authenticated users" ON public.faturas_venda
    FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Tabela de Itens da Fatura de Venda
CREATE TABLE IF NOT EXISTS public.fatura_venda_itens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fatura_id UUID NOT NULL REFERENCES public.faturas_venda(id) ON DELETE CASCADE,
    produto_id UUID REFERENCES public.produtos(id),
    servico_id UUID REFERENCES public.servicos(id),
    descricao TEXT NOT NULL,
    quantidade NUMERIC(10, 2) NOT NULL,
    valor_unitario NUMERIC(10, 2) NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Habilita RLS para a tabela de itens da fatura
ALTER TABLE public.fatura_venda_itens ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para fatura_venda_itens
DROP POLICY IF EXISTS "Allow all access to authenticated users" ON public.fatura_venda_itens;
CREATE POLICY "Allow all access to authenticated users" ON public.fatura_venda_itens
    FOR ALL
    USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Adiciona a coluna fatura_id na tabela contas_receber, se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='contas_receber' AND column_name='fatura_id') THEN
        ALTER TABLE public.contas_receber ADD COLUMN fatura_id UUID REFERENCES public.faturas_venda(id) ON DELETE SET NULL;
    END IF;
END $$;
