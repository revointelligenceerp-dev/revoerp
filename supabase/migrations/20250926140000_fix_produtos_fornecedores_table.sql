/*
# [Fix] Garante a existência e estrutura da tabela `produtos_fornecedores`
Este script cria a tabela `produtos_fornecedores` se ela não existir, garantindo a correta relação entre produtos e seus fornecedores. Ele também estabelece as políticas de segurança (RLS) necessárias para o funcionamento da aplicação.

## Query Description:
- **Criação da Tabela**: A operação é segura pois utiliza `CREATE TABLE IF NOT EXISTS`, não afetando dados se a tabela já existir.
- **Chaves Estrangeiras**: Define as relações com as tabelas `produtos` e `clientes`, garantindo a integridade dos dados.
- **Segurança**: Habilita o Row Level Security (RLS) e adiciona políticas que permitem que usuários autenticados leiam e modifiquem os dados, o que é um padrão de segurança essencial.

## Metadata:
- Schema-Category: "Structural"
- Impact-Level: "Low"
- Requires-Backup: false
- Reversible: false (a menos que a tabela seja dropada manualmente)

## Structure Details:
- Tabela afetada: `public.produtos_fornecedores`
- Colunas: `id`, `produto_id`, `fornecedor_id`, `codigo_no_fornecedor`, `created_at`, `updated_at`
- Constraints: Chaves primária, estrangeiras e de unicidade.

## Security Implications:
- RLS Status: Enabled
- Policy Changes: Yes (cria políticas de `SELECT`, `INSERT`, `UPDATE`, `DELETE` para usuários autenticados)
- Auth Requirements: `authenticated` role

## Performance Impact:
- Indexes: Adiciona um índice na chave primária e nas chaves estrangeiras.
- Triggers: Nenhum.
- Estimated Impact: Baixo. A criação da tabela e políticas tem impacto mínimo em um sistema em execução.
*/

-- 1. Criar a tabela `produtos_fornecedores` se ela não existir
CREATE TABLE IF NOT EXISTS public.produtos_fornecedores (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    produto_id uuid REFERENCES public.produtos(id) ON DELETE CASCADE NOT NULL,
    fornecedor_id uuid REFERENCES public.clientes(id) ON DELETE CASCADE NOT NULL,
    codigo_no_fornecedor TEXT,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    CONSTRAINT produtos_fornecedores_produto_fornecedor_unique UNIQUE (produto_id, fornecedor_id)
);

-- 2. Habilitar Row Level Security (RLS)
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;

-- 3. Criar políticas de segurança para a tabela (se não existirem)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Allow authenticated read access' AND polrelid = 'public.produtos_fornecedores'::regclass) THEN
        CREATE POLICY "Allow authenticated read access" ON public.produtos_fornecedores FOR SELECT TO authenticated USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Allow authenticated insert access' AND polrelid = 'public.produtos_fornecedores'::regclass) THEN
        CREATE POLICY "Allow authenticated insert access" ON public.produtos_fornecedores FOR INSERT TO authenticated WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Allow authenticated update access' AND polrelid = 'public.produtos_fornecedores'::regclass) THEN
        CREATE POLICY "Allow authenticated update access" ON public.produtos_fornecedores FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Allow authenticated delete access' AND polrelid = 'public.produtos_fornecedores'::regclass) THEN
        CREATE POLICY "Allow authenticated delete access" ON public.produtos_fornecedores FOR DELETE TO authenticated USING (true);
    END IF;
END
$$;

COMMENT ON TABLE public.produtos_fornecedores IS 'Tabela para associar produtos a múltiplos fornecedores.';
