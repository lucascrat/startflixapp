-- RODE ESTE SCRIPT NO EDITOR SQL DO SUPABASE PARA CRIAR O ADMIN

-- Habilita a extensão de criptografia para gerar a senha
create extension if not exists pgcrypto;

DO $$
DECLARE
  new_user_id uuid := gen_random_uuid();
BEGIN
  -- Verifica se o usuário já existe para evitar erro
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@startflix.com') THEN
    
    -- 1. Insere o usuário na tabela de autenticação
    INSERT INTO auth.users (
      id,
      instance_id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at
    ) VALUES (
      new_user_id,
      '00000000-0000-0000-0000-000000000000',
      'authenticated',
      'authenticated',
      'admin@startflix.com',
      crypt('01Deus02@', gen_salt('bf')), -- Senha criptografada
      now(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Administrador Sistema"}',
      now(),
      now()
    );

    -- 2. Insere o perfil de admin (caso o trigger não tenha disparado ou para garantir)
    -- O trigger 'on_auth_user_created' que criamos antes deve cuidar disso, 
    -- mas vamos forçar a atualização para garantir que seja ADMIN via SQL.
    
    -- Aguarda um momento para o trigger (opcional, mas seguro fazer update direto)
    
  END IF;
  
  -- 3. Atualiza ou Garante que o usuário seja ADMIN
  UPDATE public.profiles 
  SET role = 'admin', is_active = true 
  WHERE email = 'admin@startflix.com';
  
END $$;
