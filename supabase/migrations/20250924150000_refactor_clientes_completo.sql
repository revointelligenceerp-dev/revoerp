-- Garantir a existência da tabela pessoas_contato
CREATE TABLE IF NOT EXISTS public.pessoas_contato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    setor TEXT,
    email TEXT,
    telefone TEXT,
    ramal TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Garantir a existência da tabela cliente_anexos
CREATE TABLE IF NOT EXISTS public.cliente_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT,
    tipo TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Adicionar colunas na tabela clientes, se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='codigo') THEN
        ALTER TABLE public.clientes ADD COLUMN codigo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='tipo_pessoa') THEN
        ALTER TABLE public.clientes ADD COLUMN tipo_pessoa TEXT NOT NULL DEFAULT 'FISICA';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='rg') THEN
        ALTER TABLE public.clientes ADD COLUMN rg TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_estadual') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_estadual TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_municipal') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_municipal TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='contribuinte_icms') THEN
        ALTER TABLE public.clientes ADD COLUMN contribuinte_icms TEXT NOT NULL DEFAULT 'NAO_CONTRIBUINTE';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_logradouro') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_logradouro TEXT;
        ALTER TABLE public.clientes ADD COLUMN cobranca_numero TEXT;
        ALTER TABLE public.clientes ADD COLUMN cobranca_complemento TEXT;
        ALTER TABLE public.clientes ADD COLUMN cobranca_bairro TEXT;
        ALTER TABLE public.clientes ADD COLUMN cobranca_cep TEXT;
        ALTER TABLE public.clientes ADD COLUMN cobranca_cidade TEXT;
        ALTER TABLE public.clientes ADD COLUMN cobranca_estado TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='telefone_adicional') THEN
        ALTER TABLE public.clientes ADD COLUMN telefone_adicional TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='email_nfe') THEN
        ALTER TABLE public.clientes ADD COLUMN email_nfe TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='site') THEN
        ALTER TABLE public.clientes ADD COLUMN site TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_cliente') THEN
        ALTER TABLE public.clientes ADD COLUMN is_cliente BOOLEAN DEFAULT true;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_fornecedor') THEN
        ALTER TABLE public.clientes ADD COLUMN is_fornecedor BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_transportadora') THEN
        ALTER TABLE public.clientes ADD COLUMN is_transportadora BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='estado_civil') THEN
        ALTER TABLE public.clientes ADD COLUMN estado_civil TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='profissao') THEN
        ALTER TABLE public.clientes ADD COLUMN profissao TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='sexo') THEN
        ALTER TABLE public.clientes ADD COLUMN sexo TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='data_nascimento') THEN
        ALTER TABLE public.clientes ADD COLUMN data_nascimento DATE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='naturalidade') THEN
        ALTER TABLE public.clientes ADD COLUMN naturalidade TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='status_crm') THEN
        ALTER TABLE public.clientes ADD COLUMN status_crm TEXT;
    END IF;
     IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='condicao_pagamento_id') THEN
        ALTER TABLE public.clientes ADD COLUMN condicao_pagamento_id TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='limite_credito') THEN
        ALTER TABLE public.clientes ADD COLUMN limite_credito NUMERIC(12, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='observacoes') THEN
        ALTER TABLE public.clientes ADD COLUMN observacoes TEXT;
    END IF;
END $$;

-- Garantir a existência do bucket de anexos
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'cliente-anexos') THEN
        INSERT INTO storage.buckets (id, name, public)
        VALUES ('cliente-anexos', 'cliente-anexos', true);
    END IF;
    RAISE NOTICE 'Bucket "cliente-anexos" garantido.';
END $$;
