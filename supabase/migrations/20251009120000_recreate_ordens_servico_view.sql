/*
# [Recriação da View de Ordens de Serviço]
Este script corrige um estado inconsistente da view 'ordens_servico_view', que estava causando erros de migração. Ele também aplica a correção de segurança 'SECURITY INVOKER'.

## Query Description: [Este script irá apagar e recriar a 'tabela virtual' de ordens de serviço. NENHUM DADO SERÁ PERDIDO, pois a view é apenas uma representação dos dados das tabelas originais.]

## Metadata:
- Schema-Category: ["Structural"]
- Impact-Level: ["Low"]
- Requires-Backup: [false]
- Reversible: [true]

## Structure Details:
- Apaga a view: public.ordens_servico_view
- Recria a view: public.ordens_servico_view

## Security Implications:
- RLS Status: [N/A para a view em si, mas a nova view respeitará o RLS]
- Policy Changes: [Não]
- Auth Requirements: [A nova view usará a política 'SECURITY INVOKER']

## Performance Impact:
- Indexes: [Nenhum]
- Triggers: [Nenhum]
- Estimated Impact: [Nenhum impacto negativo. A view otimiza as leituras.]
*/

-- Apaga a view existente para garantir um estado limpo
DROP VIEW IF EXISTS public.ordens_servico_view;

-- Recria a view com a definição correta e segura
CREATE VIEW public.ordens_servico_view
WITH (security_invoker = true)
AS
SELECT
    os.id,
    os.numero,
    os.descricao_servico,
    os.data_inicio,
    os.data_previsao,
    os.data_conclusao,
    os.status,
    os.prioridade,
    os.valor_total,
    os.created_at,
    c.id as cliente_id,
    c.nome as cliente_nome,
    c.email as cliente_email,
    v.id as vendedor_id,
    v.nome as vendedor_nome,
    t.id as tecnico_id,
    t.nome as tecnico_nome
FROM
    public.ordens_servico os
LEFT JOIN public.clientes c ON os.cliente_id = c.id
LEFT JOIN public.vendedores v ON os.vendedor_id = v.id
LEFT JOIN public.vendedores t ON os.tecnico_id = t.id;

-- Garante que o usuário autenticado possa ler a view
GRANT SELECT ON public.ordens_servico_view TO authenticated;
GRANT SELECT ON public.ordens_servico_view TO anon;
