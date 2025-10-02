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
            AND p.prokind IN ('f', 'p') -- Funções e Procedures
    LOOP
        BEGIN
            alter_stmt := format('ALTER FUNCTION %I.%I(%s) SET search_path = public;',
                                 func_record.schema_name,
                                 func_record.function_name,
                                 func_record.function_args);
            RAISE NOTICE 'Executando: %', alter_stmt;
            EXECUTE alter_stmt;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Não foi possível alterar a função %.%: %',
                              func_record.schema_name,
                              func_record.function_name,
                              SQLERRM;
        END;
    END LOOP;
END $$;
