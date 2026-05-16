import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://supabase.hldesenvolvedor.site'
const supabaseAnonKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2NzE3ODY4MCwiZXhwIjo0OTIyODUyMjgwLCJyb2xlIjoiYW5vbiJ9.zdnftYkdG39mSSN_aODnw5V6ejfQyZachE_n5iyVDcI'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
