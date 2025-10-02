-- Migration para a refatoração completa do Cadastro de Clientes

DO $$
BEGIN
    RAISE NOTICE 'Iniciando a migração completa do módulo de clientes...';

    -- Adiciona a coluna codigo se não existir
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='codigo') THEN
        ALTER TABLE public.clientes ADD COLUMN codigo VARCHAR(20);
        RAISE NOTICE 'Coluna "codigo" adicionada a clientes.';
    END IF;

    -- Adiciona a coluna tipo_pessoa se não existir
    IF NOT EXISTS (SELECT FROM pg_type WHERE typname = 'tipo_pessoa_enum') THEN
        CREATE TYPE public.tipo_pessoa_enum AS ENUM ('FISICA', 'JURIDICA', 'ESTRANGEIRO');
        RAISE NOTICE 'Tipo "tipo_pessoa_enum" criado.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='tipo_pessoa') THEN
        ALTER TABLE public.clientes ADD COLUMN tipo_pessoa public.tipo_pessoa_enum NOT NULL DEFAULT 'FISICA';
        RAISE NOTICE 'Coluna "tipo_pessoa" adicionada a clientes.';
    END IF;

    -- Adiciona a coluna rg se não existir
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='rg') THEN
        ALTER TABLE public.clientes ADD COLUMN rg VARCHAR(20);
        RAISE NOTICE 'Coluna "rg" adicionada a clientes.';
    END IF;

    -- Adiciona a coluna data_nascimento se não existir
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='data_nascimento') THEN
        ALTER TABLE public.clientes ADD COLUMN data_nascimento DATE;
        RAISE NOTICE 'Coluna "data_nascimento" adicionada a clientes.';
    END IF;

    -- Adiciona a coluna inscricao_estadual se não existir
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_estadual') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_estadual VARCHAR(20);
        RAISE NOTICE 'Coluna "inscricao_estadual" adicionada a clientes.';
    END IF;

    -- Adiciona a coluna inscricao_municipal se não existir
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='inscricao_municipal') THEN
        ALTER TABLE public.clientes ADD COLUMN inscricao_municipal VARCHAR(20);
        RAISE NOTICE 'Coluna "inscricao_municipal" adicionada a clientes.';
    END IF;
    
    -- Adiciona a coluna contribuinte_icms se não existir
    IF NOT EXISTS (SELECT FROM pg_type WHERE typname = 'contribuinte_icms_enum') THEN
        CREATE TYPE public.contribuinte_icms_enum AS ENUM ('NAO_CONTRIBUINTE', 'CONTRIBUINTE', 'CONTRIBUINTE_ISENTO');
        RAISE NOTICE 'Tipo "contribuinte_icms_enum" criado.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='contribuinte_icms') THEN
        ALTER TABLE public.clientes ADD COLUMN contribuinte_icms public.contribuinte_icms_enum NOT NULL DEFAULT 'NAO_CONTRIBUINTE';
        RAISE NOTICE 'Coluna "contribuinte_icms" adicionada a clientes.';
    END IF;

    -- Adiciona a coluna nome_fantasia se não existir
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='nome_fantasia') THEN
        ALTER TABLE public.clientes ADD COLUMN nome_fantasia VARCHAR(60);
        RAISE NOTICE 'Coluna "nome_fantasia" adicionada a clientes.';
    END IF;

    -- Adiciona colunas de endereço de cobrança se não existirem
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_cep') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_cep VARCHAR(10);
        RAISE NOTICE 'Coluna "cobranca_cep" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_logradouro') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_logradouro VARCHAR(50);
        RAISE NOTICE 'Coluna "cobranca_logradouro" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_numero') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_numero VARCHAR(10);
        RAISE NOTICE 'Coluna "cobranca_numero" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_complemento') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_complemento VARCHAR(50);
        RAISE NOTICE 'Coluna "cobranca_complemento" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_bairro') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_bairro VARCHAR(30);
        RAISE NOTICE 'Coluna "cobranca_bairro" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_cidade') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_cidade VARCHAR(30);
        RAISE NOTICE 'Coluna "cobranca_cidade" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='cobranca_estado') THEN
        ALTER TABLE public.clientes ADD COLUMN cobranca_estado VARCHAR(2);
        RAISE NOTICE 'Coluna "cobranca_estado" adicionada a clientes.';
    END IF;

    -- Adiciona colunas de contato se não existirem
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='telefone_adicional') THEN
        ALTER TABLE public.clientes ADD COLUMN telefone_adicional VARCHAR(40);
        RAISE NOTICE 'Coluna "telefone_adicional" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='site') THEN
        ALTER TABLE public.clientes ADD COLUMN site VARCHAR(40);
        RAISE NOTICE 'Coluna "site" adicionada a clientes.';
    END IF;

    -- Adiciona colunas da aba "Dados Complementares" se não existirem
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='estado_civil') THEN
        ALTER TABLE public.clientes ADD COLUMN estado_civil VARCHAR(20);
        RAISE NOTICE 'Coluna "estado_civil" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='profissao') THEN
        ALTER TABLE public.clientes ADD COLUMN profissao VARCHAR(50);
        RAISE NOTICE 'Coluna "profissao" adicionada a clientes.';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='nacionalidade') THEN
        ALTER TABLE public.clientes ADD COLUMN nacionalidade VARCHAR(50);
        RAISE NOTICE 'Coluna "nacionalidade" adicionada a clientes.';
    END IF;

    -- Adiciona a coluna observacoes para a aba de observações
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='clientes' AND column_name='observacoes') THEN
        ALTER TABLE public.clientes ADD COLUMN observacoes TEXT;
        RAISE NOTICE 'Coluna "observacoes" adicionada a clientes.';
    END IF;

    -- Cria a tabela pessoas_contato se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pessoas_contato') THEN
        CREATE TABLE public.pessoas_contato (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
            nome VARCHAR(50) NOT NULL,
            setor VARCHAR(50),
            email VARCHAR(50),
            telefone VARCHAR(40),
            ramal VARCHAR(10),
            created_at TIMESTAMPTZ DEFAULT now(),
            updated_at TIMESTAMPTZ DEFAULT now()
        );
        RAISE NOTICE 'Tabela "pessoas_contato" criada.';
    ELSE
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='pessoas_contato' AND column_name='setor') THEN
            ALTER TABLE public.pessoas_contato ADD COLUMN setor VARCHAR(50);
            RAISE NOTICE 'Coluna "setor" adicionada a pessoas_contato.';
        END IF;
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='pessoas_contato' AND column_name='ramal') THEN
            ALTER TABLE public.pessoas_contato ADD COLUMN ramal VARCHAR(10);
            RAISE NOTICE 'Coluna "ramal" adicionada a pessoas_contato.';
        END IF;
    END IF;

    -- Cria a tabela cliente_anexos se não existir
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'cliente_anexos') THEN
        CREATE TABLE public.cliente_anexos (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
            nome_arquivo VARCHAR(255) NOT NULL,
            path TEXT NOT NULL,
            tamanho BIGINT NOT NULL,
            tipo VARCHAR(100) NOT NULL,
            created_at TIMESTAMPTZ DEFAULT now()
        );
        RAISE NOTICE 'Tabela "cliente_anexos" criada.';
    END IF;

    -- Garante a criação do bucket de armazenamento
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'cliente-anexos') THEN
        INSERT INTO storage.buckets (id, name, public)
        VALUES ('cliente-anexos', 'cliente-anexos', true);
        RAISE NOTICE 'Bucket "cliente-anexos" criado no Storage.';
    ELSE
        RAISE NOTICE 'Bucket "cliente-anexos" já existe.';
    END IF;

    RAISE NOTICE 'Migração do módulo de clientes concluída com sucesso.';
END $$;
