# 🚀 Deploy da Edge Function via Dashboard (Método Simplificado)

Como a instalação do CLI está apresentando problemas, vamos fazer o deploy diretamente pelo dashboard do Supabase - é mais rápido e direto!

## 📋 Passo a Passo:

### 1. Acesse seu projeto no Supabase

Abra este link no navegador:
```
https://supabase.com/dashboard/project/loroyfayqjenjnvffurw
```

### 2. Vá para Edge Functions

- No menu lateral esquerdo, clique em **"Edge Functions"**
- Ou acesse diretamente:
```
https://supabase.com/dashboard/project/loroyfayqjenjnvffurw/functions
```

### 3. Criar Nova Function

1. Clique no botão **"Create a new function"**
2. **Nome da função**: `renew-subscription`
3. Clique em **"Create function"**

### 4. Cole o Código

Abra o arquivo:
```
c:\Users\hldes\Desktop\startflix pro\supabase\functions\renew-subscription\index.ts
```

**Copie TODO o conteúdo** e cole no editor do Supabase.

### 5. Deploy

Clique em **"Deploy function"** (botão verde no canto superior direito)

### 6. Teste

Após o deploy, você pode testar direto no dashboard:

1. Vá para a aba **"Invocations"**
2. Cole este JSON de teste:
```json
{
  "userId": "test-id",
  "externalPanelUrl": "https://cms.startpainel.cc/clients/2528627"
}
```
3. Clique em **"Run"**

---

## ✅ Pronto!

Após fazer o deploy, o botão de renovação no app funcionará automaticamente!

## 🔍 Verificar se Funcionou

No dashboard do Supabase:

1. **Edge Functions** > **renew-subscription**
2. Aba **"Logs"** - Você verá os logs de execução
3. Aba **"Metrics"** - Estatísticas de uso

## ⚠️ IMPORTANTE

A Edge Function usa **browser automation** (Puppeteer/Astral), que pode não funcionar no ambiente do Supabase Edge Runtime sem configuração adicional.

### Solução Alternativa (Se não funcionar):

Use um serviço externo como:
- **Zapier** (com webhooks)
- **n8n** (self-hosted)
- **Make.com** (ex-Integromat)
- **AWS Lambda** com Puppeteer

Ou simplifique a renovação usando a **API do painel** (se disponível) ao invés de browser automation.

---

## 📝 Próximos Passos

Depois que a função estiver deployada:

1. ✅ Execute o SQL para adicionar o campo no banco:
   ```sql
   ALTER TABLE public.profiles
   ADD COLUMN IF NOT EXISTS external_panel_url TEXT;
   ```

2. ✅ Atualize o app no celular

3. ✅ Teste a renovação manual no painel admin
