/*
          # [Fix] Cria a tabela de comissões e recria a view dependente
          [Este script cria a tabela 'comissoes', que estava faltando e causando o erro 'relation does not exist'. Ele também define os tipos de dados, chaves estrangeiras, políticas de segurança (RLS) e recria a 'comissoes_view' para garantir que todo o módulo de comissões funcione corretamente.]
          ## Query Description: [Esta operação é estrutural e segura. Ela adicionará uma nova tabela e uma view ao seu banco de dados. Nenhum dado existente será perdido. Se a tabela ou o tipo já existirem parcialmente, o script é desenhado para não falhar.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          ## Structure Details:
          [Cria o tipo: public.status_comissao. Cria a tabela: public.comissoes. Recria a view: public.comissoes_view.]
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [authenticated]
          ## Performance Impact:
          - Indexes: [Cria chaves primárias e estrangeiras que são indexadas por padrão.]
          - Triggers: [N/A]
          - Estimated Impact: [Baixo. A criação da tabela e da view é uma operação rápida.]
          */

-- Cria o tipo ENUM para o status da comissão, se não existir
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'status_comissao') THEN
        CREATE TYPE public.status_comissao AS ENUM
            ('Pendente', 'Liberada', 'Paga', 'Cancelada');
    END IF;
END$$;

-- Cria a tabela de comissões, se não existir
CREATE TABLE IF NOT EXISTS public.comissoes (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    pedido_venda_id uuid NOT NULL,
    vendedor_id uuid NOT NULL,
    base_comissao numeric NOT NULL,
    percentual_comissao numeric NOT NULL,
    valor_comissao numeric NOT NULL,
    status public.status_comissao NOT NULL DEFAULT 'Pendente'::public.status_comissao,
    data_liberacao timestamp with time zone,
    data_pagamento timestamp with time zone,
    CONSTRAINT comissoes_pkey PRIMARY KEY (id),
    CONSTRAINT comissoes_pedido_venda_id_fkey FOREIGN KEY (pedido_venda_id) REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    CONSTRAINT comissoes_vendedor_id_fkey FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id) ON DELETE CASCADE
);

-- Habilita RLS e cria políticas de segurança para a tabela de comissões
ALTER TABLE public.comissoes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.comissoes;
CREATE POLICY "Enable read access for authenticated users" ON public.comissoes
AS PERMISSIVE FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.comissoes;
CREATE POLICY "Enable insert for authenticated users" ON public.comissoes
AS PERMISSIVE FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.comissoes;
CREATE POLICY "Enable update for authenticated users" ON public.comissoes
AS PERMISSIVE FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Enable delete for authenticated users" ON public.comissoes;
CREATE POLICY "Enable delete for authenticated users" ON public.comissoes
AS PERMISSIVE FOR DELETE
TO authenticated
USING (true);


-- Recria a view 'comissoes_view' para garantir que está correta
DROP VIEW IF EXISTS public.comissoes_view;
CREATE OR REPLACE VIEW public.comissoes_view AS
 SELECT c.id,
    c.pedido_venda_id,
    c.vendedor_id,
    v.nome AS vendedor_nome,
    pv.cliente_id,
    cl.nome AS cliente_nome,
    pv.data_venda,
    pv.valor_total AS valor_venda,
    c.base_comissao,
    c.percentual_comissao,
    c.valor_comissao,
    c.status,
    c.data_liberacao,
    c.data_pagamento,
    c.created_at
   FROM (((public.comissoes c
     JOIN public.vendedores v ON ((c.vendedor_id = v.id)))
     JOIN public.pedidos_venda pv ON ((c.pedido_venda_id = pv.id)))
     JOIN public.clientes cl ON ((pv.cliente_id = cl.id)));
