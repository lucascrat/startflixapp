const https = require('https');

const projectRef = process.env.SUPABASE_PROJECT_REF;
const token = process.env.SUPABASE_TOKEN;

const data = JSON.stringify({
    query: "SELECT tablename, policyname, permissive, roles, cmd, qual, with_check FROM pg_policies WHERE schemaname = 'startflix';"
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
        try {
            console.log(JSON.stringify(JSON.parse(body), null, 2));
        } catch(e) {
            console.log(body);
        }
    });
});

req.on('error', error => {
    console.error(error);
});

req.write(data);
req.end();
