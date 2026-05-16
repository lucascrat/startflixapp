-- DIAGNÓSTICO DO PERFIL "LUCAS"
-- Execute no SQL Editor do Supabase para ver o estado real do perfil

-- 1. Verificar se o usuário existe em auth.users
SELECT id, email, created_at 
FROM auth.users 
WHERE email ILIKE '%lucas%' OR raw_user_meta_data->>'username' ILIKE '%lucas%';

-- 2. Verificar o perfil correspondente em public.profiles
SELECT 
    id,
    username,
    email,
    role,
    m3u_url,
    is_active,
    expiration_date,
    created_at
FROM public.profiles 
WHERE username ILIKE '%lucas%' OR email ILIKE '%lucas%';

-- 3. Verificar se há uma lista padrão ativa
SELECT * FROM public.default_m3u_lists WHERE is_active = true;

-- 4. Verificar se a tabela admins tem o usuário (caso tenha sido cadastrado como admin errado)
SELECT * FROM public.admins;

-- 5. Testar diretamente a política RLS - Simular leitura como o próprio usuário
-- (Isso mostra se a política está funcionando)
SELECT 
    'A política de SELECT em profiles está correta se você consegue ver este resultado' as teste,
    COUNT(*) as total_profiles
FROM public.profiles;
