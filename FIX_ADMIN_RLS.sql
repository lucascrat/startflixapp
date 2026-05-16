-- CORREÇÃO COMPLETA DE RLS PARA ADMIN
-- Permite que admins vejam TODOS os clientes e pagamentos

-- ============================================
-- 1. LIMPAR POLÍTICAS DE PROFILES
-- ============================================
DROP POLICY IF EXISTS "View Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Insert Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Update Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow all authenticated to view profiles" ON public.profiles;

-- ============================================
-- 2. LIMPAR POLÍTICAS DE ADMINS
-- ============================================
DROP POLICY IF EXISTS "Admin view admins" ON public.admins;
DROP POLICY IF EXISTS "View own admin status" ON public.admins;
DROP POLICY IF EXISTS "Users check own admin status" ON public.admins;
DROP POLICY IF EXISTS "Anyone can check admins" ON public.admins;

-- ============================================
-- 3. LIMPAR POLÍTICAS DE PAYMENTS
-- ============================================
DROP POLICY IF EXISTS "Admin manage payments" ON public.payments;
DROP POLICY IF EXISTS "User view own payments" ON public.payments;
DROP POLICY IF EXISTS "Admins can view all payments" ON public.payments;
DROP POLICY IF EXISTS "Admins can manage payments" ON public.payments;

-- ============================================
-- 4. CRIAR POLÍTICA SIMPLES PARA ADMINS
-- Qualquer usuário autenticado pode verificar se está na tabela admins
-- ============================================
CREATE POLICY "Anyone can check admins" 
ON public.admins FOR SELECT 
TO authenticated
USING (true);

-- ============================================
-- 5. CRIAR POLÍTICAS PARA PROFILES
-- ============================================
-- Usuário vê seu próprio perfil
CREATE POLICY "Users can view own profile" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

-- Admin vê TODOS os perfis
CREATE POLICY "Admins can view all profiles" 
ON public.profiles FOR SELECT 
USING (
    EXISTS (SELECT 1 FROM public.admins WHERE admins.id = auth.uid())
);

-- Usuário insere seu próprio perfil
CREATE POLICY "Users can insert own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Usuário atualiza seu próprio perfil
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- Admin atualiza qualquer perfil
CREATE POLICY "Admins can update all profiles" 
ON public.profiles FOR UPDATE 
USING (
    EXISTS (SELECT 1 FROM public.admins WHERE admins.id = auth.uid())
);

-- Admin deleta qualquer perfil
CREATE POLICY "Admins can delete profiles" 
ON public.profiles FOR DELETE 
USING (
    EXISTS (SELECT 1 FROM public.admins WHERE admins.id = auth.uid())
);

-- ============================================
-- 6. CRIAR POLÍTICAS PARA PAYMENTS
-- ============================================
-- Usuário vê seus próprios pagamentos
CREATE POLICY "Users can view own payments" 
ON public.payments FOR SELECT 
USING (auth.uid() = user_id);

-- Admin vê TODOS os pagamentos
CREATE POLICY "Admins can view all payments" 
ON public.payments FOR SELECT 
USING (
    EXISTS (SELECT 1 FROM public.admins WHERE admins.id = auth.uid())
);

-- Admin gerencia todos os pagamentos
CREATE POLICY "Admins can manage payments" 
ON public.payments FOR ALL 
USING (
    EXISTS (SELECT 1 FROM public.admins WHERE admins.id = auth.uid())
);

-- ============================================
-- 7. VERIFICAR SE O ADMIN ESTÁ REGISTRADO
-- ============================================
-- Ver quem está na tabela admins
SELECT 'Admins cadastrados:' as info;
SELECT id, email FROM public.admins;

-- Ver todos os profiles
SELECT 'Profiles cadastrados:' as info2;
SELECT id, email, role, m3u_url FROM public.profiles;

SELECT 'RLS Corrigido para Admin!' as status;
