-- CRIAR BUCKET DE STORAGE PARA IMAGENS DE APPS
-- Execute isso no SQL Editor do Supabase

-- 1. Criar bucket público para imagens de apps
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'app-images',
  'app-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[]
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Remover políticas existentes (se houver)
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view app images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete" ON storage.objects;

-- 3. Permitir que qualquer usuário autenticado faça upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'app-images');

-- 4. Permitir que qualquer um veja as imagens (público)
CREATE POLICY "Anyone can view app images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'app-images');

-- 5. Permitir que usuários autenticados deletem suas imagens
CREATE POLICY "Authenticated users can delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'app-images');

SELECT 'Bucket app-images criado com sucesso!' as result;
