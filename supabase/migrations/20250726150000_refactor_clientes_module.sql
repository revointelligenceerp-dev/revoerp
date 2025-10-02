-- Habilita a extensão para gerar UUIDs se ainda não estiver habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Adiciona novas colunas à tabela de clientes, se não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='codigo') THEN
        ALTER TABLE public.clientes ADD COLUMN codigo VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='tipo_pessoa') THEN
        ALTER TABLE public.clientes ADD COLUMN tipo_pessoa TEXT NOT NULL DEFAULT 'FISICA';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cpf_cnpj') THEN
        ALTER TABLE public.clientes ADD COLUMN cpf_cnpj VARCHAR(18);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='rg') THEN
        ALTER TABLE public.clientes ADD COLUMN rg VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='data_nascimento') THEN
        ALTER TABLE public.clientes ADD COLUMN data_nascimento DATE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_estadual') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_estadual VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_municipal') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_municipal VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='contribuinte_icms') THEN
        ALTER TABLE public.clientes ADD COLUMN contribuinte_icms TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='logradouro') THEN
        ALTER TABLE public.clientes ADD COLUMN logradouro VARCHAR(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='numero') THEN
        ALTER TABLE public.clientes ADD COLUMN numero VARCHAR(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='complemento') THEN
        ALTER TABLE public.clientes ADD COLUMN complemento VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='bairro') THEN
        ALTER TABLE public.clientes ADD COLUMN bairro VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cep') THEN
        ALTER TABLE public.clientes ADD COLUMN cep VARCHAR(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cidade') THEN
        ALTER TABLE public.clientes ADD COLUMN cidade VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='estado') THEN
        ALTER TABLE public.clientes ADD COLUMN estado VARCHAR(2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='pais') THEN
        ALTER TABLE public.clientes ADD COLUMN pais VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_logradouro') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_logradouro VARCHAR(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_numero') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_numero VARCHAR(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_complemento') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_complemento VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_bairro') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_bairro VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_cep') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_cep VARCHAR(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_cidade') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_cidade VARCHAR(50);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_estado') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_estado VARCHAR(2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='telefone_adicional') THEN
        ALTER TABLE public.clientes ADD COLUMN telefone_adicional VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='celular') THEN
        ALTER TABLE public.clientes ADD COLUMN celular VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='email_nfe') THEN
        ALTER TABLE public.clientes ADD COLUMN email_nfe VARCHAR(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='site') THEN
        ALTER TABLE public.clientes ADD COLUMN site VARCHAR(100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_cliente') THEN
        ALTER TABLE public.clientes ADD COLUMN is_cliente BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_fornecedor') THEN
        ALTER TABLE public.clientes ADD COLUMN is_fornecedor BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='is_transportadora') THEN
        ALTER TABLE public.clientes ADD COLUMN is_transportadora BOOLEAN DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='limite_credito') THEN
        ALTER TABLE public.clientes ADD COLUMN limite_credito NUMERIC(15, 2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='tabela_preco_padrao_id') THEN
        ALTER TABLE public.clientes ADD COLUMN tabela_preco_padrao_id UUID;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='situacao_cliente') THEN
        ALTER TABLE public.clientes ADD COLUMN situacao_cliente TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='condicao_pagamento_padrao_id') THEN
        ALTER TABLE public.clientes ADD COLUMN condicao_pagamento_padrao_id UUID;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='prazo_medio_entrega_dias') THEN
        ALTER TABLE public.clientes ADD COLUMN prazo_medio_entrega_dias INTEGER;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='categoria_despesa_padrao_id') THEN
        ALTER TABLE public.clientes ADD COLUMN categoria_despesa_padrao_id UUID;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='placa_veiculo') THEN
        ALTER TABLE public.clientes ADD COLUMN placa_veiculo VARCHAR(10);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='uf_placa') THEN
        ALTER TABLE public.clientes ADD COLUMN uf_placa VARCHAR(2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='registro_antt') THEN
        ALTER TABLE public.clientes ADD COLUMN registro_antt VARCHAR(20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='observacoes_frete') THEN
        ALTER TABLE public.clientes ADD COLUMN observacoes_frete TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='observacoes') THEN
        ALTER TABLE public.clientes ADD COLUMN observacoes TEXT;
    END IF;
END $$;

-- Migra dados da coluna 'documento' para 'cpf_cnpj'
UPDATE public.clientes SET cpf_cnpj = documento WHERE documento IS NOT NULL AND cpf_cnpj IS NULL;
-- Migra dados da coluna 'telefone' para 'celular' se 'celular' estiver vazio
UPDATE public.clientes SET celular = telefone WHERE telefone IS NOT NULL AND celular IS NULL;

-- Remove a coluna 'documento' se ela existir
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='clientes' AND column_name='documento') THEN
        ALTER TABLE public.clientes DROP COLUMN documento;
    END IF;
END $$;

-- Cria a tabela de pessoas de contato, se não existir
CREATE TABLE IF NOT EXISTS public.pessoas_contato (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    setor VARCHAR(50),
    ramal VARCHAR(10),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cria a tabela de anexos de cliente, se não existir
CREATE TABLE IF NOT EXISTS public.cliente_anexos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL,
    path TEXT NOT NULL,
    tamanho BIGINT NOT NULL,
    tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cria o bucket de armazenamento para anexos, se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('cliente-anexos', 'cliente-anexos', true)
ON CONFLICT (id) DO NOTHING;

-- Adiciona índices para otimização de buscas
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_pessoas_contato_cliente_id ON public.pessoas_contato(cliente_id);
CREATE INDEX IF NOT EXISTS idx_cliente_anexos_cliente_id ON public.cliente_anexos(cliente_id);
