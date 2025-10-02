-- Habilita a extensão pgcrypto se ainda não estiver habilitada
CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

-- 1. Cria a função auxiliar para obter o organization_id do usuário logado de forma segura.
-- Esta função é essencial para as políticas de segurança.
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS UUID AS $$
DECLARE
  org_id UUID;
BEGIN
  -- Acessa o meta dado do usuário autenticado para encontrar seu organization_id
  SELECT raw_user_meta_data->>'organization_id' INTO org_id
  FROM auth.users
  WHERE id = auth.uid();
  RETURN org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Garante que a função use o search_path correto para evitar vulnerabilidades.
ALTER FUNCTION public.get_organization_id() SET search_path = public;

-- 2. Criação Idempotente de Tabelas de Anexos
-- Garante que todas as tabelas de anexos existam antes de aplicar as políticas.

CREATE TABLE IF NOT EXISTS public.cliente_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.contas_pagar_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conta_pagar_id UUID REFERENCES public.contas_pagar(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.contas_receber_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conta_receber_id UUID REFERENCES public.contas_receber(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.contrato_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contrato_id UUID REFERENCES public.contratos(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.ordem_servico_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ordem_servico_id UUID REFERENCES public.ordens_servico(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.pedido_venda_anexos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pedido_id UUID REFERENCES public.pedidos_venda(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    nome_arquivo TEXT NOT NULL, path TEXT NOT NULL, tamanho BIGINT NOT NULL, tipo TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Função para aplicar políticas de RLS de forma segura e idempotente.
CREATE OR REPLACE FUNCTION public.apply_rls_policy(table_name TEXT)
RETURNS void AS $$
BEGIN
  EXECUTE 'ALTER TABLE public.' || quote_ident(table_name) || ' ENABLE ROW LEVEL SECURITY;';
  
  -- Remove políticas antigas para garantir um estado limpo
  EXECUTE 'DROP POLICY IF EXISTS "Allow individual read access" ON public.' || quote_ident(table_name) || ';';
  EXECUTE 'DROP POLICY IF EXISTS "Allow individual insert access" ON public.' || quote_ident(table_name) || ';';
  EXECUTE 'DROP POLICY IF EXISTS "Allow individual update access" ON public.' || quote_ident(table_name) || ';';
  EXECUTE 'DROP POLICY IF EXISTS "Allow individual delete access" ON public.' || quote_ident(table_name) || ';';

  -- Cria as novas políticas que isolam os dados por organização
  EXECUTE 'CREATE POLICY "Allow individual read access" ON public.' || quote_ident(table_name) || 
          ' FOR SELECT USING (organization_id = get_organization_id());';
  EXECUTE 'CREATE POLICY "Allow individual insert access" ON public.' || quote_ident(table_name) || 
          ' FOR INSERT WITH CHECK (organization_id = get_organization_id());';
  EXECUTE 'CREATE POLICY "Allow individual update access" ON public.' || quote_ident(table_name) || 
          ' FOR UPDATE USING (organization_id = get_organization_id());';
  EXECUTE 'CREATE POLICY "Allow individual delete access" ON public.' || quote_ident(table_name) || 
          ' FOR DELETE USING (organization_id = get_organization_id());';
EXCEPTION
  WHEN undefined_table THEN
    RAISE WARNING 'Tabela % não encontrada, pulando aplicação de RLS.', table_name;
END;
$$ LANGUAGE plpgsql;

ALTER FUNCTION public.apply_rls_policy(text) SET search_path = public;

-- 4. Aplica as políticas de RLS em todas as tabelas necessárias.
DO $$
DECLARE
  t_name TEXT;
  tables_to_secure TEXT[] := ARRAY[
    'clientes', 'produtos', 'servicos', 'vendedores', 'embalagens', 'ordens_servico',
    'ordem_servico_itens', 'pedidos_venda', 'pedido_venda_itens', 'faturas_venda',
    'contas_receber', 'contas_pagar', 'ordens_compra', 'ordem_compra_itens',
    'devolucoes_venda', 'devolucao_venda_itens', 'contratos', 'notas_entrada',
    'nota_entrada_itens', 'crm_oportunidades', 'crm_interacoes', 'user_profiles',
    'cliente_anexos', 'contas_pagar_anexos', 'contas_receber_anexos', 'contrato_anexos',
    'ordem_servico_anexos', 'pedido_venda_anexos', 'produto_imagens', 'produto_anuncios',
    'produtos_fornecedores'
  ];
BEGIN
  FOREACH t_name IN ARRAY tables_to_secure
  LOOP
    PERFORM public.apply_rls_policy(t_name);
  END LOOP;
END;
$$;

-- 5. Limpa a função auxiliar após o uso.
DROP FUNCTION IF EXISTS public.apply_rls_policy(text);
