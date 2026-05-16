# Instalação Manual do Supabase CLI - Alternativas

Como a instalação global via npm não é suportada, você tem algumas opções:

## Opção 1: Download Direto (Mais Rápido) ✅

1. **Baixe o executável do Supabase CLI:**
   - Windows: https://github.com/supabase/cli/releases/latest/download/supabase_windows_amd64.zip

2. **Extraia e adicione ao PATH:**
   ```powershell
   # Criar diretório para o executável
   mkdir "$env:USERPROFILE\supabase-cli"
   
   # Mova o executável extraído para esta pasta
   # Depois, adicione ao PATH:
   $env:Path += ";$env:USERPROFILE\supabase-cli"
   ```

3. **Verifique a instalação:**
   ```bash
   supabase --version
   ```

## Opção 2: Via PowerShell (Recomendado) ✅

Execute estes comandos no PowerShell como Administrador:

```powershell
# Baixar o executável
$url = "https://github.com/supabase/cli/releases/latest/download/supabase_windows_amd64.zip"
$output = "$env:TEMP\supabase.zip"
Invoke-WebRequest -Uri $url -OutFile $output

# Extrair
Expand-Archive -Path $output -DestinationPath "$env:USERPROFILE\supabase-cli" -Force

# Adicionar ao PATH permanentemente
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";$env:USERPROFILE\supabase-cli",
    "User"
)

# Aplicar no terminal atual
$env:Path += ";$env:USERPROFILE\supabase-cli"
```

## Opção 3: Uso via Docker (Alternativa)

Se você tem Docker instalado:

```bash
docker run --rm supabase/edge-runtime:latest --version
```

## Opção 4: Deploy Manual via Dashboard

Como alternativa ao CLI, você pode fazer o deploy da Edge Function diretamente pelo dashboard do Supabase:

### Passos:

1. **Acesse o Supabase Dashboard:**
   https://supabase.com/dashboard/project/loroyfayqjenjnvffurw

2. **Vá para Edge Functions:**
   - Menu lateral: Database > Edge Functions
   - Ou: https://supabase.com/dashboard/project/loroyfayqjenjnvffurw/functions

3. **Criar Nova Function:**
   - Clique em "Create a new function"
   - Nome: `renew-subscription`

4. **Cole o código:**
   - Copie todo o conteúdo de `supabase/functions/renew-subscription/index.ts`
   - Cole no editor
   - Clique em "Deploy"

## Depois de Instalar o CLI

Após conseguir instalar o CLI, execute:

```bash
# Login
supabase login

# Link o projeto
supabase link --project-ref loroyfayqjenjnvffurw

# Deploy
supabase functions deploy renew-subscription
```

---

**Recomendo usar a Opção 2 (PowerShell) ou Opção 4 (Deploy Manual via Dashboard).**
