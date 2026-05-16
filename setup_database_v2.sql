-- STARTFLIX PRO - SUPABASE CLOUD SAFE SETUP (Final Version)
-- 1. CORREÇÃO DE SCHEMA E RPC
-- 2. REMOVE INSERÇÕES DIRETAS EM AUTH.USERS (Para evitar erro 42P10 e bloqueios de Cloud)
-- 3. PERMITE CRIAÇÃO DE ADMIN PELO APP (Sign Up)

-- =====================================================================
-- 0. LIMPEZA DA TABELA INCORRETA DO USUÁRIO
-- =====================================================================
-- Se você criou uma tabela admins manual com colunas erradas, isso vai limpar.
DROP TABLE IF EXISTS public.admins CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

DROP FUNCTION IF EXISTS public.is_admin() CASCADE;
DROP FUNCTION IF EXISTS public.create_profile_for_user(uuid, text, text, text) CASCADE;
DROP FUNCTION IF EXISTS public.promote_to_admin(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.demote_admin(uuid) CASCADE;

-- =====================================================================
-- 1. TABELAS CORRETAS
-- =====================================================================
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY, -- Deve bater com auth.users.id
  username text,
  email text,
  password text, -- Visual apenas
  full_name text,
  role text DEFAULT 'user',
  m3u_url text,
  is_active boolean DEFAULT true,
  expiration_date timestamptz,
  app_image_url text,
  app_mac text,
  app_creds_password text,
  tv_provider_name text,
  tv_username text,
  tv_password text,
  tv_dns text,
  created_at timestamptz DEFAULT now()
);

-- Tabela Admins deve ter ID como UUID linkado ao Auth
CREATE TABLE public.admins (
  id uuid PRIMARY KEY,
  email text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- =====================================================================
-- 2. SEGURANÇA (RLS)
-- =====================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- POLICIES
CREATE POLICY "View Profiles" ON public.profiles FOR SELECT USING (auth.uid() = id OR is_admin());
CREATE POLICY "Insert Profiles" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id OR is_admin());
CREATE POLICY "Update Profiles" ON public.profiles FOR UPDATE USING (auth.uid() = id OR is_admin());
CREATE POLICY "Delete Profiles" ON public.profiles FOR DELETE USING (is_admin());

CREATE POLICY "Allow read own admin" ON public.admins FOR SELECT USING (auth.uid() = id OR is_admin());
CREATE POLICY "Insert admin only" ON public.admins FOR INSERT WITH CHECK (is_admin());

-- =====================================================================
-- 3. RPC: CREATE PROFILE (Com Auto-Admin)
-- Chamada pelo App após Sign Up
-- =====================================================================
CREATE OR REPLACE FUNCTION public.create_profile_for_user(
  p_user_id uuid, 
  p_full_name text, 
  p_m3u_url text,
  p_password text
)
RETURNS void AS $$
DECLARE
  v_email text;
BEGIN
  -- 1. Buscar email do usuário novo
  SELECT email INTO v_email FROM auth.users WHERE id = p_user_id;
  
  -- 2. Inserir Profile
  INSERT INTO public.profiles (
    id, username, email, password, full_name, role, m3u_url, created_at
  ) VALUES (
    p_user_id,
    split_part(v_email, '@', 1), -- username extraído do email
    v_email,
    p_password,
    p_full_name,
    'user', -- padrão user
    p_m3u_url,
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    password = EXCLUDED.password;

  -- 3. AUTO-PROMOTE ADMIN (Se o email for o do admin)
  IF v_email = 'admin@startflix.app' OR v_email = 'admin@startflix.com' THEN
      INSERT INTO public.admins (id, email) VALUES (p_user_id, v_email)
      ON CONFLICT (id) DO NOTHING;
      
      UPDATE public.profiles SET role = 'admin' WHERE id = p_user_id;
  END IF;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================================
-- 4. INSTRUÇÕES FINAIS
-- =====================================================================
-- A tabela agora está limpa e correta.
-- Como a inserção via SQL falhou (Cloud Block), faça o seguinte:
-- 1. Rode este script.
-- 2. Abra o App no Celular/Emulador.
-- 3. Clique em "Novo por aqui? Assine agora" (Sign Up).
-- 4. Crie o usuário:
--      Nome: Admin System
--      Usuário: admin
--      Senha: 01Deus02@
-- 5. O sistema irá criar a conta e AUTOMATICAMENTE te tornar Admin graças à função acima.


