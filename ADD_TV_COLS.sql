-- SCRIPT PARA ADICIONAR CAMPOS DE TV NA TABELA DE PROFILES
-- Execute este script no SQL Editor do seu Supabase (Coolify)

ALTER TABLE startflix.profiles 
ADD COLUMN IF NOT EXISTS tv_enabled BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS tv_app_name TEXT,
ADD COLUMN IF NOT EXISTS tv_app_image TEXT,
ADD COLUMN IF NOT EXISTS tv_app_auth_type TEXT DEFAULT 'mac',
ADD COLUMN IF NOT EXISTS tv_app_mac TEXT,
ADD COLUMN IF NOT EXISTS tv_app_user TEXT,
ADD COLUMN IF NOT EXISTS tv_app_pass TEXT,
ADD COLUMN IF NOT EXISTS tv_app_email TEXT,
ADD COLUMN IF NOT EXISTS tv_app_pass_email TEXT;

-- Garantir que a view vw_profiles seja atualizada para incluir os novos campos
-- Corrigido para evitar erro de coluna "email" duplicada
DROP VIEW IF EXISTS public.vw_profiles;
CREATE VIEW public.vw_profiles AS
SELECT 
    p.*,
    au.last_sign_in_at
FROM startflix.profiles p
JOIN auth.users au ON p.id = au.id;
-- Nota: Removido au.email pois a tabela profiles já possui a coluna email 
-- ou ela é herdada de forma duplicada no join.
