DO $$
DECLARE
    func_record RECORD;
    alter_stmt TEXT;
BEGIN
    -- Loop through all functions and procedures in the 'public' schema
    FOR func_record IN
        SELECT
            p.proname AS function_name,
            n.nspname AS schema_name,
            pg_get_function_identity_arguments(p.oid) AS function_args
        FROM
            pg_proc p
        JOIN
            pg_namespace n ON p.pronamespace = n.oid
        JOIN
            pg_authid u ON p.proowner = u.oid
        WHERE
            n.nspname = 'public' -- Apenas funções no schema public
            AND u.rolname = 'postgres' -- Apenas funções criadas pelo usuário
            AND p.prokind IN ('f', 'p') -- Funções e Procedures
    LOOP
        BEGIN
            -- Construct the ALTER FUNCTION statement
            alter_stmt := format(
                'ALTER FUNCTION %I.%I(%s) SET search_path = public, pg_temp;',
                func_record.schema_name,
                func_record.function_name,
                func_record.function_args
            );

            RAISE NOTICE 'Attempting to execute: %', alter_stmt;
            EXECUTE alter_stmt;
            RAISE NOTICE 'Successfully set search_path for %.%', func_record.schema_name, func_record.function_name;

        EXCEPTION
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
