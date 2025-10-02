/*
  # [CORREÇÃO E POPULAÇÃO DO MÓDULO CRM]
  Este script garante que a estrutura do módulo de CRM esteja correta e, em seguida,
  insere dados de exemplo. É seguro para ser executado múltiplas vezes.

  ## Query Description: [Esta operação verifica a estrutura das tabelas do CRM,
  adicionando colunas que possam estar faltando, e então insere dados de exemplo.
  Nenhum dado existente será perdido. A operação é segura.]

  ## Metadata:
  - Schema-Category: ["Structural", "Data"]
  - Impact-Level: ["Low"]
  - Requires-Backup: [false]
  - Reversible: [false]
*/

-- PASSO 1: Garantir a estrutura correta do CRM

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'crm_etapa') THEN
        CREATE TYPE public.crm_etapa AS ENUM ('Lead', 'Prospecção', 'Negociação', 'Ganho', 'Perdido');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS public.crm_oportunidades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
    vendedor_id UUID REFERENCES public.vendedores(id) ON DELETE SET NULL,
    valor_estimado NUMERIC,
    etapa public.crm_etapa NOT NULL,
    data_fechamento_prevista DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Adiciona a coluna 'nome' se ela não existir
ALTER TABLE public.crm_oportunidades ADD COLUMN IF NOT EXISTS nome TEXT NOT NULL DEFAULT 'Nova Oportunidade';

CREATE TABLE IF NOT EXISTS public.crm_interacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    oportunidade_id UUID NOT NULL REFERENCES public.crm_oportunidades(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL,
    descricao TEXT,
    data TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    vendedor_id UUID REFERENCES public.vendedores(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 2: Popular o CRM com dados de exemplo (apenas se a tabela estiver vazia)

DO $$
DECLARE
    cliente1_id UUID;
    cliente2_id UUID;
    vendedor1_id UUID;
    vendedor2_id UUID;
BEGIN
    -- Verifica se já existem oportunidades para não duplicar os dados
    IF (SELECT COUNT(*) FROM public.crm_oportunidades) > 0 THEN
        RAISE NOTICE 'A tabela crm_oportunidades já contém dados. Nenhuma nova oportunidade foi inserida.';
        RETURN;
    END IF;

    -- Seleciona IDs de clientes e vendedores existentes para usar nos exemplos
    SELECT id INTO cliente1_id FROM public.clientes WHERE is_cliente = true ORDER BY created_at LIMIT 1;
    SELECT id INTO cliente2_id FROM public.clientes WHERE is_cliente = true ORDER BY created_at DESC LIMIT 1;
    SELECT id INTO vendedor1_id FROM public.vendedores ORDER BY created_at LIMIT 1;
    SELECT id INTO vendedor2_id FROM public.vendedores ORDER BY created_at DESC LIMIT 1;

    -- Se não encontrar clientes ou vendedores, não insere nada para evitar erros
    IF cliente1_id IS NULL OR cliente2_id IS NULL OR vendedor1_id IS NULL OR vendedor2_id IS NULL THEN
        RAISE NOTICE 'Não foram encontrados clientes ou vendedores suficientes para popular as oportunidades. Execute o script de popular dados gerais primeiro.';
        RETURN;
    END IF;

    -- Insere as oportunidades de exemplo
    INSERT INTO public.crm_oportunidades (nome, cliente_id, vendedor_id, valor_estimado, etapa, data_fechamento_prevista)
    VALUES
        ('Desenvolvimento de novo E-commerce', cliente1_id, vendedor1_id, 50000.00, 'Prospecção', NOW() + INTERVAL '30 days'),
        ('Contrato de Suporte Técnico Anual', cliente2_id, vendedor2_id, 12000.00, 'Negociação', NOW() + INTERVAL '15 days'),
        ('Consultoria de SEO para Blog', cliente1_id, vendedor1_id, 5000.00, 'Lead', NOW() + INTERVAL '45 days'),
        ('Renovação de Licença de Software', cliente2_id, vendedor2_id, 8000.00, 'Ganho', NOW() - INTERVAL '10 days'),
        ('Projeto de Migração para Nuvem', cliente1_id, vendedor2_id, 75000.00, 'Perdido', NOW() - INTERVAL '5 days'),
        ('Implementação de Sistema de Pagamentos', cliente2_id, vendedor1_id, 25000.00, 'Negociação', NOW() + INTERVAL '20 days');

    RAISE NOTICE 'Tabela crm_oportunidades populada com sucesso.';
END $$;
