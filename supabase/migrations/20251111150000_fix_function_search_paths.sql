DO $$
DECLARE
    function_record RECORD;
BEGIN
    FOR function_record IN
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
            AND NOT p.proisagg -- Exclui funções de agregação
    LOOP
        BEGIN
            -- Tenta alterar a função/procedure
            EXECUTE format('ALTER FUNCTION %I.%I(%s) SET search_path = public, pg_temp;',
                           function_record.schema_name,
                           function_record.function_name,
                           function_record.function_args);
            RAISE NOTICE 'Fixed search_path for function: %.%(%)',
                function_record.schema_name,
                function_record.function_name,
                function_record.function_args;
        EXCEPTION
            WHEN undefined_function THEN
                -- Ignora se a função não for encontrada (pode ter sido um procedure)
                CONTINUE;
            WHEN wrong_object_type THEN
                 -- Tenta alterar como procedure se falhar como função
                BEGIN
                    EXECUTE format('ALTER PROCEDURE %I.%I(%s) SET search_path = public, pg_temp;',
                                   function_record.schema_name,
                                   function_record.function_name,
                                   function_record.function_args);
                    RAISE NOTICE 'Fixed search_path for procedure: %.%(%)',
                        function_record.schema_name,
                        function_record.function_name,
                        function_record.function_args;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE WARNING 'Could not alter object %.%(%): %',
                            function_record.schema_name,
                            function_record.function_name,
                            function_record.function_args,
                            SQLERRM;
                END;
            WHEN OTHERS THEN
                RAISE WARNING 'Could not alter function %.%(%): %',
                    function_record.schema_name,
                    function_record.function_name,
                    function_record.function_args,
                    SQLERRM;
        END;
    END LOOP;
END;
$$;
