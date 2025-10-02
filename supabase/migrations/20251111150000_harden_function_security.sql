/*
          # [SECURITY] Harden All Function Security
          [This script iterates through all user-created functions in the public schema and sets a secure search_path to mitigate the 'Function Search Path Mutable' warning. This is a security best practice to prevent potential hijacking attacks.]

          ## Query Description: [This operation inspects database metadata to find functions and alters them to set a fixed search_path. It does not modify any table data and is designed to be safe to run. It will resolve the remaining security advisories related to function search paths.]
          
          ## Metadata:
          - Schema-Category: ["Structural", "Safe"]
          - Impact-Level: ["Low"]
          - Requires-Backup: [false]
          - Reversible: [true]
          
          ## Structure Details:
          [Affects the metadata of functions in the 'public' schema.]
          
          ## Security Implications:
          - RLS Status: [Not Applicable]
          - Policy Changes: [No]
          - Auth Requirements: [Admin privileges to alter functions]
          
          ## Performance Impact:
          - Indexes: [None]
          - Triggers: [None]
          - Estimated Impact: [Negligible performance impact. Improves security.]
          */

DO $$
DECLARE
    func_record RECORD;
BEGIN
    -- Set a secure search_path for the current session
    SET search_path = "$user", public;

    RAISE NOTICE 'Starting function security hardening...';

    -- Iterate over all functions in the public schema created by the current user (or roles they are a member of)
    FOR func_record IN
        SELECT
            p.proname AS function_name,
            pg_get_function_identity_arguments(p.oid) AS function_args,
            n.nspname AS schema_name
        FROM
            pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            LEFT JOIN pg_depend d ON d.objid = p.oid AND d.deptype = 'e'
        WHERE
            n.nspname = 'public'
            AND d.objid IS NULL -- Exclude extension functions
            AND p.prokind = 'f' -- 'f' for regular functions
    LOOP
        BEGIN
            RAISE NOTICE 'Hardening function: %.%(%)', func_record.schema_name, func_record.function_name, func_record.function_args;
            -- Securely set the search_path for each function
            -- This prevents the function from being hijacked by malicious code in other schemas
            EXECUTE format(
                'ALTER FUNCTION %I.%I(%s) SET search_path = "$user", public, extensions;',
                func_record.schema_name,
                func_record.function_name,
                func_record.function_args
            );
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Could not alter function %.%(%): %',
                    func_record.schema_name,
                    func_record.function_name,
                    func_record.function_args,
                    SQLERRM;
        END;
    END LOOP;

    -- Also apply to the procedure we created earlier
    BEGIN
        RAISE NOTICE 'Hardening procedure: public.apply_rls_policies_to_all_tables()';
        ALTER PROCEDURE public.apply_rls_policies_to_all_tables() SET search_path = "$user", public, extensions;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'Could not alter procedure apply_rls_policies_to_all_tables: %', SQLERRM;
    END;

    RAISE NOTICE 'Function security hardening complete.';
END $$;
