/*
          # [CRIAÇÃO DO MÓDULO DE CRM]
          Este script cria a estrutura de tabelas necessária para o módulo de CRM, incluindo oportunidades e interações.
          ## Query Description: [Esta operação é segura e apenas adiciona novas tabelas e tipos ao banco de dados. Nenhum dado existente será modificado ou removido.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Tabelas: `crm_oportunidades`, `crm_interacoes`
          - Tipos: `crm_status`
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [Added]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. Adiciona novas tabelas com índices para performance otimizada.]
*/

-- PASSO 1: CRIAÇÃO DO TIPO (ENUM) PARA STATUS DO CRM
CREATE TYPE public.crm_status AS ENUM ('LEAD', 'PROSPECT', 'NEGOCIACAO', 'GANHA', 'PERDIDA');

-- PASSO 2: CRIAÇÃO DA TABELA DE OPORTUNIDADES
CREATE TABLE public.crm_oportunidades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    titulo TEXT NOT NULL,
    cliente_id UUID NOT NULL REFERENCES public.clientes(id) ON DELETE CASCADE,
    vendedor_id UUID REFERENCES public.vendedores(id) ON DELETE SET NULL,
    valor_estimado NUMERIC NOT NULL DEFAULT 0,
    status public.crm_status NOT NULL DEFAULT 'LEAD',
    data_criacao TIMESTAMPTZ DEFAULT NOW(),
    data_fechamento_prevista DATE,
    data_fechamento_real DATE,
    observacoes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 3: CRIAÇÃO DA TABELA DE INTERAÇÕES
CREATE TABLE public.crm_interacoes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    oportunidade_id UUID NOT NULL REFERENCES public.crm_oportunidades(id) ON DELETE CASCADE,
    tipo_interacao TEXT NOT NULL, -- Ex: 'Email', 'Telefone', 'Reunião'
    descricao TEXT NOT NULL,
    data_interacao TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PASSO 4: ÍNDICES PARA PERFORMANCE
CREATE INDEX idx_crm_oportunidades_status ON public.crm_oportunidades(status);
CREATE INDEX idx_crm_oportunidades_cliente_id ON public.crm_oportunidades(cliente_id);
CREATE INDEX idx_crm_interacoes_oportunidade_id ON public.crm_interacoes(oportunidade_id);

-- PASSO 5: TRIGGERS DE ATUALIZAÇÃO
CREATE TRIGGER handle_crm_oportunidades_updated_at
BEFORE UPDATE ON public.crm_oportunidades
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER handle_crm_interacoes_updated_at
BEFORE UPDATE ON public.crm_interacoes
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();

-- PASSO 6: HABILITAR RLS E CRIAR POLÍTICAS DE ACESSO
ALTER TABLE public.crm_oportunidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crm_interacoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir leitura para todos"
ON public.crm_oportunidades
FOR SELECT
USING (true);

CREATE POLICY "Permitir inserção para todos"
ON public.crm_oportunidades
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Permitir atualização para todos"
ON public.crm_oportunidades
FOR UPDATE
USING (true)
WITH CHECK (true);

CREATE POLICY "Permitir exclusão para todos"
ON public.crm_oportunidades
FOR DELETE
USING (true);

CREATE POLICY "Permitir leitura para todos"
ON public.crm_interacoes
FOR SELECT
USING (true);

CREATE POLICY "Permitir inserção para todos"
ON public.crm_interacoes
FOR INSERT
WITH CHECK (true);

CREATE POLICY "Permitir atualização para todos"
ON public.crm_interacoes
FOR UPDATE
USING (true)
WITH CHECK (true);

CREATE POLICY "Permitir exclusão para todos"
ON public.crm_interacoes
FOR DELETE
USING (true);
