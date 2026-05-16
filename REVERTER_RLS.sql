-- REVERTER PARA VERSÃO QUE FUNCIONOU
-- Remover políticas quebradas
DROP POLICY IF EXISTS "Select profiles policy" ON public.profiles;
DROP POLICY IF EXISTS "Insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Update profiles policy" ON public.profiles;
DROP POLICY IF EXISTS "Delete profiles policy" ON public.profiles;
DROP POLICY IF EXISTS "Select payments policy" ON public.payments;
DROP POLICY IF EXISTS "Admin manage payments" ON public.payments;

-- Recriar política aberta que funcionou
CREATE POLICY "Full access for authenticated" 
ON public.profiles 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

CREATE POLICY "Full access for authenticated payments" 
ON public.payments 
FOR ALL 
TO authenticated 
USING (true) 
WITH CHECK (true);

SELECT 'Revertido para versão funcional!' as status;
