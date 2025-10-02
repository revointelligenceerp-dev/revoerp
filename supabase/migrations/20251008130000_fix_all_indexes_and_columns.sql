/*
          # [Operação de Correção e Otimização]
          Este script corrige a estrutura do banco de dados e adiciona otimizações de performance.

          ## Query Description: [Este script é seguro e verificará a existência de extensões, colunas e índices antes de criá-los, evitando erros e duplicatas. Ele garante que o banco de dados esteja alinhado com o que a aplicação espera e otimizado para buscas futuras. Nenhum dado será perdido.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Habilita a extensão 'pg_trgm'.
          - Adiciona colunas faltantes ('codigo', 'codigo_servico', 'nbs', 'situacao') à tabela 'servicos'.
          - Cria índices de performance (GIN e B-Tree) em várias tabelas para acelerar as buscas.
          
          ## Security Implications:
          - RLS Status: [Não alterado]
          - Policy Changes: [Não]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [Não alterado]
          - Estimated Impact: [Melhora significativa na performance de buscas e filtros à medida que os dados crescem.]
          */

-- Habilita a extensão para busca textual mais rápida, se ainda não estiver habilitada.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Adiciona colunas faltantes à tabela 'servicos' de forma segura.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='codigo_servico') THEN
        ALTER TABLE public.servicos ADD COLUMN codigo_servico TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='nbs') THEN
        ALTER TABLE public.servicos ADD COLUMN nbs TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='servicos' AND column_name='situacao') THEN
        ALTER TABLE public.servicos ADD COLUMN situacao TEXT DEFAULT 'ATIVO';
    END IF;
END;
$$;

-- Cria índices para otimizar buscas por texto (GIN com pg_trgm)
CREATE INDEX IF NOT EXISTS idx_clientes_nome_gin ON public.clientes USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_produtos_descricao_gin ON public.produtos USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_servicos_descricao_gin ON public.servicos USING gin (descricao gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_vendedores_nome_gin ON public.vendedores USING gin (nome gin_trgm_ops);

-- Cria índices para otimizar buscas por chaves e códigos (B-Tree)
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON public.produtos(codigo);
CREATE INDEX IF NOT EXISTS idx_servicos_codigo ON public.servicos(codigo);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_vendedor_id ON public.ordens_servico(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_tecnico_id ON public.ordens_servico(tecnico_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda(cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_vendedor_id ON public.pedidos_venda(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor_id ON public.contas_pagar(fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente_id ON public.contas_receber(cliente_id);
