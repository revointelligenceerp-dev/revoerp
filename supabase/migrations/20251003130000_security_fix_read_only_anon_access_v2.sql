/*
          # [SECURITY] Habilita RLS e Garante Acesso de Leitura para Anônimos
          Este script corrige uma falha de segurança crítica, habilitando o Row Level Security (RLS) em todas as tabelas e criando políticas que permitem que usuários não autenticados (anônimos) apenas leiam os dados. Isso impede que a aplicação quebre por falta de permissão, ao mesmo tempo que protege os dados contra modificações não autorizadas.

          ## Query Description: [Esta operação habilita a segurança em nível de linha (RLS) em todas as tabelas públicas e aplica uma política padrão de "permitir leitura para todos". NENHUM DADO SERÁ PERDIDO. É uma operação segura e essencial para a proteção do banco de dados.]
          
          ## Metadata:
          - Schema-Category: ["Security", "Structural"]
          - Impact-Level: ["High"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Habilita RLS em todas as tabelas do schema 'public'.
          - Cria uma política 'Enable read access for all users' para cada tabela.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [Nenhuma para leitura, autenticação necessária para escrita]
          
          ## Performance Impact:
          - Indexes: [Nenhum]
          - Triggers: [Nenhum]
          - Estimated Impact: [Baixo. A verificação de políticas RLS pode adicionar uma sobrecarga mínima às queries, mas é essencial para a segurança.]
          */

DO $$
DECLARE
    table_record RECORD;
    policy_name TEXT;
BEGIN
    -- Itera sobre todas as tabelas no schema 'public'
    FOR table_record IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        -- Habilita RLS na tabela, se ainda não estiver habilitado
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_record.tablename);

        -- Define o nome da política para evitar conflitos
        policy_name := 'Permitir leitura para todos os usuários em ' || table_record.tablename;

        -- Remove a política antiga se ela existir com o mesmo nome
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON public.%I;', policy_name, table_record.tablename);
        
        -- Cria uma política que permite a seleção (leitura) para todos (anônimos e autenticados)
        EXECUTE format('CREATE POLICY "%s" ON public.%I FOR SELECT USING (true);', policy_name, table_record.tablename);

        -- Remove a política de INSERT antiga se existir
        policy_name := 'Permitir insert para usuários autenticados em ' || table_record.tablename;
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON public.%I;', policy_name, table_record.tablename);

        -- Cria uma política que permite a inserção para usuários autenticados
        EXECUTE format('CREATE POLICY "%s" ON public.%I FOR INSERT WITH CHECK (auth.role() = ''authenticated'');', policy_name, table_record.tablename);

        -- Remove a política de UPDATE antiga se existir
        policy_name := 'Permitir update para usuários autenticados em ' || table_record.tablename;
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON public.%I;', policy_name, table_record.tablename);

        -- Cria uma política que permite a atualização para usuários autenticados
        EXECUTE format('CREATE POLICY "%s" ON public.%I FOR UPDATE USING (auth.role() = ''authenticated'');', policy_name, table_record.tablename);

        -- Remove a política de DELETE antiga se existir
        policy_name := 'Permitir delete para usuários autenticados em ' || table_record.tablename;
        EXECUTE format('DROP POLICY IF EXISTS "%s" ON public.%I;', policy_name, table_record.tablename);

        -- Cria uma política que permite a exclusão para usuários autenticados
        EXECUTE format('CREATE POLICY "%s" ON public.%I FOR DELETE USING (auth.role() = ''authenticated'');', policy_name, table_record.tablename);

        RAISE NOTICE 'RLS habilitado e políticas criadas para a tabela: %', table_record.tablename;
    END LOOP;
END $$;
