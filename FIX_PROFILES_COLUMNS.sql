-- ADICIONAR COLUNAS FALTANTES NA TABELA PROFILES
-- Essas colunas são necessárias para editar clientes

-- App fields
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_mac TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_image_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_creds_password TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_id TEXT;

-- App Xtream Codes credentials
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_provider_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_username TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS app_password_app TEXT;

-- External panel URL
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS external_panel_url TEXT;

-- Legacy TV fields (for backward compatibility)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tv_provider_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tv_username TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tv_password TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tv_dns TEXT;

-- Verificar resultado  
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT 'Colunas adicionadas com sucesso!' as result;
