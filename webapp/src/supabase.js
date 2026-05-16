import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'http://g118gaedeyy792j9l0t7hbzc.84.247.138.242.sslip.io'
const supabaseAnonKey = 'empty' 

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
