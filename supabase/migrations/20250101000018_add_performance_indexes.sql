/*
          # Otimização de Performance com Índices
          Este script cria índices em colunas frequentemente usadas em filtros e junções (joins), como chaves estrangeiras e campos de status. Índices aceleram drasticamente as consultas de leitura, melhorando a performance geral da aplicação à medida que a base de dados cresce.

          ## Query Description: Esta operação é segura e não afeta os dados existentes. Ela apenas cria estruturas de dados adicionais para otimizar as buscas. Não há risco de perda de dados.
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Adiciona múltiplos índices em várias tabelas para otimizar a performance.
          
          ## Security Implications:
          - RLS Status: Não aplicável
          - Policy Changes: Não
          - Auth Requirements: Não
          
          ## Performance Impact:
          - Indexes: Adicionados
          - Triggers: Não modificados
          - Estimated Impact: Melhora significativa na performance de leitura (SELECTs) em tabelas grandes. Leve e insignificante impacto na performance de escrita (INSERTs/UPDATEs).
          */

-- Índices para a tabela de clientes
CREATE INDEX IF NOT EXISTS idx_clientes_tipo ON public.clientes(tipo);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON public.clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_documento ON public.clientes(documento);

-- Índices para ordens de serviço
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_status ON public.ordens_servico(status);

-- Índices para pedidos de venda e seus itens
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_cliente_id ON public.pedidos_venda(cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_vendedor_id ON public.pedidos_venda(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_venda_status ON public.pedidos_venda(status);
CREATE INDEX IF NOT EXISTS idx_pedido_venda_itens_pedido_id ON public.pedido_venda_itens(pedido_id);
CREATE INDEX IF NOT EXISTS idx_pedido_venda_itens_produto_id ON public.pedido_venda_itens(produto_id);
CREATE INDEX IF NOT EXISTS idx_pedido_venda_itens_servico_id ON public.pedido_venda_itens(servico_id);

-- Índices para faturas de venda
CREATE INDEX IF NOT EXISTS idx_faturas_venda_pedido_id ON public.faturas_venda(pedido_id);
CREATE INDEX IF NOT EXISTS idx_faturas_venda_status ON public.faturas_venda(status);

-- Índices para contas a receber
CREATE INDEX IF NOT EXISTS idx_contas_receber_fatura_id ON public.contas_receber(fatura_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_cliente_id ON public.contas_receber(cliente_id);
CREATE INDEX IF NOT EXISTS idx_contas_receber_status ON public.contas_receber(status);

-- Índices para contas a pagar
CREATE INDEX IF NOT EXISTS idx_contas_pagar_fornecedor_id ON public.contas_pagar(fornecedor_id);
CREATE INDEX IF NOT EXISTS idx_contas_pagar_status ON public.contas_pagar(status);

-- Índices para fluxo de caixa
CREATE INDEX IF NOT EXISTS idx_fluxo_caixa_conta_receber_id ON public.fluxo_caixa(conta_receber_id);
CREATE INDEX IF NOT EXISTS idx_fluxo_caixa_conta_pagar_id ON public.fluxo_caixa(conta_pagar_id);
