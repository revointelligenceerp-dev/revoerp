/*
          # [POPULAÇÃO INICIAL DE DADOS]
          Este script insere dados de exemplo em todas as tabelas principais para popular o sistema.
          Isso permite testar as funcionalidades do frontend com dados realistas.
          Ele apaga os dados existentes para garantir um estado limpo.

          ## Query Description: [Esta operação irá apagar os dados existentes e inserir novos dados de exemplo nas tabelas. É recomendado para ambientes de desenvolvimento e teste para garantir um estado consistente.]
          
          ## Metadata:
          - Schema-Category: ["Data"]
          - Impact-Level: ["High"]
          - Requires-Backup: [true]
          - Reversible: [false]
          
          ## Structure Details:
          - Tabelas afetadas: vendedores, clientes, produtos, servicos, pedidos_venda, contas_pagar, contas_receber, etc.
          
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo, apenas inserção de dados.]
*/

-- Limpar tabelas para garantir um estado limpo
TRUNCATE TABLE 
  public.fluxo_caixa, 
  public.contas_pagar_anexos,
  public.contas_receber_anexos,
  public.contas_pagar, 
  public.contas_receber, 
  public.faturas_venda, 
  public.pedido_venda_itens, 
  public.pedidos_venda, 
  public.ordem_compra_itens, 
  public.ordens_compra, 
  public.ordem_servico_itens, 
  public.ordem_servico_anexos,
  public.ordens_servico, 
  public.produtos_fornecedores, 
  public.produto_anuncios, 
  public.produto_imagens, 
  public.produtos, 
  public.servicos, 
  public.pessoas_contato,
  public.cliente_anexos,
  public.clientes, 
  public.vendedores 
RESTART IDENTITY CASCADE;

-- Inserir Vendedores
INSERT INTO public.vendedores (id, nome, tipo_pessoa, contribuinte, email, situacao, regra_liberacao_comissao, tipo_comissao, aliquota_comissao, ativo) VALUES
('11111111-1111-1111-1111-111111111111', 'Carlos Silva', 'Física', 'Não Contribuinte', 'carlos.silva@email.com', 'Ativo com acesso ao sistema', 'Liberação total (no faturamento)', 'Comissão com alíquota fixa', 5.0, true),
('22222222-2222-2222-2222-222222222222', 'Ana Pereira', 'Física', 'Não Contribuinte', 'ana.pereira@email.com', 'Ativo com acesso ao sistema', 'Liberação parcial (pelo pagamento)', 'Comissão com alíquota fixa', 7.5, true),
('33333333-3333-3333-3333-333333333333', 'Vendas Internas', 'Jurídica', 'Contribuinte ICMS', 'vendas@revo.erp', 'Ativo sem acesso ao sistema', 'Liberação total (no faturamento)', 'Comissão com alíquota fixa', 3.0, true);

-- Inserir Clientes e Fornecedores
INSERT INTO public.clientes (id, nome, nome_fantasia, tipo_pessoa, cpf_cnpj, contribuinte_icms, is_cliente, is_fornecedor, email, celular, vendedor_id) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Tech Solutions Ltda', 'Tech Solutions', 'JURIDICA', '01.234.567/0001-89', 'Contribuinte ICMS', true, true, 'contato@techsolutions.com', '(11) 98765-4321', '11111111-1111-1111-1111-111111111111'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'João da Silva', 'Mercado do João', 'FISICA', '123.456.789-00', 'Não Contribuinte', true, false, 'joao.silva@email.com', '(21) 99876-5432', '22222222-2222-2222-2222-222222222222'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Global Supplies Inc', 'Global Supplies', 'JURIDICA', '98.765.432/0001-10', 'Contribuinte ICMS', false, true, 'supplies@global.com', '(41) 98888-7777', NULL),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Maria Oliveira', 'Loja da Maria', 'FISICA', '987.654.321-00', 'Contribuinte Isento (sem IE)', true, false, 'maria.oliveira@email.com', '(51) 97777-6666', '11111111-1111-1111-1111-111111111111'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Creative Design Studio', 'Creative Design', 'JURIDICA', '11.222.333/0001-44', 'Não Contribuinte', true, false, 'studio@creative.com', '(31) 96666-5555', '22222222-2222-2222-2222-222222222222');

