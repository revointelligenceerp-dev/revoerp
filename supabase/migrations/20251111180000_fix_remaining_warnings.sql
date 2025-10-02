DO $$
DECLARE
    func_record RECORD;
    alter_sql TEXT;
    func_def TEXT;
BEGIN
    FOR func_record IN
        SELECT
            p.oid,
            p.proname AS function_name,
            n.nspname AS schema_name,
            pg_get_function_identity_arguments(p.oid) AS function_args
        FROM
            pg_proc p
        JOIN
            pg_namespace n ON p.pronamespace = n.oid
        WHERE
            n.nspname = 'public'
            AND p.prokind IN ('f', 'p')
            AND pg_catalog.pg_get_userbyid(p.proowner) != 'supabase_admin'
    LOOP
        BEGIN
            -- Get the function definition to check if search_path is already set
            SELECT pg_get_functiondef(func_record.oid) INTO func_def;

            IF func_def NOT ILIKE '%SET search_path%' THEN
                BEGIN
                    alter_sql := format('ALTER FUNCTION %I.%I(%s) SET search_path = public, extensions;',
                                        func_record.schema_name,
                                        func_record.function_name,
                                        func_record.function_args);
                    RAISE NOTICE 'Executing: %', alter_sql;
                    EXECUTE alter_sql;
                    RAISE NOTICE 'Successfully altered function %', func_record.function_name;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE WARNING 'Could not alter function %.%: %', func_record.function_name, SQLSTATE, SQLERRM;
                END;
            ELSE
                RAISE NOTICE 'Skipping function % as search_path is already set.', func_record.function_name;
            END IF;
        END;
    END LOOP;
END;
$$;
