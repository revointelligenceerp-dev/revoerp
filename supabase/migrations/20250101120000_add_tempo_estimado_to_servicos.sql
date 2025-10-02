-- Adiciona a coluna tempo_estimado na tabela de serviços se ela não existir.
-- Isso corrige o erro "Could not find the 'tempoEstimado' column".

ALTER TABLE public.servicos
ADD COLUMN IF NOT EXISTS tempo_estimado integer;

COMMENT ON COLUMN public.servicos.tempo_estimado IS 'Tempo estimado para a conclusão do serviço, em minutos.';
