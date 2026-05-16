-- STARTFLIX PRO - COMPLETE DATABASE SETUP (V5)
-- Run this script in the Supabase SQL Editor to set up the entire database.
-- Includes Financials, Inventory, Apps, Default Lists, Client Management, and STORAGE.

-- =====================================================================
-- 0. CLEANUP (Optional - Uncomment if you want to wipe everything first)
-- =====================================================================
-- DROP TRIGGER IF EXISTS on_profile_created_assign_tv ON public.profiles;
-- DROP TRIGGER IF EXISTS trigger_assign_default_m3u ON public.profiles;
-- DROP TABLE IF EXISTS public.user_watchlist CASCADE;
-- DROP TABLE IF EXISTS public.media_accounts CASCADE;
-- DROP TABLE IF EXISTS public.client_tvs CASCADE;
-- DROP TABLE IF EXISTS public.payments CASCADE;
-- DROP TABLE IF EXISTS public.default_m3u_lists CASCADE;
-- DROP TABLE IF EXISTS public.profiles CASCADE;
-- DROP TABLE IF EXISTS public.apps CASCADE;
-- DROP TABLE IF EXISTS public.admins CASCADE;
-- -- Storage Cleanup (Optional)
-- -- DELETE FROM storage.buckets WHERE id = 'app-images';

-- =====================================================================
-- 1. BASE TABLES
-- =====================================================================

-- 1.1 APPS (List of Players/Apps available)
CREATE TABLE IF NOT EXISTS public.apps (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    image_url TEXT,
    auth_type TEXT DEFAULT 'mac', -- 'mac', 'xtream', 'url'
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 1.2 DEFAULT M3U LISTS (Auto-assigned to new users)
CREATE TABLE IF NOT EXISTS public.default_m3u_lists (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    m3u_url TEXT NOT NULL,
    priority INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 1.3 ADMINS (Explicit list for RLS)
CREATE TABLE IF NOT EXISTS public.admins (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- 1.4 PROFILES (Main User Table)
CREATE TABLE IF NOT EXISTS public.profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username text,
    email text,
    password text, -- Visual reference
    full_name text,
    role text DEFAULT 'user',
    
    -- Client App Configuration
    m3u_url text, -- Assigned Playlist
    is_active boolean DEFAULT true,
    expiration_date timestamptz,
    avatar_url text,
    line_cost numeric DEFAULT 0.0,
    
    -- App Link
    app_id UUID REFERENCES public.apps(id),
    
    -- App Credentials (for the selected App)
    app_mac_address TEXT,
    app_provider_url TEXT,
    app_username TEXT,
    app_password_app TEXT,
    
    -- Legacy/Direct Fields (Compatibility)
    app_image_url text,
    app_mac text,
    app_creds_password text,
    tv_provider_name text,
    tv_username text,
    tv_password text,
    tv_dns text,
    
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- =====================================================================
-- 2. FEATURE TABLES
-- =====================================================================

-- 2.1 MEDIA ACCOUNTS (Inventory & Managed TVs - Main System)
CREATE TABLE IF NOT EXISTS public.media_accounts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL, -- Null if in stock
    provider_name text,
    username text,
    password text,
    dns text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2.2 CLIENT TVS (Requested Table - Explicit Assignment)
CREATE TABLE IF NOT EXISTS public.client_tvs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    provider_name text,
    username text,
    password text,
    dns text,
    created_at timestamptz DEFAULT now()
);

-- 2.3 PAYMENTS
CREATE TABLE IF NOT EXISTS public.payments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    description text,
    created_at timestamptz DEFAULT now()
);

-- 2.4 USER WATCHLIST
CREATE TABLE IF NOT EXISTS public.user_watchlist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tmdb_id INTEGER NOT NULL,
  media_type TEXT NOT NULL CHECK (media_type IN ('movie', 'tv')),
  title TEXT NOT NULL,
  poster_path TEXT,
  backdrop_path TEXT,
  overview TEXT,
  vote_average NUMERIC(3,1),
  release_date TEXT,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, tmdb_id, media_type)
);

-- =====================================================================
-- 3. INDEXES
-- =====================================================================
CREATE INDEX IF NOT EXISTS idx_user_watchlist_user_id ON public.user_watchlist(user_id);
CREATE INDEX IF NOT EXISTS idx_media_accounts_user_id ON public.media_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_client_tvs_user_id ON public.client_tvs(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);

-- =====================================================================
-- 4. RLS POLICIES
-- =====================================================================

-- Admin Helper
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) 
      OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_tvs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.apps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.default_m3u_lists ENABLE ROW LEVEL SECURITY;

-- 4.1 PROFILES POLICIES
DROP POLICY IF EXISTS "View Profiles" ON public.profiles;
CREATE POLICY "View Profiles" ON public.profiles FOR SELECT USING (auth.uid() = id OR public.is_admin());

DROP POLICY IF EXISTS "Insert Profiles" ON public.profiles;
CREATE POLICY "Insert Profiles" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id OR public.is_admin());

DROP POLICY IF EXISTS "Update Profiles" ON public.profiles;
CREATE POLICY "Update Profiles" ON public.profiles FOR UPDATE USING (auth.uid() = id OR public.is_admin());

