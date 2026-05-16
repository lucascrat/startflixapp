const https = require('https');

const projectRef = process.env.SUPABASE_PROJECT_REF;
const token = process.env.SUPABASE_TOKEN;

const data = JSON.stringify({
    query: "UPDATE startflix.profiles SET has_signal = true, is_active = true WHERE id != '00000000-0000-0000-0000-000000000000';"
});

const options = {
    hostname: 'api.supabase.com',
    port: 443,
    path: `/v1/projects/${projectRef}/database/query`,
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

const req = https.request(options, res => {
    let body = '';
    res.on('data', d => body += d);
    res.on('end', () => {
        console.log("SQL Update result:", body);
    });
});

req.on('error', error => {
    console.error(error);
});

req.write(data);
req.end();
