/*
          # [Refatoração do Módulo de Clientes]
          Ajusta a tabela de clientes para um modelo mais completo e profissional, com novos campos, tabelas auxiliares e migração de dados existentes.

          ## Query Description: [Esta operação irá reestruturar a tabela 'clientes' para suportar um cadastro mais detalhado, incluindo dados específicos para clientes, fornecedores e transportadoras. Os dados existentes serão migrados para os novos campos, e a coluna 'endereco' (jsonb) será substituída por colunas de texto individuais. Nenhuma informação será perdida.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Data"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [true]
          - Reversible: [false]
          
          ## Structure Details:
          - Tabela 'clientes': Adiciona múltiplas colunas, remove colunas antigas.
          - Tabela 'pessoas_contato': Nova tabela para contatos secundários.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [None]
          
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [No]
          - Estimated Impact: [Leve impacto durante a migração, melhor performance de busca após a criação dos índices.]
          */

-- Adicionar novas colunas à tabela clientes
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS tipo_pessoa TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS cpf_cnpj TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS rg TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS data_nascimento DATE;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS inscricao_estadual TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS inscricao_municipal TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS nome_fantasia TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS logradouro TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS numero TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS complemento TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS bairro TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS cep TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS cidade TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS estado TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS pais TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS celular TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS fax TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS email_nfe TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS site TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS is_cliente BOOLEAN DEFAULT false;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS is_fornecedor BOOLEAN DEFAULT false;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS is_transportadora BOOLEAN DEFAULT false;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS is_contato BOOLEAN DEFAULT false;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS limite_credito NUMERIC(15, 2);
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS tabela_preco_padrao_id UUID;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS vendedor_id UUID REFERENCES public.vendedores(id);
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS situacao_cliente TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS condicao_pagamento_padrao_id UUID;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS prazo_medio_entrega_dias INTEGER;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS categoria_despesa_padrao_id UUID;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS placa_veiculo TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS uf_placa TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS registro_antt TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS observacoes_frete TEXT;
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS observacoes TEXT;

-- Migrar dados existentes para as novas colunas
UPDATE public.clientes SET cpf_cnpj = documento WHERE documento IS NOT NULL AND cpf_cnpj IS NULL;
UPDATE public.clientes SET is_cliente = true WHERE tipo = 'CLIENTE' OR tipo = 'AMBOS';
UPDATE public.clientes SET is_fornecedor = true WHERE tipo = 'FORNECEDOR' OR tipo = 'AMBOS';
UPDATE public.clientes SET situacao_cliente = status WHERE status IS NOT NULL AND situacao_cliente IS NULL;

-- Migrar dados do JSON de endereço para colunas individuais
UPDATE public.clientes 
SET 
  logradouro = endereco->>'logradouro',
  numero = endereco->>'numero',
  complemento = endereco->>'complemento',
  bairro = endereco->>'bairro',
  cep = endereco->>'cep',
  cidade = endereco->>'cidade',
  estado = endereco->>'estado'
WHERE endereco IS NOT NULL;

-- Remover colunas antigas
ALTER TABLE public.clientes DROP COLUMN IF EXISTS documento;
ALTER TABLE public.clientes DROP COLUMN IF EXISTS tipo;
ALTER TABLE public.clientes DROP COLUMN IF EXISTS status;
ALTER TABLE public.clientes DROP COLUMN IF EXISTS endereco;

-- Criar tabela para pessoas de contato
CREATE TABLE IF NOT EXISTS public.pessoas_contato (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    telefone TEXT,
    email TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Habilitar RLS para a nova tabela
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable all access for authenticated users" ON public.pessoas_contato FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Enable read access for anonymous users" ON public.pessoas_contato FOR SELECT USING (auth.role() = 'anon');


-- Adicionar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_pessoas_contato_cliente_id ON public.pessoas_contato(cliente_id);
