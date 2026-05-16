-- ============================================================
-- FIX RLS - Políticas mais permissivas para profiles
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- Primeiro, vamos verificar as políticas atuais
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE schemaname = 'startflix' AND tablename = 'profiles';

-- Remover políticas existentes de profiles
DROP POLICY IF EXISTS "profiles_select" ON startflix.profiles;
DROP POLICY IF EXISTS "profiles_insert" ON startflix.profiles;
DROP POLICY IF EXISTS "profiles_update" ON startflix.profiles;
DROP POLICY IF EXISTS "profiles_delete" ON startflix.profiles;

-- Política simples: Todos autenticados podem ver todos os perfis
CREATE POLICY "profiles_select_all" ON startflix.profiles
    FOR SELECT TO authenticated
    USING (true);

-- Usuários podem inserir seu próprio perfil
CREATE POLICY "profiles_insert_own" ON startflix.profiles
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = id);

-- Usuários podem atualizar seu próprio perfil OU qualquer um pode atualizar (temporário para debug)
CREATE POLICY "profiles_update_all" ON startflix.profiles
    FOR UPDATE TO authenticated
    USING (true);

-- Qualquer um pode deletar (temporário para debug)
CREATE POLICY "profiles_delete_all" ON startflix.profiles
    FOR DELETE TO authenticated
    USING (true);

-- Verificar novamente
SELECT 'Políticas atualizadas!' as status;
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'startflix' AND tablename = 'profiles';
