/*
  # [Fix] Corrige a View de Ordens de Serviço

  Este script corrige a definição da view `ordens_servico_view`, que estava causando erros devido a um nome de coluna incorreto e uma falha de segurança.

  ## Descrição da Query:
  - **DROP VIEW IF EXISTS**: Remove a view antiga e inconsistente, se ela existir. Isso garante que a nova definição seja aplicada corretamente.
  - **CREATE OR REPLACE VIEW**: Recria a view com as seguintes correções:
    1.  **Nome da Coluna**: Substitui `valor_total` por `total_servicos`, que é o nome correto da coluna na tabela `ordens_servico`.
    2.  **Segurança**: Adiciona `WITH (security_invoker = true)` para garantir que a view respeite as políticas de segurança (RLS) do usuário que a consulta, corrigindo a falha crítica de segurança `Security Definer View`.

  ## Metadados:
  - Schema-Category: "Structural"
  - Impact-Level: "Low"
  - Requires-Backup: false
  - Reversible: true (pode ser revertida recriando a view com a definição antiga)

  ## Segurança:
  Esta migração corrige uma falha de segurança crítica ao mudar a view de `SECURITY DEFINER` para `SECURITY INVOKER`.
*/
BEGIN;

-- Remove a view antiga para garantir uma recriação limpa
DROP VIEW IF EXISTS public.ordens_servico_view;

-- Recria a view com o nome da coluna correto e a configuração de segurança
CREATE VIEW public.ordens_servico_view WITH (security_invoker = true) AS
SELECT
    os.id,
    os.numero,
    os.descricao_servico,
    os.status,
    os.prioridade,
    os.data_inicio,
    os.data_previsao,
    os.data_conclusao,
    os.total_servicos, -- Coluna corrigida de 'valor_total' para 'total_servicos'
    os.created_at,
    os.cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    os.vendedor_id,
    v.nome AS vendedor_nome,
    os.tecnico_id,
    t.nome AS tecnico_nome
FROM
    public.ordens_servico os
LEFT JOIN
    public.clientes c ON os.cliente_id = c.id
LEFT JOIN
    public.vendedores v ON os.vendedor_id = v.id
LEFT JOIN
    public.vendedores t ON os.tecnico_id = t.id;

COMMIT;
