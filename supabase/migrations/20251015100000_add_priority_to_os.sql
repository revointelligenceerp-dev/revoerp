/*
          # [ADICIONA PRIORIDADE ÀS ORDENS DE SERVIÇO]
          Este script adiciona a coluna 'prioridade' à tabela 'ordens_servico' e atualiza a view correspondente.
          Esta é uma operação segura que não apaga dados existentes.
          ## Query Description: [Esta operação adiciona um novo campo para gerenciar a prioridade das Ordens de Serviço. Nenhum dado existente será perdido; as OSs atuais receberão uma prioridade padrão 'MEDIA'.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Adiciona a coluna 'prioridade' à tabela 'ordens_servico'.
          - Recria a view 'ordens_servico_view' para incluir a nova coluna.
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/
-- Adiciona a coluna 'prioridade' à tabela de ordens de serviço com um valor padrão.
ALTER TABLE public.ordens_servico
ADD COLUMN prioridade public.prioridade_os NOT NULL DEFAULT 'MEDIA';

-- Recria a view para incluir a nova coluna 'prioridade' e garantir que todas as colunas necessárias estejam presentes.
DROP VIEW IF EXISTS public.ordens_servico_view;
CREATE VIEW public.ordens_servico_view WITH (security_invoker=on) AS
SELECT
    os.id,
    os.numero,
    os.descricao_servico,
    os.data_inicio,
    os.data_previsao,
    os.status,
    os.prioridade, -- Coluna adicionada
    os.created_at,
    os.updated_at,
    c.id as cliente_id,
    c.nome as cliente_nome,
    c.email as cliente_email,
    v.id as vendedor_id,
    v.nome as vendedor_nome,
    t.id as tecnico_id,
    t.nome as tecnico_nome
FROM
    public.ordens_servico os
LEFT JOIN
    public.clientes c ON os.cliente_id = c.id
LEFT JOIN
    public.vendedores v ON os.vendedor_id = v.id
LEFT JOIN
    public.vendedores t ON os.tecnico_id = t.id;
