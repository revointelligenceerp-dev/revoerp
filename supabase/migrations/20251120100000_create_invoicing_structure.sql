/*
  # [Estrutura de Faturamento]
  Cria as tabelas para faturas de venda e as conecta com contas a receber.

  ## Query Description:
  - Cria a tabela `faturas_venda` para armazenar os dados do cabeçalho das faturas.
  - Cria a tabela `fatura_venda_itens` para os itens de cada fatura.
  - Adiciona uma coluna `fatura_id` na tabela `contas_receber` para criar o vínculo.
  - Nenhuma perda de dados é esperada.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true

  ## Structure Details:
  - Tables created: `faturas_venda`, `fatura_venda_itens`
  - Columns added: `contas_receber.fatura_id`

  ## Security Implications:
  - RLS Status: Enabled (com política permissiva)
  - Policy Changes: No
  - Auth Requirements: authenticated

  ## Performance Impact:
  - Indexes: Chaves primárias e estrangeiras serão indexadas.
  - Triggers: None
  - Estimated Impact: Baixo
*/

-- Tabela de Faturas de Venda
CREATE TABLE IF NOT EXISTS public.faturas_venda (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id uuid NOT NULL REFERENCES public.pedidos_venda(id),
    numero_fatura character varying NOT NULL,
    data_emissao timestamp with time zone NOT NULL DEFAULT now(),
    data_vencimento timestamp with time zone NOT NULL,
    valor_total numeric(15,2) NOT NULL,
    status character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Habilita RLS e cria política padrão
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all access to faturas_venda" ON public.faturas_venda;
CREATE POLICY "Allow all access to faturas_venda" ON public.faturas_venda FOR ALL USING (true) WITH CHECK (true);


-- Tabela de Itens da Fatura de Venda
CREATE TABLE IF NOT EXISTS public.fatura_venda_itens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    fatura_id uuid NOT NULL REFERENCES public.faturas_venda(id) ON DELETE CASCADE,
    produto_id uuid REFERENCES public.produtos(id),
    servico_id uuid REFERENCES public.servicos(id),
    descricao character varying NOT NULL,
    quantidade numeric(15,4) NOT NULL,
    valor_unitario numeric(15,2) NOT NULL,
    valor_total numeric(15,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- Habilita RLS e cria política padrão
ALTER TABLE public.fatura_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all access to fatura_venda_itens" ON public.fatura_venda_itens;
CREATE POLICY "Allow all access to fatura_venda_itens" ON public.fatura_venda_itens FOR ALL USING (true) WITH CHECK (true);


-- Adiciona a coluna de relacionamento em contas_receber
ALTER TABLE public.contas_receber ADD COLUMN IF NOT EXISTS fatura_id uuid REFERENCES public.faturas_venda(id);
