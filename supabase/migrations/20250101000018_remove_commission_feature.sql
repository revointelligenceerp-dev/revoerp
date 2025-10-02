-- Remove a view que depende da coluna de comissão
DROP VIEW IF EXISTS public.comissoes_calculadas;

-- Remove a coluna de comissão da tabela de vendedores
ALTER TABLE public.vendedores
DROP COLUMN IF EXISTS percentual_comissao;
