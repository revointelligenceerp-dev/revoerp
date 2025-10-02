-- Enum para Finalidade da NF
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'nf_finalidade') THEN
        CREATE TYPE public.nf_finalidade AS ENUM (
            'NORMAL',
            'COMPLEMENTAR',
            'AJUSTE',
            'DEVOLUCAO'
        );
    END IF;
END$$;

-- Enum para Tipo de Operação da NF
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'nf_tipo_operacao') THEN
        CREATE TYPE public.nf_tipo_operacao AS ENUM (
            'SAIDA',
            'ENTRADA'
        );
    END IF;
END$$;

-- Enum for Frete por Conta
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'nf_frete_por_conta') THEN
        CREATE TYPE public.nf_frete_por_conta AS ENUM (
            'EMITENTE',
            'DESTINATARIO',
            'TERCEIROS',
            'SEM_FRETE'
        );
    END IF;
END$$;

-- Tabela principal de Notas Fiscais
CREATE TABLE IF NOT EXISTS public.notas_fiscais (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_venda_id uuid REFERENCES public.pedidos_venda(id) ON DELETE SET NULL,
    cliente_id uuid NOT NULL REFERENCES public.clientes(id),
    transportador_id uuid REFERENCES public.clientes(id),
    numero integer NOT NULL,
    serie integer NOT NULL,
    data_emissao timestamptz NOT NULL DEFAULT now(),
    data_saida timestamptz,
    hora_saida time,
    natureza_operacao text,
    finalidade public.nf_finalidade NOT NULL DEFAULT 'NORMAL',
    tipo_operacao public.nf_tipo_operacao NOT NULL DEFAULT 'SAIDA',
    
    -- Cálculos de Imposto
    base_calculo_icms numeric(12, 2) DEFAULT 0,
    valor_icms numeric(12, 2) DEFAULT 0,
    base_calculo_icms_st numeric(12, 2) DEFAULT 0,
    valor_icms_st numeric(12, 2) DEFAULT 0,
    valor_total_produtos numeric(12, 2) DEFAULT 0,
    valor_frete numeric(12, 2) DEFAULT 0,
    valor_seguro numeric(12, 2) DEFAULT 0,
    outras_despesas numeric(12, 2) DEFAULT 0,
    valor_total_ipi numeric(12, 2) DEFAULT 0,
    valor_total_nota numeric(12, 2) NOT NULL,

    -- Transportador
    frete_por_conta public.nf_frete_por_conta DEFAULT 'SEM_FRETE',
    placa_veiculo text,
    uf_veiculo char(2),
    qtd_volumes integer,
    especie_volumes text,
    marca_volumes text,
    numeracao_volumes text,
    peso_bruto numeric(10, 3),
    peso_liquido numeric(10, 3),

    -- Informações Adicionais
    informacoes_complementares text,
    informacoes_fisco text,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Tabela de Itens da Nota Fiscal
CREATE TABLE IF NOT EXISTS public.nota_fiscal_itens (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nota_fiscal_id uuid NOT NULL REFERENCES public.notas_fiscais(id) ON DELETE CASCADE,
    produto_id uuid REFERENCES public.produtos(id),
    descricao text NOT NULL,
    codigo text,
    ncm text,
    cst text,
    cfop text,
    unidade text,
    quantidade numeric(12, 2) NOT NULL,
    valor_unitario numeric(12, 2) NOT NULL,
    valor_total numeric(12, 2) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Tabela de Faturas (parcelas) da Nota Fiscal
CREATE TABLE IF NOT EXISTS public.nota_fiscal_faturas (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nota_fiscal_id uuid NOT NULL REFERENCES public.notas_fiscais(id) ON DELETE CASCADE,
    numero text NOT NULL,
    vencimento date NOT NULL,
    valor numeric(12, 2) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Habilitar RLS para as novas tabelas
ALTER TABLE public.notas_fiscais ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nota_fiscal_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nota_fiscal_faturas ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS
CREATE POLICY "Permitir acesso total para usuários autenticados NF"
ON public.notas_fiscais FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Permitir acesso total para usuários autenticados NF Itens"
ON public.nota_fiscal_itens FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Permitir acesso total para usuários autenticados NF Faturas"
ON public.nota_fiscal_faturas FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