-- 4.2 APPS & DEFAULT LISTS
DROP POLICY IF EXISTS "Anyone can view active apps" ON public.apps;
CREATE POLICY "Anyone can view active apps" ON public.apps FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Admins manage apps" ON public.apps;
CREATE POLICY "Admins manage apps" ON public.apps USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Anyone can view active lists" ON public.default_m3u_lists;
CREATE POLICY "Anyone can view active lists" ON public.default_m3u_lists FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Admins manage lists" ON public.default_m3u_lists;
CREATE POLICY "Admins manage lists" ON public.default_m3u_lists USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 4.3 MEDIA ACCOUNTS (Inventory)
DROP POLICY IF EXISTS "Admin manage media_accounts" ON public.media_accounts;
CREATE POLICY "Admin manage media_accounts" ON public.media_accounts USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "User view own media_accounts" ON public.media_accounts;
CREATE POLICY "User view own media_accounts" ON public.media_accounts FOR SELECT USING (auth.uid() = user_id);

-- 4.4 CLIENT TVS
DROP POLICY IF EXISTS "Admin manage client_tvs" ON public.client_tvs;
CREATE POLICY "Admin manage client_tvs" ON public.client_tvs USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "User view own client_tvs" ON public.client_tvs;
CREATE POLICY "User view own client_tvs" ON public.client_tvs FOR SELECT USING (auth.uid() = user_id);

-- 4.5 OTHERS
DROP POLICY IF EXISTS "Admin manage payments" ON public.payments;
CREATE POLICY "Admin manage payments" ON public.payments USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "User view own payments" ON public.payments;
CREATE POLICY "User view own payments" ON public.payments FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users view own watchlist" ON public.user_watchlist;
CREATE POLICY "Users view own watchlist" ON public.user_watchlist FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users edit own watchlist" ON public.user_watchlist;
CREATE POLICY "Users edit own watchlist" ON public.user_watchlist FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admin view admins" ON public.admins;
CREATE POLICY "Admin view admins" ON public.admins FOR SELECT USING (auth.uid() = id OR public.is_admin());

-- =====================================================================
-- 5. FUNCTIONS & TRIGGERS
-- =====================================================================

-- 5.1 CREATE PROFILE
CREATE OR REPLACE FUNCTION public.create_profile_for_user(
  p_user_id uuid, p_full_name text, p_m3u_url text, p_password text
) RETURNS void AS $$
DECLARE v_email text;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = p_user_id;
  INSERT INTO public.profiles (id, username, email, password, full_name, role, m3u_url, created_at)
  VALUES (p_user_id, split_part(v_email, '@', 1), v_email, p_password, p_full_name, 'user', p_m3u_url, now())
  ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, password = EXCLUDED.password;

  IF v_email = 'admin@startflix.app' OR v_email = 'admin@startflix.com' THEN
      INSERT INTO public.admins (id, email) VALUES (p_user_id, v_email) ON CONFLICT DO NOTHING;
      UPDATE public.profiles SET role = 'admin' WHERE id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5.2 AUTO ASSIGN DEFAULT M3U
CREATE OR REPLACE FUNCTION assign_default_m3u_to_user() RETURNS TRIGGER AS $$
DECLARE default_list RECORD;
BEGIN
    SELECT m3u_url INTO default_list FROM public.default_m3u_lists WHERE is_active = true ORDER BY priority DESC LIMIT 1;
    IF default_list.m3u_url IS NOT NULL THEN
        UPDATE public.profiles SET m3u_url = default_list.m3u_url WHERE id = NEW.id AND (m3u_url IS NULL OR m3u_url = '');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_assign_default_m3u ON public.profiles;
CREATE TRIGGER trigger_assign_default_m3u AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION assign_default_m3u_to_user();

-- 5.3 AUTO ASSIGN TV FROM INVENTORY
CREATE OR REPLACE FUNCTION assign_media_account() RETURNS TRIGGER AS $$
DECLARE available_account_id uuid;
BEGIN
  SELECT id INTO available_account_id FROM public.media_accounts WHERE user_id IS NULL LIMIT 1;
  IF available_account_id IS NOT NULL THEN
    UPDATE public.media_accounts SET user_id = NEW.id, updated_at = now() WHERE id = available_account_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_profile_created_assign_tv ON public.profiles;
CREATE TRIGGER on_profile_created_assign_tv AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION assign_media_account();

-- 5.4 UPDATE CREDENTIALS
CREATE OR REPLACE FUNCTION admin_update_user_credentials(target_user_id UUID, new_email TEXT, new_password TEXT) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE auth.users SET email = new_email, encrypted_password = crypt(new_password, gen_salt('bf')), updated_at = now() WHERE id = target_user_id;
  UPDATE public.profiles SET username = split_part(new_email, '@', 1), email = new_email, password = new_password WHERE id = target_user_id;
END;
$$;

-- 6. SEED DATA (Apps)
INSERT INTO public.apps (name, auth_type, description) VALUES
('IBO Player', 'mac', 'Player popular com suporte a MAC Address'),
('XCIPTV', 'xtream', 'Player com Xtream Codes API'),
('Smarters Pro', 'xtream', 'IPTV Smarters Pro'),
('TiviMate', 'url', 'Player premium com URL M3U'),
('Outro', 'url', 'Outro player genérico')
ON CONFLICT DO NOTHING;

-- =====================================================================
-- 7. STORAGE SETUP
-- =====================================================================

-- 7.1 Create 'app-images' bucket (if it doesn't exist)
INSERT INTO storage.buckets (id, name, public)
VALUES ('app-images', 'app-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 7.2 Storage Policies

-- Public Read
DROP POLICY IF EXISTS "Public can view images" ON storage.objects;
CREATE POLICY "Public can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'app-images');

-- Admin Upload
DROP POLICY IF EXISTS "Admins can upload images" ON storage.objects;
CREATE POLICY "Admins can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'app-images' 
  AND public.is_admin()
);

-- Admin Delete
DROP POLICY IF EXISTS "Admins can delete images" ON storage.objects;
CREATE POLICY "Admins can delete images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'app-images'
  AND public.is_admin()
);
