/*
          # [SEGURANÇA] Habilita RLS e Cria Políticas de Leitura
          Este script ativa a Segurança em Nível de Linha (RLS) em todas as tabelas e cria uma política padrão que permite a leitura pública dos dados.

          ## Query Description: [Este script é uma medida de segurança essencial. Ele garante que, por padrão, os dados só possam ser lidos publicamente, mas não modificados, inseridos ou excluídos sem autenticação. Isso corrige a vulnerabilidade "RLS Disabled in Public".]
          
          ## Metadata:
          - Schema-Category: "Security"
          - Impact-Level: "High"
          - Requires-Backup: false
          - Reversible: true
          
          ## Structure Details:
          - Ativa o RLS para todas as tabelas no schema 'public'.
          - Cria uma política 'Public Read Access' para cada tabela.
          
          ## Security Implications:
          - RLS Status: Enabled
          - Policy Changes: Yes
          - Auth Requirements: Nenhuma para leitura, mas escrita/deleção exigirão novas políticas para usuários autenticados.
          
          ## Performance Impact:
          - Indexes: None
          - Triggers: None
          - Estimated Impact: Baixo. O RLS adiciona uma pequena sobrecarga, mas é crucial para a segurança.
          */

DO $$
DECLARE
    table_record RECORD;
BEGIN
    -- Itera sobre todas as tabelas no schema 'public'
    FOR table_record IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        -- Habilita RLS para a tabela, se ainda não estiver habilitado
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', table_record.tablename);

        -- Cria uma política de leitura pública (SELECT) se ela não existir
        -- Permite que qualquer pessoa (anônima ou autenticada) leia os dados
        EXECUTE format('
            CREATE POLICY "Public Read Access on %1$I"
            ON public.%1$I
            FOR SELECT
            USING (true);
        ', table_record.tablename);
        
        -- Cria uma política para usuários autenticados poderem fazer tudo (INSERT, UPDATE, DELETE)
        -- Esta é uma política permissiva para desenvolvimento. Em produção, seria mais restritiva.
        EXECUTE format('
            CREATE POLICY "Allow all for authenticated users on %1$I"
            ON public.%1$I
            FOR ALL
            USING (auth.role() = ''authenticated'');
        ', table_record.tablename);

    END LOOP;
END $$;
