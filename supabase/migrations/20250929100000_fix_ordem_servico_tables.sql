/*
# [Fix] Correção da Estrutura da Ordem de Serviço
Este script garante que as tabelas e colunas necessárias para o módulo de Ordem de Serviço existam, corrigindo possíveis falhas em migrações anteriores.

## Query Description:
- **Criação de Tabelas:** Cria as tabelas `ordem_servico_itens` e `ordem_servico_anexos` se elas não existirem.
- **Adição de Colunas:** Adiciona todas as colunas ausentes na tabela `ordens_servico`.
- **Segurança:** A operação é segura e não apaga dados existentes. Ela apenas adiciona a estrutura que está faltando.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: false (mas não destrutivo)
*/

BEGIN;

-- Garante que a tabela de itens da OS exista
CREATE TABLE IF NOT EXISTS public.ordem_servico_itens (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    ordem_servico_id uuid NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
    servico_id uuid REFERENCES public.servicos(id) ON DELETE SET NULL,
    descricao text NOT NULL,
    codigo text,
    quantidade numeric(10,2) NOT NULL DEFAULT 1,
    preco numeric(12,2) NOT NULL DEFAULT 0,
    desconto numeric(5,2) DEFAULT 0,
    valor_total numeric(12,2) NOT NULL DEFAULT 0,
    orcar boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Garante que a tabela de anexos da OS exista
CREATE TABLE IF NOT EXISTS public.ordem_servico_anexos (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    ordem_servico_id uuid NOT NULL REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
    nome_arquivo text NOT NULL,
    path text NOT NULL,
    tamanho integer NOT NULL,
    tipo text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Adiciona colunas ausentes na tabela principal 'ordens_servico'
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='descricao_servico') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN descricao_servico text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='consideracoes_finais') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN consideracoes_finais text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='data_previsao') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN data_previsao date;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='hora') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN hora time without time zone;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='data_conclusao') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN data_conclusao date;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='total_servicos') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN total_servicos numeric(12,2) DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='desconto') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN desconto numeric(12,2);
    END IF;
     IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='desconto_tipo') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN desconto_tipo text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='observacoes_servico') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN observacoes_servico text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='observacoes_internas') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN observacoes_internas text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='vendedor_id') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN vendedor_id uuid REFERENCES public.vendedores(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='comissao_percentual') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN comissao_percentual numeric(5,2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='valor_comissao') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN valor_comissao numeric(12,2);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='tecnico_id') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN tecnico_id uuid REFERENCES public.vendedores(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='orcar') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN orcar boolean DEFAULT false;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='forma_recebimento') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN forma_recebimento text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='meio_pagamento') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN meio_pagamento text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='conta_bancaria') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN conta_bancaria text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='categoria_financeira') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN categoria_financeira text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='condicao_pagamento') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN condicao_pagamento text;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='ordens_servico' AND column_name='marcadores') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN marcadores text[];
    END IF;
END $$;

COMMIT;
