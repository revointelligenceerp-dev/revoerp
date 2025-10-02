/*
          # [Segurança] Habilita Leitura para Anônimos
          [Este script ajusta as políticas de segurança (RLS) para permitir que usuários não autenticados (anônimos) possam apenas ler os dados das tabelas. As operações de escrita, atualização e exclusão continuarão protegidas, exigindo um usuário autenticado. Isso resolve o erro "Failed to fetch" que impede a aplicação de carregar os dados iniciais.]

          ## Query Description: ["Este script modifica as permissões de acesso em todas as tabelas. Ele permite a leitura pública dos dados, mas mantém a proteção contra modificações não autorizadas. Nenhuma perda de dados está prevista."]
          
          ## Metadata:
          - Schema-Category: ["Security"]
          - Impact-Level: ["Medium"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          - Tabelas Afetadas: Todas as tabelas no schema 'public'.
          - Políticas Modificadas: 'Enable read access for all users'.
          
          ## Security Implications:
          - RLS Status: [Enabled]
          - Policy Changes: [Yes]
          - Auth Requirements: [Leitura para 'anon', Escrita para 'authenticated']
          
          ## Performance Impact:
          - Indexes: [No]
          - Triggers: [No]
          - Estimated Impact: [Baixo]
          */

DO $$
DECLARE
    table_name TEXT;
BEGIN
    -- Itera sobre todas as tabelas no schema 'public'
    FOR table_name IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        -- Remove a política antiga se existir, para evitar conflitos
        EXECUTE 'DROP POLICY IF EXISTS "Enable read access for all users" ON public.' || quote_ident(table_name);
        
        -- Cria a nova política que permite leitura para todos (anônimos e autenticados)
        EXECUTE 'CREATE POLICY "Enable read access for all users" ON public.' || quote_ident(table_name)
            || ' FOR SELECT'
            || ' USING (true);';
    END LOOP;
END $$;
