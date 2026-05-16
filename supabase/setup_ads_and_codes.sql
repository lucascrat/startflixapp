-- 1. System Settings Table
CREATE TABLE IF NOT EXISTS public.system_settings (
    id TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed initial settings
INSERT INTO public.system_settings (id, value)
VALUES ('ad_config', '{"reward_duration_minutes": 90}')
ON CONFLICT (id) DO NOTHING;

-- 2. Access Codes Table
CREATE TABLE IF NOT EXISTS public.access_codes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    m3u_url TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Enable RLS
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.access_codes ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies

-- System Settings
DROP POLICY IF EXISTS "Anyone can view settings" ON public.system_settings;
CREATE POLICY "Anyone can view settings" ON public.system_settings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins manage settings" ON public.system_settings;
CREATE POLICY "Admins manage settings" ON public.system_settings USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Access Codes
DROP POLICY IF EXISTS "Anyone can check access codes" ON public.access_codes;
CREATE POLICY "Anyone can check access codes" ON public.access_codes FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Admins manage access codes" ON public.access_codes;
CREATE POLICY "Admins manage access codes" ON public.access_codes USING (public.is_admin()) WITH CHECK (public.is_admin());
