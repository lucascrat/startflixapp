-- ============================================================
-- SETUP DEVICE LIMIT SYSTEM
-- ============================================================

-- 1. Create active_devices table
CREATE TABLE IF NOT EXISTS startflix.active_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    device_name TEXT,
    last_active_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, device_id)
);

-- 2. RLS Policies
ALTER TABLE startflix.active_devices ENABLE ROW LEVEL SECURITY;

-- Allow users to see their own devices
CREATE POLICY "Users can view own devices" ON startflix.active_devices
    FOR SELECT TO authenticated USING (user_id = auth.uid());

-- Allow users to delete their own devices (logout)
CREATE POLICY "Users can delete own devices" ON startflix.active_devices
    FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Allow users to insert their own devices (handled by RPC usually, but enabling here)
CREATE POLICY "Users can insert own devices" ON startflix.active_devices
    FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
    
-- Allow users to update their own devices (heartbeat)
CREATE POLICY "Users can update own devices" ON startflix.active_devices
    FOR UPDATE TO authenticated USING (user_id = auth.uid());


-- 3. RPC Function to Register Device
CREATE OR REPLACE FUNCTION startflix.register_device(
    p_device_id TEXT,
    p_device_name TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_count INTEGER;
    v_user_id UUID;
    v_exists BOOLEAN;
BEGIN
    v_user_id := auth.uid();
    
    -- Check if device already registered
    SELECT EXISTS (
        SELECT 1 FROM startflix.active_devices 
        WHERE user_id = v_user_id AND device_id = p_device_id
    ) INTO v_exists;
    
    IF v_exists THEN
        -- Update last active
        UPDATE startflix.active_devices 
        SET last_active_at = now(),
            device_name = COALESCE(p_device_name, device_name)
        WHERE user_id = v_user_id AND device_id = p_device_id;
        
        RETURN jsonb_build_object('success', true, 'message', 'Device updated');
    END IF;

    -- Check current device count
    SELECT COUNT(*) INTO v_count 
    FROM startflix.active_devices 
    WHERE user_id = v_user_id;
    
    IF v_count >= 2 THEN
        RETURN jsonb_build_object(
            'success', false, 
            'message', 'Limite de 2 dispositivos atingido. Desconecte de um aparelho para entrar neste.'
        );
    END IF;
    
    -- Register new device
    INSERT INTO startflix.active_devices (user_id, device_id, device_name)
    VALUES (v_user_id, p_device_id, p_device_name);
    
    RETURN jsonb_build_object('success', true, 'message', 'Device registered');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
