import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://apistartflixpainel.appbr.pro'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc4OTQ1MDQ4LCJleHAiOjIwOTQzMDUwNDh9.MP2-5TXurfkLspwA_3vft9g6nIY8sUHOBaqxPfkaKBg'

const customFetch = (url, options) => {
  let finalUrl = url;
  let finalOptions = options;
  
  if (typeof url === 'string') {
    finalUrl = url.replace('/rest/v1/', '/').replace('/rest/v1', '');
    finalUrl = finalUrl.replace('/auth/v1/', '/').replace('/auth/v1', '');
  } else if (url && url.url) {
    // Handle Request object
    finalUrl = url.url.replace('/rest/v1/', '/').replace('/rest/v1', '');
    finalUrl = finalUrl.replace('/auth/v1/', '/').replace('/auth/v1', '');
    finalOptions = { ...options, ...url };
  }
  return fetch(finalUrl, finalOptions);
};

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
    detectSessionInUrl: false
  },
  global: {
    fetch: customFetch
  },
  db: {
    schema: 'startflix'
  }
})
