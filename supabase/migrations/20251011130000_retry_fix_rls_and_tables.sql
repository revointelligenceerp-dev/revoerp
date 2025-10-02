DO $$
BEGIN
    -- 1. Garante que a tabela 'fatura_venda_itens' exista antes de aplicar as políticas.
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename  = 'fatura_venda_itens') THEN
        CREATE TABLE public.fatura_venda_itens (
            id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
            fatura_id uuid NOT NULL REFERENCES public.faturas_venda(id) ON DELETE CASCADE,
            produto_id uuid REFERENCES public.produtos(id),
            servico_id uuid REFERENCES public.servicos(id),
            descricao text NOT NULL,
            quantidade numeric(10,2) NOT NULL,
            valor_unitario numeric(10,2) NOT NULL,
            valor_total numeric(10,2) NOT NULL,
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            updated_at timestamp with time zone DEFAULT now() NOT NULL
        );
    END IF;

    -- 2. Itera sobre todas as tabelas no schema 'public' e aplica as políticas de segurança.
    DECLARE
        tbl_name TEXT;
    BEGIN
        FOR tbl_name IN
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = 'public'
        LOOP
            -- Habilita RLS para a tabela
            EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl_name);

            -- Apaga políticas antigas para garantir que não haja conflitos
            EXECUTE format('DROP POLICY IF EXISTS "Permite leitura para todos" ON public.%I;', tbl_name);
            EXECUTE format('DROP POLICY IF EXISTS "Permite acesso total para autenticados" ON public.%I;', tbl_name);

            -- Cria a política de leitura para usuários anônimos (e autenticados)
            EXECUTE format('CREATE POLICY "Permite leitura para todos" ON public.%I FOR SELECT USING (true);', tbl_name);
            
            -- Cria a política de acesso total para usuários autenticados
            EXECUTE format('CREATE POLICY "Permite acesso total para autenticados" ON public.%I FOR ALL USING (auth.role() = ''authenticated'') WITH CHECK (auth.role() = ''authenticated'');', tbl_name);
        END LOOP;
    END;
END $$;
