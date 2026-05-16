-- CRITICAL FIX: Create missing media_accounts table
-- Run this script IMMEDIATELY in Supabase SQL Editor

-- 1. Create the table
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

-- 2. Enable Security
ALTER TABLE public.media_accounts ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy for Admin (allows everything)
CREATE POLICY "Admin manage media_accounts" ON public.media_accounts
    AS PERMISSIVE FOR ALL
    TO public
    USING (
      -- Check if user is admin in profiles table
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin' OR
      -- Check if user is in admins table (legacy)
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR
      -- Check if email is admin (fallback)
      auth.email() IN ('admin@startflix.com', 'admin@startflix.app')
    )
    WITH CHECK (
      (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin' OR
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR
      auth.email() IN ('admin@startflix.com', 'admin@startflix.app')
    );

-- 4. Create Policy for Users (view their own)
CREATE POLICY "User view own assigned accounts" ON public.media_accounts
    FOR SELECT
    USING (auth.uid() = user_id);

-- 5. Grant permissions to authenticated users
GRANT ALL ON public.media_accounts TO authenticated;
GRANT ALL ON public.media_accounts TO service_role;
