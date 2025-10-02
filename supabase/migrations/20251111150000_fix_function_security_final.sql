DO $$
DECLARE
    func_record RECORD;
    alter_stmt TEXT;
BEGIN
    FOR func_record IN
        SELECT
            p.proname AS function_name,
            n.nspname AS schema_name,
            pg_get_function_identity_arguments(p.oid) AS function_args
        FROM
            pg_proc p
        JOIN
            pg_namespace n ON p.pronamespace = n.oid
        WHERE
            n.nspname = 'public' -- Apenas funções no schema public
            AND p.prokind = 'f' -- Apenas Funções (não procedures ou aggregates)
            AND pg_catalog.pg_get_userbyid(p.proowner) != 'supabase_admin' -- Ignora funções do sistema
    LOOP
        BEGIN
            alter_stmt := format('ALTER FUNCTION %I.%I(%s) SET search_path = public;',
                                 func_record.schema_name,
                                 func_record.function_name,
                                 func_record.function_args);
            RAISE NOTICE 'Tentando executar: %', alter_stmt;
            EXECUTE alter_stmt;
            RAISE NOTICE 'Sucesso para a função: %', func_record.function_name;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Não foi possível alterar a função %.%: %', func_record.schema_name, func_record.function_name, SQLERRM;
        END;
    END LOOP;
END;
$$;
