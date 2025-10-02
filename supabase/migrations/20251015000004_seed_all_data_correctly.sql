/*
          # [CORREÇÃO E POPULAÇÃO DE DADOS]
          Este script insere dados de exemplo em todas as tabelas principais,
          corrigindo o erro de UUID inválido da migração anterior.
          Ele utiliza um bloco PL/pgSQL para garantir a integridade referencial entre as tabelas.

          ## Query Description: [Este script irá inserir dados de exemplo em seu banco de dados. Ele foi projetado para ser executado em um ambiente de desenvolvimento limpo e não deve causar perda de dados se as tabelas já estiverem vazias. No entanto, se houver dados existentes, podem ocorrer conflitos de chave única. Recomenda-se executar em um banco de dados recém-criado pela migração anterior.]
          
          ## Metadata:
          - Schema-Category: ["Data"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          
          ## Structure Details:
          - Insere dados nas tabelas: vendedores, clientes, produtos, servicos, pedidos_venda, contas_receber, contas_pagar, etc.
          
          ## Security Implications:
          - RLS Status: [N/A]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Leve, apenas inserção de dados de teste.]
*/
DO $$
DECLARE
    -- IDs de Vendedores
    vendedor_carlos_id UUID;
    vendedor_ana_id UUID;

    -- IDs de Clientes/Fornecedores
    cliente_tech_solutions_id UUID;
    cliente_design_inovador_id UUID;
    fornecedor_global_parts_id UUID;

    -- IDs de Produtos
    produto_teclado_id UUID;
    produto_mouse_id UUID;
    produto_monitor_id UUID;

    -- IDs de Serviços
    servico_consultoria_id UUID;
    servico_manutencao_id UUID;

    -- IDs de Pedidos
    pedido_venda_1_id UUID;
    pedido_venda_2_id UUID;

    -- IDs de Faturas
    fatura_1_id UUID;

