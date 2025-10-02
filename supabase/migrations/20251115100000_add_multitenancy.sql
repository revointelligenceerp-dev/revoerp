/*
          # [Operation Name]
          Estruturação de Multi-Tenancy

          ## Query Description: [Este script introduz a arquitetura de multi-tenancy no banco de dados. Ele cria uma tabela `organizations` para representar cada cliente (inquilino) e uma tabela `profiles` para associar usuários a essas organizações. Em seguida, adiciona uma coluna `organization_id` a todas as tabelas relevantes e ativa a Segurança em Nível de Linha (RLS) para garantir que cada organização só possa acessar seus próprios dados.

          **IMPACTO:** Esta é uma alteração estrutural profunda. Após a aplicação, todos os registros existentes precisarão ser associados a uma organização. As consultas frontend e backend precisarão ser adaptadas para funcionar com o novo contexto de organização. **BACKUP ALTAMENTE RECOMENDADO** antes de aplicar em um banco com dados existentes.]
          
          ## Metadata:
          - Schema-Category: "Structural"
          - Impact-Level: "High"
          - Requires-Backup: true
          - Reversible: false
          
          ## Structure Details:
          - **Tabelas Criadas:** `organizations`, `profiles`
          - **Tabelas Alteradas:** `clientes`, `produtos`, `servicos`, `vendedores`, `pedidos_venda`, `ordens_servico`, `contratos`, e muitas outras.
          - **Colunas Adicionadas:** `organization_id` em múltiplas tabelas.
          - **RLS Ativado:** Em todas as tabelas de dados principais.
          
          ## Security Implications:
          - RLS Status: Habilitado em tabelas críticas.
          - Policy Changes: Novas políticas de isolamento de dados por organização serão criadas.
          - Auth Requirements: As operações dependerão do `organization_id` associado ao usuário autenticado.
          
          ## Performance Impact:
          - Indexes: Adiciona índices na coluna `organization_id` para otimizar as consultas filtradas por organização.
          - Triggers: Adiciona um trigger para criar um perfil de usuário automaticamente.
          - Estimated Impact: Leve impacto negativo em escritas devido a verificações de RLS e triggers. Grande impacto positivo na segurança e escalabilidade dos dados.
          */

-- 1. Tabela para armazenar as organizações (inquilinos)
CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE public.organizations IS 'Armazena as organizações (inquilinos) do sistema.';

-- 2. Tabela de perfis para ligar usuários a organizações
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    full_name TEXT,
    avatar_url TEXT,
    updated_at TIMESTAMPTZ
);
COMMENT ON TABLE public.profiles IS 'Armazena dados de perfil dos usuários e os vincula a uma organização.';

-- 3. Função para criar um perfil automaticamente quando um novo usuário se cadastra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  org_id UUID;
BEGIN
  -- Cria uma nova organização para o novo usuário
  INSERT INTO public.organizations (name)
  VALUES ('Empresa de ' || NEW.email)
  RETURNING id INTO org_id;

  -- Insere o perfil do usuário, vinculando-o à nova organização
  INSERT INTO public.profiles (id, organization_id, full_name, avatar_url)
  VALUES (NEW.id, org_id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'avatar_url');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Trigger para executar a função acima
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Função para obter o organization_id do usuário logado
CREATE OR REPLACE FUNCTION public.get_my_organization_id()
RETURNS UUID AS $$
DECLARE
  org_id UUID;
BEGIN
  SELECT organization_id INTO org_id
  FROM public.profiles
  WHERE id = auth.uid();
  RETURN org_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Adicionar a coluna organization_id e ativar RLS para as tabelas principais
DO $$
DECLARE
    t_name TEXT;
    tables_to_update TEXT[] := ARRAY[
        'clientes', 'produtos', 'servicos', 'vendedores', 'embalagens', 
        'ordens_servico', 'ordem_servico_itens', 'ordem_servico_anexos',
        'pedidos_venda', 'pedido_venda_itens', 'pedido_venda_anexos',
        'faturas_venda', 'fatura_venda_itens',
        'contas_receber', 'contas_pagar',
        'ordens_compra', 'ordem_compra_itens',
        'contratos', 'contrato_anexos',
        'notas_entrada', 'nota_entrada_itens',
        'devolucoes_venda', 'devolucao_venda_itens',
        'crm_oportunidades', 'crm_interacoes',
        'expedicoes', 'expedicao_pedidos',
        'estoque_movimentos'
    ];
BEGIN
    FOREACH t_name IN ARRAY tables_to_update
    LOOP
        -- Adicionar coluna se não existir
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name=t_name AND column_name='organization_id') THEN
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;', t_name);
            EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%s_organization_id ON public.%s(organization_id);', t_name, t_name);
        END IF;

        -- Ativar RLS
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t_name);
        EXECUTE format('ALTER TABLE public.%I FORCE ROW LEVEL SECURITY;', t_name);

        -- Remover políticas antigas para evitar duplicatas
        EXECUTE format('DROP POLICY IF EXISTS "organization_isolation_policy" ON public.%I;', t_name);

        -- Criar política de isolamento
        EXECUTE format('
            CREATE POLICY "organization_isolation_policy" ON public.%I
            FOR ALL
            USING (organization_id = public.get_my_organization_id())
            WITH CHECK (organization_id = public.get_my_organization_id());
        ', t_name);
    END LOOP;
END;
$$;
