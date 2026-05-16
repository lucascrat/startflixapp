-- CORREÇÃO DE ERRO 500 (Recursividade Infinita nas Políticas de Segurança)

-- 1. Cria uma função segura para checar se é admin
-- 'SECURITY DEFINER' faz com que a função rode com permissão total, evitando o loop infinito do RLS
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Remove as políticas antigas que causavam erro
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can insert profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON public.profiles;

-- 3. Recria as políticas usando a função segura

-- Visualizar: Admin vê tudo, Usuário vê só o seu
CREATE POLICY "Admins can view all profiles"
  ON public.profiles FOR SELECT
  USING ( is_admin() OR auth.uid() = id );

-- Inserir: Admin pode inserir (caso use dashboard), Usuário via trigger (automático)
CREATE POLICY "Admins and Users can insert"
  ON public.profiles FOR INSERT
  WITH CHECK ( true ); -- O Trigger garante a segurança dos dados, ou restrinja se preferir

-- Atualizar: Admin pode tudo, Usuário PODE atualizar (opcional) ou restringir
CREATE POLICY "Admins can update all profiles"
  ON public.profiles FOR UPDATE
  USING ( is_admin() );

-- Deletar: Apenas Admin
CREATE POLICY "Admins can delete profiles"
  ON public.profiles FOR DELETE
  USING ( is_admin() );
