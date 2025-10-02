/*
          # [Consolidated DB Fix and Index]
          [Este script consolida várias correções e otimizações. Ele garante que a extensão pg_trgm esteja ativa, adiciona colunas que podem estar faltando em tabelas como 'servicos' e, finalmente, cria índices de performance em várias tabelas para acelerar as buscas e filtros no sistema.]

          ## Query Description: [Este script é seguro para ser executado. Ele primeiro verifica a existência de colunas e extensões antes de tentar criá-las, evitando erros. Nenhuma estrutura ou dado existente será perdido. A adição de índices pode causar um breve e leve aumento na carga do banco de dados durante a sua criação, mas não afetará a disponibilidade do sistema.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Adiciona a extensão 'pg_trgm'.
          - Adiciona a coluna 'codigo' à tabela 'servicos', se não existir.
          - Adiciona a coluna 'situacao' à tabela 'servicos', se não existir.
          - Cria múltiplos índices GIN e B-tree em várias tabelas para otimizar a performance.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [None]
          
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [None]
          - Estimated Impact: [Melhora significativamente a performance de buscas e filtros em tabelas com grande volume de dados. O impacto na escrita de dados é mínimo.]
          */

-- Habilita a extensão para busca de texto otimizada
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Garante que as colunas necessárias na tabela 'servicos' existam antes de criar índices
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='situacao') THEN
        ALTER TABLE public.servicos ADD COLUMN situacao public.situacao_servico DEFAULT 'ATIVO'::public.situacao_servico;
    END IF;
END $$;

-- Índices de Performance

-- Para buscas de texto otimizadas (usando pg_trgm)
CREATE INDEX IF NOT EXISTS idx_clientes_nome_gin ON public.clientes USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj_gin ON public.clientes USING gin (cpf_cnpj gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_produtos_descricao_gin ON public.produtos USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_servicos_descricao_gin ON public.servicos USING gin (descricao gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_servicos_codigo_gin ON public.servicos USING gin (codigo gin_trgm_ops);

-- Índices B-tree para chaves estrangeiras e campos frequentemente filtrados
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_vendedor_id ON public.ordens_servico(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_tecnico_id ON public.ordens_servico(tecnico_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_status ON public.ordens_servico(status);

CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda(cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_vendedor_id ON public.pedidos_venda(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_status ON public.pedidos_venda(status);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_data_venda ON public.pedidos_venda(data_venda);

CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor_id ON public.contas_pagar(fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_data_vencimento ON public.contas_pagar(data_vencimento);

CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente_id ON public.contas_receber(cliente_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_data_vencimento ON public.contas_receber(data_vencimento);
