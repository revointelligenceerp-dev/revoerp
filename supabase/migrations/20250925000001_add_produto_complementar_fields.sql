-- Adiciona novos campos à tabela de produtos se eles não existirem
DO $$
BEGIN
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
        -- Adiciona um índice único para o slug, se ele ainda não existir
        IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'produtos_slug_key') THEN
            ALTER TABLE public.produtos ADD CONSTRAINT produtos_slug_key UNIQUE (slug);
        END IF;
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
END $$;

-- Cria a tabela para armazenar as imagens dos produtos, se ela não existir
CREATE TABLE IF NOT EXISTS public.produto_imagens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    produto_id UUID REFERENCES public.produtos(id) ON DELETE CASCADE,
    path TEXT NOT NULL,
    nome_arquivo TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Adiciona um índice na chave estrangeira para otimizar as buscas
CREATE INDEX IF NOT EXISTS idx_produto_imagens_produto_id ON public.produto_imagens(produto_id);

-- Cria o bucket de armazenamento para as imagens dos produtos, se ele não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('produto-imagens', 'produto-imagens', true)
ON CONFLICT (id) DO NOTHING;

-- Define as políticas de segurança para o bucket (permite acesso público para leitura)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.policies WHERE policyname = 'Public Read on produto-imagens') THEN
        CREATE POLICY "Public Read on produto-imagens"
        ON storage.objects FOR SELECT
        USING ( bucket_id = 'produto-imagens' );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM storage.policies WHERE policyname = 'Authenticated Insert on produto-imagens') THEN
        CREATE POLICY "Authenticated Insert on produto-imagens"
        ON storage.objects FOR INSERT
        TO authenticated
        WITH CHECK ( bucket_id = 'produto-imagens' );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM storage.policies WHERE policyname = 'Authenticated Update on produto-imagens') THEN
        CREATE POLICY "Authenticated Update on produto-imagens"
        ON storage.objects FOR UPDATE
        TO authenticated
        USING ( bucket_id = 'produto-imagens' );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM storage.policies WHERE policyname = 'Authenticated Delete on produto-imagens') THEN
        CREATE POLICY "Authenticated Delete on produto-imagens"
        ON storage.objects FOR DELETE
        TO authenticated
        USING ( bucket_id = 'produto-imagens' );
    END IF;
END $$;
