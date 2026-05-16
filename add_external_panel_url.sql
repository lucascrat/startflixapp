-- Add external_panel_url field to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS external_panel_url TEXT;

-- Add comment to document the field
COMMENT ON COLUMN public.profiles.external_panel_url IS 'URL do cliente no painel externo para renovação automática (ex: https://cms.startpainel.cc/clients/2528627)';
