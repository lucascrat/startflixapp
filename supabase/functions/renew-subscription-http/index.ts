// Supabase Edge Function - Renovação Automática (Versão HTTP)
// Esta versão usa requisições HTTP diretas ao invés de browser automation

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { userId, externalPanelUrl } = await req.json()

        if (!userId || !externalPanelUrl) {
            return new Response(
                JSON.stringify({ error: 'Missing userId or externalPanelUrl' }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
        }

        // Credenciais do painel
        const PANEL_LOGIN = 'Lucas24H1'
        const PANEL_PASSWORD = '01Deus02'
        const PANEL_BASE_URL = 'https://cms.startpainel.cc'

        console.log(`📝 Renovando assinatura para user: ${userId}`)
        console.log(`🔗 URL: ${externalPanelUrl}`)

        // ====================================
        // MÉTODO 1: Tentar via API (se disponível)
        // ====================================

        // Extrair o client ID da URL
        const clientIdMatch = externalPanelUrl.match(/clients\/(\d+)/)
        const clientId = clientIdMatch ? clientIdMatch[1] : null

        if (!clientId) {
            throw new Error('URL inválida. Não foi possível extrair o ID do cliente.')
        }

        // Tentar fazer login e obter cookie de sessão
        console.log('🔐 Fazendo login...')
        const loginResponse = await fetch(`${PANEL_BASE_URL}/api/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: PANEL_LOGIN,
                password: PANEL_PASSWORD,
            }),
        })

        if (!loginResponse.ok) {
            throw new Error(`Login falhou: ${loginResponse.status}`)
        }

        // Extrair cookie de sessão
        const cookies = loginResponse.headers.get('set-cookie') || ''
        console.log('✅ Login bem-sucedido')

        // Tentar chamar a API de extensão
        console.log(`🔄 Tentando renovar via API...`)
        const extendResponse = await fetch(`${PANEL_BASE_URL}/api/clients/${clientId}/extend`, {
            method: 'POST',
            headers: {
                'Cookie': cookies,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                days: 30,  // Ajuste conforme necessário
            }),
        })

        let renewalSuccess = false
        if (extendResponse.ok) {
            renewalSuccess = true
            console.log('✅ Renovação via API bem-sucedida')
        } else {
            console.log(`⚠️ API não disponível ou falhou: ${extendResponse.status}`)
            // Fallback: Indicar que precisa ser feito manualmente
            console.log('ℹ️ Será necessário renovação manual')
        }

        // ====================================
        // Atualizar data de vencimento no banco
        // ====================================
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!
        const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
        const supabase = createClient(supabaseUrl, supabaseKey)

        // Calcular nova data (30 dias a partir de hoje)
        const newExpirationDate = new Date()
        newExpirationDate.setDate(newExpirationDate.getDate() + 30)

        await supabase
            .from('profiles')
            .update({
                expiration_date: newExpirationDate.toISOString(),
                updated_at: new Date().toISOString(),
            })
            .eq('id', userId)

        console.log('✅ Data de vencimento atualizada no banco')

        return new Response(
            JSON.stringify({
                success: true,
                message: renewalSuccess
                    ? 'Assinatura renovada com sucesso via API!'
                    : 'Data de vencimento atualizada. Renovação manual necessária no painel externo.',
                newExpirationDate: newExpirationDate.toISOString(),
                manualRenewalNeeded: !renewalSuccess,
                externalPanelUrl: `${externalPanelUrl}/extend`,
            }),
            {
                status: 200,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
        )

    } catch (error) {
        console.error('❌ Erro durante renovação:', error)

        return new Response(
            JSON.stringify({
                success: false,
                error: error.message,
                hint: 'Verifique se a URL do painel está correta e se as credenciais estão válidas.',
            }),
            {
                status: 500,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
        )
    }
})

/* 
NOTAS DE IMPLEMENTAÇÃO:

1. Esta versão tenta usar a API do painel diretamente (se disponível)
2. Se a API não funcionar, atualiza apenas a data no banco
3. Para automação completa, você terá 3 opções:

   OPÇÃO A: Descobrir a API do painel
   - Use DevTools do navegador (F12)
   - Faça login manualmente e renove um cliente
   - Veja quais requisições HTTP são feitas
   - Copie os endpoints e headers

   OPÇÃO B: Browser Automation Externa
   - Use Puppeteer em um servidor próprio (VPS, Railway, Render)
   - Crie uma API simples que recebe o clientId
   - Faça a automação com Headless Chrome
   - Retorne o resultado

   OPÇÃO C: Integração Zapier/Make
   - Configure um webhook
   - Use eles para fazer a automação do navegador
   - Chame via HTTP desta Edge Function

4. Para descobrir a API do painel:
   a) Abra https://cms.startpainel.cc no Chrome
   b) Pressione F12 (DevTools)
   c) Vá para aba "Network"
   d) Faça login
   e) Renove um cliente
   f) Veja todas as requisições POST/PUT
   g) Copie os endpoints, headers e body
*/
