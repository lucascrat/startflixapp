import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://apistartflixpainel.appbr.pro'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc4OTQ1MDQ4LCJleHAiOjIwOTQzMDUwNDh9.MP2-5TXurfkLspwA_3vft9g6nIY8sUHOBaqxPfkaKBg'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    db: {
        schema: 'startflix'
    }
})
