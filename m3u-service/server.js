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

// ---------------------------------------------------------------
// Stream tracking endpoints
//
// The /<user>.m3u redirect is a "passive" playlist fetch — just navigation,
// doesn't count as watching. The Android player calls these three endpoints
// to mark when it's actually playing so the admin sees real usage and the
// signal rotator only steals from users who are not currently watching.
//
//   POST /stream/start       { user_id, channel_id?, channel_name?, client_info? }
//     -> 200 { session_id, dns, username, password, account_id }
//        Begin (or refresh) the user's active session. Pass the session_id
//        to subsequent heartbeats/stops. Closes any prior open session for
//        the user automatically.
//
//   POST /stream/heartbeat   { session_id, channel_id?, channel_name? }
//     -> 200 { ok: true }
//        Call every ~30s while playing. Updates the heartbeat timestamp
//        and the (optional) current channel.
//
//   POST /stream/stop        { session_id }
//     -> 200 { ok: true, closed: <0|1> }
//        Mark the session ended (player closed, app backgrounded too long,
//        user logged out, etc).
//
// All three accept GET too with the same params as query string — convenient
// for quick testing from a browser.
// ---------------------------------------------------------------

async function readJsonBody(req) {
  return new Promise((resolve) => {
    let buf = '';
    req.on('data', c => { buf += c; if (buf.length > 1e6) req.destroy(); });
    req.on('end', () => {
      if (!buf) return resolve({});
      try { resolve(JSON.parse(buf)); } catch { resolve({}); }
    });
    req.on('error', () => resolve({}));
  });
}

async function getStreamArgs(req, url) {
  const body = req.method === 'POST' ? await readJsonBody(req) : {};
  const qs = Object.fromEntries(url.searchParams.entries());
  return { ...qs, ...body };
}

function sendJson(res, status, payload) {
  res.writeHead(status, { ...CORS, 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
}

async function handleStreamStart(req, res, url) {
  const args = await getStreamArgs(req, url);
  if (!args.user_id) return sendJson(res, 400, { success: false, error: 'user_id required' });
  try {
    const r = await callRpc('stream_start', {
      p_user_id: args.user_id,
      p_channel_id: args.channel_id || null,
      p_channel_name: args.channel_name || null,
      p_client_info: args.client_info || null,
    });
    return sendJson(res, 200, r);
  } catch (err) {
    console.error('[stream_start]', err.message);
    return sendJson(res, 500, { success: false, error: err.message });
  }
}

async function handleStreamHeartbeat(req, res, url) {
  const args = await getStreamArgs(req, url);
  if (!args.session_id) return sendJson(res, 400, { success: false, error: 'session_id required' });
  try {
    const r = await callRpc('stream_heartbeat', {
      p_session_id: args.session_id,
      p_channel_id: args.channel_id || null,
      p_channel_name: args.channel_name || null,
    });
    return sendJson(res, 200, r);
  } catch (err) {
    console.error('[stream_heartbeat]', err.message);
    return sendJson(res, 500, { success: false, error: err.message });
  }
}

async function handleStreamStop(req, res, url) {
  const args = await getStreamArgs(req, url);
  if (!args.session_id) return sendJson(res, 400, { success: false, error: 'session_id required' });
  try {
    const r = await callRpc('stream_stop', { p_session_id: args.session_id });
    return sendJson(res, 200, r);
  } catch (err) {
    console.error('[stream_stop]', err.message);
    return sendJson(res, 500, { success: false, error: err.message });
  }
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

  if (pathname === '/stream/start')     return handleStreamStart(req, res, url);
  if (pathname === '/stream/heartbeat') return handleStreamHeartbeat(req, res, url);
  if (pathname === '/stream/stop')      return handleStreamStop(req, res, url);

  if (pathname === '/' && !url.searchParams.get('uid')) {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    return res.end(
      'startflix-m3u\n' +
      '  GET  /<user_id>.m3u   -> 302 to per-user playlist (passive)\n' +
      '  GET  /master.m3u      -> 302 to master playlist (passive)\n' +
      '  POST /stream/start    { user_id, channel_id?, channel_name?, client_info? }\n' +
      '  POST /stream/heartbeat { session_id, channel_id?, channel_name? }\n' +
      '  POST /stream/stop     { session_id }\n'
    );
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
