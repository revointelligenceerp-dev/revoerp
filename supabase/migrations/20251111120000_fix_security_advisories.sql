/*
          # [SECURITY] Habilita RLS e Cria Políticas de Isolamento Multi-Tenant
          Este script corrige uma vulnerabilidade de segurança crítica, ativando o Row Level Security (RLS)
          e aplicando políticas que garantem que os dados de uma organização não possam ser acessados por outra.

          ## Query Description: [Esta operação ativa as políticas de segurança de dados em nível de linha.
          Após a aplicação, os usuários autenticados só poderão acessar os dados associados à sua própria organização.
          Não há risco de perda de dados, mas é uma mudança fundamental no controle de acesso.]
          
          ## Metadata:
          - Schema-Category: "Security"
          - Impact-Level: "High"
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Ativa o RLS em todas as tabelas de negócio.
          - Cria uma função auxiliar `current_user_organization_id()` para identificar a organização do usuário.
          - Aplica uma política de isolamento padrão em todas as tabelas afetadas.
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes
          - Auth Requirements: JWT de usuário autenticado será necessário para todas as operações de dados.
          
          ## Performance Impact:
          - Indexes: Nenhum
          - Triggers: Nenhum
          - Estimated Impact: Leve sobrecarga nas queries devido à verificação de políticas, mas essencial para a segurança.
          */

-- 1. Função auxiliar para obter o organization_id do usuário atual
CREATE OR REPLACE FUNCTION public.current_user_organization_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT organization_id FROM public.user_profiles WHERE user_id = auth.uid();
$$;

-- 2. Habilita RLS e cria políticas para cada tabela

-- Tabela de Organizações
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own organization" ON public.organizations;
CREATE POLICY "Users can view their own organization" ON public.organizations
  FOR SELECT USING (id = public.current_user_organization_id());

-- Tabela de Perfis de Usuário
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
CREATE POLICY "Users can view their own profile" ON public.user_profiles
  FOR SELECT USING (user_id = auth.uid());
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
CREATE POLICY "Users can update their own profile" ON public.user_profiles
  FOR UPDATE USING (user_id = auth.uid());

-- Política Padrão de Isolamento por Organização
CREATE OR REPLACE PROCEDURE apply_rls_policy(table_name TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_name);
  EXECUTE format('DROP POLICY IF EXISTS "Organization isolation policy" ON public.%I;', table_name);
  EXECUTE format('
    CREATE POLICY "Organization isolation policy" ON public.%I
    FOR ALL
    USING (organization_id = public.current_user_organization_id())
    WITH CHECK (organization_id = public.current_user_organization_id());
  ', table_name);
END;
$$;

-- Aplicar a política em todas as tabelas relevantes
DO $$
DECLARE
  t_name TEXT;
BEGIN
  FOR t_name IN
    SELECT table_name
    FROM information_schema.columns
    WHERE table_schema = 'public' AND column_name = 'organization_id'
      AND table_name NOT IN ('organizations', 'user_profiles')
  LOOP
    CALL apply_rls_policy(t_name);
  END LOOP;
END;
$$;

-- 3. Corrige o search_path das funções existentes (aviso de segurança)
ALTER FUNCTION public.get_visao_cobrancas(p_ano integer, p_mes integer) SET search_path = public;
ALTER FUNCTION public.get_contratos_para_faturar(p_ano integer, p_mes integer) SET search_path = public;
