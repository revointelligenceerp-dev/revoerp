-- Step 1: Garantir que a tabela 'fatura_venda_itens' exista, corrigindo a falha anterior.
CREATE TABLE IF NOT EXISTS public.fatura_venda_itens (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    fatura_id uuid NOT NULL REFERENCES public.faturas_venda(id) ON DELETE CASCADE,
    produto_id uuid REFERENCES public.produtos(id) ON DELETE SET NULL,
    servico_id uuid REFERENCES public.servicos(id) ON DELETE SET NULL,
    descricao text NOT NULL,
    quantidade numeric(10,2) NOT NULL,
    valor_unitario numeric(12,2) NOT NULL,
    valor_total numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Step 2: Re-aplicar a configuração de segurança (RLS) de forma segura em todas as tabelas.
-- Este bloco é idempotente e seguro para ser re-executado.
DO $$
DECLARE
    tbl_name TEXT;
    -- Lista completa de tabelas que devem ter RLS
    tables_to_secure TEXT[] := ARRAY[
        'clientes', 'pessoas_contato', 'cliente_anexos', 
        'produtos', 'produto_imagens', 'produto_anuncios', 'produtos_fornecedores',
        'servicos', 'vendedores', 'embalagens', 
        'ordens_servico', 'ordem_servico_itens', 'ordem_servico_anexos',
        'pedidos_venda', 'pedido_venda_itens', 'pedido_venda_anexos',
        'faturas_venda', 'fatura_venda_itens', -- Agora a tabela existe
        'contas_receber', 'contas_receber_anexos',
        'contas_pagar', 'contas_pagar_anexos',
        'fluxo_caixa',
        'expedicoes', 'expedicao_pedidos',
        'ordens_compra', 'ordem_compra_itens', 'ordem_compra_anexos'
    ];
BEGIN
    -- Habilita RLS em todas as tabelas listadas
    FOREACH tbl_name IN ARRAY tables_to_secure
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(tbl_name) || ' ENABLE ROW LEVEL SECURITY;';
    END LOOP;

    -- Remove políticas antigas para evitar conflitos, se existirem
    FOREACH tbl_name IN ARRAY tables_to_secure
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "Permitir acesso de leitura a usuários anônimos" ON public.' || quote_ident(tbl_name) || ';';
        EXECUTE 'DROP POLICY IF EXISTS "Permitir acesso total a usuários autenticados" ON public.' || quote_ident(tbl_name) || ';';
    END LOOP;

    -- Cria políticas de LEITURA para usuários anônimos
    FOREACH tbl_name IN ARRAY tables_to_secure
    LOOP
        EXECUTE 'CREATE POLICY "Permitir acesso de leitura a usuários anônimos" ON public.' || quote_ident(tbl_name) || ' FOR SELECT TO anon USING (true);';
    END LOOP;

    -- Cria políticas de ACESSO TOTAL para usuários autenticados
    FOREACH tbl_name IN ARRAY tables_to_secure
    LOOP
        EXECUTE 'CREATE POLICY "Permitir acesso total a usuários autenticados" ON public.' || quote_ident(tbl_name) || ' FOR ALL TO authenticated USING (true);';
    END LOOP;
END $$;
