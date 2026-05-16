-- ============================================================
-- FIX SIGNALS LOGIC - STARTFLIX SCHEMA
-- ============================================================

-- 1. DROP THE AUTOMATIC ASSIGNMENT TRIGGER (IT PREVENTS ROTATION)
-- This trigger was permanently binding a signal to every new user.
DROP TRIGGER IF EXISTS on_profile_created_assign_tv ON startflix.profiles;
DROP TRIGGER IF EXISTS on_profile_created_assign_tv ON public.profiles;

-- 2. ENSURE media_accounts TABLE IS IN THE CORRECT SCHEMA
-- (The setup might have created it in 'public' or 'startflix')
-- We will consolidate into 'startflix' schema for this logic.

-- 3. THE ACQUIRE SIGNAL RPC
CREATE OR REPLACE FUNCTION startflix.acquire_signal(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_account RECORD;
BEGIN
    -- First, check if the user ALREADY has a signal assigned (to avoid double-dipping)
    SELECT * INTO v_account 
    FROM startflix.media_accounts 
    WHERE user_id = p_user_id 
    LIMIT 1;

    -- If found, record it and return
    IF FOUND THEN
        RETURN json_build_object(
            'success', true,
            'dns', v_account.dns,
            'username', v_account.username,
            'password', v_account.password,
            'message', 'Sinal já estava atribuído'
        );
    END IF;

    -- If not found, look for an AVAILABLE signal (user_id IS NULL)
    -- We use FOR UPDATE SKIP LOCKED to handle concurrency safely
    SELECT * INTO v_account 
    FROM startflix.media_accounts 
    WHERE user_id IS NULL 
    ORDER BY created_at ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

    IF FOUND THEN
        -- Assign it to the user
        UPDATE startflix.media_accounts 
        SET user_id = p_user_id, updated_at = now() 
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

-- 4. THE RELEASE SIGNAL RPC
CREATE OR REPLACE FUNCTION startflix.release_signal(p_user_id UUID)
RETURNS JSON AS $$
BEGIN
    -- Release any signal assigned to this user
    UPDATE startflix.media_accounts 
    SET user_id = NULL, updated_at = now() 
    WHERE user_id = p_user_id;

    RETURN json_build_object(
        'success', true,
        'message', 'Sinal liberado com sucesso'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. ENSURE RLS ALLOWS RPC ACCESS
GRANT EXECUTE ON FUNCTION startflix.acquire_signal(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION startflix.release_signal(UUID) TO authenticated;

-- 6. SPECIAL CLEANUP: RELEASE ALL SIGNALS THAT ARE STUCK
-- (Optional: Run this once manually if needed)
-- UPDATE startflix.media_accounts SET user_id = NULL WHERE user_id IS NOT NULL;
