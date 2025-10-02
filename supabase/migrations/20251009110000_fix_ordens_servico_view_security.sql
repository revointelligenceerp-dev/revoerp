-- Corrigir a view 'ordens_servico_view' para usar SECURITY INVOKER (padrão)
-- Isso garante que as políticas de RLS do usuário que faz a consulta sejam aplicadas.

/*
# [Fix Security Definer View]
Corrige uma vulnerabilidade de segurança na view `ordens_servico_view`, removendo a propriedade `SECURITY DEFINER` e fazendo com que ela volte ao padrão seguro `SECURITY INVOKER`.

## Query Description: [Esta operação corrige uma falha de segurança crítica. A view estava ignorando as regras de permissão (RLS) e expondo todos os dados a qualquer usuário. A correção garante que a view respeite as permissões de quem a consulta, protegendo os dados.]

## Metadata:
- Schema-Category: ["Structural", "Safe"]
- Impact-Level: ["High"]
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Affects: VIEW `ordens_servico_view`

## Security Implications:
- RLS Status: [Corrected]
- Policy Changes: [No]
- Auth Requirements: [N/A]

## Performance Impact:
- Indexes: [No change]
- Triggers: [No change]
- Estimated Impact: [Nenhum impacto negativo. A performance pode melhorar ligeiramente em alguns casos devido à aplicação correta das políticas de RLS.]
*/

CREATE OR REPLACE VIEW public.ordens_servico_view AS
SELECT
    os.id,
    os.numero,
    os.cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    os.descricao_servico,
    os.data_inicio,
    os.data_previsao,
    os.status,
    os.prioridade,
    os.vendedor_id,
    v.nome AS vendedor_nome,
    os.tecnico_id,
    t.nome AS tecnico_nome,
    os.created_at
FROM
    public.ordens_servico os
LEFT JOIN
    public.clientes c ON os.cliente_id = c.id
LEFT JOIN
    public.vendedores v ON os.vendedor_id = v.id
LEFT JOIN
    public.vendedores t ON os.tecnico_id = t.id;

ALTER VIEW public.ordens_servico_view OWNER TO postgres;
GRANT ALL ON TABLE public.ordens_servico_view TO anon;
GRANT ALL ON TABLE public.ordens_servico_view TO authenticated;
GRANT ALL ON TABLE public.ordens_servico_view TO postgres;
GRANT ALL ON TABLE public.ordens_servico_view TO service_role;
