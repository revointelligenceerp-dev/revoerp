-- Habilita a extensão para busca de texto otimizada, se não existir.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Adiciona colunas faltantes à tabela 'servicos' de forma segura.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='situacao') THEN
        ALTER TABLE public.servicos ADD COLUMN situacao public.situacao_servico DEFAULT 'ATIVO'::public.situacao_servico;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo_servico') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo_servico TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='nbs') THEN
        ALTER TABLE public.servicos ADD COLUMN nbs TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='descricao_complementar') THEN
        ALTER TABLE public.servicos ADD COLUMN descricao_complementar TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='observacoes') THEN
        ALTER TABLE public.servicos ADD COLUMN observacoes TEXT;
    END IF;
END $$;

-- Adiciona colunas faltantes à tabela 'produtos' de forma segura.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='codigo') THEN
        ALTER TABLE public.produtos ADD COLUMN codigo TEXT;
    END IF;
END $$;

-- Cria índices de performance de forma segura.
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_produtos_descricao ON public.produtos USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON public.produtos(codigo);
CREATE INDEX IF NOT EXISTS idx_servicos_descricao ON public.servicos USING gin (descricao gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_servicos_codigo ON public.servicos(codigo);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);
