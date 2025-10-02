-- Remove a coluna 'codigo_barras' da tabela 'produtos' se ela existir.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'produtos'
        AND column_name = 'codigo_barras'
    ) THEN
        ALTER TABLE public.produtos DROP COLUMN codigo_barras;
    END IF;
END $$;
