-- ============================================================
-- FIX COMPLETO: Remover TODOS os triggers e funções problemáticos
-- Execute este script PRIMEIRO
-- ============================================================

-- Remover TODOS os triggers da tabela auth.users
DO $$
DECLARE
    trigger_record RECORD;
BEGIN
    FOR trigger_record IN 
        SELECT tgname 
        FROM pg_trigger 
        WHERE tgrelid = 'auth.users'::regclass
        AND tgisinternal = false
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON auth.users', trigger_record.tgname);
        RAISE NOTICE 'Dropped trigger: %', trigger_record.tgname;
    END LOOP;
END $$;

-- Remover triggers de profiles se existir no public
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles') THEN
        DROP TRIGGER IF EXISTS on_admin_role_change ON public.profiles;
    END IF;
END $$;

-- Remover funções antigas (ignorar erros)
DROP FUNCTION IF EXISTS public.sync_admin_role() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.is_admin() CASCADE;
DROP FUNCTION IF EXISTS public.on_auth_user_created() CASCADE;
DROP FUNCTION IF EXISTS public.create_profile_for_user() CASCADE;

-- Limpar qualquer outra função que possa estar causando problemas
DROP FUNCTION IF EXISTS sync_admin_role() CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

SELECT 'Limpeza concluída! Agora execute SETUP_SCHEMA_STARTFLIX.sql' as status;
