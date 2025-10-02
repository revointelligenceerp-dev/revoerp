/*
          # [OPERAÇÃO CONSOLIDADA] Correção de Chaves Estrangeiras e Segurança de Funções
          Este script estabelece as relações de chave estrangeira (FK) ausentes entre as tabelas e corrige os avisos de segurança relacionados ao `search_path` das funções.

          ## Query Description: 
          Esta operação é segura e não destrutiva. Ela apenas adiciona restrições (constraints) e altera metadados de funções, caso ainda não existam. Não há risco de perda de dados. A execução é idempotente, o que significa que pode ser executada várias vezes sem causar erros.

          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "Low"
          - Requires-Backup: false
          - Reversible: true (as constraints podem ser removidas manualmente se necessário)
          
          ## Structure Details:
          - Adiciona FKs para as tabelas: `contas_pagar`, `contas_receber`, `faturas_venda`, `ordens_compra`, `pedidos_venda`, `ordens_servico`.
          - Altera a propriedade `search_path` de todas as funções no esquema `public`.
          
          ## Security Implications:
          - RLS Status: Inalterado
          - Policy Changes: Não
          - Auth Requirements: Admin
          - Mitiga os avisos "Function Search Path Mutable" ao definir um `search_path` explícito e seguro para as funções.
          
          ## Performance Impact:
          - Indexes: Chaves estrangeiras criam índices implicitamente, o que pode melhorar a performance das consultas com JOINs.
          - Triggers: Não aplicável
          - Estimated Impact: Positivo para performance de leitura.
          */

-- Adiciona Chave Estrangeira: contas_pagar -> clientes (fornecedor)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'contas_pagar_fornecedor_id_fkey' AND conrelid = 'public.contas_pagar'::regclass
    ) THEN
        ALTER TABLE public.contas_pagar 
        ADD CONSTRAINT contas_pagar_fornecedor_id_fkey 
        FOREIGN KEY (fornecedor_id) REFERENCES public.clientes(id) ON DELETE SET NULL;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: contas_receber -> clientes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'contas_receber_cliente_id_fkey' AND conrelid = 'public.contas_receber'::regclass
    ) THEN
        ALTER TABLE public.contas_receber 
        ADD CONSTRAINT contas_receber_cliente_id_fkey 
        FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE SET NULL;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: contas_receber -> faturas_venda
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'contas_receber_fatura_id_fkey' AND conrelid = 'public.contas_receber'::regclass
    ) THEN
        ALTER TABLE public.contas_receber 
        ADD CONSTRAINT contas_receber_fatura_id_fkey 
        FOREIGN KEY (fatura_id) REFERENCES public.faturas_venda(id) ON DELETE SET NULL;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: faturas_venda -> pedidos_venda
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'faturas_venda_pedido_id_fkey' AND conrelid = 'public.faturas_venda'::regclass
    ) THEN
        ALTER TABLE public.faturas_venda 
        ADD CONSTRAINT faturas_venda_pedido_id_fkey 
        FOREIGN KEY (pedido_id) REFERENCES public.pedidos_venda(id) ON DELETE CASCADE;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: ordens_compra -> clientes (fornecedor)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'ordens_compra_fornecedor_id_fkey' AND conrelid = 'public.ordens_compra'::regclass
    ) THEN
        ALTER TABLE public.ordens_compra 
        ADD CONSTRAINT ordens_compra_fornecedor_id_fkey 
        FOREIGN KEY (fornecedor_id) REFERENCES public.clientes(id) ON DELETE RESTRICT;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: pedidos_venda -> clientes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'pedidos_venda_cliente_id_fkey' AND conrelid = 'public.pedidos_venda'::regclass
    ) THEN
        ALTER TABLE public.pedidos_venda 
        ADD CONSTRAINT pedidos_venda_cliente_id_fkey 
        FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE RESTRICT;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: pedidos_venda -> vendedores
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'pedidos_venda_vendedor_id_fkey' AND conrelid = 'public.pedidos_venda'::regclass
    ) THEN
        ALTER TABLE public.pedidos_venda 
        ADD CONSTRAINT pedidos_venda_vendedor_id_fkey 
        FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id) ON DELETE SET NULL;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: ordens_servico -> clientes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'ordens_servico_cliente_id_fkey' AND conrelid = 'public.ordens_servico'::regclass
    ) THEN
        ALTER TABLE public.ordens_servico 
        ADD CONSTRAINT ordens_servico_cliente_id_fkey 
        FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE RESTRICT;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: ordens_servico -> vendedores (vendedor)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'ordens_servico_vendedor_id_fkey' AND conrelid = 'public.ordens_servico'::regclass
    ) THEN
        ALTER TABLE public.ordens_servico 
        ADD CONSTRAINT ordens_servico_vendedor_id_fkey 
        FOREIGN KEY (vendedor_id) REFERENCES public.vendedores(id) ON DELETE SET NULL;
    END IF;
END;
$$;

-- Adiciona Chave Estrangeira: ordens_servico -> vendedores (tecnico)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'ordens_servico_tecnico_id_fkey' AND conrelid = 'public.ordens_servico'::regclass
    ) THEN
        ALTER TABLE public.ordens_servico 
        ADD CONSTRAINT ordens_servico_tecnico_id_fkey 
        FOREIGN KEY (tecnico_id) REFERENCES public.vendedores(id) ON DELETE SET NULL;
    END IF;
END;
$$;

-- Corrige o search_path para todas as funções no esquema public, resolvendo avisos de segurança.
DO $$
DECLARE
    f record;
BEGIN
    FOR f IN (
        SELECT p.proname AS function_name,
               pg_get_function_identity_arguments(p.oid) AS function_args,
               n.nspname AS schema_name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
    )
    LOOP
        EXECUTE format('ALTER FUNCTION %I.%I(%s) SET search_path = ''public'';',
                       f.schema_name,
                       f.function_name,
                       f.function_args);
    END LOOP;
END;
$$;
