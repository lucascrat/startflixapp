# Configuração do Supabase Storage para Upload de Imagens

## Passo 1: Criar o Bucket no Supabase

1. Acesse o painel do Supabase: https://supabase.com/dashboard
2. Selecione seu projeto **StartFlix Pro**
3. No menu lateral, clique em **Storage**
4. Clique em **New Bucket** (Novo Bucket)
5. Configure o bucket com as seguintes informações:
   - **Name**: `app-images`
   - **Public bucket**: ✅ Marque esta opção (permitir acesso público às imagens)
   - Clique em **Create bucket**

## Passo 2: Configurar Políticas de Acesso (RLS)

Após criar o bucket, você precisa configurar as políticas de acesso:

1. No painel do Storage, clique no bucket `app-images`
2. Clique na aba **Policies** (Políticas)
3. Crie as seguintes políticas:

### Política 1: Permitir Upload (INSERT)
```sql
CREATE POLICY "Admins can upload images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'app-images' 
  AND auth.uid() IN (
    SELECT id FROM public.profiles WHERE role = 'admin'
  )
);
```

### Política 2: Permitir Leitura Pública (SELECT)
```sql
CREATE POLICY "Public can view images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'app-images');
```

### Política 3: Permitir Deletar (DELETE) - Apenas Admins
```sql
CREATE POLICY "Admins can delete images"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'app-images'
  AND auth.uid() IN (
    SELECT id FROM public.profiles WHERE role = 'admin'
  )
);
```

## Passo 3: Testar o Upload

1. Faça login como admin no app
2. Vá para o painel administrativo
3. Edite um cliente
4. No campo "URL da Imagem (Logo)", clique no botão **Upload**
5. Selecione uma imagem do seu computador
6. A imagem será enviada para o Supabase Storage
7. O campo será preenchido automaticamente com a URL pública da imagem

## Notas Importantes

- As imagens são armazenadas com um nome único baseado no timestamp: `app_logo_[timestamp]_[nome_original]`
- As URLs públicas ficam no formato: `https://[seu-projeto].supabase.co/storage/v1/object/public/app-images/[nome_arquivo]`
- O bucket público permite que as imagens sejam acessadas sem autenticação
- Apenas administradores podem fazer upload e deletar imagens
- O tamanho máximo padrão do Supabase Storage é 50MB por arquivo

## Vantagens do Supabase Storage

✅ **Sem dependência de links externos** - As imagens ficam hospedadas no seu próprio projeto  
✅ **URLs estáveis** - Não quebram como links de terceiros  
✅ **Controle total** - Você gerencia tudo pelo dashboard do Supabase  
✅ **Performance** - CDN global do Supabase para entrega rápida  
✅ **Segurança** - Controle de acesso via RLS (Row Level Security)
