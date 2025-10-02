/*
          # [CONSOLIDATED SECURITY FIX]
          Este script consolida todas as correções de segurança necessárias para a arquitetura multi-tenant.
          Ele é projetado para ser idempotente e robusto contra timeouts, aplicando alterações de forma explícita e sequencial.

          ## Query Description: [Este script habilita a segurança em nível de linha (RLS) em todas as tabelas relevantes,
          cria as políticas de acesso necessárias para isolar os dados de cada organização e implementa um gatilho
          para injetar o ID da organização no token de autenticação do usuário (JWT). Isso garante que os dados
          de um cliente não possam ser acessados por outro.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Security"]
          - Impact-Level: ["High"]
          - Requires-Backup: true
          - Reversible: false
          
          ## Structure Details:
          - Cria/Altera as funções `get_organization_id` e `handle_new_user`.
          - Cria um gatilho `on_auth_user_created` na tabela `auth.users`.
          - Habilita RLS e cria políticas em ~30 tabelas da aplicação.
          
          ## Security Implications:
          - RLS Status: Habilitado em todas as tabelas de dados.
          - Policy Changes: Sim, políticas de isolamento de tenant são criadas.
          - Auth Requirements: O sistema passa a depender do `organization_id` no JWT do usuário.
          
          ## Performance Impact:
          - Indexes: Nenhum índice novo.
          - Triggers: Adiciona um gatilho na tabela `auth.users`.
          - Estimated Impact: Leve impacto de performance em todas as queries devido à verificação RLS, o que é esperado e necessário para a segurança.
          */

-- Parte 1: Funções e Gatilhos Essenciais

-- Função para obter o organization_id do JWT do usuário autenticado.
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
  SELECT nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
$$;

-- Função de gatilho para criar um perfil de usuário e adicionar o organization_id ao JWT.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  org_id uuid;
  user_full_name text;
BEGIN
  -- 1. Cria uma nova organização para o novo usuário.
  INSERT INTO public.organizations (name)
  VALUES (new.raw_user_meta_data->>'organization_name')
  RETURNING id INTO org_id;

  -- 2. Cria o perfil do usuário, vinculando-o à nova organização.
  user_full_name := new.raw_user_meta_data->>'full_name';
  INSERT INTO public.user_profiles (user_id, organization_id, full_name, avatar_url)
  VALUES (new.id, org_id, user_full_name, new.raw_user_meta_data->>'avatar_url');

  -- 3. Adiciona o organization_id aos metadados do usuário para que ele seja incluído no JWT.
  UPDATE auth.users
  SET raw_app_meta_data = raw_app_meta_data || jsonb_build_object('organization_id', org_id)
  WHERE id = new.id;
  
  RETURN new;
END;
$$;

-- Remove o gatilho antigo se existir e cria o novo.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- Parte 2: Aplicação de Políticas de Segurança (RLS) - Tabela por Tabela

DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizations') THEN ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.organizations; CREATE POLICY "Allow full access to own organization" ON public.organizations FOR ALL USING (id = public.get_organization_id()) WITH CHECK (id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_profiles') THEN ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.user_profiles; CREATE POLICY "Allow full access to own organization" ON public.user_profiles FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'clientes') THEN ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.clientes; CREATE POLICY "Allow full access to own organization" ON public.clientes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'produtos') THEN ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.produtos; CREATE POLICY "Allow full access to own organization" ON public.produtos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'servicos') THEN ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.servicos; CREATE POLICY "Allow full access to own organization" ON public.servicos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendedores') THEN ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.vendedores; CREATE POLICY "Allow full access to own organization" ON public.vendedores FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'embalagens') THEN ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.embalagens; CREATE POLICY "Allow full access to own organization" ON public.embalagens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ordens_servico') THEN ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.ordens_servico; CREATE POLICY "Allow full access to own organization" ON public.ordens_servico FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ordem_servico_itens') THEN ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.ordem_servico_itens; CREATE POLICY "Allow full access to own organization" ON public.ordem_servico_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ordem_servico_anexos') THEN ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.ordem_servico_anexos; CREATE POLICY "Allow full access to own organization" ON public.ordem_servico_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pedidos_venda') THEN ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.pedidos_venda; CREATE POLICY "Allow full access to own organization" ON public.pedidos_venda FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pedido_venda_itens') THEN ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.pedido_venda_itens; CREATE POLICY "Allow full access to own organization" ON public.pedido_venda_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pedido_venda_anexos') THEN ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.pedido_venda_anexos; CREATE POLICY "Allow full access to own organization" ON public.pedido_venda_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'faturas_venda') THEN ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.faturas_venda; CREATE POLICY "Allow full access to own organization" ON public.faturas_venda FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contas_receber') THEN ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.contas_receber; CREATE POLICY "Allow full access to own organization" ON public.contas_receber FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contas_receber_anexos') THEN ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.contas_receber_anexos; CREATE POLICY "Allow full access to own organization" ON public.contas_receber_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contas_pagar') THEN ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.contas_pagar; CREATE POLICY "Allow full access to own organization" ON public.contas_pagar FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contas_pagar_anexos') THEN ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.contas_pagar_anexos; CREATE POLICY "Allow full access to own organization" ON public.contas_pagar_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ordens_compra') THEN ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.ordens_compra; CREATE POLICY "Allow full access to own organization" ON public.ordens_compra FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ordem_compra_itens') THEN ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.ordem_compra_itens; CREATE POLICY "Allow full access to own organization" ON public.ordem_compra_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'estoque_movimentos') THEN ALTER TABLE public.estoque_movimentos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.estoque_movimentos; CREATE POLICY "Allow full access to own organization" ON public.estoque_movimentos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'crm_oportunidades') THEN ALTER TABLE public.crm_oportunidades ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.crm_oportunidades; CREATE POLICY "Allow full access to own organization" ON public.crm_oportunidades FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'comissoes') THEN ALTER TABLE public.comissoes ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.comissoes; CREATE POLICY "Allow full access to own organization" ON public.comissoes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'devolucoes_venda') THEN ALTER TABLE public.devolucoes_venda ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.devolucoes_venda; CREATE POLICY "Allow full access to own organization" ON public.devolucoes_venda FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'devolucao_venda_itens') THEN ALTER TABLE public.devolucao_venda_itens ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.devolucao_venda_itens; CREATE POLICY "Allow full access to own organization" ON public.devolucao_venda_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contratos') THEN ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.contratos; CREATE POLICY "Allow full access to own organization" ON public.contratos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contrato_anexos') THEN ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.contrato_anexos; CREATE POLICY "Allow full access to own organization" ON public.contrato_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notas_entrada') THEN ALTER TABLE public.notas_entrada ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.notas_entrada; CREATE POLICY "Allow full access to own organization" ON public.notas_entrada FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'nota_entrada_itens') THEN ALTER TABLE public.nota_entrada_itens ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.nota_entrada_itens; CREATE POLICY "Allow full access to own organization" ON public.nota_entrada_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'expedicoes') THEN ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.expedicoes; CREATE POLICY "Allow full access to own organization" ON public.expedicoes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'expedicao_pedidos') THEN ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.expedicao_pedidos; CREATE POLICY "Allow full access to own organization" ON public.expedicao_pedidos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'produto_imagens') THEN ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.produto_imagens; CREATE POLICY "Allow full access to own organization" ON public.produto_imagens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'produto_anuncios') THEN ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.produto_anuncios; CREATE POLICY "Allow full access to own organization" ON public.produto_anuncios FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'produtos_fornecedores') THEN ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.produtos_fornecedores; CREATE POLICY "Allow full access to own organization" ON public.produtos_fornecedores FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pessoas_contato') THEN ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.pessoas_contato; CREATE POLICY "Allow full access to own organization" ON public.pessoas_contato FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'cliente_anexos') THEN ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.cliente_anexos; CREATE POLICY "Allow full access to own organization" ON public.cliente_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
DO $$ BEGIN IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'configuracoes') THEN ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY; DROP POLICY IF EXISTS "Allow full access to own organization" ON public.configuracoes; CREATE POLICY "Allow full access to own organization" ON public.configuracoes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id()); END IF; END $$;
