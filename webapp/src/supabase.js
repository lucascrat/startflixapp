// Self-contained PostgREST client. See admin_web/src/supabase.js for full notes.
const API_URL = 'https://apistartflixpainel.appbr.pro';
const DEFAULT_SCHEMA = 'startflix';

function buildQs(params) {
  if (!params.length) return '';
  return '?' + params.map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`).join('&');
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
    this.singleMode = null;
  }
  select(c = '*') { this.selectStr = c || '*'; return this; }
  insert(d) { this.method = 'POST'; this.body = Array.isArray(d) ? d : [d]; return this; }
  update(d) { this.method = 'PATCH'; this.body = d; return this; }
  delete() { this.method = 'DELETE'; return this; }
  eq(c, v) { this.filters.push([c, `eq.${v}`]); return this; }
  neq(c, v) { this.filters.push([c, `neq.${v}`]); return this; }
  in(c, vs) { this.filters.push([c, `in.(${vs.join(',')})`]); return this; }
  order(c, o = {}) {
    const dir = o.ascending === false ? 'desc' : 'asc';
    this.orderStr = this.orderStr ? `${this.orderStr},${c}.${dir}` : `${c}.${dir}`;
    return this;
  }
  limit(n) { this.limitVal = n; return this; }
  single() { this.singleMode = 'strict'; return this; }
  maybeSingle() { this.singleMode = 'maybe'; return this; }

  async _execute() {
    const params = [['select', this.selectStr]];
    if (this.orderStr) params.push(['order', this.orderStr]);
    if (this.limitVal != null) params.push(['limit', String(this.limitVal)]);
    this.filters.forEach(([k, v]) => params.push([k, v]));
    const url = `${API_URL}/${this.table}${buildQs(params)}`;
    const headers = {
      'Accept': 'application/json',
      'Accept-Profile': this.schema,
      'Content-Profile': this.schema,
    };
    if (this.body != null) headers['Content-Type'] = 'application/json';
    if (this.singleMode === 'strict') headers['Accept'] = 'application/vnd.pgrst.object+json';
    if (this.method === 'POST' || this.method === 'PATCH') headers['Prefer'] = 'return=representation';
    try {
      const res = await fetch(url, {
        method: this.method,
        headers,
        body: this.body != null ? JSON.stringify(this.body) : undefined,
      });
      if (!res.ok) {
        let err;
        try { err = await res.json(); } catch { err = { message: `${res.status} ${res.statusText}` }; }
        return { data: null, error: err };
      }
      if (res.status === 204) return { data: null, error: null };
      const text = await res.text();
      let data = text ? JSON.parse(text) : null;
      if (this.singleMode === 'maybe' && Array.isArray(data)) data = data.length ? data[0] : null;
      return { data, error: null };
    } catch (err) {
      return { data: null, error: { message: err.message || String(err) } };
    }
  }
  then(r, j) { return this._execute().then(r, j); }
  catch(j) { return this._execute().catch(j); }
}

export const supabase = {
  supabaseUrl: API_URL,
  from(table) { return new QueryBuilder(table, DEFAULT_SCHEMA); },
  schema(name) { return { from: (t) => new QueryBuilder(t, name) }; },
};

export default supabase;
