-- CRIAR BUCKET PARA IMAGENS DE PERFIL/CLIENTES
-- Resolve o erro de upload de imagem do cliente

-- 1. Criar bucket para imagens de perfil
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-images',
  'profile-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[]
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Criar bucket para avatars (caso seja usado separadamente)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']::text[]
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 3. Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Profile images upload" ON storage.objects;
DROP POLICY IF EXISTS "Profile images view" ON storage.objects;
DROP POLICY IF EXISTS "Profile images delete" ON storage.objects;
DROP POLICY IF EXISTS "Avatars upload" ON storage.objects;
DROP POLICY IF EXISTS "Avatars view" ON storage.objects;

-- 4. Permitir upload para qualquer usuário autenticado
CREATE POLICY "Profile images upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id IN ('profile-images', 'avatars', 'app-images'));

-- 5. Permitir visualização pública
CREATE POLICY "Profile images view"
ON storage.objects FOR SELECT
TO public
USING (bucket_id IN ('profile-images', 'avatars', 'app-images'));

-- 6. Permitir delete para usuários autenticados
CREATE POLICY "Profile images delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id IN ('profile-images', 'avatars', 'app-images'));

-- 7. Permitir update
CREATE POLICY "Profile images update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id IN ('profile-images', 'avatars', 'app-images'));

SELECT 'Buckets de imagem criados!' as result;
