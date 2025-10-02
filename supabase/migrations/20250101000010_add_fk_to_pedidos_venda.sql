/*
# [Estrutura de Vendas] Adicionar Chaves Estrangeiras à Tabela de Pedidos
Adiciona as colunas `cliente_id` e `vendedor_id` à tabela `pedidos_venda` e estabelece as relações de chave estrangeira.

## Query Description:
Esta operação altera a estrutura da tabela `pedidos_venda` para incluir referências obrigatórias a clientes e opcionais a vendedores. Isso corrige um erro que impedia a criação de novos pedidos. A operação é segura e não afeta dados existentes, pois as colunas são novas.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: true (pode ser revertido com `ALTER TABLE ... DROP COLUMN ...`)

## Structure Details:
- Tabela afetada: `public.pedidos_venda`
- Colunas adicionadas: `cliente_id` (UUID, NOT NULL), `vendedor_id` (UUID, NULL)
- Constraints adicionadas: Foreign Key de `cliente_id` para `clientes(id)`, Foreign Key de `vendedor_id` para `vendedores(id)`.

## Security Implications:
- RLS Status: Habilitado (as políticas existentes não são alteradas).
- Policy Changes: Não.
- Auth Requirements: Não.

## Performance Impact:
- Indexes: Chaves estrangeiras criam índices automaticamente, o que pode melhorar o desempenho de consultas que fazem join entre essas tabelas.
- Triggers: Não.
- Estimated Impact: Positivo para o desempenho de consultas futuras.
*/

-- Adiciona a coluna cliente_id se ela não existir
ALTER TABLE public.pedidos_venda
ADD COLUMN IF NOT EXISTS cliente_id UUID NOT NULL;

-- Adiciona a coluna vendedor_id se ela não existir
ALTER TABLE public.pedidos_venda
ADD COLUMN IF NOT EXISTS vendedor_id UUID;

-- Adiciona a chave estrangeira para clientes, se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM   pg_constraint 
    WHERE  conname = 'pedidos_venda_cliente_id_fkey'
  ) THEN
    ALTER TABLE public.pedidos_venda
    ADD CONSTRAINT pedidos_venda_cliente_id_fkey
    FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE SET NULL;
  END IF;
END;
$$;

-- Adiciona a chave estrangeira para vendedores, se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM   pg_constraint 
    WHERE  conname = 'pedidos_venda_vendedor_id_fkey'
  ) THEN
    ALTER TABLE public.pedidos_venda
    ADD CONSTRAINT pedidos_venda_vendedor_id_fkey
    FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id) ON DELETE SET NULL;
  END IF;
END;
$$;
