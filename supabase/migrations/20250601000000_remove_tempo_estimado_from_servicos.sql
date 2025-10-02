/*
  # [Operação Estrutural] Remoção da coluna 'tempo_estimado' da tabela 'servicos'
  [Esta operação remove a coluna 'tempo_estimado' da tabela 'servicos', simplificando a entidade de serviço.]

  ## Query Description: [Esta operação removerá a coluna 'tempo_estimado' e todos os seus dados. A ação é irreversível. Certifique-se de que a aplicação não depende mais deste campo antes de prosseguir.]
  
  ## Metadata:
  - Schema-Category: "Structural"
  - Impact-Level: "Medium"
  - Requires-Backup: true
  - Reversible: false
  
  ## Structure Details:
  - Tabela afetada: public.servicos
  - Coluna removida: tempo_estimado
  
  ## Security Implications:
  - RLS Status: Inalterado
  - Policy Changes: Não
  - Auth Requirements: Não
  
  ## Performance Impact:
  - Indexes: Nenhum índice associado a esta coluna será afetado.
  - Triggers: Nenhum.
  - Estimated Impact: Baixo. A remoção da coluna pode causar um breve bloqueio na tabela.
*/
ALTER TABLE public.servicos
DROP COLUMN IF EXISTS tempo_estimado;
