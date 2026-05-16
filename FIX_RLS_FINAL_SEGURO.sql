-- RLS REFINADO E SEGURO (VERSÃO FINAL)
-- Baseado no teste "nuclear" que funcionou

-- ============================================
-- 1. LIMPAR POLÍTICAS ANTERIORES
-- ============================================
DROP POLICY IF EXISTS "Full access for authenticated" ON public.profiles;
DROP POLICY IF EXISTS "Full access for authenticated payments" ON public.payments;
DROP POLICY IF EXISTS "View Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Insert Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Update Profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON public.profiles;

-- ============================================
-- 2. PROFILES - Políticas Seguras
-- ============================================

-- SELECT: Usuário vê seu perfil OU Admin vê todos
CREATE POLICY "Select profiles policy" ON public.profiles 
FOR SELECT TO authenticated
USING (
    auth.uid() = id 
    OR 
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- INSERT: Usuário insere apenas seu próprio perfil
CREATE POLICY "Insert own profile" ON public.profiles 
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = id);

-- UPDATE: Usuário atualiza seu perfil OU Admin atualiza qualquer um
CREATE POLICY "Update profiles policy" ON public.profiles 
FOR UPDATE TO authenticated
USING (
    auth.uid() = id 
    OR 
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- DELETE: Apenas Admin pode deletar
CREATE POLICY "Delete profiles policy" ON public.profiles 
FOR DELETE TO authenticated
USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- ============================================
-- 3. PAYMENTS - Políticas Seguras
-- ============================================
DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
DROP POLICY IF EXISTS "Admins can view all payments" ON public.payments;
DROP POLICY IF EXISTS "Admins can manage payments" ON public.payments;

-- SELECT: Usuário vê seus pagamentos OU Admin vê todos
CREATE POLICY "Select payments policy" ON public.payments 
FOR SELECT TO authenticated
USING (
    auth.uid() = user_id 
    OR 
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- INSERT/UPDATE/DELETE: Apenas Admin
CREATE POLICY "Admin manage payments" ON public.payments 
FOR ALL TO authenticated
USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
)
WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'admin'
);

-- ============================================
-- 4. VERIFICAÇÃO
-- ============================================
SELECT 'RLS Refinado aplicado com sucesso!' as status;

-- Verificar se admin@startflix.app tem role = 'admin'
SELECT email, role FROM public.profiles WHERE email LIKE '%admin%';
