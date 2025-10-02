/*
  # Módulo de Expedição
  Cria as tabelas `expedicoes` e `expedicao_pedidos` para gerenciar lotes de envio.

  ## Query Description: 
  - Cria a tabela `expedicoes` para armazenar informações sobre cada lote de expedição.
  - Cria a tabela `expedicao_pedidos` para associar múltiplos pedidos de venda a uma expedição.
  - Habilita a Segurança em Nível de Linha (RLS) e adiciona políticas básicas para proteger os dados.
  - Não há risco de perda de dados, pois são tabelas novas.

  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true

  ## Structure Details:
  - Tabela `expedicoes`: id, data_criacao, forma_envio, status, codigo_rastreio, created_at, updated_at
  - Tabela `expedicao_pedidos`: id, expedicao_id, pedido_id, created_at

  ## Security Implications:
  - RLS Status: Enabled
  - Policy Changes: Yes
  - Auth Requirements: authenticated
*/

-- Tabela para agrupar as expedições
CREATE TABLE IF NOT EXISTS public.expedicoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_criacao TIMESTAMPTZ NOT NULL DEFAULT now(),
    forma_envio TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDENTE', -- PENDENTE, EM_TRANSPORTE, ENTREGUE
    codigo_rastreio TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Tabela para associar pedidos a uma expedição
CREATE TABLE IF NOT EXISTS public.expedicao_pedidos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expedicao_id UUID NOT NULL REFERENCES public.expedicoes(id) ON DELETE CASCADE,
    pedido_id UUID NOT NULL REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(expedicao_id, pedido_id)
);

-- Habilitar RLS
ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;

-- Políticas de Segurança
DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.expedicoes;
CREATE POLICY "Permitir acesso total para usuários autenticados"
ON public.expedicoes
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Permitir acesso total para usuários autenticados" ON public.expedicao_pedidos;
CREATE POLICY "Permitir acesso total para usuários autenticados"
ON public.expedicao_pedidos
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
