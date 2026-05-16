-- ADICIONAR COLUNAS FALTANTES NA TABELA PAYMENTS
-- Resolve o problema dos pagamentos não estarem sendo registrados

-- Adicionar coluna payment_id (ID do pagamento no Mercado Pago)
ALTER TABLE public.payments 
ADD COLUMN IF NOT EXISTS payment_id TEXT;

-- Adicionar coluna payment_method (pix, card, etc)
ALTER TABLE public.payments 
ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'manual';

-- Adicionar coluna status (approved, pending, rejected)
ALTER TABLE public.payments 
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'approved';

-- Verificar resultado
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'payments' AND table_schema = 'public';

SELECT 'Colunas adicionadas com sucesso!' as result;
