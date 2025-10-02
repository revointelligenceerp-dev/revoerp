/*
          # [ADICIONAR PRIORIDADE ÀS ORDENS DE SERVIÇO]
          Este script adiciona a coluna 'prioridade' à tabela 'ordens_servico' se ela não existir.
          Também recria a view 'ordens_servico_view' para incluir a nova coluna.
          É uma operação segura e idempotente.

          ## Query Description: [Esta operação adiciona um novo campo para prioridade nas Ordens de Serviço, sem risco de perda de dados. A view associada será atualizada para refletir a nova estrutura.]
          
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabela afetada: public.ordens_servico
          - View afetada: public.ordens_servico_view
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          
          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Nenhum impacto de performance esperado.]
*/

-- Adiciona a coluna 'prioridade' apenas se ela não existir.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'ordens_servico'
    AND column_name = 'prioridade'
  ) THEN
    ALTER TABLE public.ordens_servico
    ADD COLUMN prioridade public.prioridade_os NOT NULL DEFAULT 'MEDIA';
  END IF;
END;
$$;

-- Recria a view para incluir a nova coluna e garantir que está atualizada.
DROP VIEW IF EXISTS public.ordens_servico_view;
CREATE OR REPLACE VIEW public.ordens_servico_view AS
SELECT
    o.id,
    o.numero,
    o.descricao_servico,
    o.data_inicio,
    o.data_previsao,
    o.status,
    o.prioridade, -- Coluna adicionada
    o.created_at,
    o.updated_at,
    c.id as cliente_id,
    c.nome as cliente_nome,
    c.email as cliente_email,
    v.id as vendedor_id,
    v.nome as vendedor_nome,
    t.id as tecnico_id,
    t.nome as tecnico_nome
FROM
    public.ordens_servico o
LEFT JOIN
    public.clientes c ON o.cliente_id = c.id
LEFT JOIN
    public.vendedores v ON o.vendedor_id = v.id
LEFT JOIN
    public.vendedores t ON o.tecnico_id = t.id;
