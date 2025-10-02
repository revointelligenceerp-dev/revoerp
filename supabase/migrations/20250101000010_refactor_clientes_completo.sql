-- =================================================================
-- MIGRATION SCRIPT: Refatoração Completa do Cadastro de Clientes
-- Descrição: Adiciona novos campos à tabela 'clientes', cria
--            tabelas auxiliares e ajusta a estrutura para
--            suportar a nova interface de cadastro.
-- Migration-ID: 20250101000010
-- =================================================================

-- Habilitar a extensão pgcrypto se ainda não estiver habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =================================================================
-- Tabela: pessoas_contato
-- Descrição: Tabela para armazenar múltiplos contatos associados a um cliente.
-- =================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pessoas_contato') THEN
    CREATE TABLE public.pessoas_contato (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
        nome TEXT NOT NULL,
        setor TEXT,
        email TEXT,
        telefone TEXT,
        ramal TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    RAISE NOTICE 'Tabela "pessoas_contato" criada.';
  ELSE
    -- Adicionar colunas 'setor' e 'ramal' se não existirem
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='pessoas_contato' AND column_name='setor') THEN
      ALTER TABLE public.pessoas_contato ADD COLUMN setor TEXT;
      RAISE NOTICE 'Coluna "setor" adicionada a "pessoas_contato".';
    END IF;
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name='pessoas_contato' AND column_name='ramal') THEN
      ALTER TABLE public.pessoas_contato ADD COLUMN ramal TEXT;
      RAISE NOTICE 'Coluna "ramal" adicionada a "pessoas_contato".';
    END IF;
  END IF;
END $$;

-- =================================================================
-- Tabela: cliente_anexos
-- Descrição: Tabela para armazenar metadados de arquivos anexados aos clientes.
-- =================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'cliente_anexos') THEN
    CREATE TABLE public.cliente_anexos (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        cliente_id UUID NOT NULL,
        nome_arquivo TEXT NOT NULL,
        path TEXT NOT NULL,
        tamanho BIGINT NOT NULL,
        tipo TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
    );
    RAISE NOTICE 'Tabela "cliente_anexos" criada.';
  END IF;
END $$;

-- Adicionar a chave estrangeira para cliente_anexos se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'cliente_anexos_cliente_id_fkey' AND conrelid = 'public.cliente_anexos'::regclass
  ) THEN
    ALTER TABLE public.cliente_anexos 
    ADD CONSTRAINT cliente_anexos_cliente_id_fkey 
    FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE CASCADE;
    RAISE NOTICE 'Chave estrangeira "cliente_anexos_cliente_id_fkey" criada.';
  END IF;
END $$;

-- =================================================================
-- Bucket: cliente-anexos
-- Descrição: Bucket no Supabase Storage para os arquivos de anexos.
-- =================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('cliente-anexos', 'cliente-anexos', true, 5242880, NULL)
ON CONFLICT (id) DO NOTHING;
RAISE NOTICE 'Bucket "cliente-anexos" garantido.';

-- =================================================================
-- Tabela: clientes
-- Descrição: Adiciona as novas colunas à tabela principal de clientes.
-- =================================================================
DO $$
DECLARE
  col_exists BOOLEAN;
