-- SOLUÇÃO NUCLEAR - DESABILITAR RLS PARA PROFILES (TEMPORÁRIO PARA DEBUG)
-- Isso vai permitir que QUALQUER usuário autenticado veja TODOS os profiles
-- Use apenas para teste. Depois podemos refinar.

-- 1. Limpar todas as políticas de profiles
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
DROP POLICY IF EXISTS "Full access for authenticated" ON public.profiles;

-- 2. Criar UMA política super simples - qualquer usuário autenticado pode ver tudo
CREATE POLICY "Full access for authenticated" 
ON public.profiles 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 3. Fazer o mesmo para payments
DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
DROP POLICY IF EXISTS "Admins can view all payments" ON public.payments;
DROP POLICY IF EXISTS "Admins can manage payments" ON public.payments;
DROP POLICY IF EXISTS "Admin manage payments" ON public.payments;
DROP POLICY IF EXISTS "User view own payments" ON public.payments;
DROP POLICY IF EXISTS "Full access for authenticated payments" ON public.payments;

CREATE POLICY "Full access for authenticated payments" 
ON public.payments 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

-- 4. Verificar
SELECT 'Políticas abertas para teste. Todos os usuários autenticados podem ver tudo.' as status;

-- 5. Mostrar quantos profiles existem
SELECT COUNT(*) as total_profiles FROM public.profiles;
SELECT email, role FROM public.profiles;
