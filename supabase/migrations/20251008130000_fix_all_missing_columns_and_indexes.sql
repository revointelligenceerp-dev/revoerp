-- Habilita a extensão para buscas textuais otimizadas, se ainda não estiver habilitada.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Adiciona colunas faltantes à tabela 'servicos' de forma segura
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='situacao') THEN
        ALTER TABLE public.servicos ADD COLUMN situacao public.situacao_servico DEFAULT 'ATIVO'::public.situacao_servico;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo_servico') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo_servico VARCHAR(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='nbs') THEN
        ALTER TABLE public.servicos ADD COLUMN nbs VARCHAR(255);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='descricao_complementar') THEN
        ALTER TABLE public.servicos ADD COLUMN descricao_complementar TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='observacoes') THEN
        ALTER TABLE public.servicos ADD COLUMN observacoes TEXT;
    END IF;
END;
$$;

-- Adiciona colunas faltantes à tabela 'pedidos_venda' de forma segura
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pedidos_venda' AND column_name='expedido') THEN
        ALTER TABLE public.pedidos_venda ADD COLUMN expedido BOOLEAN DEFAULT false;
    END IF;
END;
$$;

-- Cria índices de performance para acelerar buscas e filtros.
-- Usamos 'IF NOT EXISTS' para garantir que o script possa ser executado várias vezes sem erro.

-- Índices para 'clientes'
CREATE INDEX IF NOT EXISTS idx_clientes_nome_trgm ON public.clientes USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes (cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON public.clientes (email);

-- Índices para 'produtos'
CREATE INDEX IF NOT EXISTS idx_produtos_nome_trgm ON public.produtos USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON public.produtos (codigo);

-- Índices para 'servicos'
CREATE INDEX IF NOT EXISTS idx_servicos_descricao_trgm ON public.servicos USING gin (descricao gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_servicos_codigo ON public.servicos (codigo);

-- Índices para 'vendedores'
CREATE INDEX IF NOT EXISTS idx_vendedores_nome_trgm ON public.vendedores USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_vendedores_cpf_cnpj ON public.vendedores (cpf_cnpj);

-- Índices para chaves estrangeiras (melhora performance de JOINs)
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda (cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_vendedor_id ON public.pedidos_venda (vendedor_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico (cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_vendedor_id ON public.ordens_servico (vendedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor_id ON public.contas_pagar (fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente_id ON public.contas_receber (cliente_id);
