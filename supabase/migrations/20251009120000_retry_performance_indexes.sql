-- Habilita a extensão pg_trgm para buscas de texto otimizadas
CREATE EXTENSION IF NOT EXISTS pg_trgm;

DO $$
BEGIN
    -- Adiciona colunas faltantes na tabela de serviços, se não existirem
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='situacao') THEN
        ALTER TABLE public.servicos ADD COLUMN situacao TEXT DEFAULT 'ATIVO' NOT NULL;
    END IF;

    -- Cria índices de performance apenas se eles não existirem
    -- Índices para buscas por texto (GIN com pg_trgm)
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_clientes_nome_gin') THEN
        CREATE INDEX idx_clientes_nome_gin ON public.clientes USING gin (nome gin_trgm_ops);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_produtos_descricao_gin') THEN
        CREATE INDEX idx_produtos_descricao_gin ON public.produtos USING gin (nome gin_trgm_ops);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_servicos_descricao_gin') THEN
        CREATE INDEX idx_servicos_descricao_gin ON public.servicos USING gin (descricao gin_trgm_ops);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_vendedores_nome_gin') THEN
        CREATE INDEX idx_vendedores_nome_gin ON public.vendedores USING gin (nome gin_trgm_ops);
    END IF;

    -- Índices para buscas exatas e chaves estrangeiras (B-Tree)
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_clientes_cpf_cnpj') THEN
        CREATE INDEX idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_produtos_codigo') THEN
        CREATE INDEX idx_produtos_codigo ON public.produtos(codigo);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_servicos_codigo') THEN
        CREATE INDEX idx_servicos_codigo ON public.servicos(codigo);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_pedidos_venda_cliente_id') THEN
        CREATE INDEX idx_pedidos_venda_cliente_id ON public.pedidos_venda(cliente_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_pedidos_venda_vendedor_id') THEN
        CREATE INDEX idx_pedidos_venda_vendedor_id ON public.pedidos_venda(vendedor_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ordens_servico_cliente_id') THEN
        CREATE INDEX idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_contas_pagar_fornecedor_id') THEN
        CREATE INDEX idx_contas_pagar_fornecedor_id ON public.contas_pagar(fornecedor_id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_contas_receber_cliente_id') THEN
        CREATE INDEX idx_contas_receber_cliente_id ON public.contas_receber(cliente_id);
    END IF;
END $$;
