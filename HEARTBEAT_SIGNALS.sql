-- ============================================================
-- HEARTBEAT SIGNALS - Detectar usuários ativos e liberar sinais inativos
-- Rode este script no banco de dados PostgreSQL (console do Coolify)
-- ============================================================

-- 1. Adicionar coluna last_heartbeat em media_accounts
ALTER TABLE startflix.media_accounts
  ADD COLUMN IF NOT EXISTS last_heartbeat TIMESTAMPTZ;

-- 2. Atualizar acquire_signal para registrar heartbeat ao adquirir
CREATE OR REPLACE FUNCTION startflix.acquire_signal(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_account RECORD;
BEGIN
    SELECT * INTO v_account
    FROM startflix.media_accounts
    WHERE user_id = p_user_id
    LIMIT 1;

    IF FOUND THEN
        UPDATE startflix.media_accounts
        SET last_heartbeat = NOW()
        WHERE id = v_account.id;

        RETURN json_build_object(
            'success', true,
            'dns', v_account.dns,
            'username', v_account.username,
            'password', v_account.password,
            'message', 'Sinal já estava atribuído'
        );
    END IF;

    SELECT * INTO v_account
    FROM startflix.media_accounts
    WHERE user_id IS NULL
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

    IF FOUND THEN
        UPDATE startflix.media_accounts
        SET user_id = p_user_id, updated_at = NOW(), last_heartbeat = NOW()
        WHERE id = v_account.id;

        RETURN json_build_object(
            'success', true,
            'dns', v_account.dns,
            'username', v_account.username,
            'password', v_account.password,
            'message', 'Sinal adquirido com sucesso'
        );
    ELSE
        RETURN json_build_object(
            'success', false,
            'error', 'lotado',
            'message', 'Não há sinais disponíveis no estoque momento.'
        );
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Heartbeat — chamado pelo app Flutter a cada 2 minutos enquanto ativo
CREATE OR REPLACE FUNCTION startflix.send_heartbeat(p_user_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE startflix.media_accounts
    SET last_heartbeat = NOW()
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Liberar sinais inativos — chamado pelo painel admin
--    p_minutes: minutos sem heartbeat para considerar inativo (padrão: 5)
CREATE OR REPLACE FUNCTION startflix.release_stale_signals(p_minutes INTEGER DEFAULT 5)
RETURNS JSON AS $$
DECLARE
    released INTEGER;
BEGIN
    UPDATE startflix.media_accounts
    SET user_id = NULL, last_heartbeat = NULL, updated_at = NOW()
    WHERE user_id IS NOT NULL
      AND (
        last_heartbeat IS NULL
        OR last_heartbeat < NOW() - (p_minutes || ' minutes')::INTERVAL
      );

    GET DIAGNOSTICS released = ROW_COUNT;
    RETURN json_build_object('released', released);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Grants para o role anon (usado pelo app e pelo painel via PostgREST)
GRANT EXECUTE ON FUNCTION startflix.send_heartbeat(UUID) TO anon;
GRANT EXECUTE ON FUNCTION startflix.release_stale_signals(INTEGER) TO anon;
