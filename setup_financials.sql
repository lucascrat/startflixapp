-- ADICIONAR AO SQL EDITOR NO SUPABASE

-- 1. Adiciona custo da linha ao profile
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS line_cost numeric DEFAULT 0;

-- 2. Tabela de Histórico de Pagamentos
CREATE TABLE IF NOT EXISTS public.payments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount numeric NOT NULL,
    status text DEFAULT 'completed', -- pending, completed, failed
    description text,
    created_at timestamptz DEFAULT now()
);

-- 3. Segurança RLS para pagamentos
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Admin vê tudo
CREATE POLICY "Admin view all payments" ON public.payments FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Admin insere pagamentos
CREATE POLICY "Admin insert payments" ON public.payments FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid()) OR 
  EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Usuário vê apenas seus pagamentos
CREATE POLICY "User view own payments" ON public.payments FOR SELECT USING (auth.uid() = user_id);
