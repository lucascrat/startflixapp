import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'http://g118gaedeyy792j9l0t7hbzc.84.247.138.242.sslip.io'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc4OTQ1MDQ4LCJleHAiOjIwOTQzMDUwNDh9.MP2-5TXurfkLspwA_3vft9g6nIY8sUHOBaqxPfkaKBg'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    db: {
        schema: 'startflix'
    }
})
