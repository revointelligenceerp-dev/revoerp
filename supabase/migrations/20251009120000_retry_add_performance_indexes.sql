DO $$
BEGIN
  -- Habilita a extensão para busca textual otimizada
  CREATE EXTENSION IF NOT EXISTS pg_trgm;

  -- Corrige a tabela de serviços, adicionando colunas que podem estar faltando
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo') THEN
    ALTER TABLE public.servicos ADD COLUMN codigo VARCHAR(50);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='situacao') THEN
    ALTER TABLE public.servicos ADD COLUMN situacao VARCHAR(50) DEFAULT 'ATIVO';
  END IF;
  
  -- Adiciona índices para otimizar buscas e filtros comuns
  -- Clientes
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_clientes_nome_trgm') THEN
    CREATE INDEX idx_clientes_nome_trgm ON public.clientes USING gin (nome gin_trgm_ops);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_clientes_cpf_cnpj') THEN
    CREATE INDEX idx_clientes_cpf_cnpj ON public.clientes (cpf_cnpj);
  END IF;

  -- Produtos
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_produtos_descricao_trgm') THEN
    CREATE INDEX idx_produtos_descricao_trgm ON public.produtos USING gin (nome gin_trgm_ops);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_produtos_codigo') THEN
    CREATE INDEX idx_produtos_codigo ON public.produtos (codigo);
  END IF;

  -- Serviços
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_servicos_descricao_trgm') THEN
    CREATE INDEX idx_servicos_descricao_trgm ON public.servicos USING gin (descricao gin_trgm_ops);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_servicos_codigo') THEN
    CREATE INDEX idx_servicos_codigo ON public.servicos (codigo);
  END IF;

  -- Chaves Estrangeiras
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_pedidos_venda_cliente_id') THEN
    CREATE INDEX idx_pedidos_venda_cliente_id ON public.pedidos_venda (cliente_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_pedidos_venda_vendedor_id') THEN
    CREATE INDEX idx_pedidos_venda_vendedor_id ON public.pedidos_venda (vendedor_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_ordens_servico_cliente_id') THEN
    CREATE INDEX idx_ordens_servico_cliente_id ON public.ordens_servico (cliente_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_contas_pagar_fornecedor_id') THEN
    CREATE INDEX idx_contas_pagar_fornecedor_id ON public.contas_pagar (fornecedor_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_contas_receber_cliente_id') THEN
    CREATE INDEX idx_contas_receber_cliente_id ON public.contas_receber (cliente_id);
  END IF;

END $$;
