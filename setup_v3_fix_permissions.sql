-- FIX PERMISSIONS AND SCHEMA FOR MEDIA ACCOUNTS
-- Run this in Supabase SQL Editor if you are having "Permission Denied" errors.

-- 1. Ensure Table Structure is Correct
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

-- 2. Force Enable RLS
ALTER TABLE public.media_accounts ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Admin manage media_accounts" ON public.media_accounts;
DROP POLICY IF EXISTS "User view own assigned accounts" ON public.media_accounts;

-- 4. Re-create Admin Policy (ALLOW ALL for Admins)
CREATE POLICY "Admin manage media_accounts" ON public.media_accounts
    USING (
      -- Check if user is in admins table OR has admin role
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin') OR
      -- FALLBACK: If you are logged in as the specific admin email (requires auth.jwt() metadata or similar, but simpler to rely on role)
      -- ALLOW ANY AUTHENTICATED USER TO INSERT FOR NOW (DEBUG ONLY - REMOVE IN PRODUCTION)
      -- Uncomment the line below if still failing:
      -- (auth.role() = 'authenticated')
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    )
    WITH CHECK (
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin') OR
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
    );

-- 5. Re-create User Policy
CREATE POLICY "User view own assigned accounts" ON public.media_accounts
    FOR SELECT USING (auth.uid() = user_id);

-- 6. ENSURE YOUR ADMIN USER HAS THE ROLE
-- Replace 'admin@startflix.com' with your actual admin email if different.
UPDATE public.profiles
SET role = 'admin'
WHERE id IN (
    SELECT id FROM auth.users WHERE email IN ('admin@startflix.com', 'admin@startflix.app')
);

-- 7. Verify Inventory Columns exist
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'media_accounts' AND column_name = 'user_id') THEN
        ALTER TABLE public.media_accounts ADD COLUMN user_id uuid REFERENCES public.profiles(id);
    END IF;
END $$;
