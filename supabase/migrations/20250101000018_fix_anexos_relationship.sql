-- Garante que a tabela cliente_anexos exista
CREATE TABLE IF NOT EXISTS public.cliente_anexos (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    cliente_id uuid NOT NULL,
    nome_arquivo text NOT NULL,
    path text NOT NULL,
    tamanho bigint NOT NULL,
    tipo text NOT NULL,
    CONSTRAINT cliente_anexos_pkey PRIMARY KEY (id)
);

-- Adiciona a chave estrangeira se ela não existir
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'cliente_anexos_cliente_id_fkey'
    ) THEN
        ALTER TABLE public.cliente_anexos
        ADD CONSTRAINT cliente_anexos_cliente_id_fkey
        FOREIGN KEY (cliente_id)
        REFERENCES public.clientes(id)
        ON DELETE CASCADE;
    END IF;
END;
$$;

-- Garante que o RLS esteja habilitado
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;

-- Remove e recria a política para garantir que esteja correta
DROP POLICY IF EXISTS "Enable all access for authenticated users" ON public.cliente_anexos;
CREATE POLICY "Enable all access for authenticated users"
ON public.cliente_anexos
FOR ALL
USING (true)
WITH CHECK (true);
