// Self-contained PostgREST client. Replaces @supabase/supabase-js.
// All calls go straight to our own PostgREST at apistartflixpainel.appbr.pro.
// No JWT auth, no realtime, no Supabase Auth — backed entirely by Postgres.

const API_URL = 'https://apistartflixpainel.appbr.pro';
const DEFAULT_SCHEMA = 'startflix';

function buildQs(params) {
  if (!params.length) return '';
  return '?' + params
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join('&');
}

function uuid() {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) return crypto.randomUUID();
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    const r = (Math.random() * 16) | 0;
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
  });
}

class QueryBuilder {
  constructor(table, schema) {
    this.table = table;
    this.schema = schema;
    this.method = 'GET';
    this.body = null;
    this.filters = [];
    this.selectStr = '*';
    this.orderStr = null;
    this.limitVal = null;
    this.rangeFrom = null;
    this.rangeTo = null;
    this.singleMode = null;
    this.countMode = null;
    this.headOnly = false;
    this.onConflict = null;
    this.returnPref = 'representation';
  }

  select(cols = '*', opts = {}) {
    this.selectStr = cols || '*';
    if (opts.count) this.countMode = opts.count;
    if (opts.head) {
      this.headOnly = true;
      this.method = 'HEAD';
    }
    return this;
  }

  insert(data) {
    this.method = 'POST';
    this.body = Array.isArray(data) ? data : [data];
    return this;
  }

  update(data) {
    this.method = 'PATCH';
    this.body = data;
    return this;
  }

  upsert(data, opts = {}) {
    this.method = 'POST';
    this.body = Array.isArray(data) ? data : [data];
    if (opts.onConflict) this.onConflict = opts.onConflict;
    this._upsert = true;
    return this;
  }

  delete() {
    this.method = 'DELETE';
    return this;
  }

