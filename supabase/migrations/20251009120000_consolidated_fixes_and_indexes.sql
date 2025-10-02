-- Habilita a extensão pg_trgm se não existir, essencial para buscas de texto eficientes.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Adiciona colunas faltantes à tabela 'servicos' de forma segura, verificando antes se já existem.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='situacao') THEN
        ALTER TABLE public.servicos ADD COLUMN situacao TEXT DEFAULT 'ATIVO' NOT NULL;
    END IF;
END;
$$;

-- Cria índices de performance para acelerar buscas e filtros em toda a aplicação.
-- A cláusula 'IF NOT EXISTS' garante que o script pode ser executado várias vezes sem erros.

-- Índices em 'clientes'
CREATE INDEX IF NOT EXISTS idx_clientes_nome_trgm ON public.clientes USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes (cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON public.clientes (email);

-- Índices em 'produtos'
CREATE INDEX IF NOT EXISTS idx_produtos_nome_trgm ON public.produtos USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON public.produtos (codigo);

-- Índices em 'servicos'
CREATE INDEX IF NOT EXISTS idx_servicos_descricao_trgm ON public.servicos USING gin (descricao gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_servicos_codigo ON public.servicos (codigo);

-- Índices em 'vendedores'
CREATE INDEX IF NOT EXISTS idx_vendedores_nome_trgm ON public.vendedores USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_vendedores_cpf_cnpj ON public.vendedores (cpf_cnpj);

-- Índices em chaves estrangeiras para otimizar joins
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda (cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_vendedor_id ON public.pedidos_venda (vendedor_id);
CREATE INDEX IF NOT EXISTS idx_pedido_venda_itens_pedido_id ON public.pedido_venda_itens (pedido_id);
CREATE INDEX IF NOT EXISTS idx_pedido_venda_itens_produto_id ON public.pedido_venda_itens (produto_id);
CREATE INDEX IF NOT EXISTS idx_pedido_venda_itens_servico_id ON public.pedido_venda_itens (servico_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico (cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_vendedor_id ON public.ordens_servico (vendedor_id);
CREATE INDEX IF NOT EXISTS idx_ordem_servico_itens_ordem_servico_id ON public.ordem_servico_itens (ordem_servico_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor_id ON public.contas_pagar (fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente_id ON public.contas_receber (cliente_id);
