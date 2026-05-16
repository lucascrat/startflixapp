import { createClient } from '@supabase/supabase-js'

// Usando exatamente as mesmas chaves que o App Flutter usa
const supabaseUrl = 'https://qyagfghcnzenvbhbtsvd.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5YWdmZ2hjbnplbnZiaGJ0c3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3NDU2NjksImV4cCI6MjA4MzMyMTY2OX0.k_cVE7tLn23NIuuMJlCdWw97F_ZkPpz7SS7d-MleJVc'

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    db: {
        schema: 'startflix'
    }
})
