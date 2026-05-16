# Sistema de Renovação Automática de Assinaturas

## 📋 Visão Geral

Este sistema permite que o administrador renove automaticamente as assinaturas dos clientes no painel externo (https://cms.startpainel.cc) diretamente pelo app StartFlix Pro.

## 🔧 Configuração Inicial

### Passo 1: Atualizar o Banco de Dados

Execute o SQL no Supabase para adicionar o campo necessário:

```sql
-- Execute este SQL no Supabase SQL Editor
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS external_panel_url TEXT;

COMMENT ON COLUMN public.profiles.external_panel_url IS 
'URL do cliente no painel externo para renovação automática (ex: https://cms.startpainel.cc/clients/2528627)';
```

### Passo 2: Configurar a Edge Function (Renovação Automática)

#### 2.1 Instalar Supabase CLI

Se ainda não tiver o Supabase CLI instalado:

```bash
# Windows (via npm)
npm install -g supabase

# Ou via Chocolatey
choco install supabase
```

#### 2.2 Login no Supabase

```bash
supabase login
```

#### 2.3 Linkar o Projeto

```bash
cd "c:\Users\hldes\Desktop\startflix pro"
supabase link --project-ref [SEU_PROJECT_ID]
```

> **Nota:** O PROJECT_ID pode ser encontrado na URL do seu projeto Supabase:
> `https://supabase.com/dashboard/project/[PROJECT_ID]`

#### 2.4 Deploy da Edge Function

```bash
supabase functions deploy renew-subscription
```

#### 2.5 Configurar Variáveis de Ambiente (Opcional)

Se você quiser ter mais controle sobre as credenciais do painel, pode configurar como secrets:

```bash
supabase secrets set PANEL_LOGIN=Lucas24H1
supabase secrets set PANEL_PASSWORD=01Deus02
```

E então atualizar a Edge Function para usar:
```typescript
const PANEL_LOGIN = Deno.env.get('PANEL_LOGIN') || 'Lucas24H1'
const PANEL_PASSWORD = Deno.env.get('PANEL_PASSWORD') || '01Deus02'
```

## 📱 Como Usar no App

### Para o Administrador:

1. **Abra o app e faça login como admin**

2. **Vá para o Painel Administrativo**

3. **Edite um cliente:**
   - Clique no botão de editar (ícone de lápis)

4. **Configure o Link do Painel Externo:**
   - Role até a seção "Renovação Automática"
   - No campo "Link do Painel Externo", cole a URL do cliente
   - Exemplo: `https://cms.startpainel.cc/clients/2528627`

5. **Renovar Assinatura:**
   - Após salvar o link, aparecerá um botão verde de renovação (🔄)
   - Clique no botão para renovar instantaneamente
   - O sistema irá:
     - Fazer login automático no painel externo
     - Acessar a página do cliente
     - Clicar no botão "Extender"
     - Atualizar a data de vencimento no banco (+ 30 dias)

6. **Salvar Alterações:**
   - Clique em "Salvar Alterações" para manter o link configurado

## 🔄 Renovação Automática Agendada (Futuro)

Para implementar renovação automática agendada (por exemplo, 3 dias antes do vencimento):

### Opção 1: Cron Job do Supabase (Recomendado)

1. Crie uma Edge Function adicional chamada `scheduled-renewals`:

```typescript
// supabase/functions/scheduled-renewals/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  const supabase = createClient(supabaseUrl, supabaseKey)

  // Buscar clientes que vencem em 3 dias
  const threeDaysFromNow = new Date()
  threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3)

  const { data: clients } = await supabase
    .from('profiles')
    .select('*')
    .not('external_panel_url', 'is', null)
    .lte('expiration_date', threeDaysFromNow.toISOString())
    .eq('is_active', true)

  // Renovar cada cliente
  for (const client of clients || []) {
    try {
      await fetch(`${supabaseUrl}/functions/v1/renew-subscription`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${supabaseKey}`,
        },
        body: JSON.stringify({
          userId: client.id,
          externalPanelUrl: client.external_panel_url,
        }),
      })
    } catch (error) {
      console.error(`Failed to renew client ${client.id}:`, error)
    }
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

2. Configure um Cron Job no Supabase:
   - Acesse: Platform > Edge Functions > Cron Jobs
   - Adicione: `0 0 * * *` (executa diariamente à meia-noite)
   - Função: `scheduled-renewals`

### Opção 2: Trigger do Supabase

Crie um trigger que executa quando a data de vencimento está próxima.

## 🛠️ Troubleshooting

### Erro: "Edge Function not found"
- Certifique-se de ter feito o deploy: `supabase functions deploy renew-subscription`
- Verifique se está logado: `supabase login`

### Erro: "Could not find extend button"
- O site pode ter mudado a estrutura
- Acesse manualmente o link e inspecione o botão
- Atualize os seletores na Edge Function

### Erro: "Authentication failed"
- Verifique se as credenciais estão corretas
- O site pode ter implementado Captcha

## 📊 Estrutura do Banco de Dados

```sql
-- Campo adicionado à tabela profiles
profiles {
  ...
  external_panel_url TEXT -- URL do cliente no painel externo
}
```

## 🔐 Segurança

- ✅ As credenciais do painel são armazenadas na Edge Function (servidor)
- ✅ Apenas administradores podem renovar assinaturas
- ✅ Logs completos de todas as operações
- ✅ CORS configurado para permitir apenas domínios autorizados

## 📝 Logs e Monitoramento

Para ver os logs da Edge Function:

```bash
supabase functions logs renew-subscription
```

Ou acesse o dashboard do Supabase:
Platform > Edge Functions > renew-subscription > Logs

## 🎯 Próximos Passos

1. ✅ Configurar o banco de dados
2. ✅ Fazer deploy da Edge Function
3. ✅ Testar com um cliente
4. ⏳ Configurar renovação automática agendada
5. ⏳ Adicionar notificações de sucesso/falha

## 📞 Suporte

Em caso de problemas:
1. Verifique os logs da Edge Function
2. Teste manualmente no navegador
3. Verifique se o site externo não mudou a estrutura
