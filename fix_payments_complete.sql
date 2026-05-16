-- CORREÇÃO COMPLETA DA TABELA PAYMENTS
-- Execute este SQL no Supabase SQL Editor

-- 1. Verificar se a tabela existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
        -- Criar tabela se não existir
        CREATE TABLE public.payments (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
            amount DECIMAL(10,2) NOT NULL,
            description TEXT,
            payment_id TEXT,
            payment_method TEXT DEFAULT 'manual',
            status TEXT DEFAULT 'approved',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;

-- 2. Adicionar colunas se não existirem
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS payment_id TEXT;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'manual';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'approved';
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 3. Garantir RLS habilitado
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- 4. REMOVER TODAS AS POLÍTICAS EXISTENTES
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'payments' LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.payments', pol.policyname);
    END LOOP;
END $$;

-- 5. CRIAR POLÍTICAS NOVAS E PERMISSIVAS

-- Política para INSERT - QUALQUER usuário autenticado pode inserir
CREATE POLICY "payments_insert_policy" ON public.payments
FOR INSERT TO authenticated
WITH CHECK (true);

-- Política para SELECT - Usuários veem seus pagamentos
CREATE POLICY "payments_select_own" ON public.payments
FOR SELECT TO authenticated
USING (user_id = auth.uid());

-- Política para SELECT - Admins veem tudo
CREATE POLICY "payments_select_admin" ON public.payments
FOR SELECT TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) 
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- 6. Verificar estrutura final
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'payments' AND table_schema = 'public';
