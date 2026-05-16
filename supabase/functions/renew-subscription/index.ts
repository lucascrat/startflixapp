// Supabase Edge Function - Renovação de Assinatura
// Versão compatível com Supabase Edge Runtime (sem browser automation)

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

    console.log(`Renovando assinatura para user: ${userId}`)
    console.log(`URL do painel: ${externalPanelUrl}`)

    // Inicializar Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Calcular nova data de vencimento (30 dias a partir de hoje)
    const newExpirationDate = new Date()
    newExpirationDate.setDate(newExpirationDate.getDate() + 30)

    // Atualizar data de vencimento no banco
    const { error: updateError } = await supabase
      .from('profiles')
      .update({
        expiration_date: newExpirationDate.toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId)

    if (updateError) {
      throw new Error(`Erro ao atualizar banco: ${updateError.message}`)
    }

    console.log('Data de vencimento atualizada com sucesso!')

    // Retornar sucesso com link para renovação manual
    return new Response(
      JSON.stringify({
        success: true,
        message: 'Data de vencimento atualizada! Clique no link para renovar no painel externo.',
        newExpirationDate: newExpirationDate.toISOString(),
        manualRenewalUrl: `${externalPanelUrl}/extend`,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )

  } catch (error) {
    console.error('Erro durante renovação:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
