-- SISTEMA DE APPS E LISTAS M3U PADRÃO
-- Execute este SQL no Supabase SQL Editor

-- 1. TABELA DE APPS CADASTRADOS
-- Armazena os apps disponíveis (ex: IBO Player, XCIPTV, etc)
CREATE TABLE IF NOT EXISTS public.apps (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,                          -- Nome do app (ex: IBO Player)
    image_url TEXT,                              -- URL da imagem/logo do app
    auth_type TEXT DEFAULT 'mac',                -- Tipo: 'mac', 'xtream', 'url'
    description TEXT,                            -- Descrição do app
    is_active BOOLEAN DEFAULT true,              -- Se está ativo
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABELA DE LISTAS M3U PADRÃO
-- Listas que novos usuários recebem automaticamente
CREATE TABLE IF NOT EXISTS public.default_m3u_lists (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,                          -- Nome da lista (ex: Lista Principal)
    m3u_url TEXT NOT NULL,                       -- URL da lista M3U
    priority INTEGER DEFAULT 0,                  -- Prioridade (maior = usada primeiro)
    is_active BOOLEAN DEFAULT true,              -- Se está ativa
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. ADICIONAR CAMPO app_id NA TABELA PROFILES
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS app_id UUID REFERENCES public.apps(id);

-- 4. ADICIONAR CAMPOS DE CREDENCIAIS DO APP
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS app_mac_address TEXT,
ADD COLUMN IF NOT EXISTS app_provider_url TEXT,
ADD COLUMN IF NOT EXISTS app_username TEXT,
ADD COLUMN IF NOT EXISTS app_password_app TEXT;

-- 5. RLS PARA TABELA APPS
ALTER TABLE public.apps ENABLE ROW LEVEL SECURITY;

-- Todos podem ver apps ativos
CREATE POLICY "Anyone can view active apps" ON public.apps
FOR SELECT USING (is_active = true);

-- Apenas admins podem inserir/atualizar/deletar
CREATE POLICY "Admins can manage apps" ON public.apps
FOR ALL TO authenticated
USING (
    auth.uid() IN (SELECT id FROM public.admins)
    OR auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
)
WITH CHECK (
    auth.uid() IN (SELECT id FROM public.admins)
    OR auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
);

-- 6. RLS PARA TABELA DEFAULT_M3U_LISTS
ALTER TABLE public.default_m3u_lists ENABLE ROW LEVEL SECURITY;

-- Todos podem ver listas ativas
CREATE POLICY "Anyone can view active lists" ON public.default_m3u_lists
FOR SELECT USING (is_active = true);

-- Apenas admins podem gerenciar
CREATE POLICY "Admins can manage default lists" ON public.default_m3u_lists
FOR ALL TO authenticated
USING (
    auth.uid() IN (SELECT id FROM public.admins)
    OR auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
)
WITH CHECK (
    auth.uid() IN (SELECT id FROM public.admins)
    OR auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin')
);

-- 7. INSERIR ALGUNS APPS DE EXEMPLO
INSERT INTO public.apps (name, auth_type, description) VALUES
('IBO Player', 'mac', 'Player popular com suporte a MAC Address'),
('XCIPTV', 'xtream', 'Player com Xtream Codes API'),
('Smarters Pro', 'xtream', 'IPTV Smarters Pro'),
('TiviMate', 'url', 'Player premium com URL M3U'),
('Outro', 'url', 'Outro player genérico')
ON CONFLICT DO NOTHING;

-- 8. FUNÇÃO PARA ATRIBUIR LISTA PADRÃO A NOVOS USUÁRIOS
CREATE OR REPLACE FUNCTION assign_default_m3u_to_user()
RETURNS TRIGGER AS $$
DECLARE
    default_list RECORD;
BEGIN
    -- Buscar a lista padrão com maior prioridade
    SELECT m3u_url INTO default_list
    FROM public.default_m3u_lists
    WHERE is_active = true
    ORDER BY priority DESC
    LIMIT 1;
    
    -- Se encontrou uma lista, atribuir ao usuário
    IF default_list.m3u_url IS NOT NULL THEN
        UPDATE public.profiles
        SET m3u_url = default_list.m3u_url
        WHERE id = NEW.id AND (m3u_url IS NULL OR m3u_url = '');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. TRIGGER PARA ATRIBUIR LISTA AO CRIAR USUÁRIO
DROP TRIGGER IF EXISTS trigger_assign_default_m3u ON public.profiles;
CREATE TRIGGER trigger_assign_default_m3u
AFTER INSERT ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION assign_default_m3u_to_user();

-- 10. VERIFICAR ESTRUTURA
SELECT 'Apps table created' as status;
SELECT 'Default M3U lists table created' as status;
