-- Migration para refatorar a tabela de produtos

-- 1. Adicionar ENUM para tipo_produto e situacao para garantir consistência
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tipo_produto_enum') THEN
        CREATE TYPE tipo_produto_enum AS ENUM ('SIMPLES', 'COM_VARIACOES', 'KIT', 'FABRICADO', 'MATERIA_PRIMA');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'produto_situacao_enum') THEN
        CREATE TYPE produto_situacao_enum AS ENUM ('ATIVO', 'INATIVO');
    END IF;
END$$;

-- 2. Adicionar novas colunas, verificando se já não existem
DO $$
BEGIN
    -- Mapeamento de campos antigos
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='nome') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='descricao_nf') THEN
        ALTER TABLE produtos RENAME COLUMN nome TO descricao_nf;
        RAISE NOTICE 'Coluna "nome" renomeada para "descricao_nf" para preservar dados.';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='descricao') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='observacoes') THEN
        ALTER TABLE produtos RENAME COLUMN descricao TO observacoes;
        RAISE NOTICE 'Coluna "descricao" renomeada para "observacoes" para preservar dados.';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='preco') THEN
        ALTER TABLE produtos RENAME COLUMN preco TO preco_venda;
        RAISE NOTICE 'Coluna "preco" renomeada para "preco_venda" para preservar dados.';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='produtos' AND column_name='ativo') THEN
        ALTER TABLE produtos ADD COLUMN IF NOT EXISTS situacao produto_situacao_enum DEFAULT 'ATIVO';
        UPDATE produtos SET situacao = CASE WHEN ativo = true THEN 'ATIVO' ELSE 'INATIVO' END;
        ALTER TABLE produtos DROP COLUMN ativo;
        RAISE NOTICE 'Coluna "ativo" migrada para "situacao".';
    END IF;

    -- Adicionando novas colunas
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS tipo_produto tipo_produto_enum DEFAULT 'SIMPLES';
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS nome VARCHAR(150);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS codigo_barras VARCHAR(14);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS codigo_sku VARCHAR(50);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS origem_produto SMALLINT DEFAULT 0;
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS unidade_medida VARCHAR(10);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS ncm VARCHAR(10);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS cest VARCHAR(9);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS peso_liquido NUMERIC(12, 3);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS peso_bruto NUMERIC(12, 3);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS num_volumes INT;
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS tipo_embalagem VARCHAR(50);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS embalagem_id VARCHAR(50);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS largura_cm NUMERIC(10, 2);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS altura_cm NUMERIC(10, 2);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS comprimento_cm NUMERIC(10, 2);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS controlar_estoque BOOLEAN DEFAULT true;
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS estoque_minimo INT;
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS estoque_maximo INT;
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS controlar_lotes BOOLEAN DEFAULT false;
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS localizacao VARCHAR(100);
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS dias_preparacao INT;
    ALTER TABLE produtos ADD COLUMN IF NOT EXISTS descricao_complementar TEXT;
    
    -- Ajustando tipo da coluna de preço
    ALTER TABLE produtos ALTER COLUMN preco_venda TYPE NUMERIC(12, 2);

    -- Preenchendo o novo campo "nome" com o valor antigo de "descricao_nf" para compatibilidade
    UPDATE produtos SET nome = descricao_nf WHERE nome IS NULL;

    RAISE NOTICE 'Tabela "produtos" atualizada com sucesso.';
END$$;

-- 3. Adicionar constraints e índices
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'produtos_codigo_sku_key') THEN
        ALTER TABLE produtos ADD CONSTRAINT produtos_codigo_sku_key UNIQUE (codigo_sku);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_produtos_nome') THEN
        CREATE INDEX idx_produtos_nome ON produtos(nome);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_produtos_ncm') THEN
        CREATE INDEX idx_produtos_ncm ON produtos(ncm);
    END IF;
END$$;
