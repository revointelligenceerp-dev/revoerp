-- Garante que a tabela cliente_anexos exista
CREATE TABLE IF NOT EXISTS public.cliente_anexos (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    cliente_id uuid NOT NULL,
    nome_arquivo text NOT NULL,
    path text NOT NULL,
    tamanho bigint NOT NULL,
    tipo text NOT NULL,
    CONSTRAINT cliente_anexos_pkey PRIMARY KEY (id)
);

-- Adiciona a chave estrangeira SOMENTE SE ELA NÃO EXISTIR
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM   information_schema.table_constraints
        WHERE  constraint_name = 'cliente_anexos_cliente_id_fkey'
        AND    table_name = 'cliente_anexos'
    ) THEN
        ALTER TABLE public.cliente_anexos
        ADD CONSTRAINT cliente_anexos_cliente_id_fkey
        FOREIGN KEY (cliente_id)
        REFERENCES public.clientes(id)
        ON DELETE CASCADE;
    END IF;
END;
$$;

-- Garante que RLS esteja habilitada
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;

-- Remove e recria a política para garantir que esteja correta
DROP POLICY IF EXISTS "Permite acesso total para usuários autenticados (anexos)" ON public.cliente_anexos;
CREATE POLICY "Permite acesso total para usuários autenticados (anexos)"
ON public.cliente_anexos
FOR ALL
USING (true)
WITH CHECK (true);
