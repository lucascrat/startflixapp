const fetch = require('node-fetch');

async function test() {
    const url = 'https://qyagfghcnzenvbhbtsvd.supabase.co/rest/v1/profiles?select=*';
    const apikey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5YWdmZ2hjbnplbnZiaGJ0c3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3NDU2NjksImV4cCI6MjA4MzMyMTY2OX0.k_cVE7tLn23NIuuMJlCdWw97F_ZkPpz7SS7d-MleJVc';

    try {
        const res = await fetch(url, {
            headers: {
                'apikey': apikey,
                'Authorization': `Bearer ${apikey}`,
                'Accept-Profile': 'startflix'
            }
        });
        const text = await res.text();
        console.log('Status:', res.status);
        console.log('Body:', text);
    } catch (e) {
        console.error(e);
    }
}
test();
