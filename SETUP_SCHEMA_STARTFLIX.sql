-- ============================================================
-- STARTFLIX COMPLETE DATABASE SETUP - SCHEMA STARTFLIX
-- Execute este script no SQL Editor do Supabase
-- ============================================================

-- 1. CRIAR O SCHEMA STARTFLIX
-- ============================================================
CREATE SCHEMA IF NOT EXISTS startflix;

-- 2. GRANT PERMISSIONS NO SCHEMA
-- ============================================================
GRANT USAGE ON SCHEMA startflix TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA startflix TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA startflix TO anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA startflix TO anon, authenticated, service_role;

-- Default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA startflix GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA startflix GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA startflix GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role;

-- 3. TABELA PROFILES (Usuários)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    role TEXT DEFAULT 'client',
    m3u_url TEXT,
    is_active BOOLEAN DEFAULT true,
    expiration_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    line_cost NUMERIC DEFAULT 0,
    avatar_url TEXT,
    username TEXT,
    
    -- App fields
    app_mac TEXT,
    app_image_url TEXT,
    app_creds_password TEXT,
    app_id TEXT,
    
    -- Xtream Codes credentials
    app_provider_url TEXT,
    app_username TEXT,
    app_password_app TEXT,
    
    -- External panel URL
    external_panel_url TEXT,
    
    -- Legacy TV fields
    tv_provider_name TEXT,
    tv_username TEXT,
    tv_password TEXT,
    tv_dns TEXT
);

-- 4. TABELA ADMINS
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. TABELA PAYMENTS (Pagamentos)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    payment_id TEXT,
    payment_method TEXT DEFAULT 'manual',
    status TEXT DEFAULT 'approved'
);

-- 6. TABELA APPS (Aplicativos disponíveis)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.apps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    download_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. TABELA DEFAULT_M3U_LISTS (Listas M3U padrão)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.default_m3u_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    m3u_url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. TABELA MEDIA_ACCOUNTS (Contas de mídia/TV)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.media_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_name TEXT,
    username TEXT,
    password TEXT,
    dns TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 9. TABELA USER_WATCHLIST (Lista de favoritos)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.user_watchlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    tmdb_id INTEGER NOT NULL,
    media_type TEXT NOT NULL, -- 'movie' or 'tv'
    title TEXT,
    poster_path TEXT,
    backdrop_path TEXT,
    overview TEXT,
    vote_average NUMERIC,
    release_date TEXT,
    added_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, tmdb_id, media_type)
);

-- 10. TABELA CLIENT_TVS (TVs do cliente)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.client_tvs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_name TEXT,
    username TEXT,
    password TEXT,
    dns TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- HABILITAR RLS (Row Level Security)
-- ============================================================
ALTER TABLE startflix.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE startflix.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE startflix.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE startflix.apps ENABLE ROW LEVEL SECURITY;
ALTER TABLE startflix.default_m3u_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE startflix.media_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE startflix.user_watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE startflix.client_tvs ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- FUNÇÃO PARA VERIFICAR SE É ADMIN
-- ============================================================
CREATE OR REPLACE FUNCTION startflix.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM startflix.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- POLÍTICAS RLS - PROFILES
-- ============================================================
DROP POLICY IF EXISTS "profiles_select" ON startflix.profiles;
DROP POLICY IF EXISTS "profiles_insert" ON startflix.profiles;
DROP POLICY IF EXISTS "profiles_update" ON startflix.profiles;
DROP POLICY IF EXISTS "profiles_delete" ON startflix.profiles;

-- Todos podem ver todos os perfis (necessário para admin)
CREATE POLICY "profiles_select" ON startflix.profiles
    FOR SELECT TO authenticated USING (true);

-- Usuários podem inserir seu próprio perfil
CREATE POLICY "profiles_insert" ON startflix.profiles
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

-- Usuários podem atualizar seu próprio perfil OU admins podem atualizar qualquer um
CREATE POLICY "profiles_update" ON startflix.profiles
    FOR UPDATE TO authenticated USING (
        auth.uid() = id OR startflix.is_admin()
    );

-- Apenas admins podem deletar
CREATE POLICY "profiles_delete" ON startflix.profiles
    FOR DELETE TO authenticated USING (startflix.is_admin());

-- ============================================================
-- POLÍTICAS RLS - ADMINS
-- ============================================================
DROP POLICY IF EXISTS "admins_select" ON startflix.admins;

CREATE POLICY "admins_select" ON startflix.admins
    FOR SELECT TO authenticated USING (true);

-- ============================================================
-- POLÍTICAS RLS - PAYMENTS
-- ============================================================
DROP POLICY IF EXISTS "payments_select" ON startflix.payments;
DROP POLICY IF EXISTS "payments_insert" ON startflix.payments;

-- Usuários veem seus próprios pagamentos OU admins veem todos
CREATE POLICY "payments_select" ON startflix.payments
    FOR SELECT TO authenticated USING (
        user_id = auth.uid() OR startflix.is_admin()
    );

-- Admins podem inserir pagamentos para qualquer usuário
CREATE POLICY "payments_insert" ON startflix.payments
    FOR INSERT TO authenticated WITH CHECK (
        user_id = auth.uid() OR startflix.is_admin()
    );

-- ============================================================
-- POLÍTICAS RLS - APPS
-- ============================================================
DROP POLICY IF EXISTS "apps_select" ON startflix.apps;
DROP POLICY IF EXISTS "apps_all" ON startflix.apps;

-- Todos podem ver apps ativos
CREATE POLICY "apps_select" ON startflix.apps
    FOR SELECT TO authenticated USING (true);

