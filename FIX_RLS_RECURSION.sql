-- CORREÇÃO CRÍTICA DE RLS (Recursão Infinita)
-- Execute este script no Editor SQL do Supabase IMEDIATAMENTE.
-- Isso corrigirá o erro "infinite recursion detected" que impede o carregamento do App.

-- 1. Redefinir a função is_admin() para NÃO consultar a tabela profiles.
-- Removemos a verificação circular: is_admin -> profiles -> policy -> is_admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
    -- Verifica APENAS na tabela admins. 
    -- Como a função é SECURITY DEFINER, ela tem permissão para ler essa tabela.
    RETURN EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Criar Gatilho para Sincronizar 'role' do Profile com a tabela Admins
-- Se você mudar o role para 'admin' no painel, ele adiciona automaticamente na tabela admins
CREATE OR REPLACE FUNCTION public.sync_admin_role()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role = 'admin' THEN
        INSERT INTO public.admins (id, email)
        VALUES (NEW.id, NEW.email)
        ON CONFLICT (id) DO NOTHING;
    ELSE
        DELETE FROM public.admins WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_profile_role_change ON public.profiles;
CREATE TRIGGER on_profile_role_change
AFTER INSERT OR UPDATE OF role ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.sync_admin_role();

-- 3. Garantir que todos os admins atuais estejam na tabela admins
INSERT INTO public.admins (id, email)
SELECT id, email FROM public.profiles WHERE role = 'admin'
ON CONFLICT (id) DO NOTHING;

-- 4. Confirmação
SELECT 'Correcao de RLS Aplicada com Sucesso' as status;
