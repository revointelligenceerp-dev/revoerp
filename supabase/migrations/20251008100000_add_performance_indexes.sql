/*
          # [Otimização] Adicionar Índices de Performance
          Cria índices em colunas frequentemente usadas em buscas e filtros para otimizar a performance das consultas.

          ## Query Description: 
          Esta operação é segura e não afeta os dados existentes. Ela melhora significativamente a velocidade de leitura do banco de dados à medida que o volume de dados cresce, agindo como um "índice remissivo" para as tabelas.
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (os índices podem ser removidos com `DROP INDEX`)
          
          ## Structure Details:
          - Adiciona índices nas tabelas: clientes, produtos, servicos, vendedores, pedidos_venda, ordens_servico, contas_pagar, contas_receber.
          
          ## Security Implications:
          - RLS Status: Inalterado
          - Policy Changes: Não
          - Auth Requirements: Não
          
          ## Performance Impact:
          - Indexes: Adicionados
          - Triggers: Não
          - Estimated Impact: Melhora significativa na performance de leitura (SELECT com WHERE) em tabelas grandes. Leve e insignificante sobrecarga na escrita (INSERT, UPDATE).
          */

-- Índices para buscas textuais comuns
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes (cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_produtos_nome ON public.produtos USING gin (nome gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo ON public.produtos (codigo);
CREATE INDEX IF NOT EXISTS idx_servicos_descricao ON public.servicos USING gin (descricao gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_vendedores_nome ON public.vendedores USING gin (nome gin_trgm_ops);

-- Índices para chaves estrangeiras (melhora JOINs)
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda (cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_vendedor_id ON public.pedidos_venda (vendedor_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico (cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_vendedor_id ON public.ordens_servico (vendedor_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_tecnico_id ON public.ordens_servico (tecnico_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor_id ON public.contas_pagar (fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente_id ON public.contas_receber (cliente_id);

-- Índices para ordenação e filtros de data
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_data_venda ON public.pedidos_venda (data_venda);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_data_vencimento ON public.contas_pagar (data_vencimento);
CREATE INDEX IF NOT EXISTS idx_contas_receber_data_vencimento ON public.contas_receber (data_vencimento);

-- Habilita a extensão para buscas textuais mais eficientes
CREATE EXTENSION IF NOT EXISTS pg_trgm;
