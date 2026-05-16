-- Adicionar campos necessários para o sistema de pagamentos PIX
-- Execute este SQL no Supabase

-- 1. Adicionar campo external_panel_url (se ainda não existir)
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS external_panel_url TEXT;

-- 2. Adicionar campos na tabela payments para rastrear pagamentos PIX
ALTER TABLE public.payments
ADD COLUMN IF NOT EXISTS payment_id TEXT;

ALTER TABLE public.payments
ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'manual';

ALTER TABLE public.payments
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'approved';

-- 3. Criar índice para busca por payment_id
CREATE INDEX IF NOT EXISTS idx_payments_payment_id ON public.payments(payment_id);

-- 4. Comentários
COMMENT ON COLUMN public.payments.payment_id IS 'ID do pagamento no Mercado Pago';
COMMENT ON COLUMN public.payments.payment_method IS 'Método de pagamento: pix, manual, etc';
COMMENT ON COLUMN public.payments.status IS 'Status do pagamento: pending, approved, rejected';
COMMENT ON COLUMN public.profiles.external_panel_url IS 'URL do cliente no painel externo para renovação';

-- 5. Verificar se a tabela payments existe, se não criar
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
        CREATE TABLE public.payments (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
            amount DECIMAL(10,2) NOT NULL,
            description TEXT,
            payment_id TEXT,
            payment_method TEXT DEFAULT 'manual',
            status TEXT DEFAULT 'approved',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );

        -- RLS
        ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

        -- Política: admins podem ver todos os pagamentos
        CREATE POLICY "Admins can view all payments" ON public.payments
        FOR SELECT
        TO authenticated
        USING (
            auth.uid() IN (SELECT id FROM public.admins)
        );

        -- Política: usuários podem ver seus próprios pagamentos
        CREATE POLICY "Users can view own payments" ON public.payments
        FOR SELECT
        TO authenticated
        USING (user_id = auth.uid());

        -- Política: sistema pode inserir pagamentos
        CREATE POLICY "System can insert payments" ON public.payments
        FOR INSERT
        TO authenticated
        WITH CHECK (true);
    END IF;
END $$;
