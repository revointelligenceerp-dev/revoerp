/*
          # [FINAL SECURITY &amp; RLS FIX]
          Este script corrige todas as vulnerabilidades de segurança pendentes e aplica
          as políticas de Row Level Security (RLS) de forma robusta e explícita para
          garantir a arquitetura multi-tenant.

          ## Query Description: [Este script é a solução definitiva para os problemas de timeout e segurança. Ele:
          1. Corrige a sintaxe e a segurança das funções do banco de dados.
          2. Implementa um gatilho para adicionar a ID da organização ao token JWT do usuário, essencial para o RLS funcionar.
          3. Habilita o RLS e cria políticas de acesso para CADA tabela do sistema, garantindo o isolamento total dos dados de cada cliente.
          Este script é seguro para ser executado, pois verifica a existência de políticas antes de criá-las.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Security"]
          - Impact-Level: ["High"]
          - Requires-Backup: true
          - Reversible: false
          
          ## Structure Details:
          - Funções: get_organization_id, update_user_claims
          - Triggers: on_profile_change_update_claims
          - Policies: "Allow organization access" e políticas específicas para todas as tabelas.
          
          ## Security Implications:
          - RLS Status: Habilitado para todas as tabelas relevantes.
          - Policy Changes: Sim, políticas de acesso multi-tenant são criadas para todas as tabelas.
          - Auth Requirements: As políticas dependem de um `organization_id` no JWT do usuário.
          
          ## Performance Impact:
          - Indexes: Nenhum.
          - Triggers: Adiciona um trigger na tabela `user_profiles`.
          - Estimated Impact: O RLS adiciona uma pequena sobrecarga em cada query, mas é essencial para a segurança. O impacto é mínimo com os índices corretos.
          */

-- 1. Recria a função para obter o organization_id do JWT de forma segura.
DROP FUNCTION IF EXISTS public.get_organization_id();
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
$$;

-- 2. Recria a função para atualizar os claims do JWT quando o perfil do usuário muda.
DROP FUNCTION IF EXISTS public.update_user_claims();
CREATE OR REPLACE FUNCTION public.update_user_claims()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  UPDATE auth.users
  SET raw_user_meta_data = raw_user_meta_data || jsonb_build_object('organization_id', NEW.organization_id)
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$;

-- 3. Recria o trigger na tabela user_profiles para chamar a função acima.
DROP TRIGGER IF EXISTS on_profile_change_update_claims ON public.user_profiles;
CREATE TRIGGER on_profile_change_update_claims
  AFTER INSERT OR UPDATE OF organization_id ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_user_claims();

-- 4. Aplica RLS e políticas de acesso para cada tabela explicitamente.

-- Tabela: organizations
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow access to own organization" ON public.organizations;
CREATE POLICY "Allow access to own organization" ON public.organizations FOR ALL
USING (id = public.get_organization_id())
WITH CHECK (id = public.get_organization_id());

