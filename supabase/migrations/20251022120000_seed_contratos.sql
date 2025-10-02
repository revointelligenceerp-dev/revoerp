DO $$
DECLARE
    cliente1_id uuid;
    cliente2_id uuid;
BEGIN
    -- Seleciona os IDs dos clientes existentes para usar nos contratos
    SELECT id INTO cliente1_id FROM public.clientes WHERE nome = 'Empresa de Tecnologia Inovadora S.A.' LIMIT 1;
    SELECT id INTO cliente2_id FROM public.clientes WHERE nome = 'Soluções Criativas Ltda.' LIMIT 1;

    -- Garante que os clientes foram encontrados antes de inserir
    IF cliente1_id IS NOT NULL AND cliente2_id IS NOT NULL THEN
        -- Insere os contratos apenas se a tabela estiver vazia para evitar duplicatas
        IF NOT EXISTS (SELECT 1 FROM public.contratos) THEN
            INSERT INTO public.contratos (cliente_id, descricao, situacao, data_contrato, valor, vencimento_regra, dia_vencimento, periodicidade, emitir_nf)
            VALUES
                (cliente1_id, 'Contrato de Suporte Técnico Mensal', 'Ativo', '2024-01-15', 1500.00, 'No mês corrente', 10, 'Mensal', true),
                (cliente2_id, 'Licença de Software Anual - ERP Completo', 'Ativo', '2023-11-20', 12000.00, 'No mês corrente', 15, 'Anual', true),
                (cliente1_id, 'Consultoria de SEO Trimestral', 'Inativo', '2023-05-01', 4500.00, 'No mês seguinte', 5, 'Trimestral', false),
                (cliente2_id, 'Hospedagem de Site Premium', 'Ativo', '2024-03-10', 350.00, 'No mês corrente', 20, 'Mensal', false),
                (cliente1_id, 'Manutenção de Servidores Dedicados', 'Demonstração', '2024-06-01', 2500.00, 'No mês corrente', 1, 'Mensal', true),
                (cliente2_id, 'Contrato de Desenvolvimento de App Mobile', 'Encerrado', '2022-08-01', 85000.00, 'No mês corrente', 25, 'Mensal', true);
        END IF;
    ELSE
        RAISE NOTICE 'Clientes de exemplo não encontrados. Nenhum contrato foi inserido.';
    END IF;
END $$;