BEGIN
    -- INSERIR VENDEDORES
    INSERT INTO public.vendedores (nome, tipo_pessoa, contribuinte, situacao, regra_liberacao_comissao, tipo_comissao, email, cpf_cnpj, aliquota_comissao) VALUES
    ('Carlos Silva', 'Física', 'Não Contribuinte', 'Ativo com acesso ao sistema', 'Liberação parcial (pelo pagamento)', 'Comissão com alíquota fixa', 'carlos.silva@revo.erp', '111.222.333-44', 5) RETURNING id INTO vendedor_carlos_id;
    
    INSERT INTO public.vendedores (nome, tipo_pessoa, contribuinte, situacao, regra_liberacao_comissao, tipo_comissao, email, cpf_cnpj, aliquota_comissao) VALUES
    ('Ana Pereira', 'Física', 'Não Contribuinte', 'Ativo com acesso ao sistema', 'Liberação total (no faturamento)', 'Comissão com alíquota fixa', 'ana.pereira@revo.erp', '555.666.777-88', 7) RETURNING id INTO vendedor_ana_id;

    -- INSERIR CLIENTES E FORNECEDORES
    INSERT INTO public.clientes (nome, nome_fantasia, tipo_pessoa, cpf_cnpj, contribuinte_icms, is_cliente, is_fornecedor, email, vendedor_id) VALUES
    ('Tech Solutions Ltda', 'Tech Solutions', 'JURIDICA', '12.345.678/0001-99', 'Contribuinte ICMS', true, false, 'contato@techsolutions.com', vendedor_carlos_id) RETURNING id INTO cliente_tech_solutions_id;

    INSERT INTO public.clientes (nome, nome_fantasia, tipo_pessoa, cpf_cnpj, contribuinte_icms, is_cliente, is_fornecedor, email, vendedor_id) VALUES
    ('Design Inovador EIRELI', 'Design Inovador', 'JURIDICA', '98.765.432/0001-11', 'Não Contribuinte', true, false, 'contato@designinovador.com', vendedor_ana_id) RETURNING id INTO cliente_design_inovador_id;

    INSERT INTO public.clientes (nome, nome_fantasia, tipo_pessoa, cpf_cnpj, contribuinte_icms, is_cliente, is_fornecedor, email) VALUES
    ('Global Parts S.A.', 'Global Parts', 'JURIDICA', '11.222.333/0001-44', 'Contribuinte ICMS', false, true, 'vendas@globalparts.com') RETURNING id INTO fornecedor_global_parts_id;

    -- INSERIR PRODUTOS
    INSERT INTO public.produtos (tipo_produto, nome, codigo, origem, unidade, ncm, preco_venda, controlar_estoque, estoque_inicial, situacao) VALUES
    ('Simples', 'Teclado Mecânico Gamer RGB', 'TEC-RGB-001', '1 - Estrangeira (Importação Direta)', 'UN', '8471.60.52', 350.00, true, 50, 'Ativo') RETURNING id INTO produto_teclado_id;

    INSERT INTO public.produtos (tipo_produto, nome, codigo, origem, unidade, ncm, preco_venda, controlar_estoque, estoque_inicial, situacao) VALUES
    ('Simples', 'Mouse Gamer Pro X', 'MSE-PRO-X', '2 - Estrangeira (Mercado Interno)', 'UN', '8471.60.53', 250.00, true, 100, 'Ativo') RETURNING id INTO produto_mouse_id;

    INSERT INTO public.produtos (tipo_produto, nome, codigo, origem, unidade, ncm, preco_venda, controlar_estoque, estoque_inicial, situacao) VALUES
    ('Simples', 'Monitor UltraWide 34"', 'MON-UW-34', '0 - Nacional', 'UN', '8528.52.20', 2800.00, true, 20, 'Ativo') RETURNING id INTO produto_monitor_id;

    -- INSERIR SERVIÇOS
    INSERT INTO public.servicos (descricao, codigo, preco, unidade, situacao) VALUES
    ('Consultoria em TI', 'SERV-CONS-TI', 150.00, 'HORA', 'ATIVO') RETURNING id INTO servico_consultoria_id;

    INSERT INTO public.servicos (descricao, codigo, preco, unidade, situacao) VALUES
    ('Manutenção Preventiva de Servidores', 'SERV-MAN-PREV', 800.00, 'MENSAL', 'ATIVO') RETURNING id INTO servico_manutencao_id;

    -- INSERIR PEDIDO DE VENDA 1
    INSERT INTO public.pedidos_venda (numero, cliente_id, vendedor_id, total_produtos, valor_total, data_venda, status, expedido) VALUES
    ('PV-00001', cliente_tech_solutions_id, vendedor_carlos_id, 600.00, 600.00, '2025-10-01', 'ABERTO', false) RETURNING id INTO pedido_venda_1_id;

    INSERT INTO public.pedido_venda_itens (pedido_id, produto_id, descricao, quantidade, valor_unitario, valor_total) VALUES
    (pedido_venda_1_id, produto_teclado_id, 'Teclado Mecânico Gamer RGB', 1, 350.00, 350.00),
    (pedido_venda_1_id, produto_mouse_id, 'Mouse Gamer Pro X', 1, 250.00, 250.00);

    -- INSERIR PEDIDO DE VENDA 2 (FATURADO)
    INSERT INTO public.pedidos_venda (numero, cliente_id, vendedor_id, total_produtos, valor_total, data_venda, status, expedido) VALUES
    ('PV-00002', cliente_design_inovador_id, vendedor_ana_id, 300.00, 300.00, '2025-09-15', 'FATURADO', true) RETURNING id INTO pedido_venda_2_id;

    INSERT INTO public.pedido_venda_itens (pedido_id, servico_id, descricao, quantidade, valor_unitario, valor_total) VALUES
    (pedido_venda_2_id, servico_consultoria_id, 'Consultoria em TI', 2, 150.00, 300.00);

    -- INSERIR FATURA E CONTA A RECEBER (DO PEDIDO 2)
    INSERT INTO public.faturas_venda (pedido_id, numero_fatura, data_emissao, data_vencimento, valor_total, status) VALUES
    (pedido_venda_2_id, 'FAT-00001', '2025-09-16', '2025-10-16', 300.00, 'EMITIDA') RETURNING id INTO fatura_1_id;

    INSERT INTO public.contas_receber (fatura_id, cliente_id, descricao, valor, data_vencimento, status, ocorrencia) VALUES
    (fatura_1_id, cliente_design_inovador_id, 'Referente à Fatura FAT-00001', 300.00, '2025-10-16', 'A_RECEBER', 'Única');
    
    -- INSERIR CONTA A PAGAR
    INSERT INTO public.contas_pagar (descricao, valor, data_vencimento, status, fornecedor_id, ocorrencia, competencia) VALUES
    ('Compra de Peças', 450.00, '2025-10-20', 'A_PAGAR', fornecedor_global_parts_id, 'Única', '2025-10');

    INSERT INTO public.contas_pagar (descricao, valor, data_vencimento, data_pagamento, status, fornecedor_id, ocorrencia, competencia) VALUES
    ('Assinatura Software', 120.00, '2025-09-10', '2025-09-09', 'PAGO', fornecedor_global_parts_id, 'Recorrente', '2025-09');

    -- INSERIR MOVIMENTAÇÃO DE CAIXA (DA CONTA PAGA)
    INSERT INTO public.fluxo_caixa (data, descricao, valor, tipo) VALUES
    ('2025-09-09', 'Pagamento Assinatura Software', 120.00, 'SAIDA');

END $$;
