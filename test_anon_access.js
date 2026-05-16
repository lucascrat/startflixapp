const https = require('https');

const supabaseUrl = 'https://qyagfghcnzenvbhbtsvd.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5YWdmZ2hjbnplbnZiaGJ0c3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3NDU2NjksImV4cCI6MjA4MzMyMTY2OX0.k_cVE7tLn23NIuuMJlCdWw97F_ZkPpz7SS7d-MleJVc';

const options = {
    hostname: 'qyagfghcnzenvbhbtsvd.supabase.co',
    port: 443,
    path: '/rest/v1/profiles?select=count',
    method: 'GET',
    headers: {
        'apikey': supabaseAnonKey,
        'Authorization': `Bearer ${supabaseAnonKey}`,
        'Accept-Profile': 'startflix'
    }
};

const req = https.request(options, res => {
    let body = '';
    res.on('data', d => body += d);
    res.on('end', () => {
        console.log("Anon key query result:", body);
    });
});

req.on('error', error => {
    console.error(error);
});

req.end();
