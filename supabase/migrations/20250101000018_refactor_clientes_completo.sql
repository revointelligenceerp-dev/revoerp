-- Garante a existência da tabela pessoas_contato
CREATE TABLE IF NOT EXISTS public.pessoas_contato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    setor VARCHAR(50),
    email VARCHAR(100),
    telefone VARCHAR(40),
    ramal VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Garante a existência da tabela cliente_anexos
CREATE TABLE IF NOT EXISTS public.cliente_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome_arquivo VARCHAR(255) NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT,
    tipo VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Adiciona colunas à tabela clientes, se não existirem
DO $$
BEGIN
    -- Aba Dados Gerais
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='codigo') THEN
        ALTER TABLE public.clientes ADD COLUMN codigo VARCHAR(20);
        RAISE NOTICE 'Coluna "codigo" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='tipo_pessoa') THEN
        ALTER TABLE public.clientes ADD COLUMN tipo_pessoa VARCHAR(20) DEFAULT 'FISICA';
        RAISE NOTICE 'Coluna "tipo_pessoa" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='rg') THEN
        ALTER TABLE public.clientes ADD COLUMN rg VARCHAR(20);
        RAISE NOTICE 'Coluna "rg" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_estadual') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_estadual VARCHAR(20);
        RAISE NOTICE 'Coluna "inscricao_estadual" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_municipal') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_municipal VARCHAR(20);
        RAISE NOTICE 'Coluna "inscricao_municipal" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='contribuinte_icms') THEN
        ALTER TABLE public.clientes ADD COLUMN contribuinte_icms VARCHAR(50) DEFAULT 'NAO_CONTRIBUINTE';
        RAISE NOTICE 'Coluna "contribuinte_icms" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_cliente') THEN
        ALTER TABLE public.clientes ADD COLUMN is_cliente BOOLEAN DEFAULT TRUE;
        RAISE NOTICE 'Coluna "is_cliente" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_fornecedor') THEN
        ALTER TABLE public.clientes ADD COLUMN is_fornecedor BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Coluna "is_fornecedor" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_transportadora') THEN
        ALTER TABLE public.clientes ADD COLUMN is_transportadora BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Coluna "is_transportadora" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_cep') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_cep VARCHAR(10);
        RAISE NOTICE 'Coluna "cobranca_cep" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_logradouro') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_logradouro VARCHAR(100);
        RAISE NOTICE 'Coluna "cobranca_logradouro" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_numero') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_numero VARCHAR(20);
        RAISE NOTICE 'Coluna "cobranca_numero" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_complemento') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_complemento VARCHAR(100);
        RAISE NOTICE 'Coluna "cobranca_complemento" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_bairro') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_bairro VARCHAR(50);
        RAISE NOTICE 'Coluna "cobranca_bairro" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_cidade') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_cidade VARCHAR(50);
        RAISE NOTICE 'Coluna "cobranca_cidade" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_estado') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_estado VARCHAR(2);
        RAISE NOTICE 'Coluna "cobranca_estado" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='telefone_adicional') THEN
        ALTER TABLE public.clientes ADD COLUMN telefone_adicional VARCHAR(40);
        RAISE NOTICE 'Coluna "telefone_adicional" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='site') THEN
        ALTER TABLE public.clientes ADD COLUMN site VARCHAR(100);
        RAISE NOTICE 'Coluna "site" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='email_nfe') THEN
        ALTER TABLE public.clientes ADD COLUMN email_nfe VARCHAR(100);
        RAISE NOTICE 'Coluna "email_nfe" adicionada.';
    END IF;

    -- Aba Dados Complementares
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='estado_civil') THEN
        ALTER TABLE public.clientes ADD COLUMN estado_civil VARCHAR(50);
        RAISE NOTICE 'Coluna "estado_civil" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='profissao') THEN
        ALTER TABLE public.clientes ADD COLUMN profissao VARCHAR(100);
        RAISE NOTICE 'Coluna "profissao" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='sexo') THEN
        ALTER TABLE public.clientes ADD COLUMN sexo VARCHAR(20);
        RAISE NOTICE 'Coluna "sexo" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='data_nascimento') THEN
        ALTER TABLE public.clientes ADD COLUMN data_nascimento DATE;
        RAISE NOTICE 'Coluna "data_nascimento" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='naturalidade') THEN
        ALTER TABLE public.clientes ADD COLUMN naturalidade VARCHAR(100);
        RAISE NOTICE 'Coluna "naturalidade" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='status_crm') THEN
        ALTER TABLE public.clientes ADD COLUMN status_crm VARCHAR(50);
        RAISE NOTICE 'Coluna "status_crm" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='vendedor_id') THEN
        ALTER TABLE public.clientes ADD COLUMN vendedor_id UUID REFERENCES public.vendedores(id);
        RAISE NOTICE 'Coluna "vendedor_id" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='condicao_pagamento_id') THEN
        ALTER TABLE public.clientes ADD COLUMN condicao_pagamento_id UUID; -- Adicionar FK quando a tabela existir
        RAISE NOTICE 'Coluna "condicao_pagamento_id" adicionada.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='limite_credito') THEN
        ALTER TABLE public.clientes ADD COLUMN limite_credito NUMERIC(15, 2);
        RAISE NOTICE 'Coluna "limite_credito" adicionada.';
    END IF;

    -- Aba Observações
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='observacoes') THEN
        ALTER TABLE public.clientes ADD COLUMN observacoes TEXT;
        RAISE NOTICE 'Coluna "observacoes" adicionada.';
    END IF;
END $$;

-- Garante o bucket de anexos
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'cliente-anexos') THEN
        INSERT INTO storage.buckets (id, name, public)
        VALUES ('cliente-anexos', 'cliente-anexos', true);
        RAISE NOTICE 'Bucket "cliente-anexos" criado.';
    ELSE
        RAISE NOTICE 'Bucket "cliente-anexos" já existe.';
    END IF;
END $$;
