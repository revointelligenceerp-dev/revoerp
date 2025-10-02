DO $$
DECLARE
    f_rec record;
BEGIN
    FOR f_rec IN
        SELECT p.proname AS func_name,
               pg_get_function_identity_arguments(p.oid) AS func_args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public' -- Apenas funções no schema público
          AND p.prokind = 'f' -- Apenas funções normais (não procedimentos ou agregados)
          AND NOT EXISTS ( -- Exclui funções que são parte de extensões do Postgres
              SELECT 1
              FROM pg_depend d
              JOIN pg_extension e ON d.refobjid = e.oid
              WHERE d.objid = p.oid AND d.deptype = 'e'
          )
          -- Exclui funções que já têm o search_path configurado para 'public'
          AND NOT EXISTS (
              SELECT 1
              FROM unnest(p.proconfig) AS config
              WHERE config LIKE 'search_path=public'
          )
    LOOP
        BEGIN
            RAISE NOTICE 'Configurando search_path para a função: % (%)', f_rec.func_name, f_rec.func_args;
            EXECUTE format('ALTER FUNCTION public.%I(%s) SET search_path = public;',
                           f_rec.func_name,
                           f_rec.func_args);
        EXCEPTION
            WHEN OTHERS THEN
                RAISE WARNING 'Não foi possível alterar a função %. Erro: %', f_rec.func_name, SQLERRM;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
