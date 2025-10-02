DO $$
DECLARE
    -- Declare arrays to hold existing IDs
    cliente_ids UUID[];
    vendedor_ids UUID[];
    produto_ids UUID[];
    servico_ids UUID[];

    -- Declare variables for the loop
    pedido_id_var UUID;
    cliente_id_var UUID;
    vendedor_id_var UUID;
    produto_id_var UUID;
    servico_id_var UUID;
    item_preco NUMERIC;
    item_qtd INTEGER;
    total_pedido NUMERIC;
BEGIN
    -- Check if the table is already populated
    IF EXISTS (SELECT 1 FROM public.pedidos_venda) THEN
        RAISE NOTICE 'A tabela pedidos_venda já contém dados. Nenhuma ação foi tomada.';
        RETURN;
    END IF;

    -- Populate the ID arrays
    SELECT array_agg(id) INTO cliente_ids FROM public.clientes;
    SELECT array_agg(id) INTO vendedor_ids FROM public.vendedores;
    SELECT array_agg(id) INTO produto_ids FROM public.produtos;
    SELECT array_agg(id) INTO servico_ids FROM public.servicos;

    -- Check if there are dependent entities
    IF array_length(cliente_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'Não há clientes cadastrados para criar pedidos.';
    END IF;
    IF array_length(produto_ids, 1) IS NULL AND array_length(servico_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'Não há produtos ou serviços cadastrados para criar itens de pedido.';
    END IF;

    -- Loop to create 5 orders
    FOR i IN 1..5 LOOP
        -- Reset total for each order
        total_pedido := 0;

        -- Select a random client and vendor
        cliente_id_var := cliente_ids[1 + floor(random() * array_length(cliente_ids, 1))];
        IF array_length(vendedor_ids, 1) IS NOT NULL THEN
            vendedor_id_var := vendedor_ids[1 + floor(random() * array_length(vendedor_ids, 1))];
        ELSE
            vendedor_id_var := NULL;
        END IF;

        -- Insert the main order record and get its ID
        INSERT INTO public.pedidos_venda (numero, cliente_id, vendedor_id, status, data_emissao, valor_total)
        VALUES (
            'PV-' || (1000 + i),
            cliente_id_var,
            vendedor_id_var,
            'ABERTO',
            NOW() - (i || ' days')::interval,
            0 -- Temporary value, will be updated later
        ) RETURNING id INTO pedido_id_var;

        -- Loop to create 2-4 items for each order
        FOR j IN 1.. (2 + floor(random() * 3)) LOOP
            item_qtd := 1 + floor(random() * 5);

            -- Randomly choose between a product or a service
            IF random() > 0.5 AND array_length(produto_ids, 1) IS NOT NULL THEN
                -- Add a product
                produto_id_var := produto_ids[1 + floor(random() * array_length(produto_ids, 1))];
                SELECT preco INTO item_preco FROM public.produtos WHERE id = produto_id_var;

                INSERT INTO public.pedido_venda_itens (pedido_id, produto_id, descricao, quantidade, valor_unitario, valor_total)
                SELECT
                    pedido_id_var,
                    p.id,
                    p.nome,
                    item_qtd,
                    p.preco,
                    p.preco * item_qtd
                FROM public.produtos p WHERE p.id = produto_id_var;

                total_pedido := total_pedido + (item_preco * item_qtd);

            ELSIF array_length(servico_ids, 1) IS NOT NULL THEN
                -- Add a service
                servico_id_var := servico_ids[1 + floor(random() * array_length(servico_ids, 1))];
                SELECT preco INTO item_preco FROM public.servicos WHERE id = servico_id_var;

                INSERT INTO public.pedido_venda_itens (pedido_id, servico_id, descricao, quantidade, valor_unitario, valor_total)
                SELECT
                    pedido_id_var,
                    s.id,
                    s.nome,
                    item_qtd,
                    s.preco,
                    s.preco * item_qtd
                FROM public.servicos s WHERE s.id = servico_id_var;

                total_pedido := total_pedido + (item_preco * item_qtd);
            END IF;
        END LOOP;

        -- Update the total value of the order
        UPDATE public.pedidos_venda
        SET valor_total = total_pedido
        WHERE id = pedido_id_var;

    END LOOP;
END $$;
