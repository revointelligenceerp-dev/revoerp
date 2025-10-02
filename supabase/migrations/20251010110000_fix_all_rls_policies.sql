-- This script enables Row Level Security (RLS) for all tables and sets up basic policies.
-- It allows public read-only access (for anonymous users) and full access for authenticated users.
-- This is a foundational security step.

BEGIN;

-- List of all tables managed by the application
DO $$
DECLARE
    table_name TEXT;
    tables TEXT[] := ARRAY[
        'clientes', 'pessoas_contato', 'cliente_anexos',
        'produtos', 'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
        'servicos', 'vendedores', 'embalagens',
        'ordens_servico', 'ordem_servico_itens', 'ordem_servico_anexos',
        'pedidos_venda', 'pedido_venda_itens', 'pedido_venda_anexos',
        'faturas_venda', 'fatura_venda_itens',
        'contas_receber', 'contas_receber_anexos',
        'contas_pagar', 'contas_pagar_anexos',
        'fluxo_caixa',
        'expedicoes', 'expedicao_pedidos',
        'ordens_compra', 'ordem_compra_itens', 'ordem_compra_anexos'
    ];
BEGIN
    FOREACH table_name IN ARRAY tables
    LOOP
        -- Enable RLS for the table if it's not already enabled
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_name);

        -- Drop existing policies to ensure a clean state
        EXECUTE format('DROP POLICY IF EXISTS "Allow public read access" ON public.%I;', table_name);
        EXECUTE format('DROP POLICY IF EXISTS "Allow authenticated users full access" ON public.%I;', table_name);

        -- Create a policy for public read-only access
        EXECUTE format('CREATE POLICY "Allow public read access" ON public.%I FOR SELECT USING (true);', table_name);

        -- Create a policy for full access for authenticated users
        EXECUTE format('CREATE POLICY "Allow authenticated users full access" ON public.%I FOR ALL USING (auth.role() = ''authenticated'') WITH CHECK (auth.role() = ''authenticated'');', table_name);
        
        RAISE NOTICE 'RLS enabled and policies created for table %', table_name;
    END LOOP;
END $$;

COMMIT;
