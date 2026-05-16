-- CORREÇÃO DEFINITIVA DE RLS (VERSÃO IDEMPOTENTE)
-- Pode rodar quantas vezes quiser - não dará erro

-- 1. REMOVER TODAS as políticas de profiles (garantir limpeza total)
DROP POLICY IF EXISTS "View Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Insert Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Update Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;

-- 2. REMOVER políticas de admins
DROP POLICY IF EXISTS "Admin view admins" ON public.admins;
DROP POLICY IF EXISTS "View own admin status" ON public.admins;
DROP POLICY IF EXISTS "Users check own admin status" ON public.admins;

-- 3. CRIAR políticas SIMPLES para profiles
CREATE POLICY "Users can view own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" 
ON public.profiles FOR SELECT 
USING (EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()));

CREATE POLICY "Admins can update all profiles" 
ON public.profiles FOR UPDATE 
USING (EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()));

-- 4. CRIAR política simples para admins (sem recursão)
CREATE POLICY "Users check own admin status" 
ON public.admins FOR SELECT 
USING (auth.uid() = id);

-- 5. Confirmação
SELECT 'RLS Corrigido com Sucesso!' as status;
