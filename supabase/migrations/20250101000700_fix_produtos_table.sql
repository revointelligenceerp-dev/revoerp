/*
# [SCHEMA CORRECTION] Adiciona a coluna 'codigo_barras' à tabela 'produtos'
Este script corrige a estrutura da tabela 'produtos', adicionando a coluna 'codigo_barras' que estava ausente, causando um erro de "coluna não encontrada" na aplicação. A coluna também é definida como UNIQUE para garantir a integridade dos dados.

## Query Description: "Esta operação adiciona uma nova coluna à tabela de produtos. É uma alteração estrutural segura e não afeta os dados existentes. A execução é recomendada para alinhar o banco de dados com a aplicação."
## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true

## Structure Details:
- Tabela afetada: public.produtos
- Coluna adicionada: codigo_barras (TEXT, UNIQUE)

## Security Implications:
- RLS Status: Inalterado
- Policy Changes: Não
- Auth Requirements: Não

## Performance Impact:
- Indexes: Um novo índice UNIQUE será criado para a coluna 'codigo_barras'.
- Triggers: Não
- Estimated Impact: Baixo. A adição da coluna é rápida em tabelas com poucos dados.
*/

ALTER TABLE public.produtos
ADD COLUMN IF NOT EXISTS codigo_barras TEXT;

-- Garante que a restrição de unicidade exista, mas sem causar erro se já existir.
DO $$
BEGIN
   IF NOT EXISTS (
       SELECT 1 FROM pg_constraint
       WHERE conname = 'produtos_codigo_barras_key' AND conrelid = 'public.produtos'::regclass
   ) THEN
       ALTER TABLE public.produtos ADD CONSTRAINT produtos_codigo_barras_key UNIQUE (codigo_barras);
   END IF;
END;
$$;
