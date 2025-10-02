DO $$
BEGIN
    -- Adicionar colunas à tabela produtos se não existirem
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='marca') THEN
        ALTER TABLE public.produtos ADD COLUMN marca TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='tabela_medidas') THEN
        ALTER TABLE public.produtos ADD COLUMN tabela_medidas TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='link_video') THEN
        ALTER TABLE public.produtos ADD COLUMN link_video TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='slug') THEN
        ALTER TABLE public.produtos ADD COLUMN slug TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='keywords') THEN
        ALTER TABLE public.produtos ADD COLUMN keywords TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='titulo_seo') THEN
        ALTER TABLE public.produtos ADD COLUMN titulo_seo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='descricao_seo') THEN
        ALTER TABLE public.produtos ADD COLUMN descricao_seo TEXT;
    END IF;

    -- Criar tabela de imagens de produtos se não existir
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name='produto_imagens') THEN
        CREATE TABLE public.produto_imagens (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            produto_id UUID NOT NULL REFERENCES public.produtos(id) ON DELETE CASCADE,
            path TEXT NOT NULL,
            nome_arquivo TEXT NOT NULL,
            tamanho INT NOT NULL,
            tipo TEXT NOT NULL,
            created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
        );
        -- Adicionar RLS na nova tabela
        ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
        CREATE POLICY "Public access for produto_imagens" ON public.produto_imagens FOR ALL USING (true);
    END IF;

    -- Criar bucket de armazenamento de imagens de produtos se não existir
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id='produto-imagens') THEN
        INSERT INTO storage.buckets (id, name, public)
        VALUES ('produto-imagens', 'produto-imagens', true);

        CREATE POLICY "Public Read on produto-imagens"
        ON storage.objects FOR SELECT
        USING ( bucket_id = 'produto-imagens' );

        CREATE POLICY "Authenticated Insert on produto-imagens"
        ON storage.objects FOR INSERT
        WITH CHECK ( bucket_id = 'produto-imagens' );
        
        CREATE POLICY "Authenticated Update on produto-imagens"
        ON storage.objects FOR UPDATE
        USING ( bucket_id = 'produto-imagens' );

        CREATE POLICY "Authenticated Delete on produto-imagens"
        ON storage.objects FOR DELETE
        USING ( bucket_id = 'produto-imagens' );
    END IF;

    RAISE NOTICE 'Backend para Dados Complementares de Produtos está pronto.';
END $$;