  eq(c, v) { this.filters.push([c, `eq.${v}`]); return this; }
  neq(c, v) { this.filters.push([c, `neq.${v}`]); return this; }
  gt(c, v) { this.filters.push([c, `gt.${v}`]); return this; }
  lt(c, v) { this.filters.push([c, `lt.${v}`]); return this; }
  gte(c, v) { this.filters.push([c, `gte.${v}`]); return this; }
  lte(c, v) { this.filters.push([c, `lte.${v}`]); return this; }
  like(c, v) { this.filters.push([c, `like.${v}`]); return this; }
  ilike(c, v) { this.filters.push([c, `ilike.${v}`]); return this; }
  is(c, v) { this.filters.push([c, `is.${v}`]); return this; }
  in(c, vs) {
    const list = (vs || []).map(v => {
      if (v === null) return 'null';
      const s = String(v);
      return /[,"()\s]/.test(s) ? `"${s.replace(/"/g, '\\"')}"` : s;
    }).join(',');
    this.filters.push([c, `in.(${list})`]);
    return this;
  }
  filter(c, op, v) { this.filters.push([c, `${op}.${v}`]); return this; }
  match(obj) { Object.entries(obj).forEach(([k, v]) => this.eq(k, v)); return this; }

  order(col, opts = {}) {
    const dir = opts.ascending === false ? 'desc' : 'asc';
    const piece = `${col}.${dir}${opts.nullsFirst ? '.nullsfirst' : ''}`;
    this.orderStr = this.orderStr ? `${this.orderStr},${piece}` : piece;
    return this;
  }

  limit(n) { this.limitVal = n; return this; }
  range(from, to) { this.rangeFrom = from; this.rangeTo = to; return this; }
  single() { this.singleMode = 'strict'; return this; }
  maybeSingle() { this.singleMode = 'maybe'; return this; }

  async _execute() {
    const params = [];
    const wantsSelect =
      this.method === 'GET' ||
      this.method === 'HEAD' ||
      ((this.method === 'POST' || this.method === 'PATCH' || this.method === 'DELETE') &&
        this.selectStr && this.selectStr !== '*');
    if (wantsSelect) params.push(['select', this.selectStr]);
    if (this.orderStr) params.push(['order', this.orderStr]);
    if (this.limitVal != null) params.push(['limit', String(this.limitVal)]);
    if (this.onConflict) params.push(['on_conflict', this.onConflict]);
    this.filters.forEach(([k, v]) => params.push([k, v]));

    const url = `${API_URL}/${this.table}${buildQs(params)}`;

    const headers = {
      'Accept': 'application/json',
      'Accept-Profile': this.schema,
      'Content-Profile': this.schema,
    };

    if (this.body != null) headers['Content-Type'] = 'application/json';
    if (this.singleMode === 'strict') headers['Accept'] = 'application/vnd.pgrst.object+json';

    const prefer = [];
    if (this._upsert) prefer.push('resolution=merge-duplicates');
    if (this.method === 'POST' || this.method === 'PATCH') prefer.push(`return=${this.returnPref}`);
    if (this.countMode) prefer.push(`count=${this.countMode}`);
    if (prefer.length) headers['Prefer'] = prefer.join(',');

    if (this.rangeFrom != null) headers['Range'] = `${this.rangeFrom}-${this.rangeTo}`;

    let res;
    try {
      res = await fetch(url, {
        method: this.method,
        headers,
        body: this.body != null ? JSON.stringify(this.body) : undefined,
      });
    } catch (err) {
      return { data: null, error: { message: err.message || String(err), name: err.name }, count: null, status: 0 };
    }

    let count = null;
    const cr = res.headers.get('content-range');
    if (cr) {
      const m = cr.match(/\/(\d+|\*)$/);
      if (m && m[1] !== '*') count = parseInt(m[1], 10);
    }

    if (!res.ok) {
      let errBody;
      try { errBody = await res.json(); } catch { errBody = { message: `${res.status} ${res.statusText}` }; }
      if (!errBody.message) errBody.message = `${res.status} ${res.statusText}`;
      return { data: null, error: errBody, count, status: res.status };
    }

    if (this.headOnly || res.status === 204) {
      return { data: null, error: null, count, status: res.status };
    }

    const text = await res.text();
    let data = null;
    if (text) {
      try {
        data = JSON.parse(text);
        if (this.singleMode === 'maybe' && Array.isArray(data)) data = data.length ? data[0] : null;
      } catch {
        data = text;
      }
    } else if (this.singleMode === 'maybe') {
      data = null;
    }

    return { data, error: null, count, status: res.status };
  }

  then(resolve, reject) { return this._execute().then(resolve, reject); }
  catch(fn) { return this._execute().catch(fn); }
  finally(fn) { return this._execute().finally(fn); }
}

function stubChannel(name) {
  const ch = {
    topic: name,
    on() { return ch; },
    subscribe(cb) { if (typeof cb === 'function') try { cb('CLOSED'); } catch {} return ch; },
    unsubscribe() { return Promise.resolve('ok'); },
    send() { return Promise.resolve('ok'); },
  };
  return ch;
}

export const supabase = {
  supabaseUrl: API_URL,
  options: { db: { schema: DEFAULT_SCHEMA } },

  from(table) { return new QueryBuilder(table, DEFAULT_SCHEMA); },
  schema(name) { return { from: (t) => new QueryBuilder(t, name) }; },

  async rpc(fn, args = {}) {
    try {
      const res = await fetch(`${API_URL}/rpc/${fn}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Profile': DEFAULT_SCHEMA,
          'Content-Profile': DEFAULT_SCHEMA,
        },
        body: JSON.stringify(args || {}),
      });
      if (!res.ok) {
        let err;
        try { err = await res.json(); } catch { err = { message: `${res.status} ${res.statusText}` }; }
        return { data: null, error: err };
      }
      const text = await res.text();
      return { data: text ? JSON.parse(text) : null, error: null };
    } catch (e) {
      return { data: null, error: { message: e.message } };
    }
  },

  auth: {
    signOut: () => Promise.resolve({ error: null }),
    getSession: () => Promise.resolve({ data: { session: null }, error: null }),
    getUser: () => Promise.resolve({ data: { user: null }, error: null }),
    onAuthStateChange: () => ({ data: { subscription: { unsubscribe() {} } } }),
    // No Supabase Auth: we just allocate an id and let the caller fill in details.
    async signUp({ email, password }) {
      const id = uuid();
      const profileRow = { id, email, role: 'client', is_active: true };
      if (password) profileRow.password_hash = password;
      const r = await new QueryBuilder('profiles', DEFAULT_SCHEMA)
        .insert(profileRow)
        ._execute();
      if (r.error) {
        // Friendlier message for the most common failure
        if (r.error.code === '23505' || /duplicate key/i.test(r.error.message || '')) {
          return { data: null, error: { ...r.error, message: `Já existe um cliente com o email ${email}.` } };
        }
        return { data: null, error: r.error };
      }
      const row = Array.isArray(r.data) ? r.data[0] : r.data;
      return { data: { user: { id: (row && row.id) || id, email } }, error: null };
    },
  },

  channel(name) { return stubChannel(name); },
  removeChannel() { return Promise.resolve('ok'); },
  removeAllChannels() { return Promise.resolve('ok'); },
  getChannels() { return []; },
};

export default supabase;
