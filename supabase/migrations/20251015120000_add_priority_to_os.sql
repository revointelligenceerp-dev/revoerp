/*
          # [ADICIONAR PRIORIDADE ÀS ORDENS DE SERVIÇO]
          Adiciona a coluna 'prioridade' à tabela 'ordens_servico' se ela ainda não existir.
          Esta coluna é essencial para a organização e visualização no quadro Kanban.
          ## Query Description: [Esta operação adiciona uma nova coluna à tabela de ordens de serviço. É uma alteração segura e não destrutiva, que não afeta os dados existentes. A coluna terá um valor padrão 'MEDIA' para todos os registros atuais.]
          ## Metadata:
          - Schema-Category: ["Structural"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          ## Structure Details:
          - Tabela afetada: public.ordens_servico
          - Coluna adicionada: prioridade (tipo: public.prioridade_os)
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [No]
          - Auth Requirements: [N/A]
          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Mínimo. A adição de uma coluna com valor padrão pode levar um tempo em tabelas muito grandes, mas é geralmente rápida.]
*/
ALTER TABLE public.ordens_servico
ADD COLUMN IF NOT EXISTS prioridade public.prioridade_os NOT NULL DEFAULT 'MEDIA';

COMMENT ON COLUMN public.ordens_servico.prioridade IS 'Define a prioridade da Ordem de Serviço para organização no Kanban.';