-- Admins podem fazer tudo com apps
CREATE POLICY "apps_all" ON startflix.apps
    FOR ALL TO authenticated USING (startflix.is_admin());

-- ============================================================
-- POLÍTICAS RLS - DEFAULT_M3U_LISTS
-- ============================================================
DROP POLICY IF EXISTS "default_m3u_select" ON startflix.default_m3u_lists;
DROP POLICY IF EXISTS "default_m3u_all" ON startflix.default_m3u_lists;

CREATE POLICY "default_m3u_select" ON startflix.default_m3u_lists
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "default_m3u_all" ON startflix.default_m3u_lists
    FOR ALL TO authenticated USING (startflix.is_admin());

-- ============================================================
-- POLÍTICAS RLS - MEDIA_ACCOUNTS
-- ============================================================
DROP POLICY IF EXISTS "media_accounts_select" ON startflix.media_accounts;
DROP POLICY IF EXISTS "media_accounts_all" ON startflix.media_accounts;

CREATE POLICY "media_accounts_select" ON startflix.media_accounts
    FOR SELECT TO authenticated USING (
        user_id = auth.uid() OR startflix.is_admin()
    );

CREATE POLICY "media_accounts_all" ON startflix.media_accounts
    FOR ALL TO authenticated USING (
        user_id = auth.uid() OR startflix.is_admin()
    );

-- ============================================================
-- POLÍTICAS RLS - USER_WATCHLIST
-- ============================================================
DROP POLICY IF EXISTS "watchlist_select" ON startflix.user_watchlist;
DROP POLICY IF EXISTS "watchlist_insert" ON startflix.user_watchlist;
DROP POLICY IF EXISTS "watchlist_delete" ON startflix.user_watchlist;

CREATE POLICY "watchlist_select" ON startflix.user_watchlist
    FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "watchlist_insert" ON startflix.user_watchlist
    FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "watchlist_delete" ON startflix.user_watchlist
    FOR DELETE TO authenticated USING (user_id = auth.uid());

-- ============================================================
-- POLÍTICAS RLS - CLIENT_TVS
-- ============================================================
DROP POLICY IF EXISTS "client_tvs_select" ON startflix.client_tvs;
DROP POLICY IF EXISTS "client_tvs_all" ON startflix.client_tvs;

CREATE POLICY "client_tvs_select" ON startflix.client_tvs
    FOR SELECT TO authenticated USING (
        user_id = auth.uid() OR startflix.is_admin()
    );

CREATE POLICY "client_tvs_all" ON startflix.client_tvs
    FOR ALL TO authenticated USING (
        user_id = auth.uid() OR startflix.is_admin()
    );

-- ============================================================
-- TRIGGER PARA CRIAR PERFIL AUTOMATICAMENTE
-- ============================================================
CREATE OR REPLACE FUNCTION startflix.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO startflix.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        'client'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remover trigger se existir e recriar
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION startflix.handle_new_user();

-- ============================================================
-- FUNÇÃO RPC PARA ADMIN ATUALIZAR CREDENCIAIS
-- ============================================================
CREATE OR REPLACE FUNCTION startflix.admin_update_user_credentials(
    p_user_id UUID,
    p_new_email TEXT,
    p_new_password TEXT
)
RETURNS VOID AS $$
DECLARE
    v_is_admin BOOLEAN;
BEGIN
    -- Verificar se quem chama é admin
    SELECT EXISTS (
        SELECT 1 FROM startflix.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    ) INTO v_is_admin;
    
    IF NOT v_is_admin THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can update user credentials';
    END IF;
    
    -- Atualizar email no auth.users
    UPDATE auth.users 
    SET email = p_new_email,
        encrypted_password = crypt(p_new_password, gen_salt('bf'))
    WHERE id = p_user_id;
    
    -- Atualizar email no profiles
    UPDATE startflix.profiles
    SET email = p_new_email,
        username = split_part(p_new_email, '@', 1)
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================

-- Criar buckets de storage
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('app-images', 'app-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[]),
    ('profile-images', 'profile-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[]),
    ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[])
ON CONFLICT (id) DO UPDATE SET public = true;

-- Políticas de storage
DROP POLICY IF EXISTS "Storage upload policy" ON storage.objects;
DROP POLICY IF EXISTS "Storage view policy" ON storage.objects;
DROP POLICY IF EXISTS "Storage delete policy" ON storage.objects;
DROP POLICY IF EXISTS "Storage update policy" ON storage.objects;

CREATE POLICY "Storage upload policy"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id IN ('app-images', 'profile-images', 'avatars'));

CREATE POLICY "Storage view policy"
ON storage.objects FOR SELECT
TO public
USING (bucket_id IN ('app-images', 'profile-images', 'avatars'));

CREATE POLICY "Storage delete policy"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id IN ('app-images', 'profile-images', 'avatars'));

CREATE POLICY "Storage update policy"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id IN ('app-images', 'profile-images', 'avatars'));

-- ============================================================
-- CRIAR ADMIN PADRÃO (opcional - descomente se necessário)
-- ============================================================
-- Primeiro crie o usuário admin@startflix.app via Auth do Supabase
-- Depois execute:
-- INSERT INTO startflix.profiles (id, email, full_name, role)
-- SELECT id, email, 'Administrador', 'admin'
-- FROM auth.users WHERE email = 'admin@startflix.app'
-- ON CONFLICT (id) DO UPDATE SET role = 'admin';

-- ============================================================
-- VERIFICAÇÃO FINAL
-- ============================================================
SELECT 'Schema startflix criado com sucesso!' as status;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'startflix' ORDER BY table_name;
