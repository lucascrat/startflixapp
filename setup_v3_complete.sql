-- COMPREHENSIVE UPDATE SCRIPT (V3)
-- Run this in Supabase SQL Editor to enable Financials, Inventory, and Avatars.

-- 1. ENABLE FINANCIALS
CREATE TABLE IF NOT EXISTS public.payments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    description text,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin manage payments" ON public.payments
    USING (
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    )
    WITH CHECK (
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "User view own payments" ON public.payments
    FOR SELECT USING (auth.uid() = user_id);

-- Add line_cost to profiles if not exists
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'line_cost') THEN
        ALTER TABLE public.profiles ADD COLUMN line_cost numeric DEFAULT 0.0;
    END IF;
END $$;

-- 2. ENABLE AVATARS
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'avatar_url') THEN
        ALTER TABLE public.profiles ADD COLUMN avatar_url text;
    END IF;
END $$;

-- 3. ENABLE MEDIA INVENTORY (Multi-TV + Stock)
CREATE TABLE IF NOT EXISTS public.media_accounts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    provider_name text,
    username text,
    password text,
    dns text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.media_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin manage media_accounts" ON public.media_accounts
    USING (
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    )
    WITH CHECK (
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "User view own assigned accounts" ON public.media_accounts
    FOR SELECT USING (auth.uid() = user_id);

-- 4. MIGRATE EXISTING TV DATA (Legacy -> New Table)
-- Only run if table is empty or we want to ensure data is there. We use WHERE NOT EXISTS to avoid duplicates.
INSERT INTO public.media_accounts (user_id, provider_name, username, password, dns)
SELECT id, tv_provider_name, tv_username, tv_password, tv_dns
FROM public.profiles
WHERE (tv_username IS NOT NULL AND tv_username != '')
AND NOT EXISTS (
    SELECT 1 FROM public.media_accounts WHERE public.media_accounts.username = public.profiles.tv_username
);


-- 5. AUTO-ASSIGN TRIGGER
-- When a new profile is created, try to assign an available media account
CREATE OR REPLACE FUNCTION assign_media_account()
RETURNS TRIGGER AS $$
DECLARE
  available_account_id uuid;
BEGIN
  -- Find one available account (user_id is null)
  SELECT id INTO available_account_id
  FROM public.media_accounts
  WHERE user_id IS NULL
  LIMIT 1;

  -- If found, assign it to the new user
  IF available_account_id IS NOT NULL THEN
    UPDATE public.media_accounts
    SET user_id = NEW.id, updated_at = now()
    WHERE id = available_account_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists to recreate
DROP TRIGGER IF EXISTS on_profile_created_assign_tv ON public.profiles;

CREATE TRIGGER on_profile_created_assign_tv
  AFTER INSERT ON public.profiles
  FOR EACH ROW
  EXECUTE PROCEDURE assign_media_account();
