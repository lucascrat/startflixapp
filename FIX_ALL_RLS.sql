-- ============================================================
-- FIX RLS PARA TODAS AS TABELAS DO SCHEMA STARTFLIX
-- Execute este script no Supabase SQL Editor
-- ============================================================

-- APPS - Políticas permissivas
DROP POLICY IF EXISTS "apps_select" ON startflix.apps;
DROP POLICY IF EXISTS "apps_all" ON startflix.apps;
DROP POLICY IF EXISTS "apps_select_all" ON startflix.apps;

CREATE POLICY "apps_select_all" ON startflix.apps
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "apps_insert_all" ON startflix.apps
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "apps_update_all" ON startflix.apps
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "apps_delete_all" ON startflix.apps
    FOR DELETE TO authenticated
    USING (true);

-- DEFAULT_M3U_LISTS - Políticas permissivas
DROP POLICY IF EXISTS "default_m3u_select" ON startflix.default_m3u_lists;
DROP POLICY IF EXISTS "default_m3u_all" ON startflix.default_m3u_lists;

CREATE POLICY "default_m3u_select_all" ON startflix.default_m3u_lists
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "default_m3u_insert_all" ON startflix.default_m3u_lists
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "default_m3u_update_all" ON startflix.default_m3u_lists
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "default_m3u_delete_all" ON startflix.default_m3u_lists
    FOR DELETE TO authenticated
    USING (true);

-- CLIENT_TVS - Políticas permissivas
DROP POLICY IF EXISTS "client_tvs_select" ON startflix.client_tvs;
DROP POLICY IF EXISTS "client_tvs_all" ON startflix.client_tvs;

CREATE POLICY "client_tvs_select_all" ON startflix.client_tvs
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "client_tvs_insert_all" ON startflix.client_tvs
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "client_tvs_update_all" ON startflix.client_tvs
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "client_tvs_delete_all" ON startflix.client_tvs
    FOR DELETE TO authenticated
    USING (true);

-- PAYMENTS - Políticas permissivas
DROP POLICY IF EXISTS "payments_select" ON startflix.payments;
DROP POLICY IF EXISTS "payments_insert" ON startflix.payments;

CREATE POLICY "payments_select_all" ON startflix.payments
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "payments_insert_all" ON startflix.payments
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "payments_update_all" ON startflix.payments
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "payments_delete_all" ON startflix.payments
    FOR DELETE TO authenticated
    USING (true);

-- MEDIA_ACCOUNTS - Políticas permissivas
DROP POLICY IF EXISTS "media_accounts_select" ON startflix.media_accounts;
DROP POLICY IF EXISTS "media_accounts_all" ON startflix.media_accounts;

CREATE POLICY "media_accounts_select_all" ON startflix.media_accounts
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "media_accounts_insert_all" ON startflix.media_accounts
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "media_accounts_update_all" ON startflix.media_accounts
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "media_accounts_delete_all" ON startflix.media_accounts
    FOR DELETE TO authenticated
    USING (true);

-- USER_WATCHLIST - Políticas permissivas
DROP POLICY IF EXISTS "watchlist_select" ON startflix.user_watchlist;
DROP POLICY IF EXISTS "watchlist_insert" ON startflix.user_watchlist;
DROP POLICY IF EXISTS "watchlist_delete" ON startflix.user_watchlist;

CREATE POLICY "watchlist_select_all" ON startflix.user_watchlist
    FOR SELECT TO authenticated
    USING (true);

CREATE POLICY "watchlist_insert_all" ON startflix.user_watchlist
    FOR INSERT TO authenticated
    WITH CHECK (true);

CREATE POLICY "watchlist_update_all" ON startflix.user_watchlist
    FOR UPDATE TO authenticated
    USING (true);

CREATE POLICY "watchlist_delete_all" ON startflix.user_watchlist
    FOR DELETE TO authenticated
    USING (true);

-- ADMINS - Políticas permissivas
DROP POLICY IF EXISTS "admins_select" ON startflix.admins;

CREATE POLICY "admins_select_all" ON startflix.admins
    FOR SELECT TO authenticated
    USING (true);

-- Verificar políticas criadas
SELECT 'Políticas RLS atualizadas!' as status;
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'startflix'
ORDER BY tablename, policyname;
