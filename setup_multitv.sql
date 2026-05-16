-- ADICIONAR AO SQL EDITOR NO SUPABASE

-- 1. Cria tabela para Múltiplas TVs
CREATE TABLE IF NOT EXISTS public.client_tvs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    provider_name text,
    username text,
    password text,
    dns text,
    created_at timestamptz DEFAULT now()
);

-- 2. Segurança RLS
ALTER TABLE public.client_tvs ENABLE ROW LEVEL SECURITY;

-- Admin gerencia tudo
CREATE POLICY "Admin manage tvs" ON public.client_tvs
    USING (
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    )
    WITH CHECK (
      EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Usuário vê apenas suas TVs
CREATE POLICY "User view own tvs" ON public.client_tvs
    FOR SELECT USING (auth.uid() = user_id);

-- 3. Migração de Dados (Copia dos profiles para a nova tabela)
INSERT INTO public.client_tvs (user_id, provider_name, username, password, dns)
SELECT id, tv_provider_name, tv_username, tv_password, tv_dns
FROM public.profiles
WHERE tv_username IS NOT NULL OR tv_dns IS NOT NULL;
