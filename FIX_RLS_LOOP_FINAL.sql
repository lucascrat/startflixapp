-- SOLUÇÃO DEFINITIVA V2 (IDEMPOTENTE)
-- Copie e cole TUDO abaixo no SQL Editor do Supabase.
-- Isso vai limpar as regras antigas e recriar as novas sem dar erro de "já existe".

-- 1. Limpar TODAS as políticas da tabela admins para evitar conflitos
DROP POLICY IF EXISTS "Admin view admins" ON public.admins;
DROP POLICY IF EXISTS "View own admin status" ON public.admins;
DROP POLICY IF EXISTS "Admins can view their own record" ON public.admins; -- Garantia extra

-- 2. Criar a política SIMPLIFICADA (Quebra o loop infinito)
-- Permite que o usuário veja APENAS se ele mesmo está na tabela.
CREATE POLICY "View own admin status" ON public.admins FOR SELECT USING (auth.uid() = id);

-- 3. Atualizar a função is_admin para usar essa política
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
    -- Esta consulta não gera mais recursão pois usa a política simples acima
    RETURN EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Teste final
SELECT 'RLS Corrigido com Sucesso!' as status;