-- Inserir Produtos
INSERT INTO public.produtos (id, tipo_produto, nome, codigo, origem, unidade, ncm, preco_venda, controlar_estoque, estoque_inicial, situacao) VALUES
('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'Simples', 'Mouse Gamer Pro X', 'MSE-PRO-X', '1 - Estrangeira (Importação Direta)', 'UN', '8471.60.53', 250.00, true, 100, 'Ativo'),
('e2e2e2e2-e2e2-e2e2-e2e2-e2e2e2e2e2e2', 'Simples', 'Teclado Mecânico RGB', 'TEC-MEC-RGB', '1 - Estrangeira (Importação Direta)', 'UN', '8471.60.52', 450.00, true, 50, 'Ativo'),
('f3f3f3f3-f3f3-f3f3-f3f3-f3f3f3f3f3f3', 'Simples', 'Monitor Ultrawide 34"', 'MON-UW-34', '2 - Estrangeira (Mercado Interno)', 'UN', '8528.52.20', 2800.00, true, 20, 'Ativo'),
('g4g4g4g4-g4g4-g4g4-g4g4-g4g4g4g4g4g4', 'Simples', 'Cadeira Gamer Ergonômica', 'CAD-GAMER-01', '0 - Nacional', 'UN', '9401.30.90', 1200.00, true, 30, 'Ativo'),
('h5h5h5h5-h5h5-h5h5-h5h5-h5h5h5h5h5h5', 'Matéria Prima', 'Resma de Papel A4', 'PAP-A4-500', '0 - Nacional', 'UN', '4802.56.10', 25.00, true, 500, 'Ativo');

-- Inserir Serviços
INSERT INTO public.servicos (id, descricao, codigo, preco, unidade, situacao) VALUES
('f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1', 'Instalação de Software', 'SERV-INST-SW', 150.00, 'HR', 'ATIVO'),
('f2f2f2f2-f2f2-f2f2-f2f2-f2f2f2f2f2f2', 'Manutenção Preventiva de PC', 'SERV-MAN-PC', 200.00, 'UN', 'ATIVO'),
('f3f3f3f3-f3f3-f3f3-f3f3-f3f3f3f3f3f3', 'Consultoria de TI (Hora)', 'SERV-CONS-TI', 350.00, 'HR', 'ATIVO');

-- Inserir Pedidos de Venda
INSERT INTO public.pedidos_venda (id, numero, cliente_id, vendedor_id, total_produtos, valor_total, data_venda, status, expedido) VALUES
('abcabcab-cabc-abca-bcab-cabcabcabcab', 'PV-001', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 700.00, 700.00, NOW() - INTERVAL '5 days', 'ABERTO', false),
('defdefde-fdef-defd-efde-fdefdefdefde', 'PV-002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 3250.00, 3250.00, NOW() - INTERVAL '3 days', 'FATURADO', true),
('12345678-1234-1234-1234-1234567890ab', 'PV-003', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 1200.00, 1200.00, NOW() - INTERVAL '1 day', 'ABERTO', false);

-- Inserir Itens nos Pedidos de Venda
INSERT INTO public.pedido_venda_itens (pedido_id, produto_id, descricao, quantidade, valor_unitario, valor_total) VALUES
('abcabcab-cabc-abca-bcab-cabcabcabcab', 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'Mouse Gamer Pro X', 1, 250.00, 250.00),
('abcabcab-cabc-abca-bcab-cabcabcabcab', 'e2e2e2e2-e2e2-e2e2-e2e2-e2e2e2e2e2e2', 'Teclado Mecânico RGB', 1, 450.00, 450.00),
('defdefde-fdef-defd-efde-fdefdefdefde', 'f3f3f3f3-f3f3-f3f3-f3f3-f3f3f3f3f3f3', 'Monitor Ultrawide 34"', 1, 2800.00, 2800.00),
('12345678-1234-1234-1234-1234567890ab', 'g4g4g4g4-g4g4-g4g4-g4g4-g4g4g4g4g4g4', 'Cadeira Gamer Ergonômica', 1, 1200.00, 1200.00);
INSERT INTO public.pedido_venda_itens (pedido_id, servico_id, descricao, quantidade, valor_unitario, valor_total) VALUES
('defdefde-fdef-defd-efde-fdefdefdefde', 'f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1', 'Instalação de Software', 3, 150.00, 450.00);

-- Inserir Faturas para Pedidos Faturados
INSERT INTO public.faturas_venda (id, pedido_id, numero_fatura, data_emissao, data_vencimento, valor_total, status) VALUES
('12312312-3123-1231-2312-312312312312', 'defdefde-fdef-defd-efde-fdefdefdefde', 'FAT-001', NOW() - INTERVAL '3 days', NOW() + INTERVAL '27 days', 3250.00, 'EMITIDA');

-- Inserir Contas a Receber
INSERT INTO public.contas_receber (fatura_id, cliente_id, descricao, valor, data_vencimento, status, ocorrencia) VALUES
('12312312-3123-1231-2312-312312312312', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Fatura FAT-001', 3250.00, NOW() + INTERVAL '27 days', 'A_RECEBER', 'Única'),
(NULL, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Serviço de Design - Parcela 1/2', 1500.00, NOW() - INTERVAL '5 days', 'VENCIDO', 'Recorrente');

-- Inserir Contas a Pagar
INSERT INTO public.contas_pagar (id, descricao, valor, data_vencimento, status, fornecedor_id, ocorrencia) VALUES
('c0c0c0c0-c0c0-c0c0-c0c0-c0c0c0c0c0c0', 'Aluguel Escritório', 2500.00, NOW() + INTERVAL '5 days', 'A_PAGAR', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Recorrente'),
('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'Compra de Materiais', 850.00, NOW() - INTERVAL '2 days', 'VENCIDO', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Única'),
('c2c2c2c2-c2c2-c2c2-c2c2-c2c2c2c2c2c2', 'Energia Elétrica', 450.00, NOW() + INTERVAL '10 days', 'A_PAGAR', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Recorrente');

-- Inserir Ordens de Serviço
INSERT INTO public.ordens_servico (id, numero, cliente_id, descricao_servico, data_inicio, status, prioridade, total_servicos) VALUES
('os1os1os-os1o-s1os-1os1-os1os1os1os1', 'OS-001', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Configuração de rede e servidores.', NOW() - INTERVAL '7 days', 'EM_ANDAMENTO', 'ALTA', 700.00),
('os2os2os-os2o-s2os-2os2-os2os2os2os2', 'OS-002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Troca de peças e formatação de notebook.', NOW() - INTERVAL '2 days', 'ABERTA', 'MEDIA', 200.00);

-- Inserir Itens nas Ordens de Serviço
INSERT INTO public.ordem_servico_itens (ordem_servico_id, servico_id, descricao, quantidade, preco, desconto, valor_total) VALUES
('os1os1os-os1o-s1os-1os1-os1os1os1os1', 'f3f3f3f3-f3f3-f3f3-f3f3-f3f3f3f3f3f3', 'Consultoria de TI (Hora)', 2, 350.00, 0, 700.00),
('os2os2os-os2o-s2os-2os2-os2os2os2os2', 'f2f2f2f2-f2f2-f2f2-f2f2-f2f2f2f2f2f2', 'Manutenção Preventiva de PC', 1, 200.00, 0, 200.00);

-- Liquidar uma conta a pagar para gerar fluxo de caixa
UPDATE public.contas_pagar SET status = 'PAGO', data_pagamento = NOW() WHERE id = 'c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1';

-- Liquidar uma conta a receber para gerar fluxo de caixa
UPDATE public.contas_receber SET status = 'RECEBIDO', data_pagamento = NOW() WHERE descricao = 'Serviço de Design - Parcela 1/2';
