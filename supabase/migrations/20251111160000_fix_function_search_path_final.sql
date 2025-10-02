DO $$
DECLARE
    func_record RECORD;
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
            EXECUTE format('ALTER FUNCTION %I.%I(%s) SET search_path = public',
                           func_record.schema_name,
                           func_record.function_name,
                           func_record.function_args);
            RAISE NOTICE 'Set search_path for function: %.%(%)',
                         func_record.schema_name,
                         func_record.function_name,
                         func_record.function_args;
        EXCEPTION
            WHEN insufficient_privilege THEN
                RAISE NOTICE 'Skipping function %.%(%) due to insufficient privileges.',
                              func_record.schema_name,
                              func_record.function_name,
                              func_record.function_args;
            WHEN OTHERS THEN
                RAISE WARNING 'Could not alter function %.%(%): %',
                              func_record.schema_name,
                              func_record.function_name,
                              func_record.function_args,
                              SQLERRM;
        END;
    END LOOP;
END;
$$;
