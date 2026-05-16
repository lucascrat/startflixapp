-- ============================================================
-- STARTFLIX COMPLETE DATABASE SETUP - 2026 CONSOLIDATED
-- Schema: startflix
-- Executar este script no SQL Editor do Supabase
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
    updated_at TIMESTAMPTZ DEFAULT now(),
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

-- 4. TABELA ADMINS (Fallback/Legacy)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. TABELA PAYMENTS (Pagamentos - Inclui campos Efí/Pix)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    payment_id TEXT, -- txid da Efí
    payment_method TEXT DEFAULT 'pix',
    status TEXT DEFAULT 'pending'
);

-- 6. TABELA APPS (Aplicativos disponíveis)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.apps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    download_url TEXT,
    auth_type TEXT DEFAULT 'url', -- 'url', 'mac', 'xtream'
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. TABELA DEFAULT_M3U_LISTS (Configurações Automáticas)
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

-- 9. TABELA USER_WATCHLIST (Favoritos/Minha Lista)
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

-- 10. TABELA CLIENT_TVS (Monitoramento de dispositivos)
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

-- 11. TABELA ADMIN_SETTINGS (Configurações Gerais)
-- ============================================================
CREATE TABLE IF NOT EXISTS startflix.admin_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
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
ALTER TABLE startflix.admin_settings ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- FUNÇÃO SEGURA PARA VERIFICAR ADMIN (EVITA LOOP)
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
CREATE POLICY "profiles_select" ON startflix.profiles
    FOR SELECT TO authenticated USING (auth.uid() = id OR startflix.is_admin());

DROP POLICY IF EXISTS "profiles_insert" ON startflix.profiles;
CREATE POLICY "profiles_insert" ON startflix.profiles
    FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "profiles_update" ON startflix.profiles;
CREATE POLICY "profiles_update" ON startflix.profiles
    FOR UPDATE TO authenticated USING (auth.uid() = id OR startflix.is_admin());

DROP POLICY IF EXISTS "profiles_delete" ON startflix.profiles;
CREATE POLICY "profiles_delete" ON startflix.profiles
    FOR DELETE TO authenticated USING (startflix.is_admin());

-- ============================================================
-- POLÍTICAS RLS - PAYMENTS
-- ============================================================
DROP POLICY IF EXISTS "payments_select" ON startflix.payments;
CREATE POLICY "payments_select" ON startflix.payments
    FOR SELECT TO authenticated USING (user_id = auth.uid() OR startflix.is_admin());

DROP POLICY IF EXISTS "payments_insert" ON startflix.payments;
CREATE POLICY "payments_insert" ON startflix.payments
    FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid() OR startflix.is_admin());

-- ============================================================
-- POLÍTICAS RLS - APPS & M3U (Público visualizar, Admin gerenciar)
-- ============================================================
CREATE POLICY "apps_public_select" ON startflix.apps FOR SELECT TO authenticated USING (true);
CREATE POLICY "apps_admin_all" ON startflix.apps FOR ALL TO authenticated USING (startflix.is_admin());

CREATE POLICY "m3u_public_select" ON startflix.default_m3u_lists FOR SELECT TO authenticated USING (true);
CREATE POLICY "m3u_admin_all" ON startflix.default_m3u_lists FOR ALL TO authenticated USING (startflix.is_admin());

-- ============================================================
-- POLÍTICAS RLS - WATCHLIST
-- ============================================================
CREATE POLICY "watchlist_owner" ON startflix.user_watchlist FOR ALL TO authenticated USING (user_id = auth.uid());

-- ============================================================
-- TRIGGER PARA CRIAR PERFIL NO SIGNUP
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION startflix.handle_new_user();

-- ============================================================
-- RPC: ATUALIZAR CREDENCIAIS (ADMIN ONLY)
-- ============================================================
CREATE OR REPLACE FUNCTION startflix.admin_update_user_credentials(
    p_user_id UUID,
    p_new_email TEXT,
    p_new_password TEXT
)
RETURNS VOID AS $$
BEGIN
    IF NOT startflix.is_admin() THEN
        RAISE EXCEPTION 'Acesso negado';
    END IF;
    
    -- Atualizar Auth
    UPDATE auth.users 
    SET email = p_new_email,
        encrypted_password = crypt(p_new_password, gen_salt('bf'))
    WHERE id = p_user_id;
    
    -- Atualizar Profile
    UPDATE startflix.profiles
    SET email = p_new_email
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- STORAGE SETUP
-- ============================================================
-- Criar buckets (ignora se já existirem)
INSERT INTO storage.buckets (id, name, public)
VALUES ('app-images', 'app-images', true),
       ('profile-images', 'profile-images', true),
       ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas de Storage Simplificadas
CREATE POLICY "Public Read Access" ON storage.objects FOR SELECT TO public USING (true);
CREATE POLICY "Authed Edit Access" ON storage.objects FOR ALL TO authenticated USING (true);

-- ============================================================
-- VERIFICAÇÃO FINAL
-- ============================================================
SELECT 'StartFlix Database V2026 Ready!' as status;
