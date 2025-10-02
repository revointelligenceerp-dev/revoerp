-- Remove a coluna de comissão da tabela de vendedores

ALTER TABLE public.vendedores
DROP COLUMN IF EXISTS percentual_comissao;
