/*
          # [CRIAÇÃO DO MÓDULO DE CRM]
          Cria as tabelas e tipos necessários para o funcionamento do módulo de CRM, incluindo o funil de vendas (Kanban).
          Esta operação é segura e não afeta dados existentes.

          ## Query Description: [Este script adiciona novas tabelas ('crm_oportunidades', 'crm_interacoes') e um novo tipo ('crm_etapa') ao banco de dados. Não há risco para os dados existentes, pois apenas novas estruturas estão sendo criadas. As políticas de segurança (RLS) são habilitadas para garantir que os dados do CRM sejam acessíveis pela aplicação.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabelas: crm_oportunidades, crm_interacoes
          - Tipos: crm_etapa
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. Adiciona novas tabelas com índices para garantir a performance das consultas.]
*/

-- PASSO 1: CRIAÇÃO DO TIPO (ENUM) PARA AS ETAPAS DO FUNIL
CREATE TYPE public.crm_etapa AS ENUM (
    'Lead',
    'Prospecção',
    'Negociação',
    'Ganho',
    'Perdido'
);

-- PASSO 2: CRIAÇÃO DA TABELA DE OPORTUNIDADES
CREATE TABLE IF NOT EXISTS public.crm_oportunidades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nome TEXT NOT NULL,
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE SET NULL,
    vendedor_id UUID REFERENCES public.vendedores(id) ON DELETE SET NULL,
    valor_estimado NUMERIC DEFAULT 0,
    etapa public.crm_etapa NOT NULL DEFAULT 'Lead',
    data_fechamento_prevista DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
COMMENT ON TABLE public.crm_oportunidades IS 'Armazena as oportunidades de negócio do funil de vendas.';

-- PASSO 3: CRIAÇÃO DA TABELA DE INTERAÇÕES
CREATE TABLE IF NOT EXISTS public.crm_interacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    oportunidade_id UUID NOT NULL REFERENCES public.crm_oportunidades(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL, -- 'Email', 'Ligação', 'Reunião', 'Nota'
    descricao TEXT NOT NULL,
    data TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    vendedor_id UUID REFERENCES public.vendedores(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
COMMENT ON TABLE public.crm_interacoes IS 'Registra o histórico de interações com uma oportunidade.';

-- PASSO 4: CRIAÇÃO DE TRIGGERS E ÍNDICES
-- Trigger para auto-atualizar 'updated_at'
CREATE TRIGGER handle_crm_oportunidades_updated_at
BEFORE UPDATE ON public.crm_oportunidades
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_crm_interacoes_updated_at
BEFORE UPDATE ON public.crm_interacoes
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_crm_oportunidades_cliente_id ON public.crm_oportunidades(cliente_id);
CREATE INDEX IF NOT EXISTS idx_crm_oportunidades_vendedor_id ON public.crm_oportunidades(vendedor_id);
CREATE INDEX IF NOT EXISTS idx_crm_oportunidades_etapa ON public.crm_oportunidades(etapa);
CREATE INDEX IF NOT EXISTS idx_crm_interacoes_oportunidade_id ON public.crm_interacoes(oportunidade_id);

-- PASSO 5: HABILITAÇÃO DO RLS E CRIAÇÃO DE POLÍTICAS
ALTER TABLE public.crm_oportunidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crm_interacoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permite acesso total para usuários autenticados (oportunidades)"
ON public.crm_oportunidades
FOR ALL
USING (auth.role() = 'authenticated');

CREATE POLICY "Permite acesso total para usuários autenticados (interacoes)"
ON public.crm_interacoes
FOR ALL
USING (auth.role() = 'authenticated');

-- Política para permitir leitura anônima (ideal para desenvolvimento)
CREATE POLICY "Permite leitura anônima (oportunidades)"
ON public.crm_oportunidades
FOR SELECT
USING (true);

CREATE POLICY "Permite leitura anônima (interacoes)"
ON public.crm_interacoes
FOR SELECT
USING (true);
