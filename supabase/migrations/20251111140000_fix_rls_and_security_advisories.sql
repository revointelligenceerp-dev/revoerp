-- =================================================================
-- MIGRATION: Correção Definitiva de Segurança (RLS)
--
-- Este script resolve os avisos de segurança críticos ao:
-- 1. Criar uma função auxiliar segura para obter o ID da organização do usuário.
-- 2. Habilitar a Segurança em Nível de Linha (RLS) em todas as tabelas relevantes.
-- 3. Criar políticas que garantem que os usuários só possam acessar os dados de sua própria organização.
--
-- Este script é IDEMPOTENTE e pode ser executado com segurança várias vezes.
-- =================================================================

-- Passo 1: Criar uma função auxiliar segura para obter o ID da organização do usuário a partir do JWT.
-- Isso também corrige o aviso "Function Search Path Mutable".
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
-- Define um caminho de busca fixo e seguro para a função.
SET search_path = public
AS $$
  -- Extrai 'organization_id' das reivindicações personalizadas do JWT.
  -- Retorna NULL se a reivindicação não estiver presente.
  SELECT nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
$$;

-- Passo 2: Aplicar políticas de RLS a todas as tabelas específicas da organização.
DO $$
DECLARE
    table_name TEXT;
    -- Array de todas as tabelas que devem ser segregadas por organização.
    tables_to_secure TEXT[] := ARRAY[
        'clientes', 'produtos', 'servicos', 'vendedores', 'embalagens',
        'ordens_servico', 'pedidos_venda', 'faturas_venda', 'contas_receber',
        'contas_pagar', 'fluxo_caixa', 'ordens_compra', 'crm_oportunidades',
        'devolucoes_venda', 'contratos', 'notas_entrada', 'expedicoes',
        'configuracoes',
        -- Tabelas de junção/filhas
        'pessoas_contato', 'cliente_anexos', 'produto_imagens', 'produto_anuncios',
        'produtos_fornecedores', 'ordem_servico_itens', 'ordem_servico_anexos',
        'pedido_venda_itens', 'pedido_venda_anexos', 'contas_receber_anexos',
        'contas_pagar_anexos', 'ordem_compra_itens', 'ordem_compra_anexos',
        'crm_interacoes', 'devolucao_venda_itens', 'contrato_anexos',
        'nota_entrada_itens', 'expedicao_pedidos'
    ];
BEGIN
    FOREACH table_name IN ARRAY tables_to_secure
    LOOP
        -- Verifica se a tabela existe no schema público para evitar erros.
        IF EXISTS (
            SELECT 1
            FROM information_schema.tables
            WHERE table_schema = 'public' AND tables.table_name = table_name
        ) THEN
            RAISE NOTICE 'Aplicando RLS para a tabela: %', table_name;

            -- Habilita RLS na tabela se ainda não estiver habilitado.
            EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_name);

            -- Remove políticas antigas para garantir um estado limpo.
            EXECUTE format('DROP POLICY IF EXISTS "Enable CRUD for organization members" ON public.%I;', table_name);

            -- Cria uma política única e abrangente para todas as ações (SELECT, INSERT, UPDATE, DELETE).
            -- A política garante que a coluna 'organization_id' da linha corresponda ao ID da organização do usuário.
            EXECUTE format(
                'CREATE POLICY "Enable CRUD for organization members" ON public.%I FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());',
                table_name
            );
        ELSE
            RAISE WARNING 'Tabela não encontrada, pulando RLS para: %', table_name;
        END IF;
    END LOOP;
END;
$$;

-- Passo 3: Aplicar políticas de RLS especiais para 'organizations' e 'user_profiles'.

-- Para a tabela 'organizations':
-- Usuários só devem poder ver e interagir com o registro de sua própria organização.
RAISE NOTICE 'Aplicando RLS para a tabela: organizations';
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow access to own organization" ON public.organizations;
CREATE POLICY "Allow access to own organization" ON public.organizations
  FOR ALL
  USING (id = public.get_organization_id());

-- Para a tabela 'user_profiles':
-- Usuários devem poder ver e atualizar seu próprio perfil, mas não o de outros.
RAISE NOTICE 'Aplicando RLS para a tabela: user_profiles';
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow individual access" ON public.user_profiles;
CREATE POLICY "Allow individual access" ON public.user_profiles
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

RAISE NOTICE 'Migração de RLS concluída com sucesso.';
