-- ============================================================
-- M3U SYSTEM IMPROVEMENTS: AUTO-LEASE & PERSISTENT LINKS
-- ============================================================

-- 1. ADICIONAR COLUNA PARA CONTROLE DE ATIVIDADE SE NÃO EXISTIR
-- Usaremos updated_at para controlar o tempo de "lease" (contrato) do sinal.

-- 2. FUNÇÃO ACQUIRE DYNAMICO (MELHORADA PARA PLAYERS EXTERNOS)
CREATE OR REPLACE FUNCTION startflix.acquire_m3u_signal(p_user_id UUID, p_is_external BOOLEAN DEFAULT FALSE)
RETURNS JSON AS $$
DECLARE
    v_account RECORD;
    v_lease_interval INTERVAL := '3 hours'; -- Tempo que um sinal fica preso sem renovação
BEGIN
    -- 0. Verificar se o usuário existe e está ativo/pago (OPCIONAL mas recomendado)
    -- IF NOT EXISTS (SELECT 1 FROM startflix.profiles WHERE id = p_user_id AND is_active = true) THEN
    --     RETURN json_build_object('success', false, 'error', 'unauthorized', 'message', 'Usuário inativo ou não encontrado');
    -- END IF;

    -- 1. Se o usuário já tem um sinal, apenas renovamos o tempo de uso dele
    SELECT * INTO v_account 
    FROM startflix.media_accounts 
    WHERE user_id = p_user_id 
    LIMIT 1;

    IF FOUND THEN
        UPDATE startflix.media_accounts 
        SET updated_at = now() 
        WHERE id = v_account.id;

        RETURN json_build_object(
            'success', true,
            'dns', v_account.dns,
            'username', v_account.username,
            'password', v_account.password,
            'message', 'Sinal renovado'
        );
    END IF;

    -- 2. Tentar pegar um sinal TOTALMENTE LIVRE
    SELECT * INTO v_account 
    FROM startflix.media_accounts 
    WHERE user_id IS NULL 
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

    IF FOUND THEN
        UPDATE startflix.media_accounts 
        SET user_id = p_user_id, updated_at = now() 
        WHERE id = v_account.id;

        RETURN json_build_object(
            'success', true,
            'dns', v_account.dns,
            'username', v_account.username,
            'password', v_account.password,
            'message', 'Novo sinal adquirido'
        );
    END IF;

    -- 3. Se o estoque está CHEIO, tentar pegar um sinal "ESTAGNADO" (Expirou o lease)
    -- Um sinal é estagnado se updated_at for muito antigo
    SELECT * INTO v_account 
    FROM startflix.media_accounts 
    WHERE updated_at < (now() - v_lease_interval)
    ORDER BY updated_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

    IF FOUND THEN
        -- "Rouba" o sinal do usuário anterior que não o usa há horas
        UPDATE startflix.media_accounts 
        SET user_id = p_user_id, updated_at = now() 
        WHERE id = v_account.id;

        RETURN json_build_object(
            'success', true,
            'dns', v_account.dns,
            'username', v_account.username,
            'password', v_account.password,
            'message', 'Sinal rotacionado (recuperado de inatividade)'
        );
    END IF;

    -- 4. Sem sinais disponíveis
    RETURN json_build_object(
        'success', false,
        'error', 'full',
        'message', 'Capacidade máxima atingida. Tente novamente mais tarde.'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Garantir acesso
GRANT EXECUTE ON FUNCTION startflix.acquire_m3u_signal(UUID, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION startflix.acquire_m3u_signal(UUID, BOOLEAN) TO anon; -- Necessário para link direto se não usarmos token seguro

-- 3. CRIAR VIEW PARA MONITORAMENTO DE LEASE NO PAINEL ADMIN
CREATE OR REPLACE VIEW startflix.vw_inventory_status AS
SELECT 
    id,
    provider_name,
    dns,
    username,
    user_id,
    updated_at,
    CASE 
        WHEN user_id IS NULL THEN 'LIVRE'
        WHEN updated_at < (now() - interval '3 hours') THEN 'ESTAGNADO (Disponível p/ Rotação)'
        ELSE 'EM USO ATIVO'
    END as current_status
FROM startflix.media_accounts;
