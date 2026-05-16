-- Adiciona coluna ads_enabled na tabela profiles
-- Padrão TRUE = propagandas ativadas para todos os clientes
ALTER TABLE startflix.profiles
ADD COLUMN IF NOT EXISTS ads_enabled BOOLEAN DEFAULT true NOT NULL;

-- Comentário explicativo
COMMENT ON COLUMN startflix.profiles.ads_enabled IS 'Controla se o cliente vê propagandas no app. true = anúncios ativados (padrão), false = sem anúncios.';
