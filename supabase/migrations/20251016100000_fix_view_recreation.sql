/*
          # [CORREÇÃO DE VIEWS: DROP AND RECREATE]
          Este script corrige o erro 'cannot drop columns from view' ao recriar explicitamente as views 'ordens_servico_view' e 'dre_mensal'.
          Isso garante que as views sejam atualizadas corretamente, mesmo que suas colunas tenham mudado.
          Este script também aplica a correção de segurança 'SECURITY INVOKER'.

          ## Query Description: [Esta operação irá recriar duas views ('ordens_servico_view' e 'dre_mensal') para corrigir um erro de sintaxe e aplicar melhorias de segurança. Nenhuma perda de dados ocorrerá, pois as views são apenas representações dos dados existentes.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [false]
          
          ## Structure Details:
          - Views afetadas: public.ordens_servico_view, public.dre_mensal
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [N/A]
          - Triggers: [N/A]
          - Estimated Impact: [Mínimo. A recriação de views é uma operação rápida.]
*/
-- PASSO 1: DROP VIEWS EXISTENTES PARA EVITAR ERROS DE ALTERAÇÃO
DROP VIEW IF EXISTS public.ordens_servico_view;
DROP VIEW IF EXISTS public.dre_mensal;

-- PASSO 2: RECRIAÇÃO DAS VIEWS COM A ESTRUTURA CORRETA E SEGURANÇA
-- Correção da view ordens_servico_view
CREATE VIEW public.ordens_servico_view
WITH (security_invoker = true)
AS SELECT os.id,
    os.numero,
    os.cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    os.descricao_servico,
    os.vendedor_id,
    v.nome AS vendedor_nome,
    os.tecnico_id,
    t.nome AS tecnico_nome,
    os.status,
    os.prioridade,
    os.data_inicio,
    os.data_previsao,
    os.created_at
   FROM public.ordens_servico os
     LEFT JOIN public.clientes c ON os.cliente_id = c.id
     LEFT JOIN public.vendedores v ON os.vendedor_id = v.id
     LEFT JOIN public.vendedores t ON os.tecnico_id = t.id;

-- Correção da view dre_mensal
CREATE VIEW public.dre_mensal
WITH (security_invoker = true)
AS SELECT date_part('year'::text, d.dia) AS ano,
    date_part('month'::text, d.dia) AS mes,
    to_char(d.dia, 'TMMonth'::text) AS mes_nome,
    COALESCE(sum(r.valor), 0::numeric) AS receita,
    COALESCE(sum(p.valor), 0::numeric) AS despesa,
    COALESCE(sum(r.valor), 0::numeric) - COALESCE(sum(p.valor), 0::numeric) AS resultado
   FROM generate_series(date_trunc('year'::text, now() - '1 year'::interval), date_trunc('month'::text, now()), '1 month'::interval) d(dia)
     LEFT JOIN public.contas_receber r ON date_trunc('month'::text, r.data_pagamento) = d.dia AND r.status = 'RECEBIDO'::public.status_conta_receber
     LEFT JOIN public.contas_pagar p ON date_trunc('month'::text, p.data_pagamento) = d.dia AND p.status = 'PAGO'::public.status_conta_pagar
  GROUP BY (date_part('year'::text, d.dia)), (date_part('month'::text, d.dia)), (to_char(d.dia, 'TMMonth'::text))
  ORDER BY (date_part('year'::text, d.dia)), (date_part('month'::text, d.dia));
