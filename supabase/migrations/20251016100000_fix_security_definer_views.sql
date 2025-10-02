/*
          # [CORREÇÃO DE SEGURANÇA: SECURITY DEFINER VIEWS]
          Este script corrige uma vulnerabilidade de segurança crítica, recriando as views 'ordens_servico_view' e 'dre_mensal' com a propriedade 'SECURITY INVOKER'.
          Isso garante que as permissões de acesso (RLS) do usuário que faz a consulta sejam respeitadas.
          ## Query Description: [Operação segura que não afeta dados. Altera a definição de duas views para corrigir uma falha de segurança, garantindo que as permissões de acesso sejam aplicadas corretamente.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Views afetadas: 'ordens_servico_view', 'dre_mensal'
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- PASSO 1: Remover as views inseguras existentes
DROP VIEW IF EXISTS public.ordens_servico_view;
DROP VIEW IF EXISTS public.dre_mensal;

-- PASSO 2: Recriar a view de Ordens de Serviço com SECURITY INVOKER
CREATE OR REPLACE VIEW public.ordens_servico_view
WITH (security_invoker = true)
AS SELECT
    os.id,
    os.numero,
    os.descricao_servico,
    os.data_inicio,
    os.data_previsao,
    os.status,
    os.prioridade,
    os.created_at,
    os.cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    os.vendedor_id,
    v.nome AS vendedor_nome,
    os.tecnico_id,
    t.nome AS tecnico_nome
   FROM public.ordens_servico os
     LEFT JOIN public.clientes c ON os.cliente_id = c.id
     LEFT JOIN public.vendedores v ON os.vendedor_id = v.id
     LEFT JOIN public.vendedores t ON os.tecnico_id = t.id;

-- PASSO 3: Recriar a view de DRE Mensal com SECURITY INVOKER
CREATE OR REPLACE VIEW public.dre_mensal
WITH (security_invoker = true)
AS SELECT
    date_part('year'::text, f.data) AS ano,
    date_part('month'::text, f.data) AS mes,
    to_char(f.data, 'TMMonth'::text) AS mes_nome,
    sum(
        CASE
            WHEN f.tipo = 'ENTRADA'::public.tipo_movimento_caixa THEN f.valor
            ELSE 0::numeric
        END) AS receita,
    sum(
        CASE
            WHEN f.tipo = 'SAIDA'::public.tipo_movimento_caixa THEN f.valor
            ELSE 0::numeric
        END) AS despesa,
    sum(
        CASE
            WHEN f.tipo = 'ENTRADA'::public.tipo_movimento_caixa THEN f.valor
            ELSE -f.valor
        END) AS resultado
   FROM public.fluxo_caixa f
  GROUP BY (date_part('year'::text, f.data)), (date_part('month'::text, f.data)), (to_char(f.data, 'TMMonth'::text))
  ORDER BY (date_part('year'::text, f.data)), (date_part('month'::text, f.data));
