-- CORREÇÃO DE RLS PARA TABELA PAYMENTS
-- Execute este SQL no Supabase SQL Editor

-- 1. Remover políticas existentes (se houver)
DROP POLICY IF EXISTS "System can insert payments" ON public.payments;
DROP POLICY IF EXISTS "Admins can view all payments" ON public.payments;
DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
DROP POLICY IF EXISTS "Allow authenticated users to insert payments" ON public.payments;

-- 2. Criar política para permitir INSERT por usuários autenticados
CREATE POLICY "Allow authenticated users to insert payments" 
ON public.payments
FOR INSERT
TO authenticated
WITH CHECK (true);

-- 3. Política para usuários verem seus próprios pagamentos
CREATE POLICY "Users can view own payments" 
ON public.payments
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- 4. Política para admins verem todos os pagamentos
CREATE POLICY "Admins can view all payments" 
ON public.payments
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM public.admins)
  OR auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
);

-- 5. Garantir que RLS está habilitado
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- 6. Adicionar campos se não existirem
ALTER TABLE public.payments 
ADD COLUMN IF NOT EXISTS payment_id TEXT,
ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'manual',
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'approved';

-- 7. Verificar estrutura da tabela
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'payments';
