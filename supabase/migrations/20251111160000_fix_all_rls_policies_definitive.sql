DO $$
DECLARE
    table_name TEXT;
    -- Lista das tabelas mais críticas para o funcionamento da aplicação.
    tables_to_fix TEXT[] := ARRAY[
        'clientes', 'pessoas_contato', 'cliente_anexos',
        'produtos', 'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
        'servicos', 'vendedores',
        'pedidos_venda', 'pedido_venda_itens',
        'faturas_venda', 'fatura_venda_itens',
        'contas_receber', 'contas_receber_anexos',
        'contas_pagar', 'contas_pagar_anexos',
        'fluxo_caixa',
        'categorias_financeiras',
        'formas_pagamento',
        'ordens_compra', 'ordem_compra_itens',
        'ordens_servico', 'ordem_servico_itens', 'ordem_servico_anexos',
        'contratos', 'contrato_anexos',
        'devolucoes_venda', 'devolucao_venda_itens',
        'notas_entrada', 'nota_entrada_itens',
        'configuracoes', 'comissoes', 'crm_oportunidades', 'embalagens', 'estoque_movimentos'
    ];
BEGIN
    FOREACH table_name IN ARRAY tables_to_fix
    LOOP
        BEGIN
            -- 1. Garante que o role 'authenticated' tenha permissões na tabela
            EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.' || quote_ident(table_name) || ' TO authenticated;';
            
            -- 2. Habilita a segurança em nível de linha (RLS)
            EXECUTE 'ALTER TABLE public.' || quote_ident(table_name) || ' ENABLE ROW LEVEL SECURITY;';
            
            -- 3. Remove a política antiga para evitar conflitos
            EXECUTE 'DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.' || quote_ident(table_name) || ';';
            
            -- 4. Cria uma política permissiva que concede acesso total a usuários autenticados
            EXECUTE 'CREATE POLICY "Permitir acesso total para usuários autenticados" ON public.' || quote_ident(table_name) || 
                    ' FOR ALL TO authenticated USING (true) WITH CHECK (true);';
        EXCEPTION
            WHEN undefined_table THEN
                RAISE WARNING 'Tabela não encontrada, pulando: %', table_name;
            WHEN OTHERS THEN
                RAISE WARNING 'Não foi possível corrigir a tabela %: %', table_name, SQLERRM;
        END;
    END LOOP;
END $$;
