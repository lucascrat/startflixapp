# Guia Técnico: Integração Supabase e Pagamentos (Efí/Pix)

Este documento detalha a arquitetura e os passos necessários para replicar a integração do Supabase e do sistema de pagamentos Pix em novos projetos.

---

## 1. Integração Supabase

O Supabase é utilizado como Backend-as-a-Service (BaaS), fornecendo Banco de Dados (PostgreSQL), Autenticação, Realtime e Edge Functions.

### 1.1. Configuração do Cliente (Frontend)
Para conectar seu app ao Supabase, utilize o pacote `@supabase/supabase-js`.

**Arquivo de Referência:** `services/supabaseClient.ts`
```typescript
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'SUA_URL_AQUI';
const SUPABASE_ANON_KEY = 'SUA_ANON_KEY_AQUI';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

### 1.2. Banco de Dados e Realtime
- **Tabelas:** Organize seus dados em schemas (ex: `public`).
- **Realtime:** Ative o Realtime nas tabelas que precisam de atualização instantânea (ex: `rides`, `messages`).
- **RLS (Row Level Security):** Sempre ative políticas de segurança para garantir que usuários acessem apenas seus próprios dados.

### 1.3. Edge Functions (Lógica Serverless)
Use Edge Functions para tarefas que exigem chaves secretas ou lógica pesada.
- **Notificações Push (FCM):** Centralize o envio via Edge Function para ocultar as chaves do Firebase.
- **Deploy:** `supabase functions deploy nome-da-funcao`

---

## 2. Integração de Pagamentos (Pix via Efí/VPS)

Devido a restrições de segurança e certificados (MTLS) exigidos pelo Banco Central para o Pix, utilizamos uma **VPS (Hostinger)** como intermediária.

### 2.1. Arquitetura do Pagamento
1. **Frontend:** Solicita a criação de um pagamento.
2. **Ponte (Edge Function):** Recebe a requisição do app e a encaminha para a VPS.
3. **VPS (Backend Node.js):**
   - Autentica com a API da Efí usando certificados `.p12`.
   - Gera o QR Code Pix e a chave "Copia e Cola".
4. **Retorno:** O QR Code volta para o App.

### 2.2. Por que usar uma VPS?
As Edge Functions (Deno) possuem limitações para carregar certificados binários complexos e bibliotecas específicas de bancos brasileiros. A VPS Node.js oferece controle total sobre o ambiente.

### 2.3. Código do Serviço (Frontend)
**Arquivo de Referência:** `services/paymentService.ts`
```typescript
const VPS_URL = 'http://SEU_IP_VPS:3000/payment-manager';

export const createPixPayment = async (planId, user, payerData) => {
    // Para Android Nativo, use CapacitorHttp para evitar problemas de CORS
    const response = await CapacitorHttp.post({
        url: VPS_URL,
        data: { action: 'create', planId, user, payerData }
    });
    return response.data;
};
```

---

## 3. Notificações Push (FCM V1)

Para notificações funcionarem em 2024/2025, deve-se usar a **API FCM V1** (baseada em HTTP v1 e JWT).

### 3.1. Configuração
1. Gere um arquivo JSON de Chave de Serviço no Console do Firebase.
2. Armazene as informações desse JSON no banco de dados Supabase (tabela `admin_settings`).
3. A Edge Function lê essas chaves, gera um token JWT e envia para o Google.

---

## 4. Checklist para Novo App

- [ ] **Supabase:** Criar projeto, configurar tabelas e políticas RLS.
- [ ] **Firebase:** Criar projeto, baixar `google-services.json` e gerar chave de serviço.
- [ ] **Efí Bank:** Obter ClientID, ClientSecret e Certificado `.p12`.
- [ ] **VPS:** Instalar Node.js, configurar o servidor de pagamento e abrir a porta 3000.
- [ ] **Configurações:** Atualizar URLs e Keys no arquivo `constants.ts` do novo projeto.

---
*Guia gerado em 31/12/2025 para suporte a novos desenvolvimentos.*