BEGIN
  -- Função para verificar se a coluna existe
  CREATE OR REPLACE FUNCTION column_exists(table_name_in TEXT, column_name_in TEXT)
  RETURNS BOOLEAN AS
  $func$
  BEGIN
    RETURN EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = table_name_in AND column_name = column_name_in
    );
  END
  $func$ LANGUAGE plpgsql;

  -- Adicionar colunas
  IF NOT column_exists('clientes', 'codigo') THEN ALTER TABLE public.clientes ADD COLUMN codigo TEXT; RAISE NOTICE 'Coluna "codigo" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'tipo_pessoa') THEN ALTER TABLE public.clientes ADD COLUMN tipo_pessoa TEXT; RAISE NOTICE 'Coluna "tipo_pessoa" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'rg') THEN ALTER TABLE public.clientes ADD COLUMN rg TEXT; RAISE NOTICE 'Coluna "rg" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'data_nascimento') THEN ALTER TABLE public.clientes ADD COLUMN data_nascimento DATE; RAISE NOTICE 'Coluna "data_nascimento" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'inscricao_estadual') THEN ALTER TABLE public.clientes ADD COLUMN inscricao_estadual TEXT; RAISE NOTICE 'Coluna "inscricao_estadual" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'inscricao_municipal') THEN ALTER TABLE public.clientes ADD COLUMN inscricao_municipal TEXT; RAISE NOTICE 'Coluna "inscricao_municipal" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'contribuinte_icms') THEN ALTER TABLE public.clientes ADD COLUMN contribuinte_icms TEXT; RAISE NOTICE 'Coluna "contribuinte_icms" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'logradouro') THEN ALTER TABLE public.clientes ADD COLUMN logradouro TEXT; RAISE NOTICE 'Coluna "logradouro" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'numero') THEN ALTER TABLE public.clientes ADD COLUMN numero TEXT; RAISE NOTICE 'Coluna "numero" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'complemento') THEN ALTER TABLE public.clientes ADD COLUMN complemento TEXT; RAISE NOTICE 'Coluna "complemento" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'bairro') THEN ALTER TABLE public.clientes ADD COLUMN bairro TEXT; RAISE NOTICE 'Coluna "bairro" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cep') THEN ALTER TABLE public.clientes ADD COLUMN cep TEXT; RAISE NOTICE 'Coluna "cep" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cidade') THEN ALTER TABLE public.clientes ADD COLUMN cidade TEXT; RAISE NOTICE 'Coluna "cidade" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'estado') THEN ALTER TABLE public.clientes ADD COLUMN estado TEXT; RAISE NOTICE 'Coluna "estado" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'pais') THEN ALTER TABLE public.clientes ADD COLUMN pais TEXT; RAISE NOTICE 'Coluna "pais" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cobranca_logradouro') THEN ALTER TABLE public.clientes ADD COLUMN cobranca_logradouro TEXT; RAISE NOTICE 'Coluna "cobranca_logradouro" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cobranca_numero') THEN ALTER TABLE public.clientes ADD COLUMN cobranca_numero TEXT; RAISE NOTICE 'Coluna "cobranca_numero" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cobranca_complemento') THEN ALTER TABLE public.clientes ADD COLUMN cobranca_complemento TEXT; RAISE NOTICE 'Coluna "cobranca_complemento" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cobranca_bairro') THEN ALTER TABLE public.clientes ADD COLUMN cobranca_bairro TEXT; RAISE NOTICE 'Coluna "cobranca_bairro" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cobranca_cep') THEN ALTER TABLE public.clientes ADD COLUMN cobranca_cep TEXT; RAISE NOTICE 'Coluna "cobranca_cep" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cobranca_cidade') THEN ALTER TABLE public.clientes ADD COLUMN cobranca_cidade TEXT; RAISE NOTICE 'Coluna "cobranca_cidade" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'cobranca_estado') THEN ALTER TABLE public.clientes ADD COLUMN cobranca_estado TEXT; RAISE NOTICE 'Coluna "cobranca_estado" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'telefone_adicional') THEN ALTER TABLE public.clientes ADD COLUMN telefone_adicional TEXT; RAISE NOTICE 'Coluna "telefone_adicional" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'celular') THEN ALTER TABLE public.clientes ADD COLUMN celular TEXT; RAISE NOTICE 'Coluna "celular" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'email_nfe') THEN ALTER TABLE public.clientes ADD COLUMN email_nfe TEXT; RAISE NOTICE 'Coluna "email_nfe" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'site') THEN ALTER TABLE public.clientes ADD COLUMN site TEXT; RAISE NOTICE 'Coluna "site" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'is_cliente') THEN ALTER TABLE public.clientes ADD COLUMN is_cliente BOOLEAN DEFAULT false; RAISE NOTICE 'Coluna "is_cliente" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'is_fornecedor') THEN ALTER TABLE public.clientes ADD COLUMN is_fornecedor BOOLEAN DEFAULT false; RAISE NOTICE 'Coluna "is_fornecedor" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'is_transportadora') THEN ALTER TABLE public.clientes ADD COLUMN is_transportadora BOOLEAN DEFAULT false; RAISE NOTICE 'Coluna "is_transportadora" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'limite_credito') THEN ALTER TABLE public.clientes ADD COLUMN limite_credito NUMERIC(15, 2); RAISE NOTICE 'Coluna "limite_credito" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'tabela_preco_padrao_id') THEN ALTER TABLE public.clientes ADD COLUMN tabela_preco_padrao_id UUID; RAISE NOTICE 'Coluna "tabela_preco_padrao_id" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'situacao_cliente') THEN ALTER TABLE public.clientes ADD COLUMN situacao_cliente TEXT; RAISE NOTICE 'Coluna "situacao_cliente" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'condicao_pagamento_padrao_id') THEN ALTER TABLE public.clientes ADD COLUMN condicao_pagamento_padrao_id UUID; RAISE NOTICE 'Coluna "condicao_pagamento_padrao_id" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'prazo_medio_entrega_dias') THEN ALTER TABLE public.clientes ADD COLUMN prazo_medio_entrega_dias INTEGER; RAISE NOTICE 'Coluna "prazo_medio_entrega_dias" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'categoria_despesa_padrao_id') THEN ALTER TABLE public.clientes ADD COLUMN categoria_despesa_padrao_id UUID; RAISE NOTICE 'Coluna "categoria_despesa_padrao_id" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'placa_veiculo') THEN ALTER TABLE public.clientes ADD COLUMN placa_veiculo TEXT; RAISE NOTICE 'Coluna "placa_veiculo" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'uf_placa') THEN ALTER TABLE public.clientes ADD COLUMN uf_placa TEXT; RAISE NOTICE 'Coluna "uf_placa" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'registro_antt') THEN ALTER TABLE public.clientes ADD COLUMN registro_antt TEXT; RAISE NOTICE 'Coluna "registro_antt" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'observacoes_frete') THEN ALTER TABLE public.clientes ADD COLUMN observacoes_frete TEXT; RAISE NOTICE 'Coluna "observacoes_frete" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'observacoes') THEN ALTER TABLE public.clientes ADD COLUMN observacoes TEXT; RAISE NOTICE 'Coluna "observacoes" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'estado_civil') THEN ALTER TABLE public.clientes ADD COLUMN estado_civil TEXT; RAISE NOTICE 'Coluna "estado_civil" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'profissao') THEN ALTER TABLE public.clientes ADD COLUMN profissao TEXT; RAISE NOTICE 'Coluna "profissao" adicionada.'; END IF;
  IF NOT column_exists('clientes', 'sexo') THEN ALTER TABLE public.clientes ADD COLUMN sexo TEXT; RAISE NOTICE 'Coluna "sexo" adicionada.'; END IF;

  -- Renomear 'nome' para 'nome_razao_social' se 'nome_razao_social' não existir
  IF column_exists('clientes', 'nome') AND NOT column_exists('clientes', 'nome_razao_social') THEN
    ALTER TABLE public.clientes RENAME COLUMN nome TO nome_razao_social;
    RAISE NOTICE 'Coluna "nome" renomeada para "nome_razao_social".';
  END IF;

  -- Adicionar a coluna 'nome' se ela não existir (caso a anterior tenha sido renomeada)
  IF NOT column_exists('clientes', 'nome') THEN
    ALTER TABLE public.clientes ADD COLUMN nome TEXT;
    RAISE NOTICE 'Coluna "nome" (para compatibilidade) adicionada.';
  END IF;

  -- Mapear dados antigos (se 'nome_razao_social' foi recém-criada)
  UPDATE public.clientes SET nome = nome_razao_social WHERE nome IS NULL AND nome_razao_social IS NOT NULL;
  RAISE NOTICE 'Dados de "nome_razao_social" mapeados para "nome".';

  -- Garantir que a coluna 'cpf_cnpj' exista
  IF NOT column_exists('clientes', 'cpf_cnpj') THEN
    ALTER TABLE public.clientes ADD COLUMN cpf_cnpj TEXT;
    RAISE NOTICE 'Coluna "cpf_cnpj" adicionada.';
  END IF;

  DROP FUNCTION column_exists;
END $$;

-- =================================================================
-- Adicionar Índices para Performance
-- =================================================================
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON public.clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_nome_razao_social ON public.clientes(nome_razao_social);
RAISE NOTICE 'Índices para performance garantidos na tabela "clientes".';
