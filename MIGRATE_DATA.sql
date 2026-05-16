-- ============================================================
-- MIGRAR DADOS DO public.profiles PARA startflix.profiles
-- Execute este script para copiar os dados dos clientes
-- ============================================================

-- Verificar se existe a tabela antiga
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles') THEN
        RAISE NOTICE 'Tabela public.profiles encontrada. Migrando dados...';
        
        -- Atualizar os dados existentes em startflix.profiles com os dados de public.profiles
        UPDATE startflix.profiles sp
        SET 
            email = COALESCE(sp.email, pp.email),
            full_name = COALESCE(sp.full_name, pp.full_name),
            role = COALESCE(pp.role, sp.role),
            m3u_url = COALESCE(pp.m3u_url, sp.m3u_url),
            is_active = COALESCE(pp.is_active, sp.is_active),
            expiration_date = COALESCE(pp.expiration_date, sp.expiration_date),
            line_cost = COALESCE(pp.line_cost, sp.line_cost),
            avatar_url = COALESCE(pp.avatar_url, sp.avatar_url),
            username = COALESCE(pp.username, sp.username),
            app_mac = COALESCE(pp.app_mac, sp.app_mac),
            app_image_url = COALESCE(pp.app_image_url, sp.app_image_url),
            app_creds_password = COALESCE(pp.app_creds_password, sp.app_creds_password),
            app_id = COALESCE(pp.app_id, sp.app_id),
            app_provider_url = COALESCE(pp.app_provider_url, sp.app_provider_url),
            app_username = COALESCE(pp.app_username, sp.app_username),
            app_password_app = COALESCE(pp.app_password_app, sp.app_password_app),
            external_panel_url = COALESCE(pp.external_panel_url, sp.external_panel_url),
            tv_provider_name = COALESCE(pp.tv_provider_name, sp.tv_provider_name),
            tv_username = COALESCE(pp.tv_username, sp.tv_username),
            tv_password = COALESCE(pp.tv_password, sp.tv_password),
            tv_dns = COALESCE(pp.tv_dns, sp.tv_dns)
        FROM public.profiles pp
        WHERE sp.id = pp.id;
        
        -- Inserir perfis que existem em public mas não em startflix
        INSERT INTO startflix.profiles (
            id, email, full_name, role, m3u_url, is_active, expiration_date,
            created_at, line_cost, avatar_url, username, app_mac, app_image_url,
            app_creds_password, app_id, app_provider_url, app_username, app_password_app,
            external_panel_url, tv_provider_name, tv_username, tv_password, tv_dns
        )
        SELECT 
            pp.id, pp.email, pp.full_name, pp.role, pp.m3u_url, pp.is_active, pp.expiration_date,
            pp.created_at, pp.line_cost, pp.avatar_url, pp.username, 
            pp.app_mac, pp.app_image_url, pp.app_creds_password, pp.app_id,
            pp.app_provider_url, pp.app_username, pp.app_password_app,
            pp.external_panel_url, pp.tv_provider_name, pp.tv_username, pp.tv_password, pp.tv_dns
        FROM public.profiles pp
        WHERE NOT EXISTS (
            SELECT 1 FROM startflix.profiles sp WHERE sp.id = pp.id
        );
        
        RAISE NOTICE 'Migração concluída!';
    ELSE
        RAISE NOTICE 'Tabela public.profiles não existe. Nada a migrar.';
    END IF;
END $$;

-- Mostrar dados migrados
SELECT id, email, role, m3u_url, is_active 
FROM startflix.profiles 
ORDER BY created_at DESC;
