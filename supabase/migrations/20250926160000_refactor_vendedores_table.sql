/*
  ## Refatoração da Tabela de Vendedores com Correção de Duplicatas
  Este script realiza duas ações principais:
  1. **Corrige e-mails duplicados**: Antes de aplicar a regra de e-mail único, este script identifica vendedores com o mesmo e-mail e atualiza os registros duplicados para garantir a unicidade, preservando todos os dados.
  2. **Atualiza a estrutura da tabela**: Adiciona todas as novas colunas necessárias para o formulário de cadastro de vendedor.
*/

-- Etapa 1: Resolver e-mails duplicados
-- Mantém o primeiro registro criado e atualiza os demais com um sufixo único.
WITH duplicates AS (
  SELECT
    id,
    email,
    ROW_NUMBER() OVER(PARTITION BY email ORDER BY created_at ASC) as rn
  FROM
    public.vendedores
)
UPDATE
  public.vendedores
SET
  email = 
    CASE 
      WHEN email IS NULL THEN 'email_nulo_' || SUBSTRING(id::text, 1, 8)
      WHEN STRPOS(email, '@') > 0 THEN
        LEFT(email, STRPOS(email, '@') - 1) || '_dup_' || SUBSTRING(id::text, 1, 4) || RIGHT(email, LENGTH(email) - STRPOS(email, '@') + 1)
      ELSE
        email || '_dup_' || SUBSTRING(id::text, 1, 4)
    END
WHERE
  id IN (SELECT id FROM duplicates WHERE rn > 1);

-- Garante que não haja emails nulos antes de adicionar a constraint
UPDATE public.vendedores SET email = 'email_nulo_' || SUBSTRING(id::text, 1, 8) || '@empresa.com' WHERE email IS NULL;

-- Etapa 2: Adicionar novas colunas à tabela 'vendedores'
-- Usamos um bloco DO para adicionar colunas apenas se elas não existirem.
DO $$
BEGIN
  -- Seção de Identificação
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'nome_fantasia') THEN ALTER TABLE public.vendedores ADD COLUMN nome_fantasia TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'codigo') THEN ALTER TABLE public.vendedores ADD COLUMN codigo TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'tipo_pessoa') THEN ALTER TABLE public.vendedores ADD COLUMN tipo_pessoa TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'cpf_cnpj') THEN ALTER TABLE public.vendedores ADD COLUMN cpf_cnpj TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'contribuinte') THEN ALTER TABLE public.vendedores ADD COLUMN contribuinte TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'inscricao_estadual') THEN ALTER TABLE public.vendedores ADD COLUMN inscricao_estadual TEXT; END IF;

  -- Seção de Endereço
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'cep') THEN ALTER TABLE public.vendedores ADD COLUMN cep TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'cidade') THEN ALTER TABLE public.vendedores ADD COLUMN cidade TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'uf') THEN ALTER TABLE public.vendedores ADD COLUMN uf TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'logradouro') THEN ALTER TABLE public.vendedores ADD COLUMN logradouro TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'bairro') THEN ALTER TABLE public.vendedores ADD COLUMN bairro TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'numero') THEN ALTER TABLE public.vendedores ADD COLUMN numero TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'complemento') THEN ALTER TABLE public.vendedores ADD COLUMN complemento TEXT; END IF;

  -- Seção de Contatos
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'celular') THEN ALTER TABLE public.vendedores ADD COLUMN celular TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'email_comunicacoes') THEN ALTER TABLE public.vendedores ADD COLUMN email_comunicacoes TEXT; END IF;

  -- Seção de Situação / Depósito
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'situacao') THEN ALTER TABLE public.vendedores ADD COLUMN situacao TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'deposito_id') THEN ALTER TABLE public.vendedores ADD COLUMN deposito_id TEXT; END IF;

  -- Seção de Dados de Acesso
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'usuario_sistema') THEN ALTER TABLE public.vendedores ADD COLUMN usuario_sistema TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'acesso_restrito_horario') THEN ALTER TABLE public.vendedores ADD COLUMN acesso_restrito_horario BOOLEAN DEFAULT FALSE; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'acesso_restrito_ip') THEN ALTER TABLE public.vendedores ADD COLUMN acesso_restrito_ip BOOLEAN DEFAULT FALSE; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'ips_permitidos') THEN ALTER TABLE public.vendedores ADD COLUMN ips_permitidos TEXT[]; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'perfil_acesso_contatos') THEN ALTER TABLE public.vendedores ADD COLUMN perfil_acesso_contatos TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'modulos_acessiveis') THEN ALTER TABLE public.vendedores ADD COLUMN modulos_acessiveis JSONB; END IF;

  -- Seção de Comissionamento
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'regra_liberacao_comissao') THEN ALTER TABLE public.vendedores ADD COLUMN regra_liberacao_comissao TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'tipo_comissao') THEN ALTER TABLE public.vendedores ADD COLUMN tipo_comissao TEXT; END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'aliquota_comissao') THEN ALTER TABLE public.vendedores ADD COLUMN aliquota_comissao NUMERIC(5, 2); END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'desconsiderar_comissao_linha_produto') THEN ALTER TABLE public.vendedores ADD COLUMN desconsiderar_comissao_linha_produto BOOLEAN DEFAULT FALSE; END IF;
  
  -- Seção de Observações
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'observacoes') THEN ALTER TABLE public.vendedores ADD COLUMN observacoes TEXT; END IF;

  -- Adiciona a restrição UNIQUE no e-mail, se não existir
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'vendedores_email_key' AND conrelid = 'public.vendedores'::regclass) THEN
    ALTER TABLE public.vendedores ADD CONSTRAINT vendedores_email_key UNIQUE (email);
  END IF;

END $$;
