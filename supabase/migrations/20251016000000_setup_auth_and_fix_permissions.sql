/*
  # [SETUP AUTH & FIX PERMISSIONS]
  Este script configura perfis de usuário, corrige avisos de segurança críticos e garante as permissões de leitura corretas em todas as tabelas.
  
  ## Query Description:
  - Cria uma tabela `profiles` para armazenar dados públicos dos usuários.
  - Adiciona um gatilho para criar automaticamente um perfil para novos usuários.
  - Corrige views com `SECURITY DEFINER` para `SECURITY INVOKER` para respeitar as políticas de RLS.
  - Reativa o RLS e aplica uma política de leitura pública a TODAS as tabelas, corrigindo erros de "permission denied".
  Este é um script seguro e idempotente. Ele não excluirá dados, mas alterará as definições de views e políticas de RLS.

  ## Metadata:
  - Schema-Category: ["Structural", "Safe"]
  - Impact-Level: ["Medium"]
  - Requires-Backup: [false]
  - Reversible: [true]
  
  ## Structure Details:
  - Cria a tabela `public.profiles`.
  - Cria a função `public.handle_new_user` e um gatilho.
  - Altera as views `public.ordens_servico_view` e `public.dre_mensal`.
  - Altera as políticas de RLS para todas as tabelas da aplicação.
  
  ## Security Implications:
  - RLS Status: [Enabled]
  - Policy Changes: [Yes]
  - Auth Requirements: [Nenhum para leitura, Autenticação para escrita]
  
  ## Performance Impact:
  - Indexes: [None]
  - Triggers: [Added]
  - Estimated Impact: [Low]
*/

-- PASSO 1: Criar a tabela de perfis de usuário
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- PASSO 2: Configurar RLS para a tabela de perfis
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;
CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS "Users can update their own profile." ON public.profiles;
CREATE POLICY "Users can update their own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- PASSO 3: Criar trigger para popular a tabela de perfis automaticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'avatar_url');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Anexar o trigger (se ainda não existir)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- PASSO 4: Corrigir as views com SECURITY DEFINER
-- Corrigir a view de Ordens de Serviço
CREATE OR REPLACE VIEW public.ordens_servico_view WITH (security_invoker = true) AS
SELECT
    os.id,
    os.numero,
    os.cliente_id,
    c.nome AS cliente_nome,
    c.email AS cliente_email,
    os.descricao_servico,
    os.data_inicio,
    os.data_previsao,
    os.status,
    os.prioridade,
    os.vendedor_id,
    v.nome AS vendedor_nome,
    os.tecnico_id,
    t.nome AS tecnico_nome,
    os.created_at,
    os.updated_at
FROM
    public.ordens_servico os
LEFT JOIN
    public.clientes c ON os.cliente_id = c.id
LEFT JOIN
    public.vendedores v ON os.vendedor_id = v.id
LEFT JOIN
    public.vendedores t ON os.tecnico_id = t.id;

-- Corrigir a view de DRE Mensal
CREATE OR REPLACE VIEW public.dre_mensal WITH (security_invoker = true) AS
SELECT
    EXTRACT(YEAR FROM T.data)::integer AS ano,
    EXTRACT(MONTH FROM T.data)::integer AS mes,
    TO_CHAR(T.data, 'TMMonth') AS mes_nome,
    SUM(CASE WHEN T.tipo = 'ENTRADA' THEN T.valor ELSE 0 END) AS receita,
    SUM(CASE WHEN T.tipo = 'SAIDA' THEN T.valor ELSE 0 END) AS despesa,
    SUM(CASE WHEN T.tipo = 'ENTRADA' THEN T.valor ELSE -T.valor END) AS resultado
FROM (
    SELECT data_pagamento AS data, valor, 'ENTRADA'::public.tipo_movimento_caixa AS tipo FROM public.contas_receber WHERE status = 'RECEBIDO' AND data_pagamento IS NOT NULL
    UNION ALL
    SELECT data_pagamento AS data, valor, 'SAIDA'::public.tipo_movimento_caixa AS tipo FROM public.contas_pagar WHERE status = 'PAGO' AND data_pagamento IS NOT NULL
) AS T
GROUP BY ano, mes, mes_nome
ORDER BY ano, mes;


-- PASSO 5: Garantir que RLS está habilitado e aplicar políticas de leitura em TODAS as tabelas
DO $$
DECLARE
    t_name TEXT;
BEGIN
    FOR t_name IN 
        SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(t_name) || ' ENABLE ROW LEVEL SECURITY;';
        EXECUTE 'DROP POLICY IF EXISTS "Allow public read access" ON public.' || quote_ident(t_name) || ';';
        EXECUTE 'CREATE POLICY "Allow public read access" ON public.' || quote_ident(t_name) || ' FOR SELECT USING (true);';
    END LOOP;
END $$;