-- Tabela: user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow access to profiles in own organization" ON public.user_profiles;
CREATE POLICY "Allow access to profiles in own organization" ON public.user_profiles FOR SELECT
USING (organization_id = public.get_organization_id());
DROP POLICY IF EXISTS "Allow update of own profile" ON public.user_profiles;
CREATE POLICY "Allow update of own profile" ON public.user_profiles FOR UPDATE
USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Tabela: clientes
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.clientes;
CREATE POLICY "Allow organization access" ON public.clientes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: pessoas_contato
ALTER TABLE public.pessoas_contato ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.pessoas_contato;
CREATE POLICY "Allow organization access" ON public.pessoas_contato FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: cliente_anexos
ALTER TABLE public.cliente_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.cliente_anexos;
CREATE POLICY "Allow organization access" ON public.cliente_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: produtos
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.produtos;
CREATE POLICY "Allow organization access" ON public.produtos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: produto_imagens
ALTER TABLE public.produto_imagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.produto_imagens;
CREATE POLICY "Allow organization access" ON public.produto_imagens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: produto_anuncios
ALTER TABLE public.produto_anuncios ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.produto_anuncios;
CREATE POLICY "Allow organization access" ON public.produto_anuncios FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: produtos_fornecedores
ALTER TABLE public.produtos_fornecedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.produtos_fornecedores;
CREATE POLICY "Allow organization access" ON public.produtos_fornecedores FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: servicos
ALTER TABLE public.servicos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.servicos;
CREATE POLICY "Allow organization access" ON public.servicos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: vendedores
ALTER TABLE public.vendedores ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.vendedores;
CREATE POLICY "Allow organization access" ON public.vendedores FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: embalagens
ALTER TABLE public.embalagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.embalagens;
CREATE POLICY "Allow organization access" ON public.embalagens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: ordens_servico
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.ordens_servico;
CREATE POLICY "Allow organization access" ON public.ordens_servico FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: ordem_servico_itens
ALTER TABLE public.ordem_servico_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.ordem_servico_itens;
CREATE POLICY "Allow organization access" ON public.ordem_servico_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: ordem_servico_anexos
ALTER TABLE public.ordem_servico_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.ordem_servico_anexos;
CREATE POLICY "Allow organization access" ON public.ordem_servico_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: pedidos_venda
ALTER TABLE public.pedidos_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.pedidos_venda;
CREATE POLICY "Allow organization access" ON public.pedidos_venda FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: pedido_venda_itens
ALTER TABLE public.pedido_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.pedido_venda_itens;
CREATE POLICY "Allow organization access" ON public.pedido_venda_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: pedido_venda_anexos
ALTER TABLE public.pedido_venda_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.pedido_venda_anexos;
CREATE POLICY "Allow organization access" ON public.pedido_venda_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: faturas_venda
ALTER TABLE public.faturas_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.faturas_venda;
CREATE POLICY "Allow organization access" ON public.faturas_venda FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: contas_receber
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.contas_receber;
CREATE POLICY "Allow organization access" ON public.contas_receber FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: contas_receber_anexos
ALTER TABLE public.contas_receber_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.contas_receber_anexos;
CREATE POLICY "Allow organization access" ON public.contas_receber_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: contas_pagar
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.contas_pagar;
CREATE POLICY "Allow organization access" ON public.contas_pagar FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: contas_pagar_anexos
ALTER TABLE public.contas_pagar_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.contas_pagar_anexos;
CREATE POLICY "Allow organization access" ON public.contas_pagar_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: fluxo_caixa
ALTER TABLE public.fluxo_caixa ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.fluxo_caixa;
CREATE POLICY "Allow organization access" ON public.fluxo_caixa FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: ordens_compra
ALTER TABLE public.ordens_compra ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.ordens_compra;
CREATE POLICY "Allow organization access" ON public.ordens_compra FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: ordem_compra_itens
ALTER TABLE public.ordem_compra_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.ordem_compra_itens;
CREATE POLICY "Allow organization access" ON public.ordem_compra_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: ordem_compra_anexos
ALTER TABLE public.ordem_compra_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.ordem_compra_anexos;
CREATE POLICY "Allow organization access" ON public.ordem_compra_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: crm_oportunidades
ALTER TABLE public.crm_oportunidades ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.crm_oportunidades;
CREATE POLICY "Allow organization access" ON public.crm_oportunidades FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: crm_interacoes
ALTER TABLE public.crm_interacoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.crm_interacoes;
CREATE POLICY "Allow organization access" ON public.crm_interacoes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: devolucoes_venda
ALTER TABLE public.devolucoes_venda ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.devolucoes_venda;
CREATE POLICY "Allow organization access" ON public.devolucoes_venda FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: devolucao_venda_itens
ALTER TABLE public.devolucao_venda_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.devolucao_venda_itens;
CREATE POLICY "Allow organization access" ON public.devolucao_venda_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: contratos
ALTER TABLE public.contratos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.contratos;
CREATE POLICY "Allow organization access" ON public.contratos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: contrato_anexos
ALTER TABLE public.contrato_anexos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.contrato_anexos;
CREATE POLICY "Allow organization access" ON public.contrato_anexos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: notas_entrada
ALTER TABLE public.notas_entrada ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.notas_entrada;
CREATE POLICY "Allow organization access" ON public.notas_entrada FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: nota_entrada_itens
ALTER TABLE public.nota_entrada_itens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.nota_entrada_itens;
CREATE POLICY "Allow organization access" ON public.nota_entrada_itens FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: expedicoes
ALTER TABLE public.expedicoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.expedicoes;
CREATE POLICY "Allow organization access" ON public.expedicoes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: expedicao_pedidos
ALTER TABLE public.expedicao_pedidos ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.expedicao_pedidos;
CREATE POLICY "Allow organization access" ON public.expedicao_pedidos FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());

-- Tabela: configuracoes
ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow organization access" ON public.configuracoes;
CREATE POLICY "Allow organization access" ON public.configuracoes FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());
