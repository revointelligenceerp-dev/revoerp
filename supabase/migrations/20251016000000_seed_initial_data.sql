/*
          # [INSERÇÃO DE DADOS INICIAIS]
          Este script popula as tabelas principais com dados de exemplo para facilitar testes e desenvolvimento.
          ## Query Description: [Esta operação insere dados de exemplo nas tabelas. Não apaga dados existentes, mas pode falhar se os IDs já existirem. É seguro para um ambiente de desenvolvimento limpo.]
          ## Metadata:
          - Schema-Category: ["Data"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Insere dados em: clientes, vendedores, produtos, servicos, pedidos_venda, contas_pagar, faturas_venda, contas_receber, ordens_servico.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Leve, apenas inserção de poucos registros.]
*/

-- Inserir Clientes e Fornecedores
INSERT INTO public.clientes (id, nome, tipo_pessoa, contribuinte_icms, is_cliente, is_fornecedor, email, cpf_cnpj, cep, logradouro, numero, bairro, cidade, estado) VALUES
('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Empresa Cliente Exemplo SA', 'JURIDICA', 'Contribuinte ICMS', true, false, 'cliente@exemplo.com', '11.222.333/0001-44', '01001-000', 'Praça da Sé', '100', 'Sé', 'São Paulo', 'SP'),
('f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1', 'Fornecedor de Componentes LTDA', 'JURIDICA', 'Contribuinte ICMS', false, true, 'fornecedor@email.com', '55.666.777/0001-88', '20040-004', 'Avenida Rio Branco', '1', 'Centro', 'Rio de Janeiro', 'RJ')
ON CONFLICT (id) DO NOTHING;

-- Inserir Vendedores
INSERT INTO public.vendedores (id, nome, tipo_pessoa, contribuinte, situacao, regra_liberacao_comissao, tipo_comissao, email, cpf_cnpj) VALUES
('v1v1v1v1-v1v1-v1v1-v1v1-v1v1v1v1v1v1', 'Carlos Silva', 'Física', 'Não Contribuinte', 'Ativo com acesso ao sistema', 'Liberação parcial (pelo pagamento)', 'Comissão com alíquota fixa', 'carlos.silva@email.com', '123.456.789-00')
ON CONFLICT (id) DO NOTHING;

-- Inserir Produtos
INSERT INTO public.produtos (id, tipo_produto, nome, codigo, origem, unidade, ncm, preco_venda, controlar_estoque, estoque_inicial, situacao) VALUES
('p1p1p1p1-p1p1-p1p1-p1p1-p1p1p1p1p1p1', 'Simples', 'Mouse Gamer Pro X', 'MSE-PRO-X', '0 - Nacional', 'UN', '8471.60.53', 250.00, true, 100, 'Ativo'),
('p2p2p2p2-p2p2-p2p2-p2p2-p2p2p2p2p2p2', 'Simples', 'Teclado Mecânico RGB', 'TEC-MEC-RGB', '2 - Estrangeira (Mercado Interno)', 'UN', '8471.60.52', 450.00, true, 50, 'Ativo')
ON CONFLICT (id) DO NOTHING;

-- Inserir Serviços
INSERT INTO public.servicos (id, descricao, preco, unidade, situacao) VALUES
('s1s1s1s1-s1s1-s1s1-s1s1-s1s1s1s1s1s1', 'Instalação de Software', 150.00, 'HR', 'ATIVO'),
('s2s2s2s2-s2s2-s2s2-s2s2-s2s2s2s2s2s2', 'Manutenção Preventiva de Hardware', 200.00, 'UN', 'ATIVO')
ON CONFLICT (id) DO NOTHING;

-- Inserir Pedidos de Venda
INSERT INTO public.pedidos_venda (id, numero, cliente_id, vendedor_id, total_produtos, valor_total, data_venda, status, expedido) VALUES
('pv1pv1pv1p-v1p1-v1p1-v1p1-v1p1v1p1v1p1', 'PV-001', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'v1v1v1v1-v1v1-v1v1-v1v1-v1v1v1v1v1v1', 700.00, 700.00, '2025-10-01', 'ABERTO', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.pedido_venda_itens (id, pedido_id, produto_id, descricao, quantidade, valor_unitario, valor_total) VALUES
('pvi1pvi1p1-pvi1-pvi1-pvi1-pvi1pvi1pvi1', 'pv1pv1pv1p-v1p1-v1p1-v1p1-v1p1v1p1v1p1', 'p1p1p1p1-p1p1-p1p1-p1p1-p1p1p1p1p1p1', 'Mouse Gamer Pro X', 1, 250.00, 250.00),
('pvi2pvi2p2-pvi2-pvi2-pvi2-pvi2pvi2pvi2', 'pv1pv1pv1p-v1p1-v1p1-v1p1-v1p1v1p1v1p1', 'p2p2p2p2-p2p2-p2p2-p2p2-p2p2p2p2p2p2', 'Teclado Mecânico RGB', 1, 450.00, 450.00)
ON CONFLICT (id) DO NOTHING;

-- Inserir Contas a Pagar
INSERT INTO public.contas_pagar (id, descricao, valor, data_vencimento, status, fornecedor_id, ocorrencia) VALUES
('cp1cp1cp1c-p1c1-p1c1-p1c1-p1c1p1c1p1c1', 'Compra de Componentes', 1200.00, '2025-10-30', 'A_PAGAR', 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1', 'Única')
ON CONFLICT (id) DO NOTHING;

-- Inserir Faturas e Contas a Receber
INSERT INTO public.faturas_venda (id, pedido_id, numero_fatura, data_emissao, data_vencimento, valor_total, status) VALUES
('fv1fv1fv1f-v1f1-v1f1-v1f1-v1f1v1f1v1f1', 'pv1pv1pv1p-v1p1-v1p1-v1p1-v1p1v1p1v1p1', 'FAT-001', '2025-10-01', '2025-10-31', 700.00, 'EMITIDA')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.contas_receber (id, fatura_id, cliente_id, valor, data_vencimento, status, ocorrencia) VALUES
('cr1cr1cr1c-r1c1-r1c1-r1c1-r1c1r1c1r1c1', 'fv1fv1fv1f-v1f1-v1f1-v1f1-v1f1v1f1v1f1', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 700.00, '2025-10-31', 'A_RECEBER', 'Única')
ON CONFLICT (id) DO NOTHING;

-- Inserir Ordens de Serviço
INSERT INTO public.ordens_servico (id, numero, cliente_id, descricao_servico, data_inicio, total_servicos, status, prioridade) VALUES
('os1os1os1o-s1o1-s1o1-s1o1-s1o1s1o1s1o1', 'OS-001', 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Manutenção em servidor', '2025-10-02', 200.00, 'ABERTA', 'ALTA')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.ordem_servico_itens (id, ordem_servico_id, servico_id, descricao, quantidade, preco, desconto, valor_total, orcar) VALUES
('osi1osi1o1-si1o-si1o-si1o-si1osi1osi1', 'os1os1os1o-s1o1-s1o1-s1o1-s1o1s1o1s1o1', 's2s2s2s2-s2s2-s2s2-s2s2-s2s2s2s2s2s2', 'Manutenção Preventiva de Hardware', 1, 200.00, 0, 200.00, false)
ON CONFLICT (id) DO NOTHING;
