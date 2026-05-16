// startflix-m3u: tiny HTTP service that replaces the old Supabase Edge Function `get-m3u`.
//
// Behaviour:
//   GET /<id>.m3u            -> per-user link, calls acquire_m3u_signal(p_user_id, true)
//   GET /master.m3u          -> master pool, calls acquire_global_signal()
//   GET /?uid=<id>           -> same as /<id>.m3u
//   GET /functions/v1/get-m3u/<id>.m3u  -> legacy path kept for clients still on the old URL
//
// After picking the signal (rotation logic lives in the DB RPC), the service
// 302-redirects to the upstream IPTV URL. The Android client app follows the
// redirect from its residential IP so the IPTV provider's datacenter-IP block
// (Contabo, etc.) doesn't matter — the actual playlist fetch never originates
// from our server.

import http from 'node:http';
import { URL } from 'node:url';

const POSTGREST_URL = process.env.POSTGREST_URL || 'https://apistartflixpainel.appbr.pro';
const POSTGREST_SCHEMA = process.env.POSTGREST_SCHEMA || 'startflix';
const PORT = parseInt(process.env.PORT || '3000', 10);

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, OPTIONS',
};

const TV_USER_AGENT =
  'Mozilla/5.0 (SmartTV; identifier) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

function errorM3U(message) {
  return `#EXTM3U\n#EXTINF:-1, ${message}\nhttp://error.com\n`;
}

function extractUserId(pathname, search) {
  const qs = new URLSearchParams(search);
  const fromQuery = qs.get('uid');
  if (fromQuery) return fromQuery;

  const parts = pathname.split('/').filter(Boolean);
  for (let i = parts.length - 1; i >= 0; i--) {
    const p = parts[i];
    if (p === 'get-m3u' || p === 'functions' || p === 'v1') continue;
    return p.split('.')[0];
  }
  return null;
}

async function callRpc(fn, args) {
  const res = await fetch(`${POSTGREST_URL}/rpc/${fn}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Profile': POSTGREST_SCHEMA,
      'Content-Profile': POSTGREST_SCHEMA,
    },
    body: JSON.stringify(args || {}),
  });
  if (!res.ok) {
    let body;
    try { body = await res.json(); } catch { body = { message: `${res.status} ${res.statusText}` }; }
    throw new Error(`RPC ${fn} failed: ${body.message || res.status}`);
  }
  return await res.json();
}

function buildUpstreamUrl({ dns, username, password }) {
  let target = (dns || '').trim();
  if (target.includes('get.php')) {
    target = target.replace('output=ts', 'output=m3u8').replace('output=mpegts', 'output=m3u8');
    if (!target.includes('output=')) {
      target += (target.includes('?') ? '&' : '?') + 'output=m3u8';
    }
    return target;
  }
  if (!/^https?:\/\//i.test(target)) target = `http://${target}`;
  if (target.endsWith('/')) target = target.slice(0, -1);
  return `${target}/get.php?username=${encodeURIComponent(username || '')}&password=${encodeURIComponent(password || '')}&type=m3u_plus&output=m3u8`;
}

async function handleM3U(req, res, pathname) {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const userId = extractUserId(pathname, url.search);
  const isMaster = !userId || userId === 'master' || userId === 'global';

  let signal;
  try {
    signal = isMaster
      ? await callRpc('acquire_global_signal', {})
      : await callRpc('acquire_m3u_signal', { p_user_id: userId, p_is_external: true });
  } catch (err) {
    console.error('[acquire]', err.message);
    res.writeHead(200, { ...CORS, 'Content-Type': 'text/plain' });
    res.end(errorM3U('ESTOQUE INDISPONIVEL'));
    return;
  }

  if (!signal || !signal.success) {
    res.writeHead(200, { ...CORS, 'Content-Type': 'text/plain' });
    res.end(errorM3U(signal?.message || 'ESTOQUE INDISPONIVEL'));
    return;
  }

  const upstream = buildUpstreamUrl(signal);
  console.log(`[redirect] ${isMaster ? 'master' : userId} -> ${upstream}`);

  // The IPTV provider blocks all datacenter IPs (Contabo, etc.) and would
  // 404 us if we tried to proxy the playlist server-side. The consumers
  // (Android app, IPTV players on residential networks) follow redirects
  // fine, so just hand them the upstream URL and let them fetch directly
  // from their own residential IP.
  res.writeHead(302, {
    ...CORS,
    'Location': upstream,
    'Cache-Control': 'no-cache, no-store, must-revalidate',
  });
  res.end();
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, CORS);
    return res.end();
  }

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = url.pathname;

  if (pathname === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ ok: true, service: 'startflix-m3u' }));
  }

  if (pathname === '/' && !url.searchParams.get('uid')) {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    return res.end('startflix-m3u: use /<user_id>.m3u or /master.m3u');
  }

  if (req.method !== 'GET') {
    res.writeHead(405, CORS);
    return res.end();
  }

  try {
    await handleM3U(req, res, pathname);
  } catch (err) {
    console.error('[handler]', err);
    if (!res.headersSent) {
      res.writeHead(200, { ...CORS, 'Content-Type': 'text/plain' });
    }
    res.end(errorM3U('ERRO INTERNO'));
  }
});

server.listen(PORT, () => {
  console.log(`startflix-m3u listening on :${PORT}`);
  console.log(`  POSTGREST_URL=${POSTGREST_URL}`);
  console.log(`  POSTGREST_SCHEMA=${POSTGREST_SCHEMA}`);
});
