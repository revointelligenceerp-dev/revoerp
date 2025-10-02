-- =================================================================
-- MIGRATION: FINAL MULTI-TENANCY & RLS FIX
-- DESCRIPTION: This script provides a definitive fix for multi-tenancy setup and RLS policies.
-- It is designed to be idempotent and avoid connection timeouts by breaking operations into smaller, explicit steps.
-- =================================================================

-- PART 1: Core Multi-Tenancy Tables
-- Ensures the fundamental tables for organizations and user profiles exist.
CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id)
);

-- PART 2: Helper Functions & Triggers
-- These are crucial for injecting the organization_id into the JWT and for RLS policies to work.

-- Function to get the current user's organization_id from the JWT claims.
CREATE OR REPLACE FUNCTION public.get_organization_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT nullif(current_setting('request.jwt.claims', true)::json->>'organization_id', '')::uuid;
$$;

-- Trigger function to automatically create an organization and profile for a new user,
-- and most importantly, inject the organization_id into the user's app metadata.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  new_org_id UUID;
BEGIN
  -- Create a new organization for the new user
  INSERT INTO public.organizations (name)
  VALUES (NEW.raw_user_meta_data->>'full_name' || '''s Organization')
  RETURNING id INTO new_org_id;

  -- Create a user profile linking the user to the new organization
  INSERT INTO public.user_profiles (user_id, organization_id, full_name, avatar_url)
  VALUES (NEW.id, new_org_id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'avatar_url');

  -- Inject the organization_id into the user's app metadata (this will be in the JWT)
  UPDATE auth.users
  SET raw_app_meta_data = raw_app_meta_data || jsonb_build_object('organization_id', new_org_id)
  WHERE id = NEW.id;
  
  RETURN NEW;
END;
$$;

-- Drop existing trigger to ensure a clean slate
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create the trigger that fires the function when a new user signs up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();


-- PART 3: Add 'organization_id' column to all necessary tables
-- This is done idempotently using DO blocks to prevent errors on re-runs.

DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.clientes'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.clientes ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.produtos'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.produtos ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.servicos'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.servicos ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.vendedores'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.vendedores ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.embalagens'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.embalagens ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.ordens_servico'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.ordens_servico ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.pedidos_venda'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.pedidos_venda ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.faturas_venda'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.faturas_venda ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.contas_receber'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.contas_receber ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.contas_pagar'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.contas_pagar ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.fluxo_caixa'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.fluxo_caixa ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.ordens_compra'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.ordens_compra ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.crm_oportunidades'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.crm_oportunidades ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.contratos'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.contratos ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.notas_entrada'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.notas_entrada ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.devolucoes_venda'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.devolucoes_venda ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.expedicoes'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.expedicoes ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_attribute WHERE attrelid = 'public.configuracoes'::regclass AND attname = 'organization_id') THEN
    ALTER TABLE public.configuracoes ADD COLUMN organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE;
  END IF;
END $$;


-- PART 4: Enable RLS and Create Policies for each table
-- This is the core of the multi-tenancy security.

-- Helper procedure to apply RLS policy idempotently
CREATE OR REPLACE PROCEDURE apply_rls_policy(table_name TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_name);
  EXECUTE format('DROP POLICY IF EXISTS "Allow full access to own organization" ON public.%I;', table_name);
  EXECUTE format('CREATE POLICY "Allow full access to own organization" ON public.%I FOR ALL USING (organization_id = public.get_organization_id()) WITH CHECK (organization_id = public.get_organization_id());', table_name);
END;
$$;

-- Apply policies to all tables
CALL apply_rls_policy('clientes');
CALL apply_rls_policy('produtos');
CALL apply_rls_policy('servicos');
CALL apply_rls_policy('vendedores');
CALL apply_rls_policy('embalagens');
CALL apply_rls_policy('ordens_servico');
CALL apply_rls_policy('pedidos_venda');
CALL apply_rls_policy('faturas_venda');
CALL apply_rls_policy('contas_receber');
CALL apply_rls_policy('contas_pagar');
CALL apply_rls_policy('fluxo_caixa');
CALL apply_rls_policy('ordens_compra');
CALL apply_rls_policy('crm_oportunidades');
CALL apply_rls_policy('contratos');
CALL apply_rls_policy('notas_entrada');
CALL apply_rls_policy('devolucoes_venda');
CALL apply_rls_policy('expedicoes');
CALL apply_rls_policy('configuracoes');

-- Also secure the user_profiles table itself
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
CREATE POLICY "Users can view their own profile" ON public.user_profiles FOR SELECT USING (user_id = auth.uid());
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
CREATE POLICY "Users can update their own profile" ON public.user_profiles FOR UPDATE USING (user_id = auth.uid());

-- And the organizations table
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can access their own organization" ON public.organizations;
CREATE POLICY "Users can access their own organization" ON public.organizations FOR ALL USING (id = public.get_organization_id());

-- Drop the helper procedure
DROP PROCEDURE IF EXISTS apply_rls_policy(TEXT);

-- =================================================================
-- END OF MIGRATION
-- =================================================================
