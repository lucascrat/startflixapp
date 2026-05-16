-- ============================================================
-- VERIFICAR E MIGRAR APPS PARA O SCHEMA STARTFLIX
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- 1. Verificar se existem apps no schema startflix
SELECT 'Apps em startflix.apps:' as info;
SELECT id, name, is_active FROM startflix.apps;

-- 2. Verificar se existem apps no schema public (antigo)
SELECT 'Apps em public.apps (se existir):' as info;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'apps') THEN
        RAISE NOTICE 'Tabela public.apps existe. Verificando dados...';
    ELSE
        RAISE NOTICE 'Tabela public.apps não existe.';
    END IF;
END $$;

-- 3. Se a tabela public.apps existir, migrar dados
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'apps') THEN
        INSERT INTO startflix.apps (id, name, description, image_url, download_url, is_active, created_at)
        SELECT id, name, description, image_url, download_url, is_active, created_at
        FROM public.apps
        WHERE NOT EXISTS (
            SELECT 1 FROM startflix.apps sa WHERE sa.id = public.apps.id
        );
        RAISE NOTICE 'Migração de apps concluída.';
    END IF;
END $$;

-- 4. Verificar resultado
SELECT 'Resultado final:' as info;
SELECT id, name, is_active, image_url FROM startflix.apps;

-- 5. Se não tiver nenhum app, criar um app de exemplo
INSERT INTO startflix.apps (name, description, image_url, is_active)
SELECT 'App Exemplo', 'Um app de exemplo para teste', null, true
WHERE NOT EXISTS (SELECT 1 FROM startflix.apps);

SELECT 'Apps após inserção:' as info;
SELECT * FROM startflix.apps;
