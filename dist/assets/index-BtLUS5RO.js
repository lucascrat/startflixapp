var _a;
(function() {
  const e = document.createElement("link").relList;
  if (e && e.supports && e.supports("modulepreload")) return;
  for (const n of document.querySelectorAll('link[rel="modulepreload"]')) s(n);
  new MutationObserver((n) => {
    for (const i of n) if (i.type === "childList") for (const a of i.addedNodes) a.tagName === "LINK" && a.rel === "modulepreload" && s(a);
  }).observe(document, { childList: true, subtree: true });
  function t(n) {
    const i = {};
    return n.integrity && (i.integrity = n.integrity), n.referrerPolicy && (i.referrerPolicy = n.referrerPolicy), n.crossOrigin === "use-credentials" ? i.credentials = "include" : n.crossOrigin === "anonymous" ? i.credentials = "omit" : i.credentials = "same-origin", i;
  }
  function s(n) {
    if (n.ep) return;
    n.ep = true;
    const i = t(n);
    fetch(n.href, i);
  }
})();
const Bt = { xmlns: "http://www.w3.org/2000/svg", width: 24, height: 24, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round" };
const Nt = ([r, e, t]) => {
  const s = document.createElementNS("http://www.w3.org/2000/svg", r);
  return Object.keys(e).forEach((n) => {
    s.setAttribute(n, String(e[n]));
  }), (t == null ? void 0 : t.length) && t.forEach((n) => {
    const i = Nt(n);
    s.appendChild(i);
  }), s;
}, ir = (r, e = {}) => {
  const s = { ...Bt, ...e };
  return Nt(["svg", s, r]);
};
const ar = (r) => Array.from(r.attributes).reduce((e, t) => (e[t.name] = t.value, e), {}), or = (r) => typeof r == "string" ? r : !r || !r.class ? "" : r.class && typeof r.class == "string" ? r.class.split(" ") : r.class && Array.isArray(r.class) ? r.class : "", lr = (r) => r.flatMap(or).map((t) => t.trim()).filter(Boolean).filter((t, s, n) => n.indexOf(t) === s).join(" "), cr = (r) => r.replace(/(\w)(\w*)(_|-|\s*)/g, (e, t, s) => t.toUpperCase() + s.toLowerCase()), ut = (r, { nameAttr: e, icons: t, attrs: s }) => {
  var _a2;
  const n = r.getAttribute(e);
  if (n == null) return;
  const i = cr(n), a = t[i];
  if (!a) return console.warn(`${r.outerHTML} icon name was not found in the provided icons object.`);
  const o = ar(r), l = { ...Bt, "data-lucide": n, ...s, ...o }, c = lr(["lucide", `lucide-${n}`, o, s]);
  c && Object.assign(l, { class: c });
  const u = ir(a, l);
  return (_a2 = r.parentNode) == null ? void 0 : _a2.replaceChild(u, r);
};
const ur = [["path", { d: "M8 2v4" }], ["path", { d: "M16 2v4" }], ["rect", { width: "18", height: "18", x: "3", y: "4", rx: "2" }], ["path", { d: "M3 10h18" }]];
const dr = [["circle", { cx: "12", cy: "12", r: "10" }], ["line", { x1: "12", x2: "12", y1: "8", y2: "12" }], ["line", { x1: "12", x2: "12.01", y1: "16", y2: "16" }]];
const hr = [["path", { d: "M21.801 10A10 10 0 1 1 17 3.335" }], ["path", { d: "m9 11 3 3L22 4" }]];
const fr = [["circle", { cx: "12", cy: "12", r: "10" }], ["path", { d: "m15 9-6 6" }], ["path", { d: "m9 9 6 6" }]];
const pr = [["rect", { width: "14", height: "14", x: "8", y: "8", rx: "2", ry: "2" }], ["path", { d: "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2" }]];
const gr = [["rect", { width: "20", height: "14", x: "2", y: "5", rx: "2" }], ["line", { x1: "2", x2: "22", y1: "10", y2: "10" }]];
const mr = [["line", { x1: "12", x2: "12", y1: "2", y2: "22" }], ["path", { d: "M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" }]];
const yr = [["rect", { width: "7", height: "9", x: "3", y: "3", rx: "1" }], ["rect", { width: "7", height: "5", x: "14", y: "3", rx: "1" }], ["rect", { width: "7", height: "9", x: "14", y: "12", rx: "1" }], ["rect", { width: "7", height: "5", x: "3", y: "16", rx: "1" }]];
const vr = [["path", { d: "m16 17 5-5-5-5" }], ["path", { d: "M21 12H9" }], ["path", { d: "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" }]];
const wr = [["path", { d: "M2.992 16.342a2 2 0 0 1 .094 1.167l-1.065 3.29a1 1 0 0 0 1.236 1.168l3.413-.998a2 2 0 0 1 1.099.092 10 10 0 1 0-4.777-4.719" }]];
const br = [["rect", { width: "20", height: "14", x: "2", y: "3", rx: "2" }], ["line", { x1: "8", x2: "16", y1: "21", y2: "21" }], ["line", { x1: "12", x2: "12", y1: "17", y2: "21" }]];
const _r = [["path", { d: "M11 21.73a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73z" }], ["path", { d: "M12 22V12" }], ["polyline", { points: "3.29 7 12 12 20.71 7" }], ["path", { d: "m7.5 4.27 9 5.15" }]];
const Er = [["path", { d: "M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z" }]];
const Sr = [["path", { d: "M5 12h14" }], ["path", { d: "M12 5v14" }]];
const kr = [["path", { d: "M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" }], ["path", { d: "M21 3v5h-5" }], ["path", { d: "M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" }], ["path", { d: "M8 16H3v5" }]];
const Tr = [["path", { d: "M9.671 4.136a2.34 2.34 0 0 1 4.659 0 2.34 2.34 0 0 0 3.319 1.915 2.34 2.34 0 0 1 2.33 4.033 2.34 2.34 0 0 0 0 3.831 2.34 2.34 0 0 1-2.33 4.033 2.34 2.34 0 0 0-3.319 1.915 2.34 2.34 0 0 1-4.659 0 2.34 2.34 0 0 0-3.32-1.915 2.34 2.34 0 0 1-2.33-4.033 2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915" }], ["circle", { cx: "12", cy: "12", r: "3" }]];
const Ir = [["path", { d: "M2 20h.01" }], ["path", { d: "M7 20v-4" }]];
const xr = [["path", { d: "M2 20h.01" }], ["path", { d: "M7 20v-4" }], ["path", { d: "M12 20v-8" }], ["path", { d: "M17 20V8" }], ["path", { d: "M22 4v16" }]];
const Or = [["path", { d: "M12 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" }], ["path", { d: "M18.375 2.625a1 1 0 0 1 3 3l-9.013 9.014a2 2 0 0 1-.853.505l-2.873.84a.5.5 0 0 1-.62-.62l.84-2.873a2 2 0 0 1 .506-.852z" }]];
const Ar = [["path", { d: "M10 11v6" }], ["path", { d: "M14 11v6" }], ["path", { d: "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6" }], ["path", { d: "M3 6h18" }], ["path", { d: "M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" }]];
const Rr = [["path", { d: "M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6" }], ["path", { d: "M3 6h18" }], ["path", { d: "M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" }]];
const Cr = [["path", { d: "m18.84 12.25 1.72-1.71h-.02a5.004 5.004 0 0 0-.12-7.07 5.006 5.006 0 0 0-6.95 0l-1.72 1.71" }], ["path", { d: "m5.17 11.75-1.71 1.71a5.004 5.004 0 0 0 .12 7.07 5.006 5.006 0 0 0 6.95 0l1.71-1.71" }], ["line", { x1: "8", x2: "8", y1: "2", y2: "5" }], ["line", { x1: "2", x2: "5", y1: "8", y2: "8" }], ["line", { x1: "16", x2: "16", y1: "19", y2: "22" }], ["line", { x1: "19", x2: "22", y1: "16", y2: "16" }]];
const $r = [["path", { d: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" }], ["circle", { cx: "9", cy: "7", r: "4" }], ["line", { x1: "19", x2: "19", y1: "8", y2: "14" }], ["line", { x1: "22", x2: "16", y1: "11", y2: "11" }]];
const Pr = [["path", { d: "M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" }], ["circle", { cx: "12", cy: "7", r: "4" }]];
const jr = [["path", { d: "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" }], ["path", { d: "M16 3.128a4 4 0 0 1 0 7.744" }], ["path", { d: "M22 21v-2a4 4 0 0 0-3-3.87" }], ["circle", { cx: "9", cy: "7", r: "4" }]];
const Ur = [["path", { d: "M10.513 4.856 13.12 2.17a.5.5 0 0 1 .86.46l-1.377 4.317" }], ["path", { d: "M15.656 10H20a1 1 0 0 1 .78 1.63l-1.72 1.773" }], ["path", { d: "M16.273 16.273 10.88 21.83a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14H4a1 1 0 0 1-.78-1.63l4.507-4.643" }], ["path", { d: "m2 2 20 20" }]];
const Br = [["path", { d: "M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z" }]];
const Dt = ({ icons: r = {}, nameAttr: e = "data-lucide", attrs: t = {}, root: s = document, inTemplates: n } = {}) => {
  if (!Object.values(r).length) throw new Error(`Please provide an icons object.
If you want to use all the icons you can import it like:
 \`import { createIcons, icons } from 'lucide';
lucide.createIcons({icons});\``);
  if (typeof s > "u") throw new Error("`createIcons()` only works in a browser environment.");
  if (Array.from(s.querySelectorAll(`[${e}]`)).forEach((a) => ut(a, { nameAttr: e, icons: r, attrs: t })), n && Array.from(s.querySelectorAll("template")).forEach((o) => Dt({ icons: r, nameAttr: e, attrs: t, root: o.content, inTemplates: n })), e === "data-lucide") {
    const a = s.querySelectorAll("[icon-name]");
    a.length > 0 && (console.warn("[Lucide] Some icons were found with the now deprecated icon-name attribute. These will still be replaced for backwards compatibility, but will no longer be supported in v1.0 and you should switch to data-lucide"), Array.from(a).forEach((o) => ut(o, { nameAttr: "icon-name", icons: r, attrs: t })));
  }
};
function Pe(r, e) {
  var t = {};
  for (var s in r) Object.prototype.hasOwnProperty.call(r, s) && e.indexOf(s) < 0 && (t[s] = r[s]);
  if (r != null && typeof Object.getOwnPropertySymbols == "function") for (var n = 0, s = Object.getOwnPropertySymbols(r); n < s.length; n++) e.indexOf(s[n]) < 0 && Object.prototype.propertyIsEnumerable.call(r, s[n]) && (t[s[n]] = r[s[n]]);
  return t;
}
function Nr(r, e, t, s) {
  function n(i) {
    return i instanceof t ? i : new t(function(a) {
      a(i);
    });
  }
  return new (t || (t = Promise))(function(i, a) {
    function o(u) {
      try {
        c(s.next(u));
      } catch (h) {
        a(h);
      }
    }
    function l(u) {
      try {
        c(s.throw(u));
      } catch (h) {
        a(h);
      }
    }
    function c(u) {
      u.done ? i(u.value) : n(u.value).then(o, l);
    }
    c((s = s.apply(r, e || [])).next());
  });
}
const Dr = (r) => r ? (...e) => r(...e) : (...e) => fetch(...e);
class rt extends Error {
  constructor(e, t = "FunctionsError", s) {
    super(e), this.name = t, this.context = s;
  }
}
class Lr extends rt {
  constructor(e) {
    super("Failed to send a request to the Edge Function", "FunctionsFetchError", e);
  }
}
class dt extends rt {
  constructor(e) {
    super("Relay Error invoking the Edge Function", "FunctionsRelayError", e);
  }
}
class ht extends rt {
  constructor(e) {
    super("Edge Function returned a non-2xx status code", "FunctionsHttpError", e);
  }
}
var He;
(function(r) {
  r.Any = "any", r.ApNortheast1 = "ap-northeast-1", r.ApNortheast2 = "ap-northeast-2", r.ApSouth1 = "ap-south-1", r.ApSoutheast1 = "ap-southeast-1", r.ApSoutheast2 = "ap-southeast-2", r.CaCentral1 = "ca-central-1", r.EuCentral1 = "eu-central-1", r.EuWest1 = "eu-west-1", r.EuWest2 = "eu-west-2", r.EuWest3 = "eu-west-3", r.SaEast1 = "sa-east-1", r.UsEast1 = "us-east-1", r.UsWest1 = "us-west-1", r.UsWest2 = "us-west-2";
})(He || (He = {}));
class Mr {
  constructor(e, { headers: t = {}, customFetch: s, region: n = He.Any } = {}) {
    this.url = e, this.headers = t, this.region = n, this.fetch = Dr(s);
  }
  setAuth(e) {
    this.headers.Authorization = `Bearer ${e}`;
  }
  invoke(e) {
    return Nr(this, arguments, void 0, function* (t, s = {}) {
      var n;
      let i, a;
      try {
        const { headers: o, method: l, body: c, signal: u, timeout: h } = s;
        let d = {}, { region: f } = s;
        f || (f = this.region);
        const p = new URL(`${this.url}/${t}`);
        f && f !== "any" && (d["x-region"] = f, p.searchParams.set("forceFunctionRegion", f));
        let g;
        c && (o && !Object.prototype.hasOwnProperty.call(o, "Content-Type") || !o) ? typeof Blob < "u" && c instanceof Blob || c instanceof ArrayBuffer ? (d["Content-Type"] = "application/octet-stream", g = c) : typeof c == "string" ? (d["Content-Type"] = "text/plain", g = c) : typeof FormData < "u" && c instanceof FormData ? g = c : (d["Content-Type"] = "application/json", g = JSON.stringify(c)) : g = c;
        let m = u;
        h && (a = new AbortController(), i = setTimeout(() => a.abort(), h), u ? (m = a.signal, u.addEventListener("abort", () => a.abort())) : m = a.signal);
        const v = yield this.fetch(p.toString(), { method: l || "POST", headers: Object.assign(Object.assign(Object.assign({}, d), this.headers), o), body: g, signal: m }).catch(($) => {
          throw new Lr($);
        }), b = v.headers.get("x-relay-error");
        if (b && b === "true") throw new dt(v);
        if (!v.ok) throw new ht(v);
        let y = ((n = v.headers.get("Content-Type")) !== null && n !== void 0 ? n : "text/plain").split(";")[0].trim(), k;
        return y === "application/json" ? k = yield v.json() : y === "application/octet-stream" || y === "application/pdf" ? k = yield v.blob() : y === "text/event-stream" ? k = v : y === "multipart/form-data" ? k = yield v.formData() : k = yield v.text(), { data: k, error: null, response: v };
      } catch (o) {
        return { data: null, error: o, response: o instanceof ht || o instanceof dt ? o.context : void 0 };
      } finally {
        i && clearTimeout(i);
      }
    });
  }
}
var qr = class extends Error {
  constructor(r) {
    super(r.message), this.name = "PostgrestError", this.details = r.details, this.hint = r.hint, this.code = r.code;
  }
}, Vr = class {
  constructor(r) {
    var e, t;
    this.shouldThrowOnError = false, this.method = r.method, this.url = r.url, this.headers = new Headers(r.headers), this.schema = r.schema, this.body = r.body, this.shouldThrowOnError = (e = r.shouldThrowOnError) !== null && e !== void 0 ? e : false, this.signal = r.signal, this.isMaybeSingle = (t = r.isMaybeSingle) !== null && t !== void 0 ? t : false, r.fetch ? this.fetch = r.fetch : this.fetch = fetch;
  }
  throwOnError() {
    return this.shouldThrowOnError = true, this;
  }
  setHeader(r, e) {
    return this.headers = new Headers(this.headers), this.headers.set(r, e), this;
  }
  then(r, e) {
    var t = this;
    this.schema === void 0 || (["GET", "HEAD"].includes(this.method) ? this.headers.set("Accept-Profile", this.schema) : this.headers.set("Content-Profile", this.schema)), this.method !== "GET" && this.method !== "HEAD" && this.headers.set("Content-Type", "application/json");
    const s = this.fetch;
    let n = s(this.url.toString(), { method: this.method, headers: this.headers, body: JSON.stringify(this.body), signal: this.signal }).then(async (i) => {
      let a = null, o = null, l = null, c = i.status, u = i.statusText;
      if (i.ok) {
        var h, d;
        if (t.method !== "HEAD") {
          var f;
          const v = await i.text();
          v === "" || (t.headers.get("Accept") === "text/csv" || t.headers.get("Accept") && (!((f = t.headers.get("Accept")) === null || f === void 0) && f.includes("application/vnd.pgrst.plan+text")) ? o = v : o = JSON.parse(v));
        }
        const g = (h = t.headers.get("Prefer")) === null || h === void 0 ? void 0 : h.match(/count=(exact|planned|estimated)/), m = (d = i.headers.get("content-range")) === null || d === void 0 ? void 0 : d.split("/");
        g && m && m.length > 1 && (l = parseInt(m[1])), t.isMaybeSingle && t.method === "GET" && Array.isArray(o) && (o.length > 1 ? (a = { code: "PGRST116", details: `Results contain ${o.length} rows, application/vnd.pgrst.object+json requires 1 row`, hint: null, message: "JSON object requested, multiple (or no) rows returned" }, o = null, l = null, c = 406, u = "Not Acceptable") : o.length === 1 ? o = o[0] : o = null);
      } else {
        var p;
        const g = await i.text();
        try {
          a = JSON.parse(g), Array.isArray(a) && i.status === 404 && (o = [], a = null, c = 200, u = "OK");
        } catch {
          i.status === 404 && g === "" ? (c = 204, u = "No Content") : a = { message: g };
        }
        if (a && t.isMaybeSingle && (!(a == null || (p = a.details) === null || p === void 0) && p.includes("0 rows")) && (a = null, c = 200, u = "OK"), a && t.shouldThrowOnError) throw new qr(a);
      }
      return { error: a, data: o, count: l, status: c, statusText: u };
    });
    return this.shouldThrowOnError || (n = n.catch((i) => {
      var a;
      let o = "";
      const l = i == null ? void 0 : i.cause;
      if (l) {
        var c, u, h, d;
        const p = (c = l == null ? void 0 : l.message) !== null && c !== void 0 ? c : "", g = (u = l == null ? void 0 : l.code) !== null && u !== void 0 ? u : "";
        o = `${(h = i == null ? void 0 : i.name) !== null && h !== void 0 ? h : "FetchError"}: ${i == null ? void 0 : i.message}`, o += `

Caused by: ${(d = l == null ? void 0 : l.name) !== null && d !== void 0 ? d : "Error"}: ${p}`, g && (o += ` (${g})`), (l == null ? void 0 : l.stack) && (o += `
${l.stack}`);
      } else {
        var f;
        o = (f = i == null ? void 0 : i.stack) !== null && f !== void 0 ? f : "";
      }
      return { error: { message: `${(a = i == null ? void 0 : i.name) !== null && a !== void 0 ? a : "FetchError"}: ${i == null ? void 0 : i.message}`, details: o, hint: "", code: "" }, data: null, count: null, status: 0, statusText: "" };
    })), n.then(r, e);
  }
  returns() {
    return this;
  }
  overrideTypes() {
    return this;
  }
}, Wr = class extends Vr {
  select(r) {
    let e = false;
    const t = (r ?? "*").split("").map((s) => /\s/.test(s) && !e ? "" : (s === '"' && (e = !e), s)).join("");
    return this.url.searchParams.set("select", t), this.headers.append("Prefer", "return=representation"), this;
  }
  order(r, { ascending: e = true, nullsFirst: t, foreignTable: s, referencedTable: n = s } = {}) {
    const i = n ? `${n}.order` : "order", a = this.url.searchParams.get(i);
    return this.url.searchParams.set(i, `${a ? `${a},` : ""}${r}.${e ? "asc" : "desc"}${t === void 0 ? "" : t ? ".nullsfirst" : ".nullslast"}`), this;
  }
  limit(r, { foreignTable: e, referencedTable: t = e } = {}) {
    const s = typeof t > "u" ? "limit" : `${t}.limit`;
    return this.url.searchParams.set(s, `${r}`), this;
  }
  range(r, e, { foreignTable: t, referencedTable: s = t } = {}) {
    const n = typeof s > "u" ? "offset" : `${s}.offset`, i = typeof s > "u" ? "limit" : `${s}.limit`;
    return this.url.searchParams.set(n, `${r}`), this.url.searchParams.set(i, `${e - r + 1}`), this;
  }
  abortSignal(r) {
    return this.signal = r, this;
  }
  single() {
    return this.headers.set("Accept", "application/vnd.pgrst.object+json"), this;
  }
  maybeSingle() {
    return this.method === "GET" ? this.headers.set("Accept", "application/json") : this.headers.set("Accept", "application/vnd.pgrst.object+json"), this.isMaybeSingle = true, this;
  }
  csv() {
    return this.headers.set("Accept", "text/csv"), this;
  }
  geojson() {
    return this.headers.set("Accept", "application/geo+json"), this;
  }
  explain({ analyze: r = false, verbose: e = false, settings: t = false, buffers: s = false, wal: n = false, format: i = "text" } = {}) {
    var a;
    const o = [r ? "analyze" : null, e ? "verbose" : null, t ? "settings" : null, s ? "buffers" : null, n ? "wal" : null].filter(Boolean).join("|"), l = (a = this.headers.get("Accept")) !== null && a !== void 0 ? a : "application/json";
    return this.headers.set("Accept", `application/vnd.pgrst.plan+${i}; for="${l}"; options=${o};`), i === "json" ? this : this;
  }
  rollback() {
    return this.headers.append("Prefer", "tx=rollback"), this;
  }
  returns() {
    return this;
  }
  maxAffected(r) {
    return this.headers.append("Prefer", "handling=strict"), this.headers.append("Prefer", `max-affected=${r}`), this;
  }
};
const ft = new RegExp("[,()]");
var ce = class extends Wr {
  eq(r, e) {
    return this.url.searchParams.append(r, `eq.${e}`), this;
  }
  neq(r, e) {
    return this.url.searchParams.append(r, `neq.${e}`), this;
  }
  gt(r, e) {
    return this.url.searchParams.append(r, `gt.${e}`), this;
  }
  gte(r, e) {
    return this.url.searchParams.append(r, `gte.${e}`), this;
  }
  lt(r, e) {
    return this.url.searchParams.append(r, `lt.${e}`), this;
  }
  lte(r, e) {
    return this.url.searchParams.append(r, `lte.${e}`), this;
  }
  like(r, e) {
    return this.url.searchParams.append(r, `like.${e}`), this;
  }
  likeAllOf(r, e) {
    return this.url.searchParams.append(r, `like(all).{${e.join(",")}}`), this;
  }
  likeAnyOf(r, e) {
    return this.url.searchParams.append(r, `like(any).{${e.join(",")}}`), this;
  }
  ilike(r, e) {
    return this.url.searchParams.append(r, `ilike.${e}`), this;
  }
  ilikeAllOf(r, e) {
    return this.url.searchParams.append(r, `ilike(all).{${e.join(",")}}`), this;
  }
  ilikeAnyOf(r, e) {
    return this.url.searchParams.append(r, `ilike(any).{${e.join(",")}}`), this;
  }
  regexMatch(r, e) {
    return this.url.searchParams.append(r, `match.${e}`), this;
  }
  regexIMatch(r, e) {
    return this.url.searchParams.append(r, `imatch.${e}`), this;
  }
  is(r, e) {
    return this.url.searchParams.append(r, `is.${e}`), this;
  }
  isDistinct(r, e) {
    return this.url.searchParams.append(r, `isdistinct.${e}`), this;
  }
  in(r, e) {
    const t = Array.from(new Set(e)).map((s) => typeof s == "string" && ft.test(s) ? `"${s}"` : `${s}`).join(",");
    return this.url.searchParams.append(r, `in.(${t})`), this;
  }
  notIn(r, e) {
    const t = Array.from(new Set(e)).map((s) => typeof s == "string" && ft.test(s) ? `"${s}"` : `${s}`).join(",");
    return this.url.searchParams.append(r, `not.in.(${t})`), this;
  }
  contains(r, e) {
    return typeof e == "string" ? this.url.searchParams.append(r, `cs.${e}`) : Array.isArray(e) ? this.url.searchParams.append(r, `cs.{${e.join(",")}}`) : this.url.searchParams.append(r, `cs.${JSON.stringify(e)}`), this;
  }
  containedBy(r, e) {
    return typeof e == "string" ? this.url.searchParams.append(r, `cd.${e}`) : Array.isArray(e) ? this.url.searchParams.append(r, `cd.{${e.join(",")}}`) : this.url.searchParams.append(r, `cd.${JSON.stringify(e)}`), this;
  }
  rangeGt(r, e) {
    return this.url.searchParams.append(r, `sr.${e}`), this;
  }
  rangeGte(r, e) {
    return this.url.searchParams.append(r, `nxl.${e}`), this;
  }
  rangeLt(r, e) {
    return this.url.searchParams.append(r, `sl.${e}`), this;
  }
  rangeLte(r, e) {
    return this.url.searchParams.append(r, `nxr.${e}`), this;
  }
  rangeAdjacent(r, e) {
    return this.url.searchParams.append(r, `adj.${e}`), this;
  }
  overlaps(r, e) {
    return typeof e == "string" ? this.url.searchParams.append(r, `ov.${e}`) : this.url.searchParams.append(r, `ov.{${e.join(",")}}`), this;
  }
  textSearch(r, e, { config: t, type: s } = {}) {
    let n = "";
    s === "plain" ? n = "pl" : s === "phrase" ? n = "ph" : s === "websearch" && (n = "w");
    const i = t === void 0 ? "" : `(${t})`;
    return this.url.searchParams.append(r, `${n}fts${i}.${e}`), this;
  }
  match(r) {
    return Object.entries(r).forEach(([e, t]) => {
      this.url.searchParams.append(e, `eq.${t}`);
    }), this;
  }
  not(r, e, t) {
    return this.url.searchParams.append(r, `not.${e}.${t}`), this;
  }
  or(r, { foreignTable: e, referencedTable: t = e } = {}) {
    const s = t ? `${t}.or` : "or";
    return this.url.searchParams.append(s, `(${r})`), this;
  }
  filter(r, e, t) {
    return this.url.searchParams.append(r, `${e}.${t}`), this;
  }
}, zr = class {
  constructor(r, { headers: e = {}, schema: t, fetch: s }) {
    this.url = r, this.headers = new Headers(e), this.schema = t, this.fetch = s;
  }
  select(r, e) {
    const { head: t = false, count: s } = e ?? {}, n = t ? "HEAD" : "GET";
    let i = false;
    const a = (r ?? "*").split("").map((o) => /\s/.test(o) && !i ? "" : (o === '"' && (i = !i), o)).join("");
    return this.url.searchParams.set("select", a), s && this.headers.append("Prefer", `count=${s}`), new ce({ method: n, url: this.url, headers: this.headers, schema: this.schema, fetch: this.fetch });
  }
  insert(r, { count: e, defaultToNull: t = true } = {}) {
    var s;
    const n = "POST";
    if (e && this.headers.append("Prefer", `count=${e}`), t || this.headers.append("Prefer", "missing=default"), Array.isArray(r)) {
      const i = r.reduce((a, o) => a.concat(Object.keys(o)), []);
      if (i.length > 0) {
        const a = [...new Set(i)].map((o) => `"${o}"`);
        this.url.searchParams.set("columns", a.join(","));
      }
    }
    return new ce({ method: n, url: this.url, headers: this.headers, schema: this.schema, body: r, fetch: (s = this.fetch) !== null && s !== void 0 ? s : fetch });
  }
  upsert(r, { onConflict: e, ignoreDuplicates: t = false, count: s, defaultToNull: n = true } = {}) {
    var i;
    const a = "POST";
    if (this.headers.append("Prefer", `resolution=${t ? "ignore" : "merge"}-duplicates`), e !== void 0 && this.url.searchParams.set("on_conflict", e), s && this.headers.append("Prefer", `count=${s}`), n || this.headers.append("Prefer", "missing=default"), Array.isArray(r)) {
      const o = r.reduce((l, c) => l.concat(Object.keys(c)), []);
      if (o.length > 0) {
        const l = [...new Set(o)].map((c) => `"${c}"`);
        this.url.searchParams.set("columns", l.join(","));
      }
    }
    return new ce({ method: a, url: this.url, headers: this.headers, schema: this.schema, body: r, fetch: (i = this.fetch) !== null && i !== void 0 ? i : fetch });
  }
  update(r, { count: e } = {}) {
    var t;
    const s = "PATCH";
    return e && this.headers.append("Prefer", `count=${e}`), new ce({ method: s, url: this.url, headers: this.headers, schema: this.schema, body: r, fetch: (t = this.fetch) !== null && t !== void 0 ? t : fetch });
  }
  delete({ count: r } = {}) {
    var e;
    const t = "DELETE";
    return r && this.headers.append("Prefer", `count=${r}`), new ce({ method: t, url: this.url, headers: this.headers, schema: this.schema, fetch: (e = this.fetch) !== null && e !== void 0 ? e : fetch });
  }
}, Hr = class Lt {
  constructor(e, { headers: t = {}, schema: s, fetch: n } = {}) {
    this.url = e, this.headers = new Headers(t), this.schemaName = s, this.fetch = n;
  }
  from(e) {
    if (!e || typeof e != "string" || e.trim() === "") throw new Error("Invalid relation name: relation must be a non-empty string.");
    return new zr(new URL(`${this.url}/${e}`), { headers: new Headers(this.headers), schema: this.schemaName, fetch: this.fetch });
  }
  schema(e) {
    return new Lt(this.url, { headers: this.headers, schema: e, fetch: this.fetch });
  }
  rpc(e, t = {}, { head: s = false, get: n = false, count: i } = {}) {
    var a;
    let o;
    const l = new URL(`${this.url}/rpc/${e}`);
    let c;
    s || n ? (o = s ? "HEAD" : "GET", Object.entries(t).filter(([h, d]) => d !== void 0).map(([h, d]) => [h, Array.isArray(d) ? `{${d.join(",")}}` : `${d}`]).forEach(([h, d]) => {
      l.searchParams.append(h, d);
    })) : (o = "POST", c = t);
    const u = new Headers(this.headers);
    return i && u.set("Prefer", `count=${i}`), new ce({ method: o, url: l, headers: u, schema: this.schemaName, body: c, fetch: (a = this.fetch) !== null && a !== void 0 ? a : fetch });
  }
};
class Fr {
  constructor() {
  }
  static detectEnvironment() {
    var e;
    if (typeof WebSocket < "u") return { type: "native", constructor: WebSocket };
    if (typeof globalThis < "u" && typeof globalThis.WebSocket < "u") return { type: "native", constructor: globalThis.WebSocket };
    if (typeof global < "u" && typeof global.WebSocket < "u") return { type: "native", constructor: global.WebSocket };
    if (typeof globalThis < "u" && typeof globalThis.WebSocketPair < "u" && typeof globalThis.WebSocket > "u") return { type: "cloudflare", error: "Cloudflare Workers detected. WebSocket clients are not supported in Cloudflare Workers.", workaround: "Use Cloudflare Workers WebSocket API for server-side WebSocket handling, or deploy to a different runtime." };
    if (typeof globalThis < "u" && globalThis.EdgeRuntime || typeof navigator < "u" && (!((e = navigator.userAgent) === null || e === void 0) && e.includes("Vercel-Edge"))) return { type: "unsupported", error: "Edge runtime detected (Vercel Edge/Netlify Edge). WebSockets are not supported in edge functions.", workaround: "Use serverless functions or a different deployment target for WebSocket functionality." };
    if (typeof process < "u") {
      const t = process.versions;
      if (t && t.node) {
        const s = t.node, n = parseInt(s.replace(/^v/, "").split(".")[0]);
        return n >= 22 ? typeof globalThis.WebSocket < "u" ? { type: "native", constructor: globalThis.WebSocket } : { type: "unsupported", error: `Node.js ${n} detected but native WebSocket not found.`, workaround: "Provide a WebSocket implementation via the transport option." } : { type: "unsupported", error: `Node.js ${n} detected without native WebSocket support.`, workaround: `For Node.js < 22, install "ws" package and provide it via the transport option:
import ws from "ws"
new RealtimeClient(url, { transport: ws })` };
      }
    }
    return { type: "unsupported", error: "Unknown JavaScript runtime without WebSocket support.", workaround: "Ensure you're running in a supported environment (browser, Node.js, Deno) or provide a custom WebSocket implementation." };
  }
  static getWebSocketConstructor() {
    const e = this.detectEnvironment();
    if (e.constructor) return e.constructor;
    let t = e.error || "WebSocket not supported in this environment.";
    throw e.workaround && (t += `

Suggested solution: ${e.workaround}`), new Error(t);
  }
  static createWebSocket(e, t) {
    const s = this.getWebSocketConstructor();
    return new s(e, t);
  }
  static isWebSocketSupported() {
    try {
      const e = this.detectEnvironment();
      return e.type === "native" || e.type === "ws";
    } catch {
      return false;
    }
  }
}
const Kr = "2.89.0", Gr = `realtime-js/${Kr}`, Mt = "1.0.0", Jr = "2.0.0", pt = Mt, Fe = 1e4, Yr = 1e3, Xr = 100;
var K;
(function(r) {
  r[r.connecting = 0] = "connecting", r[r.open = 1] = "open", r[r.closing = 2] = "closing", r[r.closed = 3] = "closed";
})(K || (K = {}));
var C;
(function(r) {
  r.closed = "closed", r.errored = "errored", r.joined = "joined", r.joining = "joining", r.leaving = "leaving";
})(C || (C = {}));
var q;
(function(r) {
  r.close = "phx_close", r.error = "phx_error", r.join = "phx_join", r.reply = "phx_reply", r.leave = "phx_leave", r.access_token = "access_token";
})(q || (q = {}));
var Ke;
(function(r) {
  r.websocket = "websocket";
})(Ke || (Ke = {}));
var Z;
(function(r) {
  r.Connecting = "connecting", r.Open = "open", r.Closing = "closing", r.Closed = "closed";
})(Z || (Z = {}));
class Qr {
  constructor(e) {
    this.HEADER_LENGTH = 1, this.USER_BROADCAST_PUSH_META_LENGTH = 6, this.KINDS = { userBroadcastPush: 3, userBroadcast: 4 }, this.BINARY_ENCODING = 0, this.JSON_ENCODING = 1, this.BROADCAST_EVENT = "broadcast", this.allowedMetadataKeys = [], this.allowedMetadataKeys = e ?? [];
  }
  encode(e, t) {
    if (e.event === this.BROADCAST_EVENT && !(e.payload instanceof ArrayBuffer) && typeof e.payload.event == "string") return t(this._binaryEncodeUserBroadcastPush(e));
    let s = [e.join_ref, e.ref, e.topic, e.event, e.payload];
    return t(JSON.stringify(s));
  }
  _binaryEncodeUserBroadcastPush(e) {
    var t;
    return this._isArrayBuffer((t = e.payload) === null || t === void 0 ? void 0 : t.payload) ? this._encodeBinaryUserBroadcastPush(e) : this._encodeJsonUserBroadcastPush(e);
  }
  _encodeBinaryUserBroadcastPush(e) {
    var t, s;
    const n = (s = (t = e.payload) === null || t === void 0 ? void 0 : t.payload) !== null && s !== void 0 ? s : new ArrayBuffer(0);
    return this._encodeUserBroadcastPush(e, this.BINARY_ENCODING, n);
  }
  _encodeJsonUserBroadcastPush(e) {
    var t, s;
    const n = (s = (t = e.payload) === null || t === void 0 ? void 0 : t.payload) !== null && s !== void 0 ? s : {}, a = new TextEncoder().encode(JSON.stringify(n)).buffer;
    return this._encodeUserBroadcastPush(e, this.JSON_ENCODING, a);
  }
  _encodeUserBroadcastPush(e, t, s) {
    var n, i;
    const a = e.topic, o = (n = e.ref) !== null && n !== void 0 ? n : "", l = (i = e.join_ref) !== null && i !== void 0 ? i : "", c = e.payload.event, u = this.allowedMetadataKeys ? this._pick(e.payload, this.allowedMetadataKeys) : {}, h = Object.keys(u).length === 0 ? "" : JSON.stringify(u);
    if (l.length > 255) throw new Error(`joinRef length ${l.length} exceeds maximum of 255`);
    if (o.length > 255) throw new Error(`ref length ${o.length} exceeds maximum of 255`);
    if (a.length > 255) throw new Error(`topic length ${a.length} exceeds maximum of 255`);
    if (c.length > 255) throw new Error(`userEvent length ${c.length} exceeds maximum of 255`);
    if (h.length > 255) throw new Error(`metadata length ${h.length} exceeds maximum of 255`);
    const d = this.USER_BROADCAST_PUSH_META_LENGTH + l.length + o.length + a.length + c.length + h.length, f = new ArrayBuffer(this.HEADER_LENGTH + d);
    let p = new DataView(f), g = 0;
    p.setUint8(g++, this.KINDS.userBroadcastPush), p.setUint8(g++, l.length), p.setUint8(g++, o.length), p.setUint8(g++, a.length), p.setUint8(g++, c.length), p.setUint8(g++, h.length), p.setUint8(g++, t), Array.from(l, (v) => p.setUint8(g++, v.charCodeAt(0))), Array.from(o, (v) => p.setUint8(g++, v.charCodeAt(0))), Array.from(a, (v) => p.setUint8(g++, v.charCodeAt(0))), Array.from(c, (v) => p.setUint8(g++, v.charCodeAt(0))), Array.from(h, (v) => p.setUint8(g++, v.charCodeAt(0)));
    var m = new Uint8Array(f.byteLength + s.byteLength);
    return m.set(new Uint8Array(f), 0), m.set(new Uint8Array(s), f.byteLength), m.buffer;
  }
  decode(e, t) {
    if (this._isArrayBuffer(e)) {
      let s = this._binaryDecode(e);
      return t(s);
    }
    if (typeof e == "string") {
      const s = JSON.parse(e), [n, i, a, o, l] = s;
      return t({ join_ref: n, ref: i, topic: a, event: o, payload: l });
    }
    return t({});
  }
  _binaryDecode(e) {
    const t = new DataView(e), s = t.getUint8(0), n = new TextDecoder();
    if (s === this.KINDS.userBroadcast) return this._decodeUserBroadcast(e, t, n);
  }
  _decodeUserBroadcast(e, t, s) {
    const n = t.getUint8(1), i = t.getUint8(2), a = t.getUint8(3), o = t.getUint8(4);
    let l = this.HEADER_LENGTH + 4;
    const c = s.decode(e.slice(l, l + n));
    l = l + n;
    const u = s.decode(e.slice(l, l + i));
    l = l + i;
    const h = s.decode(e.slice(l, l + a));
    l = l + a;
    const d = e.slice(l, e.byteLength), f = o === this.JSON_ENCODING ? JSON.parse(s.decode(d)) : d, p = { type: this.BROADCAST_EVENT, event: u, payload: f };
    return a > 0 && (p.meta = JSON.parse(h)), { join_ref: null, ref: null, topic: c, event: this.BROADCAST_EVENT, payload: p };
  }
  _isArrayBuffer(e) {
    var t;
    return e instanceof ArrayBuffer || ((t = e == null ? void 0 : e.constructor) === null || t === void 0 ? void 0 : t.name) === "ArrayBuffer";
  }
  _pick(e, t) {
    return !e || typeof e != "object" ? {} : Object.fromEntries(Object.entries(e).filter(([s]) => t.includes(s)));
  }
}
class qt {
  constructor(e, t) {
    this.callback = e, this.timerCalc = t, this.timer = void 0, this.tries = 0, this.callback = e, this.timerCalc = t;
  }
  reset() {
    this.tries = 0, clearTimeout(this.timer), this.timer = void 0;
  }
  scheduleTimeout() {
    clearTimeout(this.timer), this.timer = setTimeout(() => {
      this.tries = this.tries + 1, this.callback();
    }, this.timerCalc(this.tries + 1));
  }
}
var I;
(function(r) {
  r.abstime = "abstime", r.bool = "bool", r.date = "date", r.daterange = "daterange", r.float4 = "float4", r.float8 = "float8", r.int2 = "int2", r.int4 = "int4", r.int4range = "int4range", r.int8 = "int8", r.int8range = "int8range", r.json = "json", r.jsonb = "jsonb", r.money = "money", r.numeric = "numeric", r.oid = "oid", r.reltime = "reltime", r.text = "text", r.time = "time", r.timestamp = "timestamp", r.timestamptz = "timestamptz", r.timetz = "timetz", r.tsrange = "tsrange", r.tstzrange = "tstzrange";
})(I || (I = {}));
const gt = (r, e, t = {}) => {
  var s;
  const n = (s = t.skipTypes) !== null && s !== void 0 ? s : [];
  return e ? Object.keys(e).reduce((i, a) => (i[a] = Zr(a, r, e, n), i), {}) : {};
}, Zr = (r, e, t, s) => {
  const n = e.find((o) => o.name === r), i = n == null ? void 0 : n.type, a = t[r];
  return i && !s.includes(i) ? Vt(i, a) : Ge(a);
}, Vt = (r, e) => {
  if (r.charAt(0) === "_") {
    const t = r.slice(1, r.length);
    return ss(e, t);
  }
  switch (r) {
    case I.bool:
      return es(e);
    case I.float4:
    case I.float8:
    case I.int2:
    case I.int4:
    case I.int8:
    case I.numeric:
    case I.oid:
      return ts(e);
    case I.json:
    case I.jsonb:
      return rs(e);
    case I.timestamp:
      return ns(e);
    case I.abstime:
    case I.date:
    case I.daterange:
    case I.int4range:
    case I.int8range:
    case I.money:
    case I.reltime:
    case I.text:
    case I.time:
    case I.timestamptz:
    case I.timetz:
    case I.tsrange:
    case I.tstzrange:
      return Ge(e);
    default:
      return Ge(e);
  }
}, Ge = (r) => r, es = (r) => {
  switch (r) {
    case "t":
      return true;
    case "f":
      return false;
    default:
      return r;
  }
}, ts = (r) => {
  if (typeof r == "string") {
    const e = parseFloat(r);
    if (!Number.isNaN(e)) return e;
  }
  return r;
}, rs = (r) => {
  if (typeof r == "string") try {
    return JSON.parse(r);
  } catch {
    return r;
  }
  return r;
}, ss = (r, e) => {
  if (typeof r != "string") return r;
  const t = r.length - 1, s = r[t];
  if (r[0] === "{" && s === "}") {
    let i;
    const a = r.slice(1, t);
    try {
      i = JSON.parse("[" + a + "]");
    } catch {
      i = a ? a.split(",") : [];
    }
    return i.map((o) => Vt(e, o));
  }
  return r;
}, ns = (r) => typeof r == "string" ? r.replace(" ", "T") : r, Wt = (r) => {
  const e = new URL(r);
  return e.protocol = e.protocol.replace(/^ws/i, "http"), e.pathname = e.pathname.replace(/\/+$/, "").replace(/\/socket\/websocket$/i, "").replace(/\/socket$/i, "").replace(/\/websocket$/i, ""), e.pathname === "" || e.pathname === "/" ? e.pathname = "/api/broadcast" : e.pathname = e.pathname + "/api/broadcast", e.href;
};
class Be {
  constructor(e, t, s = {}, n = Fe) {
    this.channel = e, this.event = t, this.payload = s, this.timeout = n, this.sent = false, this.timeoutTimer = void 0, this.ref = "", this.receivedResp = null, this.recHooks = [], this.refEvent = null;
  }
  resend(e) {
    this.timeout = e, this._cancelRefEvent(), this.ref = "", this.refEvent = null, this.receivedResp = null, this.sent = false, this.send();
  }
  send() {
    this._hasReceived("timeout") || (this.startTimeout(), this.sent = true, this.channel.socket.push({ topic: this.channel.topic, event: this.event, payload: this.payload, ref: this.ref, join_ref: this.channel._joinRef() }));
  }
  updatePayload(e) {
    this.payload = Object.assign(Object.assign({}, this.payload), e);
  }
  receive(e, t) {
    var s;
    return this._hasReceived(e) && t((s = this.receivedResp) === null || s === void 0 ? void 0 : s.response), this.recHooks.push({ status: e, callback: t }), this;
  }
  startTimeout() {
    if (this.timeoutTimer) return;
    this.ref = this.channel.socket._makeRef(), this.refEvent = this.channel._replyEventName(this.ref);
    const e = (t) => {
      this._cancelRefEvent(), this._cancelTimeout(), this.receivedResp = t, this._matchReceive(t);
    };
    this.channel._on(this.refEvent, {}, e), this.timeoutTimer = setTimeout(() => {
      this.trigger("timeout", {});
    }, this.timeout);
  }
  trigger(e, t) {
    this.refEvent && this.channel._trigger(this.refEvent, { status: e, response: t });
  }
  destroy() {
    this._cancelRefEvent(), this._cancelTimeout();
  }
  _cancelRefEvent() {
    this.refEvent && this.channel._off(this.refEvent, {});
  }
  _cancelTimeout() {
    clearTimeout(this.timeoutTimer), this.timeoutTimer = void 0;
  }
  _matchReceive({ status: e, response: t }) {
    this.recHooks.filter((s) => s.status === e).forEach((s) => s.callback(t));
  }
  _hasReceived(e) {
    return this.receivedResp && this.receivedResp.status === e;
  }
}
var mt;
(function(r) {
  r.SYNC = "sync", r.JOIN = "join", r.LEAVE = "leave";
})(mt || (mt = {}));
class ge {
  constructor(e, t) {
    this.channel = e, this.state = {}, this.pendingDiffs = [], this.joinRef = null, this.enabled = false, this.caller = { onJoin: () => {
    }, onLeave: () => {
    }, onSync: () => {
    } };
    const s = (t == null ? void 0 : t.events) || { state: "presence_state", diff: "presence_diff" };
    this.channel._on(s.state, {}, (n) => {
      const { onJoin: i, onLeave: a, onSync: o } = this.caller;
      this.joinRef = this.channel._joinRef(), this.state = ge.syncState(this.state, n, i, a), this.pendingDiffs.forEach((l) => {
        this.state = ge.syncDiff(this.state, l, i, a);
      }), this.pendingDiffs = [], o();
    }), this.channel._on(s.diff, {}, (n) => {
      const { onJoin: i, onLeave: a, onSync: o } = this.caller;
      this.inPendingSyncState() ? this.pendingDiffs.push(n) : (this.state = ge.syncDiff(this.state, n, i, a), o());
    }), this.onJoin((n, i, a) => {
      this.channel._trigger("presence", { event: "join", key: n, currentPresences: i, newPresences: a });
    }), this.onLeave((n, i, a) => {
      this.channel._trigger("presence", { event: "leave", key: n, currentPresences: i, leftPresences: a });
    }), this.onSync(() => {
      this.channel._trigger("presence", { event: "sync" });
    });
  }
  static syncState(e, t, s, n) {
    const i = this.cloneDeep(e), a = this.transformState(t), o = {}, l = {};
    return this.map(i, (c, u) => {
      a[c] || (l[c] = u);
    }), this.map(a, (c, u) => {
      const h = i[c];
      if (h) {
        const d = u.map((m) => m.presence_ref), f = h.map((m) => m.presence_ref), p = u.filter((m) => f.indexOf(m.presence_ref) < 0), g = h.filter((m) => d.indexOf(m.presence_ref) < 0);
        p.length > 0 && (o[c] = p), g.length > 0 && (l[c] = g);
      } else o[c] = u;
    }), this.syncDiff(i, { joins: o, leaves: l }, s, n);
  }
  static syncDiff(e, t, s, n) {
    const { joins: i, leaves: a } = { joins: this.transformState(t.joins), leaves: this.transformState(t.leaves) };
    return s || (s = () => {
    }), n || (n = () => {
    }), this.map(i, (o, l) => {
      var c;
      const u = (c = e[o]) !== null && c !== void 0 ? c : [];
      if (e[o] = this.cloneDeep(l), u.length > 0) {
        const h = e[o].map((f) => f.presence_ref), d = u.filter((f) => h.indexOf(f.presence_ref) < 0);
        e[o].unshift(...d);
      }
      s(o, u, l);
    }), this.map(a, (o, l) => {
      let c = e[o];
      if (!c) return;
      const u = l.map((h) => h.presence_ref);
      c = c.filter((h) => u.indexOf(h.presence_ref) < 0), e[o] = c, n(o, c, l), c.length === 0 && delete e[o];
    }), e;
  }
  static map(e, t) {
    return Object.getOwnPropertyNames(e).map((s) => t(s, e[s]));
  }
  static transformState(e) {
    return e = this.cloneDeep(e), Object.getOwnPropertyNames(e).reduce((t, s) => {
      const n = e[s];
      return "metas" in n ? t[s] = n.metas.map((i) => (i.presence_ref = i.phx_ref, delete i.phx_ref, delete i.phx_ref_prev, i)) : t[s] = n, t;
    }, {});
  }
  static cloneDeep(e) {
    return JSON.parse(JSON.stringify(e));
  }
  onJoin(e) {
    this.caller.onJoin = e;
  }
  onLeave(e) {
    this.caller.onLeave = e;
  }
  onSync(e) {
    this.caller.onSync = e;
  }
  inPendingSyncState() {
    return !this.joinRef || this.joinRef !== this.channel._joinRef();
  }
}
var yt;
(function(r) {
  r.ALL = "*", r.INSERT = "INSERT", r.UPDATE = "UPDATE", r.DELETE = "DELETE";
})(yt || (yt = {}));
var me;
(function(r) {
  r.BROADCAST = "broadcast", r.PRESENCE = "presence", r.POSTGRES_CHANGES = "postgres_changes", r.SYSTEM = "system";
})(me || (me = {}));
var z;
(function(r) {
  r.SUBSCRIBED = "SUBSCRIBED", r.TIMED_OUT = "TIMED_OUT", r.CLOSED = "CLOSED", r.CHANNEL_ERROR = "CHANNEL_ERROR";
})(z || (z = {}));
class he {
  constructor(e, t = { config: {} }, s) {
    var n, i;
    if (this.topic = e, this.params = t, this.socket = s, this.bindings = {}, this.state = C.closed, this.joinedOnce = false, this.pushBuffer = [], this.subTopic = e.replace(/^realtime:/i, ""), this.params.config = Object.assign({ broadcast: { ack: false, self: false }, presence: { key: "", enabled: false }, private: false }, t.config), this.timeout = this.socket.timeout, this.joinPush = new Be(this, q.join, this.params, this.timeout), this.rejoinTimer = new qt(() => this._rejoinUntilConnected(), this.socket.reconnectAfterMs), this.joinPush.receive("ok", () => {
      this.state = C.joined, this.rejoinTimer.reset(), this.pushBuffer.forEach((a) => a.send()), this.pushBuffer = [];
    }), this._onClose(() => {
      this.rejoinTimer.reset(), this.socket.log("channel", `close ${this.topic} ${this._joinRef()}`), this.state = C.closed, this.socket._remove(this);
    }), this._onError((a) => {
      this._isLeaving() || this._isClosed() || (this.socket.log("channel", `error ${this.topic}`, a), this.state = C.errored, this.rejoinTimer.scheduleTimeout());
    }), this.joinPush.receive("timeout", () => {
      this._isJoining() && (this.socket.log("channel", `timeout ${this.topic}`, this.joinPush.timeout), this.state = C.errored, this.rejoinTimer.scheduleTimeout());
    }), this.joinPush.receive("error", (a) => {
      this._isLeaving() || this._isClosed() || (this.socket.log("channel", `error ${this.topic}`, a), this.state = C.errored, this.rejoinTimer.scheduleTimeout());
    }), this._on(q.reply, {}, (a, o) => {
      this._trigger(this._replyEventName(o), a);
    }), this.presence = new ge(this), this.broadcastEndpointURL = Wt(this.socket.endPoint), this.private = this.params.config.private || false, !this.private && (!((i = (n = this.params.config) === null || n === void 0 ? void 0 : n.broadcast) === null || i === void 0) && i.replay)) throw `tried to use replay on public channel '${this.topic}'. It must be a private channel.`;
  }
  subscribe(e, t = this.timeout) {
    var s, n, i;
    if (this.socket.isConnected() || this.socket.connect(), this.state == C.closed) {
      const { config: { broadcast: a, presence: o, private: l } } = this.params, c = (n = (s = this.bindings.postgres_changes) === null || s === void 0 ? void 0 : s.map((f) => f.filter)) !== null && n !== void 0 ? n : [], u = !!this.bindings[me.PRESENCE] && this.bindings[me.PRESENCE].length > 0 || ((i = this.params.config.presence) === null || i === void 0 ? void 0 : i.enabled) === true, h = {}, d = { broadcast: a, presence: Object.assign(Object.assign({}, o), { enabled: u }), postgres_changes: c, private: l };
      this.socket.accessTokenValue && (h.access_token = this.socket.accessTokenValue), this._onError((f) => e == null ? void 0 : e(z.CHANNEL_ERROR, f)), this._onClose(() => e == null ? void 0 : e(z.CLOSED)), this.updateJoinPayload(Object.assign({ config: d }, h)), this.joinedOnce = true, this._rejoin(t), this.joinPush.receive("ok", async ({ postgres_changes: f }) => {
        var p;
        if (this.socket._isManualToken() || this.socket.setAuth(), f === void 0) {
          e == null ? void 0 : e(z.SUBSCRIBED);
          return;
        } else {
          const g = this.bindings.postgres_changes, m = (p = g == null ? void 0 : g.length) !== null && p !== void 0 ? p : 0, v = [];
          for (let b = 0; b < m; b++) {
            const y = g[b], { filter: { event: k, schema: $, table: T, filter: R } } = y, F = f && f[b];
            if (F && F.event === k && he.isFilterValueEqual(F.schema, $) && he.isFilterValueEqual(F.table, T) && he.isFilterValueEqual(F.filter, R)) v.push(Object.assign(Object.assign({}, y), { id: F.id }));
            else {
              this.unsubscribe(), this.state = C.errored, e == null ? void 0 : e(z.CHANNEL_ERROR, new Error("mismatch between server and client bindings for postgres changes"));
              return;
            }
          }
          this.bindings.postgres_changes = v, e && e(z.SUBSCRIBED);
          return;
        }
      }).receive("error", (f) => {
        this.state = C.errored, e == null ? void 0 : e(z.CHANNEL_ERROR, new Error(JSON.stringify(Object.values(f).join(", ") || "error")));
      }).receive("timeout", () => {
        e == null ? void 0 : e(z.TIMED_OUT);
      });
    }
    return this;
  }
  presenceState() {
    return this.presence.state;
  }
  async track(e, t = {}) {
    return await this.send({ type: "presence", event: "track", payload: e }, t.timeout || this.timeout);
  }
  async untrack(e = {}) {
    return await this.send({ type: "presence", event: "untrack" }, e);
  }
  on(e, t, s) {
    return this.state === C.joined && e === me.PRESENCE && (this.socket.log("channel", `resubscribe to ${this.topic} due to change in presence callbacks on joined channel`), this.unsubscribe().then(async () => await this.subscribe())), this._on(e, t, s);
  }
  async httpSend(e, t, s = {}) {
    var n;
    if (t == null) return Promise.reject("Payload is required for httpSend()");
    const i = { apikey: this.socket.apiKey ? this.socket.apiKey : "", "Content-Type": "application/json" };
    this.socket.accessTokenValue && (i.Authorization = `Bearer ${this.socket.accessTokenValue}`);
    const a = { method: "POST", headers: i, body: JSON.stringify({ messages: [{ topic: this.subTopic, event: e, payload: t, private: this.private }] }) }, o = await this._fetchWithTimeout(this.broadcastEndpointURL, a, (n = s.timeout) !== null && n !== void 0 ? n : this.timeout);
    if (o.status === 202) return { success: true };
    let l = o.statusText;
    try {
      const c = await o.json();
      l = c.error || c.message || l;
    } catch {
    }
    return Promise.reject(new Error(l));
  }
  async send(e, t = {}) {
    var s, n;
    if (!this._canPush() && e.type === "broadcast") {
      console.warn("Realtime send() is automatically falling back to REST API. This behavior will be deprecated in the future. Please use httpSend() explicitly for REST delivery.");
      const { event: i, payload: a } = e, o = { apikey: this.socket.apiKey ? this.socket.apiKey : "", "Content-Type": "application/json" };
      this.socket.accessTokenValue && (o.Authorization = `Bearer ${this.socket.accessTokenValue}`);
      const l = { method: "POST", headers: o, body: JSON.stringify({ messages: [{ topic: this.subTopic, event: i, payload: a, private: this.private }] }) };
      try {
        const c = await this._fetchWithTimeout(this.broadcastEndpointURL, l, (s = t.timeout) !== null && s !== void 0 ? s : this.timeout);
        return await ((n = c.body) === null || n === void 0 ? void 0 : n.cancel()), c.ok ? "ok" : "error";
      } catch (c) {
        return c.name === "AbortError" ? "timed out" : "error";
      }
    } else return new Promise((i) => {
      var a, o, l;
      const c = this._push(e.type, e, t.timeout || this.timeout);
      e.type === "broadcast" && !(!((l = (o = (a = this.params) === null || a === void 0 ? void 0 : a.config) === null || o === void 0 ? void 0 : o.broadcast) === null || l === void 0) && l.ack) && i("ok"), c.receive("ok", () => i("ok")), c.receive("error", () => i("error")), c.receive("timeout", () => i("timed out"));
    });
  }
  updateJoinPayload(e) {
    this.joinPush.updatePayload(e);
  }
  unsubscribe(e = this.timeout) {
    this.state = C.leaving;
    const t = () => {
      this.socket.log("channel", `leave ${this.topic}`), this._trigger(q.close, "leave", this._joinRef());
    };
    this.joinPush.destroy();
    let s = null;
    return new Promise((n) => {
      s = new Be(this, q.leave, {}, e), s.receive("ok", () => {
        t(), n("ok");
      }).receive("timeout", () => {
        t(), n("timed out");
      }).receive("error", () => {
        n("error");
      }), s.send(), this._canPush() || s.trigger("ok", {});
    }).finally(() => {
      s == null ? void 0 : s.destroy();
    });
  }
  teardown() {
    this.pushBuffer.forEach((e) => e.destroy()), this.pushBuffer = [], this.rejoinTimer.reset(), this.joinPush.destroy(), this.state = C.closed, this.bindings = {};
  }
  async _fetchWithTimeout(e, t, s) {
    const n = new AbortController(), i = setTimeout(() => n.abort(), s), a = await this.socket.fetch(e, Object.assign(Object.assign({}, t), { signal: n.signal }));
    return clearTimeout(i), a;
  }
  _push(e, t, s = this.timeout) {
    if (!this.joinedOnce) throw `tried to push '${e}' to '${this.topic}' before joining. Use channel.subscribe() before pushing events`;
    let n = new Be(this, e, t, s);
    return this._canPush() ? n.send() : this._addToPushBuffer(n), n;
  }
  _addToPushBuffer(e) {
    if (e.startTimeout(), this.pushBuffer.push(e), this.pushBuffer.length > Xr) {
      const t = this.pushBuffer.shift();
      t && (t.destroy(), this.socket.log("channel", `discarded push due to buffer overflow: ${t.event}`, t.payload));
    }
  }
  _onMessage(e, t, s) {
    return t;
  }
  _isMember(e) {
    return this.topic === e;
  }
  _joinRef() {
    return this.joinPush.ref;
  }
  _trigger(e, t, s) {
    var n, i;
    const a = e.toLocaleLowerCase(), { close: o, error: l, leave: c, join: u } = q;
    if (s && [o, l, c, u].indexOf(a) >= 0 && s !== this._joinRef()) return;
    let d = this._onMessage(a, t, s);
    if (t && !d) throw "channel onMessage callbacks must return the payload, modified or unmodified";
    ["insert", "update", "delete"].includes(a) ? (n = this.bindings.postgres_changes) === null || n === void 0 || n.filter((f) => {
      var p, g, m;
      return ((p = f.filter) === null || p === void 0 ? void 0 : p.event) === "*" || ((m = (g = f.filter) === null || g === void 0 ? void 0 : g.event) === null || m === void 0 ? void 0 : m.toLocaleLowerCase()) === a;
    }).map((f) => f.callback(d, s)) : (i = this.bindings[a]) === null || i === void 0 || i.filter((f) => {
      var p, g, m, v, b, y;
      if (["broadcast", "presence", "postgres_changes"].includes(a)) if ("id" in f) {
        const k = f.id, $ = (p = f.filter) === null || p === void 0 ? void 0 : p.event;
        return k && ((g = t.ids) === null || g === void 0 ? void 0 : g.includes(k)) && ($ === "*" || ($ == null ? void 0 : $.toLocaleLowerCase()) === ((m = t.data) === null || m === void 0 ? void 0 : m.type.toLocaleLowerCase()));
      } else {
        const k = (b = (v = f == null ? void 0 : f.filter) === null || v === void 0 ? void 0 : v.event) === null || b === void 0 ? void 0 : b.toLocaleLowerCase();
        return k === "*" || k === ((y = t == null ? void 0 : t.event) === null || y === void 0 ? void 0 : y.toLocaleLowerCase());
      }
      else return f.type.toLocaleLowerCase() === a;
    }).map((f) => {
      if (typeof d == "object" && "ids" in d) {
        const p = d.data, { schema: g, table: m, commit_timestamp: v, type: b, errors: y } = p;
        d = Object.assign(Object.assign({}, { schema: g, table: m, commit_timestamp: v, eventType: b, new: {}, old: {}, errors: y }), this._getPayloadRecords(p));
      }
      f.callback(d, s);
    });
  }
  _isClosed() {
    return this.state === C.closed;
  }
  _isJoined() {
    return this.state === C.joined;
  }
  _isJoining() {
    return this.state === C.joining;
  }
  _isLeaving() {
    return this.state === C.leaving;
  }
  _replyEventName(e) {
    return `chan_reply_${e}`;
  }
  _on(e, t, s) {
    const n = e.toLocaleLowerCase(), i = { type: n, filter: t, callback: s };
    return this.bindings[n] ? this.bindings[n].push(i) : this.bindings[n] = [i], this;
  }
  _off(e, t) {
    const s = e.toLocaleLowerCase();
    return this.bindings[s] && (this.bindings[s] = this.bindings[s].filter((n) => {
      var i;
      return !(((i = n.type) === null || i === void 0 ? void 0 : i.toLocaleLowerCase()) === s && he.isEqual(n.filter, t));
    })), this;
  }
  static isEqual(e, t) {
    if (Object.keys(e).length !== Object.keys(t).length) return false;
    for (const s in e) if (e[s] !== t[s]) return false;
    return true;
  }
  static isFilterValueEqual(e, t) {
    return (e ?? void 0) === (t ?? void 0);
  }
  _rejoinUntilConnected() {
    this.rejoinTimer.scheduleTimeout(), this.socket.isConnected() && this._rejoin();
  }
  _onClose(e) {
    this._on(q.close, {}, e);
  }
  _onError(e) {
    this._on(q.error, {}, (t) => e(t));
  }
  _canPush() {
    return this.socket.isConnected() && this._isJoined();
  }
  _rejoin(e = this.timeout) {
    this._isLeaving() || (this.socket._leaveOpenTopic(this.topic), this.state = C.joining, this.joinPush.resend(e));
  }
  _getPayloadRecords(e) {
    const t = { new: {}, old: {} };
    return (e.type === "INSERT" || e.type === "UPDATE") && (t.new = gt(e.columns, e.record)), (e.type === "UPDATE" || e.type === "DELETE") && (t.old = gt(e.columns, e.old_record)), t;
  }
}
const Ne = () => {
}, Te = { HEARTBEAT_INTERVAL: 25e3, RECONNECT_DELAY: 10, HEARTBEAT_TIMEOUT_FALLBACK: 100 }, is = [1e3, 2e3, 5e3, 1e4], as = 1e4, os = `
  addEventListener("message", (e) => {
    if (e.data.event === "start") {
      setInterval(() => postMessage({ event: "keepAlive" }), e.data.interval);
    }
  });`;
class ls {
  constructor(e, t) {
    var s;
    if (this.accessTokenValue = null, this.apiKey = null, this._manuallySetToken = false, this.channels = new Array(), this.endPoint = "", this.httpEndpoint = "", this.headers = {}, this.params = {}, this.timeout = Fe, this.transport = null, this.heartbeatIntervalMs = Te.HEARTBEAT_INTERVAL, this.heartbeatTimer = void 0, this.pendingHeartbeatRef = null, this.heartbeatCallback = Ne, this.ref = 0, this.reconnectTimer = null, this.vsn = pt, this.logger = Ne, this.conn = null, this.sendBuffer = [], this.serializer = new Qr(), this.stateChangeCallbacks = { open: [], close: [], error: [], message: [] }, this.accessToken = null, this._connectionState = "disconnected", this._wasManualDisconnect = false, this._authPromise = null, this._resolveFetch = (n) => n ? (...i) => n(...i) : (...i) => fetch(...i), !(!((s = t == null ? void 0 : t.params) === null || s === void 0) && s.apikey)) throw new Error("API key is required to connect to Realtime");
    this.apiKey = t.params.apikey, this.endPoint = `${e}/${Ke.websocket}`, this.httpEndpoint = Wt(e), this._initializeOptions(t), this._setupReconnectionTimer(), this.fetch = this._resolveFetch(t == null ? void 0 : t.fetch);
  }
  connect() {
    if (!(this.isConnecting() || this.isDisconnecting() || this.conn !== null && this.isConnected())) {
      if (this._setConnectionState("connecting"), this.accessToken && !this._authPromise && this._setAuthSafely("connect"), this.transport) this.conn = new this.transport(this.endpointURL());
      else try {
        this.conn = Fr.createWebSocket(this.endpointURL());
      } catch (e) {
        this._setConnectionState("disconnected");
        const t = e.message;
        throw t.includes("Node.js") ? new Error(`${t}

To use Realtime in Node.js, you need to provide a WebSocket implementation:

Option 1: Use Node.js 22+ which has native WebSocket support
Option 2: Install and provide the "ws" package:

  npm install ws

  import ws from "ws"
  const client = new RealtimeClient(url, {
    ...options,
    transport: ws
  })`) : new Error(`WebSocket not available: ${t}`);
      }
      this._setupConnectionHandlers();
    }
  }
  endpointURL() {
    return this._appendParams(this.endPoint, Object.assign({}, this.params, { vsn: this.vsn }));
  }
  disconnect(e, t) {
    if (!this.isDisconnecting()) if (this._setConnectionState("disconnecting", true), this.conn) {
      const s = setTimeout(() => {
        this._setConnectionState("disconnected");
      }, 100);
      this.conn.onclose = () => {
        clearTimeout(s), this._setConnectionState("disconnected");
      }, typeof this.conn.close == "function" && (e ? this.conn.close(e, t ?? "") : this.conn.close()), this._teardownConnection();
    } else this._setConnectionState("disconnected");
  }
  getChannels() {
    return this.channels;
  }
  async removeChannel(e) {
    const t = await e.unsubscribe();
    return this.channels.length === 0 && this.disconnect(), t;
  }
  async removeAllChannels() {
    const e = await Promise.all(this.channels.map((t) => t.unsubscribe()));
    return this.channels = [], this.disconnect(), e;
  }
  log(e, t, s) {
    this.logger(e, t, s);
  }
  connectionState() {
    switch (this.conn && this.conn.readyState) {
      case K.connecting:
        return Z.Connecting;
      case K.open:
        return Z.Open;
      case K.closing:
        return Z.Closing;
      default:
        return Z.Closed;
    }
  }
  isConnected() {
    return this.connectionState() === Z.Open;
  }
  isConnecting() {
    return this._connectionState === "connecting";
  }
  isDisconnecting() {
    return this._connectionState === "disconnecting";
  }
  channel(e, t = { config: {} }) {
    const s = `realtime:${e}`, n = this.getChannels().find((i) => i.topic === s);
    if (n) return n;
    {
      const i = new he(`realtime:${e}`, t, this);
      return this.channels.push(i), i;
    }
  }
  push(e) {
    const { topic: t, event: s, payload: n, ref: i } = e, a = () => {
      this.encode(e, (o) => {
        var l;
        (l = this.conn) === null || l === void 0 || l.send(o);
      });
    };
    this.log("push", `${t} ${s} (${i})`, n), this.isConnected() ? a() : this.sendBuffer.push(a);
  }
  async setAuth(e = null) {
    this._authPromise = this._performAuth(e);
    try {
      await this._authPromise;
    } finally {
      this._authPromise = null;
    }
  }
  _isManualToken() {
    return this._manuallySetToken;
  }
  async sendHeartbeat() {
    var e;
    if (!this.isConnected()) {
      try {
        this.heartbeatCallback("disconnected");
      } catch (t) {
        this.log("error", "error in heartbeat callback", t);
      }
      return;
    }
    if (this.pendingHeartbeatRef) {
      this.pendingHeartbeatRef = null, this.log("transport", "heartbeat timeout. Attempting to re-establish connection");
      try {
        this.heartbeatCallback("timeout");
      } catch (t) {
        this.log("error", "error in heartbeat callback", t);
      }
      this._wasManualDisconnect = false, (e = this.conn) === null || e === void 0 || e.close(Yr, "heartbeat timeout"), setTimeout(() => {
        var t;
        this.isConnected() || (t = this.reconnectTimer) === null || t === void 0 || t.scheduleTimeout();
      }, Te.HEARTBEAT_TIMEOUT_FALLBACK);
      return;
    }
    this.pendingHeartbeatRef = this._makeRef(), this.push({ topic: "phoenix", event: "heartbeat", payload: {}, ref: this.pendingHeartbeatRef });
    try {
      this.heartbeatCallback("sent");
    } catch (t) {
      this.log("error", "error in heartbeat callback", t);
    }
    this._setAuthSafely("heartbeat");
  }
  onHeartbeat(e) {
    this.heartbeatCallback = e;
  }
  flushSendBuffer() {
    this.isConnected() && this.sendBuffer.length > 0 && (this.sendBuffer.forEach((e) => e()), this.sendBuffer = []);
  }
  _makeRef() {
    let e = this.ref + 1;
    return e === this.ref ? this.ref = 0 : this.ref = e, this.ref.toString();
  }
  _leaveOpenTopic(e) {
    let t = this.channels.find((s) => s.topic === e && (s._isJoined() || s._isJoining()));
    t && (this.log("transport", `leaving duplicate topic "${e}"`), t.unsubscribe());
  }
  _remove(e) {
    this.channels = this.channels.filter((t) => t.topic !== e.topic);
  }
  _onConnMessage(e) {
    this.decode(e.data, (t) => {
      if (t.topic === "phoenix" && t.event === "phx_reply") try {
        this.heartbeatCallback(t.payload.status === "ok" ? "ok" : "error");
      } catch (c) {
        this.log("error", "error in heartbeat callback", c);
      }
      t.ref && t.ref === this.pendingHeartbeatRef && (this.pendingHeartbeatRef = null);
      const { topic: s, event: n, payload: i, ref: a } = t, o = a ? `(${a})` : "", l = i.status || "";
      this.log("receive", `${l} ${s} ${n} ${o}`.trim(), i), this.channels.filter((c) => c._isMember(s)).forEach((c) => c._trigger(n, i, a)), this._triggerStateCallbacks("message", t);
    });
  }
  _clearTimer(e) {
    var t;
    e === "heartbeat" && this.heartbeatTimer ? (clearInterval(this.heartbeatTimer), this.heartbeatTimer = void 0) : e === "reconnect" && ((t = this.reconnectTimer) === null || t === void 0 || t.reset());
  }
  _clearAllTimers() {
    this._clearTimer("heartbeat"), this._clearTimer("reconnect");
  }
  _setupConnectionHandlers() {
    this.conn && ("binaryType" in this.conn && (this.conn.binaryType = "arraybuffer"), this.conn.onopen = () => this._onConnOpen(), this.conn.onerror = (e) => this._onConnError(e), this.conn.onmessage = (e) => this._onConnMessage(e), this.conn.onclose = (e) => this._onConnClose(e), this.conn.readyState === K.open && this._onConnOpen());
  }
  _teardownConnection() {
    if (this.conn) {
      if (this.conn.readyState === K.open || this.conn.readyState === K.connecting) try {
        this.conn.close();
      } catch (e) {
        this.log("error", "Error closing connection", e);
      }
      this.conn.onopen = null, this.conn.onerror = null, this.conn.onmessage = null, this.conn.onclose = null, this.conn = null;
    }
    this._clearAllTimers(), this._terminateWorker(), this.channels.forEach((e) => e.teardown());
  }
  _onConnOpen() {
    this._setConnectionState("connected"), this.log("transport", `connected to ${this.endpointURL()}`), (this._authPromise || (this.accessToken && !this.accessTokenValue ? this.setAuth() : Promise.resolve())).then(() => {
      this.flushSendBuffer();
    }).catch((t) => {
      this.log("error", "error waiting for auth on connect", t), this.flushSendBuffer();
    }), this._clearTimer("reconnect"), this.worker ? this.workerRef || this._startWorkerHeartbeat() : this._startHeartbeat(), this._triggerStateCallbacks("open");
  }
  _startHeartbeat() {
    this.heartbeatTimer && clearInterval(this.heartbeatTimer), this.heartbeatTimer = setInterval(() => this.sendHeartbeat(), this.heartbeatIntervalMs);
  }
  _startWorkerHeartbeat() {
    this.workerUrl ? this.log("worker", `starting worker for from ${this.workerUrl}`) : this.log("worker", "starting default worker");
    const e = this._workerObjectUrl(this.workerUrl);
    this.workerRef = new Worker(e), this.workerRef.onerror = (t) => {
      this.log("worker", "worker error", t.message), this._terminateWorker();
    }, this.workerRef.onmessage = (t) => {
      t.data.event === "keepAlive" && this.sendHeartbeat();
    }, this.workerRef.postMessage({ event: "start", interval: this.heartbeatIntervalMs });
  }
  _terminateWorker() {
    this.workerRef && (this.log("worker", "terminating worker"), this.workerRef.terminate(), this.workerRef = void 0);
  }
  _onConnClose(e) {
    var t;
    this._setConnectionState("disconnected"), this.log("transport", "close", e), this._triggerChanError(), this._clearTimer("heartbeat"), this._wasManualDisconnect || (t = this.reconnectTimer) === null || t === void 0 || t.scheduleTimeout(), this._triggerStateCallbacks("close", e);
  }
  _onConnError(e) {
    this._setConnectionState("disconnected"), this.log("transport", `${e}`), this._triggerChanError(), this._triggerStateCallbacks("error", e);
  }
  _triggerChanError() {
    this.channels.forEach((e) => e._trigger(q.error));
  }
  _appendParams(e, t) {
    if (Object.keys(t).length === 0) return e;
    const s = e.match(/\?/) ? "&" : "?", n = new URLSearchParams(t);
    return `${e}${s}${n}`;
  }
  _workerObjectUrl(e) {
    let t;
    if (e) t = e;
    else {
      const s = new Blob([os], { type: "application/javascript" });
      t = URL.createObjectURL(s);
    }
    return t;
  }
  _setConnectionState(e, t = false) {
    this._connectionState = e, e === "connecting" ? this._wasManualDisconnect = false : e === "disconnecting" && (this._wasManualDisconnect = t);
  }
  async _performAuth(e = null) {
    let t, s = false;
    if (e) t = e, s = true;
    else if (this.accessToken) try {
      t = await this.accessToken();
    } catch (n) {
      this.log("error", "Error fetching access token from callback", n), t = this.accessTokenValue;
    }
    else t = this.accessTokenValue;
    s ? this._manuallySetToken = true : this.accessToken && (this._manuallySetToken = false), this.accessTokenValue != t && (this.accessTokenValue = t, this.channels.forEach((n) => {
      const i = { access_token: t, version: Gr };
      t && n.updateJoinPayload(i), n.joinedOnce && n._isJoined() && n._push(q.access_token, { access_token: t });
    }));
  }
  async _waitForAuthIfNeeded() {
    this._authPromise && await this._authPromise;
  }
  _setAuthSafely(e = "general") {
    this._isManualToken() || this.setAuth().catch((t) => {
      this.log("error", `Error setting auth in ${e}`, t);
    });
  }
  _triggerStateCallbacks(e, t) {
    try {
      this.stateChangeCallbacks[e].forEach((s) => {
        try {
          s(t);
        } catch (n) {
          this.log("error", `error in ${e} callback`, n);
        }
      });
    } catch (s) {
      this.log("error", `error triggering ${e} callbacks`, s);
    }
  }
  _setupReconnectionTimer() {
    this.reconnectTimer = new qt(async () => {
      setTimeout(async () => {
        await this._waitForAuthIfNeeded(), this.isConnected() || this.connect();
      }, Te.RECONNECT_DELAY);
    }, this.reconnectAfterMs);
  }
  _initializeOptions(e) {
    var t, s, n, i, a, o, l, c, u, h, d, f;
    switch (this.transport = (t = e == null ? void 0 : e.transport) !== null && t !== void 0 ? t : null, this.timeout = (s = e == null ? void 0 : e.timeout) !== null && s !== void 0 ? s : Fe, this.heartbeatIntervalMs = (n = e == null ? void 0 : e.heartbeatIntervalMs) !== null && n !== void 0 ? n : Te.HEARTBEAT_INTERVAL, this.worker = (i = e == null ? void 0 : e.worker) !== null && i !== void 0 ? i : false, this.accessToken = (a = e == null ? void 0 : e.accessToken) !== null && a !== void 0 ? a : null, this.heartbeatCallback = (o = e == null ? void 0 : e.heartbeatCallback) !== null && o !== void 0 ? o : Ne, this.vsn = (l = e == null ? void 0 : e.vsn) !== null && l !== void 0 ? l : pt, (e == null ? void 0 : e.params) && (this.params = e.params), (e == null ? void 0 : e.logger) && (this.logger = e.logger), ((e == null ? void 0 : e.logLevel) || (e == null ? void 0 : e.log_level)) && (this.logLevel = e.logLevel || e.log_level, this.params = Object.assign(Object.assign({}, this.params), { log_level: this.logLevel })), this.reconnectAfterMs = (c = e == null ? void 0 : e.reconnectAfterMs) !== null && c !== void 0 ? c : ((p) => is[p - 1] || as), this.vsn) {
      case Mt:
        this.encode = (u = e == null ? void 0 : e.encode) !== null && u !== void 0 ? u : ((p, g) => g(JSON.stringify(p))), this.decode = (h = e == null ? void 0 : e.decode) !== null && h !== void 0 ? h : ((p, g) => g(JSON.parse(p)));
        break;
      case Jr:
        this.encode = (d = e == null ? void 0 : e.encode) !== null && d !== void 0 ? d : this.serializer.encode.bind(this.serializer), this.decode = (f = e == null ? void 0 : e.decode) !== null && f !== void 0 ? f : this.serializer.decode.bind(this.serializer);
        break;
      default:
        throw new Error(`Unsupported serializer version: ${this.vsn}`);
    }
    if (this.worker) {
      if (typeof window < "u" && !window.Worker) throw new Error("Web Worker is not supported");
      this.workerUrl = e == null ? void 0 : e.workerUrl;
    }
  }
}
var ye = class extends Error {
  constructor(r, e) {
    var _a2;
    super(r), this.name = "IcebergError", this.status = e.status, this.icebergType = e.icebergType, this.icebergCode = e.icebergCode, this.details = e.details, this.isCommitStateUnknown = e.icebergType === "CommitStateUnknownException" || [500, 502, 504].includes(e.status) && ((_a2 = e.icebergType) == null ? void 0 : _a2.includes("CommitState")) === true;
  }
  isNotFound() {
    return this.status === 404;
  }
  isConflict() {
    return this.status === 409;
  }
  isAuthenticationTimeout() {
    return this.status === 419;
  }
};
function cs(r, e, t) {
  const s = new URL(e, r);
  if (t) for (const [n, i] of Object.entries(t)) i !== void 0 && s.searchParams.set(n, i);
  return s.toString();
}
async function us(r) {
  return !r || r.type === "none" ? {} : r.type === "bearer" ? { Authorization: `Bearer ${r.token}` } : r.type === "header" ? { [r.name]: r.value } : r.type === "custom" ? await r.getHeaders() : {};
}
function ds(r) {
  const e = r.fetchImpl ?? globalThis.fetch;
  return { async request({ method: t, path: s, query: n, body: i, headers: a }) {
    const o = cs(r.baseUrl, s, n), l = await us(r.auth), c = await e(o, { method: t, headers: { ...i ? { "Content-Type": "application/json" } : {}, ...l, ...a }, body: i ? JSON.stringify(i) : void 0 }), u = await c.text(), h = (c.headers.get("content-type") || "").includes("application/json"), d = h && u ? JSON.parse(u) : u;
    if (!c.ok) {
      const f = h ? d : void 0, p = f == null ? void 0 : f.error;
      throw new ye((p == null ? void 0 : p.message) ?? `Request failed with status ${c.status}`, { status: c.status, icebergType: p == null ? void 0 : p.type, icebergCode: p == null ? void 0 : p.code, details: f });
    }
    return { status: c.status, headers: c.headers, data: d };
  } };
}
function Ie(r) {
  return r.join("");
}
var hs = class {
  constructor(r, e = "") {
    this.client = r, this.prefix = e;
  }
  async listNamespaces(r) {
    const e = r ? { parent: Ie(r.namespace) } : void 0;
    return (await this.client.request({ method: "GET", path: `${this.prefix}/namespaces`, query: e })).data.namespaces.map((s) => ({ namespace: s }));
  }
  async createNamespace(r, e) {
    const t = { namespace: r.namespace, properties: e == null ? void 0 : e.properties };
    return (await this.client.request({ method: "POST", path: `${this.prefix}/namespaces`, body: t })).data;
  }
  async dropNamespace(r) {
    await this.client.request({ method: "DELETE", path: `${this.prefix}/namespaces/${Ie(r.namespace)}` });
  }
  async loadNamespaceMetadata(r) {
    return { properties: (await this.client.request({ method: "GET", path: `${this.prefix}/namespaces/${Ie(r.namespace)}` })).data.properties };
  }
  async namespaceExists(r) {
    try {
      return await this.client.request({ method: "HEAD", path: `${this.prefix}/namespaces/${Ie(r.namespace)}` }), true;
    } catch (e) {
      if (e instanceof ye && e.status === 404) return false;
      throw e;
    }
  }
  async createNamespaceIfNotExists(r, e) {
    try {
      return await this.createNamespace(r, e);
    } catch (t) {
      if (t instanceof ye && t.status === 409) return;
      throw t;
    }
  }
};
function se(r) {
  return r.join("");
}
var fs = class {
  constructor(r, e = "", t) {
    this.client = r, this.prefix = e, this.accessDelegation = t;
  }
  async listTables(r) {
    return (await this.client.request({ method: "GET", path: `${this.prefix}/namespaces/${se(r.namespace)}/tables` })).data.identifiers;
  }
  async createTable(r, e) {
    const t = {};
    return this.accessDelegation && (t["X-Iceberg-Access-Delegation"] = this.accessDelegation), (await this.client.request({ method: "POST", path: `${this.prefix}/namespaces/${se(r.namespace)}/tables`, body: e, headers: t })).data.metadata;
  }
  async updateTable(r, e) {
    const t = await this.client.request({ method: "POST", path: `${this.prefix}/namespaces/${se(r.namespace)}/tables/${r.name}`, body: e });
    return { "metadata-location": t.data["metadata-location"], metadata: t.data.metadata };
  }
  async dropTable(r, e) {
    await this.client.request({ method: "DELETE", path: `${this.prefix}/namespaces/${se(r.namespace)}/tables/${r.name}`, query: { purgeRequested: String((e == null ? void 0 : e.purge) ?? false) } });
  }
  async loadTable(r) {
    const e = {};
    return this.accessDelegation && (e["X-Iceberg-Access-Delegation"] = this.accessDelegation), (await this.client.request({ method: "GET", path: `${this.prefix}/namespaces/${se(r.namespace)}/tables/${r.name}`, headers: e })).data.metadata;
  }
  async tableExists(r) {
    const e = {};
    this.accessDelegation && (e["X-Iceberg-Access-Delegation"] = this.accessDelegation);
    try {
      return await this.client.request({ method: "HEAD", path: `${this.prefix}/namespaces/${se(r.namespace)}/tables/${r.name}`, headers: e }), true;
    } catch (t) {
      if (t instanceof ye && t.status === 404) return false;
      throw t;
    }
  }
  async createTableIfNotExists(r, e) {
    try {
      return await this.createTable(r, e);
    } catch (t) {
      if (t instanceof ye && t.status === 409) return await this.loadTable({ namespace: r.namespace, name: e.name });
      throw t;
    }
  }
}, ps = class {
  constructor(r) {
    var _a2;
    let e = "v1";
    r.catalogName && (e += `/${r.catalogName}`);
    const t = r.baseUrl.endsWith("/") ? r.baseUrl : `${r.baseUrl}/`;
    this.client = ds({ baseUrl: t, auth: r.auth, fetchImpl: r.fetch }), this.accessDelegation = (_a2 = r.accessDelegation) == null ? void 0 : _a2.join(","), this.namespaceOps = new hs(this.client, e), this.tableOps = new fs(this.client, e, this.accessDelegation);
  }
  async listNamespaces(r) {
    return this.namespaceOps.listNamespaces(r);
  }
  async createNamespace(r, e) {
    return this.namespaceOps.createNamespace(r, e);
  }
  async dropNamespace(r) {
    await this.namespaceOps.dropNamespace(r);
  }
  async loadNamespaceMetadata(r) {
    return this.namespaceOps.loadNamespaceMetadata(r);
  }
  async listTables(r) {
    return this.tableOps.listTables(r);
  }
  async createTable(r, e) {
    return this.tableOps.createTable(r, e);
  }
  async updateTable(r, e) {
    return this.tableOps.updateTable(r, e);
  }
  async dropTable(r, e) {
    await this.tableOps.dropTable(r, e);
  }
  async loadTable(r) {
    return this.tableOps.loadTable(r);
  }
  async namespaceExists(r) {
    return this.namespaceOps.namespaceExists(r);
  }
  async tableExists(r) {
    return this.tableOps.tableExists(r);
  }
  async createNamespaceIfNotExists(r, e) {
    return this.namespaceOps.createNamespaceIfNotExists(r, e);
  }
  async createTableIfNotExists(r, e) {
    return this.tableOps.createTableIfNotExists(r, e);
  }
}, je = class extends Error {
  constructor(r) {
    super(r), this.__isStorageError = true, this.name = "StorageError";
  }
};
function x(r) {
  return typeof r == "object" && r !== null && "__isStorageError" in r;
}
var gs = class extends je {
  constructor(r, e, t) {
    super(r), this.name = "StorageApiError", this.status = e, this.statusCode = t;
  }
  toJSON() {
    return { name: this.name, message: this.message, status: this.status, statusCode: this.statusCode };
  }
}, Je = class extends je {
  constructor(r, e) {
    super(r), this.name = "StorageUnknownError", this.originalError = e;
  }
};
const st = (r) => r ? (...e) => r(...e) : (...e) => fetch(...e), ms = () => Response, Ye = (r) => {
  if (Array.isArray(r)) return r.map((t) => Ye(t));
  if (typeof r == "function" || r !== Object(r)) return r;
  const e = {};
  return Object.entries(r).forEach(([t, s]) => {
    const n = t.replace(/([-_][a-z])/gi, (i) => i.toUpperCase().replace(/[-_]/g, ""));
    e[n] = Ye(s);
  }), e;
}, ys = (r) => {
  if (typeof r != "object" || r === null) return false;
  const e = Object.getPrototypeOf(r);
  return (e === null || e === Object.prototype || Object.getPrototypeOf(e) === null) && !(Symbol.toStringTag in r) && !(Symbol.iterator in r);
}, vs = (r) => !r || typeof r != "string" || r.length === 0 || r.length > 100 || r.trim() !== r || r.includes("/") || r.includes("\\") ? false : /^[\w!.\*'() &$@=;:+,?-]+$/.test(r);
function ve(r) {
  "@babel/helpers - typeof";
  return ve = typeof Symbol == "function" && typeof Symbol.iterator == "symbol" ? function(e) {
    return typeof e;
  } : function(e) {
    return e && typeof Symbol == "function" && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e;
  }, ve(r);
}
function ws(r, e) {
  if (ve(r) != "object" || !r) return r;
  var t = r[Symbol.toPrimitive];
  if (t !== void 0) {
    var s = t.call(r, e);
    if (ve(s) != "object") return s;
    throw new TypeError("@@toPrimitive must return a primitive value.");
  }
  return (e === "string" ? String : Number)(r);
}
function bs(r) {
  var e = ws(r, "string");
  return ve(e) == "symbol" ? e : e + "";
}
function _s(r, e, t) {
  return (e = bs(e)) in r ? Object.defineProperty(r, e, { value: t, enumerable: true, configurable: true, writable: true }) : r[e] = t, r;
}
function vt(r, e) {
  var t = Object.keys(r);
  if (Object.getOwnPropertySymbols) {
    var s = Object.getOwnPropertySymbols(r);
    e && (s = s.filter(function(n) {
      return Object.getOwnPropertyDescriptor(r, n).enumerable;
    })), t.push.apply(t, s);
  }
  return t;
}
function E(r) {
  for (var e = 1; e < arguments.length; e++) {
    var t = arguments[e] != null ? arguments[e] : {};
    e % 2 ? vt(Object(t), true).forEach(function(s) {
      _s(r, s, t[s]);
    }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(r, Object.getOwnPropertyDescriptors(t)) : vt(Object(t)).forEach(function(s) {
      Object.defineProperty(r, s, Object.getOwnPropertyDescriptor(t, s));
    });
  }
  return r;
}
const De = (r) => {
  var e;
  return r.msg || r.message || r.error_description || (typeof r.error == "string" ? r.error : (e = r.error) === null || e === void 0 ? void 0 : e.message) || JSON.stringify(r);
}, Es = async (r, e, t) => {
  r instanceof await ms() && !(t == null ? void 0 : t.noResolveJson) ? r.json().then((s) => {
    const n = r.status || 500, i = (s == null ? void 0 : s.statusCode) || n + "";
    e(new gs(De(s), n, i));
  }).catch((s) => {
    e(new Je(De(s), s));
  }) : e(new Je(De(r), r));
}, Ss = (r, e, t, s) => {
  const n = { method: r, headers: (e == null ? void 0 : e.headers) || {} };
  return r === "GET" || !s ? n : (ys(s) ? (n.headers = E({ "Content-Type": "application/json" }, e == null ? void 0 : e.headers), n.body = JSON.stringify(s)) : n.body = s, (e == null ? void 0 : e.duplex) && (n.duplex = e.duplex), E(E({}, n), t));
};
async function Se(r, e, t, s, n, i) {
  return new Promise((a, o) => {
    r(t, Ss(e, s, n, i)).then((l) => {
      if (!l.ok) throw l;
      return (s == null ? void 0 : s.noResolveJson) ? l : l.json();
    }).then((l) => a(l)).catch((l) => Es(l, o, s));
  });
}
async function we(r, e, t, s) {
  return Se(r, "GET", e, t, s);
}
async function M(r, e, t, s, n) {
  return Se(r, "POST", e, s, n, t);
}
async function Xe(r, e, t, s, n) {
  return Se(r, "PUT", e, s, n, t);
}
async function ks(r, e, t, s) {
  return Se(r, "HEAD", e, E(E({}, t), {}, { noResolveJson: true }), s);
}
async function nt(r, e, t, s, n) {
  return Se(r, "DELETE", e, s, n, t);
}
var Ts = class {
  constructor(r, e) {
    this.downloadFn = r, this.shouldThrowOnError = e;
  }
  then(r, e) {
    return this.execute().then(r, e);
  }
  async execute() {
    var r = this;
    try {
      return { data: (await r.downloadFn()).body, error: null };
    } catch (e) {
      if (r.shouldThrowOnError) throw e;
      if (x(e)) return { data: null, error: e };
      throw e;
    }
  }
};
let zt;
zt = Symbol.toStringTag;
var Is = class {
  constructor(r, e) {
    this.downloadFn = r, this.shouldThrowOnError = e, this[zt] = "BlobDownloadBuilder", this.promise = null;
  }
  asStream() {
    return new Ts(this.downloadFn, this.shouldThrowOnError);
  }
  then(r, e) {
    return this.getPromise().then(r, e);
  }
  catch(r) {
    return this.getPromise().catch(r);
  }
  finally(r) {
    return this.getPromise().finally(r);
  }
  getPromise() {
    return this.promise || (this.promise = this.execute()), this.promise;
  }
  async execute() {
    var r = this;
    try {
      return { data: await (await r.downloadFn()).blob(), error: null };
    } catch (e) {
      if (r.shouldThrowOnError) throw e;
      if (x(e)) return { data: null, error: e };
      throw e;
    }
  }
};
const xs = { limit: 100, offset: 0, sortBy: { column: "name", order: "asc" } }, wt = { cacheControl: "3600", contentType: "text/plain;charset=UTF-8", upsert: false };
var Os = class {
  constructor(r, e = {}, t, s) {
    this.shouldThrowOnError = false, this.url = r, this.headers = e, this.bucketId = t, this.fetch = st(s);
  }
  throwOnError() {
    return this.shouldThrowOnError = true, this;
  }
  async uploadOrUpdate(r, e, t, s) {
    var n = this;
    try {
      let i;
      const a = E(E({}, wt), s);
      let o = E(E({}, n.headers), r === "POST" && { "x-upsert": String(a.upsert) });
      const l = a.metadata;
      typeof Blob < "u" && t instanceof Blob ? (i = new FormData(), i.append("cacheControl", a.cacheControl), l && i.append("metadata", n.encodeMetadata(l)), i.append("", t)) : typeof FormData < "u" && t instanceof FormData ? (i = t, i.has("cacheControl") || i.append("cacheControl", a.cacheControl), l && !i.has("metadata") && i.append("metadata", n.encodeMetadata(l))) : (i = t, o["cache-control"] = `max-age=${a.cacheControl}`, o["content-type"] = a.contentType, l && (o["x-metadata"] = n.toBase64(n.encodeMetadata(l))), (typeof ReadableStream < "u" && i instanceof ReadableStream || i && typeof i == "object" && "pipe" in i && typeof i.pipe == "function") && !a.duplex && (a.duplex = "half")), (s == null ? void 0 : s.headers) && (o = E(E({}, o), s.headers));
      const c = n._removeEmptyFolders(e), u = n._getFinalPath(c), h = await (r == "PUT" ? Xe : M)(n.fetch, `${n.url}/object/${u}`, i, E({ headers: o }, (a == null ? void 0 : a.duplex) ? { duplex: a.duplex } : {}));
      return { data: { path: c, id: h.Id, fullPath: h.Key }, error: null };
    } catch (i) {
      if (n.shouldThrowOnError) throw i;
      if (x(i)) return { data: null, error: i };
      throw i;
    }
  }
  async upload(r, e, t) {
    return this.uploadOrUpdate("POST", r, e, t);
  }
  async uploadToSignedUrl(r, e, t, s) {
    var n = this;
    const i = n._removeEmptyFolders(r), a = n._getFinalPath(i), o = new URL(n.url + `/object/upload/sign/${a}`);
    o.searchParams.set("token", e);
    try {
      let l;
      const c = E({ upsert: wt.upsert }, s), u = E(E({}, n.headers), { "x-upsert": String(c.upsert) });
      return typeof Blob < "u" && t instanceof Blob ? (l = new FormData(), l.append("cacheControl", c.cacheControl), l.append("", t)) : typeof FormData < "u" && t instanceof FormData ? (l = t, l.append("cacheControl", c.cacheControl)) : (l = t, u["cache-control"] = `max-age=${c.cacheControl}`, u["content-type"] = c.contentType), { data: { path: i, fullPath: (await Xe(n.fetch, o.toString(), l, { headers: u })).Key }, error: null };
    } catch (l) {
      if (n.shouldThrowOnError) throw l;
      if (x(l)) return { data: null, error: l };
      throw l;
    }
  }
  async createSignedUploadUrl(r, e) {
    var t = this;
    try {
      let s = t._getFinalPath(r);
      const n = E({}, t.headers);
      (e == null ? void 0 : e.upsert) && (n["x-upsert"] = "true");
      const i = await M(t.fetch, `${t.url}/object/upload/sign/${s}`, {}, { headers: n }), a = new URL(t.url + i.url), o = a.searchParams.get("token");
      if (!o) throw new je("No token returned by API");
      return { data: { signedUrl: a.toString(), path: r, token: o }, error: null };
    } catch (s) {
      if (t.shouldThrowOnError) throw s;
      if (x(s)) return { data: null, error: s };
      throw s;
    }
  }
  async update(r, e, t) {
    return this.uploadOrUpdate("PUT", r, e, t);
  }
  async move(r, e, t) {
    var s = this;
    try {
      return { data: await M(s.fetch, `${s.url}/object/move`, { bucketId: s.bucketId, sourceKey: r, destinationKey: e, destinationBucket: t == null ? void 0 : t.destinationBucket }, { headers: s.headers }), error: null };
    } catch (n) {
      if (s.shouldThrowOnError) throw n;
      if (x(n)) return { data: null, error: n };
      throw n;
    }
  }
  async copy(r, e, t) {
    var s = this;
    try {
      return { data: { path: (await M(s.fetch, `${s.url}/object/copy`, { bucketId: s.bucketId, sourceKey: r, destinationKey: e, destinationBucket: t == null ? void 0 : t.destinationBucket }, { headers: s.headers })).Key }, error: null };
    } catch (n) {
      if (s.shouldThrowOnError) throw n;
      if (x(n)) return { data: null, error: n };
      throw n;
    }
  }
  async createSignedUrl(r, e, t) {
    var s = this;
    try {
      let n = s._getFinalPath(r), i = await M(s.fetch, `${s.url}/object/sign/${n}`, E({ expiresIn: e }, (t == null ? void 0 : t.transform) ? { transform: t.transform } : {}), { headers: s.headers });
      const a = (t == null ? void 0 : t.download) ? `&download=${t.download === true ? "" : t.download}` : "";
      return i = { signedUrl: encodeURI(`${s.url}${i.signedURL}${a}`) }, { data: i, error: null };
    } catch (n) {
      if (s.shouldThrowOnError) throw n;
      if (x(n)) return { data: null, error: n };
      throw n;
    }
  }
  async createSignedUrls(r, e, t) {
    var s = this;
    try {
      const n = await M(s.fetch, `${s.url}/object/sign/${s.bucketId}`, { expiresIn: e, paths: r }, { headers: s.headers }), i = (t == null ? void 0 : t.download) ? `&download=${t.download === true ? "" : t.download}` : "";
      return { data: n.map((a) => E(E({}, a), {}, { signedUrl: a.signedURL ? encodeURI(`${s.url}${a.signedURL}${i}`) : null })), error: null };
    } catch (n) {
      if (s.shouldThrowOnError) throw n;
      if (x(n)) return { data: null, error: n };
      throw n;
    }
  }
  download(r, e) {
    const t = typeof (e == null ? void 0 : e.transform) < "u" ? "render/image/authenticated" : "object", s = this.transformOptsToQueryString((e == null ? void 0 : e.transform) || {}), n = s ? `?${s}` : "", i = this._getFinalPath(r), a = () => we(this.fetch, `${this.url}/${t}/${i}${n}`, { headers: this.headers, noResolveJson: true });
    return new Is(a, this.shouldThrowOnError);
  }
  async info(r) {
    var e = this;
    const t = e._getFinalPath(r);
    try {
      return { data: Ye(await we(e.fetch, `${e.url}/object/info/${t}`, { headers: e.headers })), error: null };
    } catch (s) {
      if (e.shouldThrowOnError) throw s;
      if (x(s)) return { data: null, error: s };
      throw s;
    }
  }
  async exists(r) {
    var e = this;
    const t = e._getFinalPath(r);
    try {
      return await ks(e.fetch, `${e.url}/object/${t}`, { headers: e.headers }), { data: true, error: null };
    } catch (s) {
      if (e.shouldThrowOnError) throw s;
      if (x(s) && s instanceof Je) {
        const n = s.originalError;
        if ([400, 404].includes(n == null ? void 0 : n.status)) return { data: false, error: s };
      }
      throw s;
    }
  }
  getPublicUrl(r, e) {
    const t = this._getFinalPath(r), s = [], n = (e == null ? void 0 : e.download) ? `download=${e.download === true ? "" : e.download}` : "";
    n !== "" && s.push(n);
    const i = typeof (e == null ? void 0 : e.transform) < "u" ? "render/image" : "object", a = this.transformOptsToQueryString((e == null ? void 0 : e.transform) || {});
    a !== "" && s.push(a);
    let o = s.join("&");
    return o !== "" && (o = `?${o}`), { data: { publicUrl: encodeURI(`${this.url}/${i}/public/${t}${o}`) } };
  }
  async remove(r) {
    var e = this;
    try {
      return { data: await nt(e.fetch, `${e.url}/object/${e.bucketId}`, { prefixes: r }, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  async list(r, e, t) {
    var s = this;
    try {
      const n = E(E(E({}, xs), e), {}, { prefix: r || "" });
      return { data: await M(s.fetch, `${s.url}/object/list/${s.bucketId}`, n, { headers: s.headers }, t), error: null };
    } catch (n) {
      if (s.shouldThrowOnError) throw n;
      if (x(n)) return { data: null, error: n };
      throw n;
    }
  }
  async listV2(r, e) {
    var t = this;
    try {
      const s = E({}, r);
      return { data: await M(t.fetch, `${t.url}/object/list-v2/${t.bucketId}`, s, { headers: t.headers }, e), error: null };
    } catch (s) {
      if (t.shouldThrowOnError) throw s;
      if (x(s)) return { data: null, error: s };
      throw s;
    }
  }
  encodeMetadata(r) {
    return JSON.stringify(r);
  }
  toBase64(r) {
    return typeof Buffer < "u" ? Buffer.from(r).toString("base64") : btoa(r);
  }
  _getFinalPath(r) {
    return `${this.bucketId}/${r.replace(/^\/+/, "")}`;
  }
  _removeEmptyFolders(r) {
    return r.replace(/^\/|\/$/g, "").replace(/\/+/g, "/");
  }
  transformOptsToQueryString(r) {
    const e = [];
    return r.width && e.push(`width=${r.width}`), r.height && e.push(`height=${r.height}`), r.resize && e.push(`resize=${r.resize}`), r.format && e.push(`format=${r.format}`), r.quality && e.push(`quality=${r.quality}`), e.join("&");
  }
};
const Ht = "2.89.0", Ft = { "X-Client-Info": `storage-js/${Ht}` };
var As = class {
  constructor(r, e = {}, t, s) {
    this.shouldThrowOnError = false;
    const n = new URL(r);
    (s == null ? void 0 : s.useNewHostname) && /supabase\.(co|in|red)$/.test(n.hostname) && !n.hostname.includes("storage.supabase.") && (n.hostname = n.hostname.replace("supabase.", "storage.supabase.")), this.url = n.href.replace(/\/$/, ""), this.headers = E(E({}, Ft), e), this.fetch = st(t);
  }
  throwOnError() {
    return this.shouldThrowOnError = true, this;
  }
  async listBuckets(r) {
    var e = this;
    try {
      const t = e.listBucketOptionsToQueryString(r);
      return { data: await we(e.fetch, `${e.url}/bucket${t}`, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  async getBucket(r) {
    var e = this;
    try {
      return { data: await we(e.fetch, `${e.url}/bucket/${r}`, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  async createBucket(r, e = { public: false }) {
    var t = this;
    try {
      return { data: await M(t.fetch, `${t.url}/bucket`, { id: r, name: r, type: e.type, public: e.public, file_size_limit: e.fileSizeLimit, allowed_mime_types: e.allowedMimeTypes }, { headers: t.headers }), error: null };
    } catch (s) {
      if (t.shouldThrowOnError) throw s;
      if (x(s)) return { data: null, error: s };
      throw s;
    }
  }
  async updateBucket(r, e) {
    var t = this;
    try {
      return { data: await Xe(t.fetch, `${t.url}/bucket/${r}`, { id: r, name: r, public: e.public, file_size_limit: e.fileSizeLimit, allowed_mime_types: e.allowedMimeTypes }, { headers: t.headers }), error: null };
    } catch (s) {
      if (t.shouldThrowOnError) throw s;
      if (x(s)) return { data: null, error: s };
      throw s;
    }
  }
  async emptyBucket(r) {
    var e = this;
    try {
      return { data: await M(e.fetch, `${e.url}/bucket/${r}/empty`, {}, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  async deleteBucket(r) {
    var e = this;
    try {
      return { data: await nt(e.fetch, `${e.url}/bucket/${r}`, {}, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  listBucketOptionsToQueryString(r) {
    const e = {};
    return r && ("limit" in r && (e.limit = String(r.limit)), "offset" in r && (e.offset = String(r.offset)), r.search && (e.search = r.search), r.sortColumn && (e.sortColumn = r.sortColumn), r.sortOrder && (e.sortOrder = r.sortOrder)), Object.keys(e).length > 0 ? "?" + new URLSearchParams(e).toString() : "";
  }
}, Rs = class {
  constructor(r, e = {}, t) {
    this.shouldThrowOnError = false, this.url = r.replace(/\/$/, ""), this.headers = E(E({}, Ft), e), this.fetch = st(t);
  }
  throwOnError() {
    return this.shouldThrowOnError = true, this;
  }
  async createBucket(r) {
    var e = this;
    try {
      return { data: await M(e.fetch, `${e.url}/bucket`, { name: r }, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  async listBuckets(r) {
    var e = this;
    try {
      const t = new URLSearchParams();
      (r == null ? void 0 : r.limit) !== void 0 && t.set("limit", r.limit.toString()), (r == null ? void 0 : r.offset) !== void 0 && t.set("offset", r.offset.toString()), (r == null ? void 0 : r.sortColumn) && t.set("sortColumn", r.sortColumn), (r == null ? void 0 : r.sortOrder) && t.set("sortOrder", r.sortOrder), (r == null ? void 0 : r.search) && t.set("search", r.search);
      const s = t.toString(), n = s ? `${e.url}/bucket?${s}` : `${e.url}/bucket`;
      return { data: await we(e.fetch, n, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  async deleteBucket(r) {
    var e = this;
    try {
      return { data: await nt(e.fetch, `${e.url}/bucket/${r}`, {}, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (x(t)) return { data: null, error: t };
      throw t;
    }
  }
  from(r) {
    var e = this;
    if (!vs(r)) throw new je("Invalid bucket name: File, folder, and bucket names must follow AWS object key naming guidelines and should avoid the use of any other characters.");
    const t = new ps({ baseUrl: this.url, catalogName: r, auth: { type: "custom", getHeaders: async () => e.headers }, fetch: this.fetch }), s = this.shouldThrowOnError;
    return new Proxy(t, { get(n, i) {
      const a = n[i];
      return typeof a != "function" ? a : async (...o) => {
        try {
          return { data: await a.apply(n, o), error: null };
        } catch (l) {
          if (s) throw l;
          return { data: null, error: l };
        }
      };
    } });
  }
};
const it = { "X-Client-Info": `storage-js/${Ht}`, "Content-Type": "application/json" };
var Kt = class extends Error {
  constructor(r) {
    super(r), this.__isStorageVectorsError = true, this.name = "StorageVectorsError";
  }
};
function N(r) {
  return typeof r == "object" && r !== null && "__isStorageVectorsError" in r;
}
var Le = class extends Kt {
  constructor(r, e, t) {
    super(r), this.name = "StorageVectorsApiError", this.status = e, this.statusCode = t;
  }
  toJSON() {
    return { name: this.name, message: this.message, status: this.status, statusCode: this.statusCode };
  }
}, Cs = class extends Kt {
  constructor(r, e) {
    super(r), this.name = "StorageVectorsUnknownError", this.originalError = e;
  }
};
const at = (r) => r ? (...e) => r(...e) : (...e) => fetch(...e), $s = (r) => {
  if (typeof r != "object" || r === null) return false;
  const e = Object.getPrototypeOf(r);
  return (e === null || e === Object.prototype || Object.getPrototypeOf(e) === null) && !(Symbol.toStringTag in r) && !(Symbol.iterator in r);
}, bt = (r) => r.msg || r.message || r.error_description || r.error || JSON.stringify(r), Ps = async (r, e, t) => {
  if (r && typeof r == "object" && "status" in r && "ok" in r && typeof r.status == "number" && !(t == null ? void 0 : t.noResolveJson)) {
    const s = r.status || 500, n = r;
    if (typeof n.json == "function") n.json().then((i) => {
      const a = (i == null ? void 0 : i.statusCode) || (i == null ? void 0 : i.code) || s + "";
      e(new Le(bt(i), s, a));
    }).catch(() => {
      const i = s + "";
      e(new Le(n.statusText || `HTTP ${s} error`, s, i));
    });
    else {
      const i = s + "";
      e(new Le(n.statusText || `HTTP ${s} error`, s, i));
    }
  } else e(new Cs(bt(r), r));
}, js = (r, e, t, s) => {
  const n = { method: r, headers: (e == null ? void 0 : e.headers) || {} };
  return s ? ($s(s) ? (n.headers = E({ "Content-Type": "application/json" }, e == null ? void 0 : e.headers), n.body = JSON.stringify(s)) : n.body = s, E(E({}, n), t)) : n;
};
async function Us(r, e, t, s, n, i) {
  return new Promise((a, o) => {
    r(t, js(e, s, n, i)).then((l) => {
      if (!l.ok) throw l;
      if (s == null ? void 0 : s.noResolveJson) return l;
      const c = l.headers.get("content-type");
      return !c || !c.includes("application/json") ? {} : l.json();
    }).then((l) => a(l)).catch((l) => Ps(l, o, s));
  });
}
async function D(r, e, t, s, n) {
  return Us(r, "POST", e, s, n, t);
}
var Bs = class {
  constructor(r, e = {}, t) {
    this.shouldThrowOnError = false, this.url = r.replace(/\/$/, ""), this.headers = E(E({}, it), e), this.fetch = at(t);
  }
  throwOnError() {
    return this.shouldThrowOnError = true, this;
  }
  async createIndex(r) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/CreateIndex`, r, { headers: e.headers }) || {}, error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async getIndex(r, e) {
    var t = this;
    try {
      return { data: await D(t.fetch, `${t.url}/GetIndex`, { vectorBucketName: r, indexName: e }, { headers: t.headers }), error: null };
    } catch (s) {
      if (t.shouldThrowOnError) throw s;
      if (N(s)) return { data: null, error: s };
      throw s;
    }
  }
  async listIndexes(r) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/ListIndexes`, r, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async deleteIndex(r, e) {
    var t = this;
    try {
      return { data: await D(t.fetch, `${t.url}/DeleteIndex`, { vectorBucketName: r, indexName: e }, { headers: t.headers }) || {}, error: null };
    } catch (s) {
      if (t.shouldThrowOnError) throw s;
      if (N(s)) return { data: null, error: s };
      throw s;
    }
  }
}, Ns = class {
  constructor(r, e = {}, t) {
    this.shouldThrowOnError = false, this.url = r.replace(/\/$/, ""), this.headers = E(E({}, it), e), this.fetch = at(t);
  }
  throwOnError() {
    return this.shouldThrowOnError = true, this;
  }
  async putVectors(r) {
    var e = this;
    try {
      if (r.vectors.length < 1 || r.vectors.length > 500) throw new Error("Vector batch size must be between 1 and 500 items");
      return { data: await D(e.fetch, `${e.url}/PutVectors`, r, { headers: e.headers }) || {}, error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async getVectors(r) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/GetVectors`, r, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async listVectors(r) {
    var e = this;
    try {
      if (r.segmentCount !== void 0) {
        if (r.segmentCount < 1 || r.segmentCount > 16) throw new Error("segmentCount must be between 1 and 16");
        if (r.segmentIndex !== void 0 && (r.segmentIndex < 0 || r.segmentIndex >= r.segmentCount)) throw new Error(`segmentIndex must be between 0 and ${r.segmentCount - 1}`);
      }
      return { data: await D(e.fetch, `${e.url}/ListVectors`, r, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async queryVectors(r) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/QueryVectors`, r, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async deleteVectors(r) {
    var e = this;
    try {
      if (r.keys.length < 1 || r.keys.length > 500) throw new Error("Keys batch size must be between 1 and 500 items");
      return { data: await D(e.fetch, `${e.url}/DeleteVectors`, r, { headers: e.headers }) || {}, error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
}, Ds = class {
  constructor(r, e = {}, t) {
    this.shouldThrowOnError = false, this.url = r.replace(/\/$/, ""), this.headers = E(E({}, it), e), this.fetch = at(t);
  }
  throwOnError() {
    return this.shouldThrowOnError = true, this;
  }
  async createBucket(r) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/CreateVectorBucket`, { vectorBucketName: r }, { headers: e.headers }) || {}, error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async getBucket(r) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/GetVectorBucket`, { vectorBucketName: r }, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async listBuckets(r = {}) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/ListVectorBuckets`, r, { headers: e.headers }), error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
  async deleteBucket(r) {
    var e = this;
    try {
      return { data: await D(e.fetch, `${e.url}/DeleteVectorBucket`, { vectorBucketName: r }, { headers: e.headers }) || {}, error: null };
    } catch (t) {
      if (e.shouldThrowOnError) throw t;
      if (N(t)) return { data: null, error: t };
      throw t;
    }
  }
}, Ls = class extends Ds {
  constructor(r, e = {}) {
    super(r, e.headers || {}, e.fetch);
  }
  from(r) {
    return new Ms(this.url, this.headers, r, this.fetch);
  }
  async createBucket(r) {
    var e = () => super.createBucket, t = this;
    return e().call(t, r);
  }
  async getBucket(r) {
    var e = () => super.getBucket, t = this;
    return e().call(t, r);
  }
  async listBuckets(r = {}) {
    var e = () => super.listBuckets, t = this;
    return e().call(t, r);
  }
  async deleteBucket(r) {
    var e = () => super.deleteBucket, t = this;
    return e().call(t, r);
  }
}, Ms = class extends Bs {
  constructor(r, e, t, s) {
    super(r, e, s), this.vectorBucketName = t;
  }
  async createIndex(r) {
    var e = () => super.createIndex, t = this;
    return e().call(t, E(E({}, r), {}, { vectorBucketName: t.vectorBucketName }));
  }
  async listIndexes(r = {}) {
    var e = () => super.listIndexes, t = this;
    return e().call(t, E(E({}, r), {}, { vectorBucketName: t.vectorBucketName }));
  }
  async getIndex(r) {
    var e = () => super.getIndex, t = this;
    return e().call(t, t.vectorBucketName, r);
  }
  async deleteIndex(r) {
    var e = () => super.deleteIndex, t = this;
    return e().call(t, t.vectorBucketName, r);
  }
  index(r) {
    return new qs(this.url, this.headers, this.vectorBucketName, r, this.fetch);
  }
}, qs = class extends Ns {
  constructor(r, e, t, s, n) {
    super(r, e, n), this.vectorBucketName = t, this.indexName = s;
  }
  async putVectors(r) {
    var e = () => super.putVectors, t = this;
    return e().call(t, E(E({}, r), {}, { vectorBucketName: t.vectorBucketName, indexName: t.indexName }));
  }
  async getVectors(r) {
    var e = () => super.getVectors, t = this;
    return e().call(t, E(E({}, r), {}, { vectorBucketName: t.vectorBucketName, indexName: t.indexName }));
  }
  async listVectors(r = {}) {
    var e = () => super.listVectors, t = this;
    return e().call(t, E(E({}, r), {}, { vectorBucketName: t.vectorBucketName, indexName: t.indexName }));
  }
  async queryVectors(r) {
    var e = () => super.queryVectors, t = this;
    return e().call(t, E(E({}, r), {}, { vectorBucketName: t.vectorBucketName, indexName: t.indexName }));
  }
  async deleteVectors(r) {
    var e = () => super.deleteVectors, t = this;
    return e().call(t, E(E({}, r), {}, { vectorBucketName: t.vectorBucketName, indexName: t.indexName }));
  }
}, Vs = class extends As {
  constructor(r, e = {}, t, s) {
    super(r, e, t, s);
  }
  from(r) {
    return new Os(this.url, this.headers, r, this.fetch);
  }
  get vectors() {
    return new Ls(this.url + "/vector", { headers: this.headers, fetch: this.fetch });
  }
  get analytics() {
    return new Rs(this.url + "/iceberg", this.headers, this.fetch);
  }
};
const Gt = "2.89.0", ue = 30 * 1e3, Qe = 3, Me = Qe * ue, Ws = "http://localhost:9999", zs = "supabase.auth.token", Hs = { "X-Client-Info": `gotrue-js/${Gt}` }, Ze = "X-Supabase-Api-Version", Jt = { "2024-01-01": { timestamp: Date.parse("2024-01-01T00:00:00.0Z"), name: "2024-01-01" } }, Fs = /^([a-z0-9_-]{4})*($|[a-z0-9_-]{3}$|[a-z0-9_-]{2}$)$/i, Ks = 600 * 1e3;
class be extends Error {
  constructor(e, t, s) {
    super(e), this.__isAuthError = true, this.name = "AuthError", this.status = t, this.code = s;
  }
}
function w(r) {
  return typeof r == "object" && r !== null && "__isAuthError" in r;
}
class Gs extends be {
  constructor(e, t, s) {
    super(e, t, s), this.name = "AuthApiError", this.status = t, this.code = s;
  }
}
function Js(r) {
  return w(r) && r.name === "AuthApiError";
}
class ee extends be {
  constructor(e, t) {
    super(e), this.name = "AuthUnknownError", this.originalError = t;
  }
}
class H extends be {
  constructor(e, t, s, n) {
    super(e, s, n), this.name = t, this.status = s;
  }
}
class B extends H {
  constructor() {
    super("Auth session missing!", "AuthSessionMissingError", 400, void 0);
  }
}
function Ys(r) {
  return w(r) && r.name === "AuthSessionMissingError";
}
class ne extends H {
  constructor() {
    super("Auth session or user missing", "AuthInvalidTokenResponseError", 500, void 0);
  }
}
class xe extends H {
  constructor(e) {
    super(e, "AuthInvalidCredentialsError", 400, void 0);
  }
}
class Oe extends H {
  constructor(e, t = null) {
    super(e, "AuthImplicitGrantRedirectError", 500, void 0), this.details = null, this.details = t;
  }
  toJSON() {
    return { name: this.name, message: this.message, status: this.status, details: this.details };
  }
}
function Xs(r) {
  return w(r) && r.name === "AuthImplicitGrantRedirectError";
}
class _t extends H {
  constructor(e, t = null) {
    super(e, "AuthPKCEGrantCodeExchangeError", 500, void 0), this.details = null, this.details = t;
  }
  toJSON() {
    return { name: this.name, message: this.message, status: this.status, details: this.details };
  }
}
class Qs extends H {
  constructor() {
    super("PKCE code verifier not found in storage. This can happen if the auth flow was initiated in a different browser or device, or if the storage was cleared. For SSR frameworks (Next.js, SvelteKit, etc.), use @supabase/ssr on both the server and client to store the code verifier in cookies.", "AuthPKCECodeVerifierMissingError", 400, "pkce_code_verifier_not_found");
  }
}
class et extends H {
  constructor(e, t) {
    super(e, "AuthRetryableFetchError", t, void 0);
  }
}
function qe(r) {
  return w(r) && r.name === "AuthRetryableFetchError";
}
class Et extends H {
  constructor(e, t, s) {
    super(e, "AuthWeakPasswordError", t, "weak_password"), this.reasons = s;
  }
}
class tt extends H {
  constructor(e) {
    super(e, "AuthInvalidJwtError", 400, "invalid_jwt");
  }
}
const Re = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".split(""), St = ` 	
\r=`.split(""), Zs = (() => {
  const r = new Array(128);
  for (let e = 0; e < r.length; e += 1) r[e] = -1;
  for (let e = 0; e < St.length; e += 1) r[St[e].charCodeAt(0)] = -2;
  for (let e = 0; e < Re.length; e += 1) r[Re[e].charCodeAt(0)] = e;
  return r;
})();
function kt(r, e, t) {
  if (r !== null) for (e.queue = e.queue << 8 | r, e.queuedBits += 8; e.queuedBits >= 6; ) {
    const s = e.queue >> e.queuedBits - 6 & 63;
    t(Re[s]), e.queuedBits -= 6;
  }
  else if (e.queuedBits > 0) for (e.queue = e.queue << 6 - e.queuedBits, e.queuedBits = 6; e.queuedBits >= 6; ) {
    const s = e.queue >> e.queuedBits - 6 & 63;
    t(Re[s]), e.queuedBits -= 6;
  }
}
function Yt(r, e, t) {
  const s = Zs[r];
  if (s > -1) for (e.queue = e.queue << 6 | s, e.queuedBits += 6; e.queuedBits >= 8; ) t(e.queue >> e.queuedBits - 8 & 255), e.queuedBits -= 8;
  else {
    if (s === -2) return;
    throw new Error(`Invalid Base64-URL character "${String.fromCharCode(r)}"`);
  }
}
function Tt(r) {
  const e = [], t = (a) => {
    e.push(String.fromCodePoint(a));
  }, s = { utf8seq: 0, codepoint: 0 }, n = { queue: 0, queuedBits: 0 }, i = (a) => {
    rn(a, s, t);
  };
  for (let a = 0; a < r.length; a += 1) Yt(r.charCodeAt(a), n, i);
  return e.join("");
}
function en(r, e) {
  if (r <= 127) {
    e(r);
    return;
  } else if (r <= 2047) {
    e(192 | r >> 6), e(128 | r & 63);
    return;
  } else if (r <= 65535) {
    e(224 | r >> 12), e(128 | r >> 6 & 63), e(128 | r & 63);
    return;
  } else if (r <= 1114111) {
    e(240 | r >> 18), e(128 | r >> 12 & 63), e(128 | r >> 6 & 63), e(128 | r & 63);
    return;
  }
  throw new Error(`Unrecognized Unicode codepoint: ${r.toString(16)}`);
}
function tn(r, e) {
  for (let t = 0; t < r.length; t += 1) {
    let s = r.charCodeAt(t);
    if (s > 55295 && s <= 56319) {
      const n = (s - 55296) * 1024 & 65535;
      s = (r.charCodeAt(t + 1) - 56320 & 65535 | n) + 65536, t += 1;
    }
    en(s, e);
  }
}
function rn(r, e, t) {
  if (e.utf8seq === 0) {
    if (r <= 127) {
      t(r);
      return;
    }
    for (let s = 1; s < 6; s += 1) if ((r >> 7 - s & 1) === 0) {
      e.utf8seq = s;
      break;
    }
    if (e.utf8seq === 2) e.codepoint = r & 31;
    else if (e.utf8seq === 3) e.codepoint = r & 15;
    else if (e.utf8seq === 4) e.codepoint = r & 7;
    else throw new Error("Invalid UTF-8 sequence");
    e.utf8seq -= 1;
  } else if (e.utf8seq > 0) {
    if (r <= 127) throw new Error("Invalid UTF-8 sequence");
    e.codepoint = e.codepoint << 6 | r & 63, e.utf8seq -= 1, e.utf8seq === 0 && t(e.codepoint);
  }
}
function fe(r) {
  const e = [], t = { queue: 0, queuedBits: 0 }, s = (n) => {
    e.push(n);
  };
  for (let n = 0; n < r.length; n += 1) Yt(r.charCodeAt(n), t, s);
  return new Uint8Array(e);
}
function sn(r) {
  const e = [];
  return tn(r, (t) => e.push(t)), new Uint8Array(e);
}
function te(r) {
  const e = [], t = { queue: 0, queuedBits: 0 }, s = (n) => {
    e.push(n);
  };
  return r.forEach((n) => kt(n, t, s)), kt(null, t, s), e.join("");
}
function nn(r) {
  return Math.round(Date.now() / 1e3) + r;
}
function an() {
  return /* @__PURE__ */ Symbol("auth-callback");
}
const j = () => typeof window < "u" && typeof document < "u", Y = { tested: false, writable: false }, Xt = () => {
  if (!j()) return false;
  try {
    if (typeof globalThis.localStorage != "object") return false;
  } catch {
    return false;
  }
  if (Y.tested) return Y.writable;
  const r = `lswt-${Math.random()}${Math.random()}`;
  try {
    globalThis.localStorage.setItem(r, r), globalThis.localStorage.removeItem(r), Y.tested = true, Y.writable = true;
  } catch {
    Y.tested = true, Y.writable = false;
  }
  return Y.writable;
};
function on(r) {
  const e = {}, t = new URL(r);
  if (t.hash && t.hash[0] === "#") try {
    new URLSearchParams(t.hash.substring(1)).forEach((n, i) => {
      e[i] = n;
    });
  } catch {
  }
  return t.searchParams.forEach((s, n) => {
    e[n] = s;
  }), e;
}
const Qt = (r) => r ? (...e) => r(...e) : (...e) => fetch(...e), ln = (r) => typeof r == "object" && r !== null && "status" in r && "ok" in r && "json" in r && typeof r.json == "function", de = async (r, e, t) => {
  await r.setItem(e, JSON.stringify(t));
}, X = async (r, e) => {
  const t = await r.getItem(e);
  if (!t) return null;
  try {
    return JSON.parse(t);
  } catch {
    return t;
  }
}, P = async (r, e) => {
  await r.removeItem(e);
};
class Ue {
  constructor() {
    this.promise = new Ue.promiseConstructor((e, t) => {
      this.resolve = e, this.reject = t;
    });
  }
}
Ue.promiseConstructor = Promise;
function Ve(r) {
  const e = r.split(".");
  if (e.length !== 3) throw new tt("Invalid JWT structure");
  for (let s = 0; s < e.length; s++) if (!Fs.test(e[s])) throw new tt("JWT not in base64url format");
  return { header: JSON.parse(Tt(e[0])), payload: JSON.parse(Tt(e[1])), signature: fe(e[2]), raw: { header: e[0], payload: e[1] } };
}
async function cn(r) {
  return await new Promise((e) => {
    setTimeout(() => e(null), r);
  });
}
function un(r, e) {
  return new Promise((s, n) => {
    (async () => {
      for (let i = 0; i < 1 / 0; i++) try {
        const a = await r(i);
        if (!e(i, null, a)) {
          s(a);
          return;
        }
      } catch (a) {
        if (!e(i, a)) {
          n(a);
          return;
        }
      }
    })();
  });
}
function dn(r) {
  return ("0" + r.toString(16)).substr(-2);
}
function hn() {
  const e = new Uint32Array(56);
  if (typeof crypto > "u") {
    const t = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~", s = t.length;
    let n = "";
    for (let i = 0; i < 56; i++) n += t.charAt(Math.floor(Math.random() * s));
    return n;
  }
  return crypto.getRandomValues(e), Array.from(e, dn).join("");
}
async function fn(r) {
  const t = new TextEncoder().encode(r), s = await crypto.subtle.digest("SHA-256", t), n = new Uint8Array(s);
  return Array.from(n).map((i) => String.fromCharCode(i)).join("");
}
async function pn(r) {
  if (!(typeof crypto < "u" && typeof crypto.subtle < "u" && typeof TextEncoder < "u")) return console.warn("WebCrypto API is not supported. Code challenge method will default to use plain instead of sha256."), r;
  const t = await fn(r);
  return btoa(t).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
async function ie(r, e, t = false) {
  const s = hn();
  let n = s;
  t && (n += "/PASSWORD_RECOVERY"), await de(r, `${e}-code-verifier`, n);
  const i = await pn(s);
  return [i, s === i ? "plain" : "s256"];
}
const gn = /^2[0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/i;
function mn(r) {
  const e = r.headers.get(Ze);
  if (!e || !e.match(gn)) return null;
  try {
    return /* @__PURE__ */ new Date(`${e}T00:00:00.0Z`);
  } catch {
    return null;
  }
}
function yn(r) {
  if (!r) throw new Error("Missing exp claim");
  const e = Math.floor(Date.now() / 1e3);
  if (r <= e) throw new Error("JWT has expired");
}
function vn(r) {
  switch (r) {
    case "RS256":
      return { name: "RSASSA-PKCS1-v1_5", hash: { name: "SHA-256" } };
    case "ES256":
      return { name: "ECDSA", namedCurve: "P-256", hash: { name: "SHA-256" } };
    default:
      throw new Error("Invalid alg claim");
  }
}
const wn = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
function ae(r) {
  if (!wn.test(r)) throw new Error("@supabase/auth-js: Expected parameter to be UUID but is not");
}
function We() {
  const r = {};
  return new Proxy(r, { get: (e, t) => {
    if (t === "__isUserNotAvailableProxy") return true;
    if (typeof t == "symbol") {
      const s = t.toString();
      if (s === "Symbol(Symbol.toPrimitive)" || s === "Symbol(Symbol.toStringTag)" || s === "Symbol(util.inspect.custom)") return;
    }
    throw new Error(`@supabase/auth-js: client was created with userStorage option and there was no user stored in the user storage. Accessing the "${t}" property of the session object is not supported. Please use getUser() instead.`);
  }, set: (e, t) => {
    throw new Error(`@supabase/auth-js: client was created with userStorage option and there was no user stored in the user storage. Setting the "${t}" property of the session object is not supported. Please use getUser() to fetch a user object you can manipulate.`);
  }, deleteProperty: (e, t) => {
    throw new Error(`@supabase/auth-js: client was created with userStorage option and there was no user stored in the user storage. Deleting the "${t}" property of the session object is not supported. Please use getUser() to fetch a user object you can manipulate.`);
  } });
}
function bn(r, e) {
  return new Proxy(r, { get: (t, s, n) => {
    if (s === "__isInsecureUserWarningProxy") return true;
    if (typeof s == "symbol") {
      const i = s.toString();
      if (i === "Symbol(Symbol.toPrimitive)" || i === "Symbol(Symbol.toStringTag)" || i === "Symbol(util.inspect.custom)" || i === "Symbol(nodejs.util.inspect.custom)") return Reflect.get(t, s, n);
    }
    return !e.value && typeof s == "string" && (console.warn("Using the user object as returned from supabase.auth.getSession() or from some supabase.auth.onAuthStateChange() events could be insecure! This value comes directly from the storage medium (usually cookies on the server) and may not be authentic. Use supabase.auth.getUser() instead which authenticates the data by contacting the Supabase Auth server."), e.value = true), Reflect.get(t, s, n);
  } });
}
function It(r) {
  return JSON.parse(JSON.stringify(r));
}
const Q = (r) => r.msg || r.message || r.error_description || r.error || JSON.stringify(r), _n = [502, 503, 504];
async function xt(r) {
  var e;
  if (!ln(r)) throw new et(Q(r), 0);
  if (_n.includes(r.status)) throw new et(Q(r), r.status);
  let t;
  try {
    t = await r.json();
  } catch (i) {
    throw new ee(Q(i), i);
  }
  let s;
  const n = mn(r);
  if (n && n.getTime() >= Jt["2024-01-01"].timestamp && typeof t == "object" && t && typeof t.code == "string" ? s = t.code : typeof t == "object" && t && typeof t.error_code == "string" && (s = t.error_code), s) {
    if (s === "weak_password") throw new Et(Q(t), r.status, ((e = t.weak_password) === null || e === void 0 ? void 0 : e.reasons) || []);
    if (s === "session_not_found") throw new B();
  } else if (typeof t == "object" && t && typeof t.weak_password == "object" && t.weak_password && Array.isArray(t.weak_password.reasons) && t.weak_password.reasons.length && t.weak_password.reasons.reduce((i, a) => i && typeof a == "string", true)) throw new Et(Q(t), r.status, t.weak_password.reasons);
  throw new Gs(Q(t), r.status || 500, s);
}
const En = (r, e, t, s) => {
  const n = { method: r, headers: (e == null ? void 0 : e.headers) || {} };
  return r === "GET" ? n : (n.headers = Object.assign({ "Content-Type": "application/json;charset=UTF-8" }, e == null ? void 0 : e.headers), n.body = JSON.stringify(s), Object.assign(Object.assign({}, n), t));
};
async function _(r, e, t, s) {
  var n;
  const i = Object.assign({}, s == null ? void 0 : s.headers);
  i[Ze] || (i[Ze] = Jt["2024-01-01"].name), (s == null ? void 0 : s.jwt) && (i.Authorization = `Bearer ${s.jwt}`);
  const a = (n = s == null ? void 0 : s.query) !== null && n !== void 0 ? n : {};
  (s == null ? void 0 : s.redirectTo) && (a.redirect_to = s.redirectTo);
  const o = Object.keys(a).length ? "?" + new URLSearchParams(a).toString() : "", l = await Sn(r, e, t + o, { headers: i, noResolveJson: s == null ? void 0 : s.noResolveJson }, {}, s == null ? void 0 : s.body);
  return (s == null ? void 0 : s.xform) ? s == null ? void 0 : s.xform(l) : { data: Object.assign({}, l), error: null };
}
async function Sn(r, e, t, s, n, i) {
  const a = En(e, s, n, i);
  let o;
  try {
    o = await r(t, Object.assign({}, a));
  } catch (l) {
    throw console.error(l), new et(Q(l), 0);
  }
  if (o.ok || await xt(o), s == null ? void 0 : s.noResolveJson) return o;
  try {
    return await o.json();
  } catch (l) {
    await xt(l);
  }
}
function L(r) {
  var e;
  let t = null;
  In(r) && (t = Object.assign({}, r), r.expires_at || (t.expires_at = nn(r.expires_in)));
  const s = (e = r.user) !== null && e !== void 0 ? e : r;
  return { data: { session: t, user: s }, error: null };
}
function Ot(r) {
  const e = L(r);
  return !e.error && r.weak_password && typeof r.weak_password == "object" && Array.isArray(r.weak_password.reasons) && r.weak_password.reasons.length && r.weak_password.message && typeof r.weak_password.message == "string" && r.weak_password.reasons.reduce((t, s) => t && typeof s == "string", true) && (e.data.weak_password = r.weak_password), e;
}
function G(r) {
  var e;
  return { data: { user: (e = r.user) !== null && e !== void 0 ? e : r }, error: null };
}
function kn(r) {
  return { data: r, error: null };
}
function Tn(r) {
  const { action_link: e, email_otp: t, hashed_token: s, redirect_to: n, verification_type: i } = r, a = Pe(r, ["action_link", "email_otp", "hashed_token", "redirect_to", "verification_type"]), o = { action_link: e, email_otp: t, hashed_token: s, redirect_to: n, verification_type: i }, l = Object.assign({}, a);
  return { data: { properties: o, user: l }, error: null };
}
function At(r) {
  return r;
}
function In(r) {
  return r.access_token && r.refresh_token && r.expires_in;
}
const ze = ["global", "local", "others"];
class xn {
  constructor({ url: e = "", headers: t = {}, fetch: s }) {
    this.url = e, this.headers = t, this.fetch = Qt(s), this.mfa = { listFactors: this._listFactors.bind(this), deleteFactor: this._deleteFactor.bind(this) }, this.oauth = { listClients: this._listOAuthClients.bind(this), createClient: this._createOAuthClient.bind(this), getClient: this._getOAuthClient.bind(this), updateClient: this._updateOAuthClient.bind(this), deleteClient: this._deleteOAuthClient.bind(this), regenerateClientSecret: this._regenerateOAuthClientSecret.bind(this) };
  }
  async signOut(e, t = ze[0]) {
    if (ze.indexOf(t) < 0) throw new Error(`@supabase/auth-js: Parameter scope must be one of ${ze.join(", ")}`);
    try {
      return await _(this.fetch, "POST", `${this.url}/logout?scope=${t}`, { headers: this.headers, jwt: e, noResolveJson: true }), { data: null, error: null };
    } catch (s) {
      if (w(s)) return { data: null, error: s };
      throw s;
    }
  }
  async inviteUserByEmail(e, t = {}) {
    try {
      return await _(this.fetch, "POST", `${this.url}/invite`, { body: { email: e, data: t.data }, headers: this.headers, redirectTo: t.redirectTo, xform: G });
    } catch (s) {
      if (w(s)) return { data: { user: null }, error: s };
      throw s;
    }
  }
  async generateLink(e) {
    try {
      const { options: t } = e, s = Pe(e, ["options"]), n = Object.assign(Object.assign({}, s), t);
      return "newEmail" in s && (n.new_email = s == null ? void 0 : s.newEmail, delete n.newEmail), await _(this.fetch, "POST", `${this.url}/admin/generate_link`, { body: n, headers: this.headers, xform: Tn, redirectTo: t == null ? void 0 : t.redirectTo });
    } catch (t) {
      if (w(t)) return { data: { properties: null, user: null }, error: t };
      throw t;
    }
  }
  async createUser(e) {
    try {
      return await _(this.fetch, "POST", `${this.url}/admin/users`, { body: e, headers: this.headers, xform: G });
    } catch (t) {
      if (w(t)) return { data: { user: null }, error: t };
      throw t;
    }
  }
  async listUsers(e) {
    var t, s, n, i, a, o, l;
    try {
      const c = { nextPage: null, lastPage: 0, total: 0 }, u = await _(this.fetch, "GET", `${this.url}/admin/users`, { headers: this.headers, noResolveJson: true, query: { page: (s = (t = e == null ? void 0 : e.page) === null || t === void 0 ? void 0 : t.toString()) !== null && s !== void 0 ? s : "", per_page: (i = (n = e == null ? void 0 : e.perPage) === null || n === void 0 ? void 0 : n.toString()) !== null && i !== void 0 ? i : "" }, xform: At });
      if (u.error) throw u.error;
      const h = await u.json(), d = (a = u.headers.get("x-total-count")) !== null && a !== void 0 ? a : 0, f = (l = (o = u.headers.get("link")) === null || o === void 0 ? void 0 : o.split(",")) !== null && l !== void 0 ? l : [];
      return f.length > 0 && (f.forEach((p) => {
        const g = parseInt(p.split(";")[0].split("=")[1].substring(0, 1)), m = JSON.parse(p.split(";")[1].split("=")[1]);
        c[`${m}Page`] = g;
      }), c.total = parseInt(d)), { data: Object.assign(Object.assign({}, h), c), error: null };
    } catch (c) {
      if (w(c)) return { data: { users: [] }, error: c };
      throw c;
    }
  }
  async getUserById(e) {
    ae(e);
    try {
      return await _(this.fetch, "GET", `${this.url}/admin/users/${e}`, { headers: this.headers, xform: G });
    } catch (t) {
      if (w(t)) return { data: { user: null }, error: t };
      throw t;
    }
  }
  async updateUserById(e, t) {
    ae(e);
    try {
      return await _(this.fetch, "PUT", `${this.url}/admin/users/${e}`, { body: t, headers: this.headers, xform: G });
    } catch (s) {
      if (w(s)) return { data: { user: null }, error: s };
      throw s;
    }
  }
  async deleteUser(e, t = false) {
    ae(e);
    try {
      return await _(this.fetch, "DELETE", `${this.url}/admin/users/${e}`, { headers: this.headers, body: { should_soft_delete: t }, xform: G });
    } catch (s) {
      if (w(s)) return { data: { user: null }, error: s };
      throw s;
    }
  }
  async _listFactors(e) {
    ae(e.userId);
    try {
      const { data: t, error: s } = await _(this.fetch, "GET", `${this.url}/admin/users/${e.userId}/factors`, { headers: this.headers, xform: (n) => ({ data: { factors: n }, error: null }) });
      return { data: t, error: s };
    } catch (t) {
      if (w(t)) return { data: null, error: t };
      throw t;
    }
  }
  async _deleteFactor(e) {
    ae(e.userId), ae(e.id);
    try {
      return { data: await _(this.fetch, "DELETE", `${this.url}/admin/users/${e.userId}/factors/${e.id}`, { headers: this.headers }), error: null };
    } catch (t) {
      if (w(t)) return { data: null, error: t };
      throw t;
    }
  }
  async _listOAuthClients(e) {
    var t, s, n, i, a, o, l;
    try {
      const c = { nextPage: null, lastPage: 0, total: 0 }, u = await _(this.fetch, "GET", `${this.url}/admin/oauth/clients`, { headers: this.headers, noResolveJson: true, query: { page: (s = (t = e == null ? void 0 : e.page) === null || t === void 0 ? void 0 : t.toString()) !== null && s !== void 0 ? s : "", per_page: (i = (n = e == null ? void 0 : e.perPage) === null || n === void 0 ? void 0 : n.toString()) !== null && i !== void 0 ? i : "" }, xform: At });
      if (u.error) throw u.error;
      const h = await u.json(), d = (a = u.headers.get("x-total-count")) !== null && a !== void 0 ? a : 0, f = (l = (o = u.headers.get("link")) === null || o === void 0 ? void 0 : o.split(",")) !== null && l !== void 0 ? l : [];
      return f.length > 0 && (f.forEach((p) => {
        const g = parseInt(p.split(";")[0].split("=")[1].substring(0, 1)), m = JSON.parse(p.split(";")[1].split("=")[1]);
        c[`${m}Page`] = g;
      }), c.total = parseInt(d)), { data: Object.assign(Object.assign({}, h), c), error: null };
    } catch (c) {
      if (w(c)) return { data: { clients: [] }, error: c };
      throw c;
    }
  }
  async _createOAuthClient(e) {
    try {
      return await _(this.fetch, "POST", `${this.url}/admin/oauth/clients`, { body: e, headers: this.headers, xform: (t) => ({ data: t, error: null }) });
    } catch (t) {
      if (w(t)) return { data: null, error: t };
      throw t;
    }
  }
  async _getOAuthClient(e) {
    try {
      return await _(this.fetch, "GET", `${this.url}/admin/oauth/clients/${e}`, { headers: this.headers, xform: (t) => ({ data: t, error: null }) });
    } catch (t) {
      if (w(t)) return { data: null, error: t };
      throw t;
    }
  }
  async _updateOAuthClient(e, t) {
    try {
      return await _(this.fetch, "PUT", `${this.url}/admin/oauth/clients/${e}`, { body: t, headers: this.headers, xform: (s) => ({ data: s, error: null }) });
    } catch (s) {
      if (w(s)) return { data: null, error: s };
      throw s;
    }
  }
  async _deleteOAuthClient(e) {
    try {
      return await _(this.fetch, "DELETE", `${this.url}/admin/oauth/clients/${e}`, { headers: this.headers, noResolveJson: true }), { data: null, error: null };
    } catch (t) {
      if (w(t)) return { data: null, error: t };
      throw t;
    }
  }
  async _regenerateOAuthClientSecret(e) {
    try {
      return await _(this.fetch, "POST", `${this.url}/admin/oauth/clients/${e}/regenerate_secret`, { headers: this.headers, xform: (t) => ({ data: t, error: null }) });
    } catch (t) {
      if (w(t)) return { data: null, error: t };
      throw t;
    }
  }
}
function Rt(r = {}) {
  return { getItem: (e) => r[e] || null, setItem: (e, t) => {
    r[e] = t;
  }, removeItem: (e) => {
    delete r[e];
  } };
}
const oe = { debug: !!(globalThis && Xt() && globalThis.localStorage && globalThis.localStorage.getItem("supabase.gotrue-js.locks.debug") === "true") };
class Zt extends Error {
  constructor(e) {
    super(e), this.isAcquireTimeout = true;
  }
}
class On extends Zt {
}
async function An(r, e, t) {
  oe.debug && console.log("@supabase/gotrue-js: navigatorLock: acquire lock", r, e);
  const s = new globalThis.AbortController();
  return e > 0 && setTimeout(() => {
    s.abort(), oe.debug && console.log("@supabase/gotrue-js: navigatorLock acquire timed out", r);
  }, e), await Promise.resolve().then(() => globalThis.navigator.locks.request(r, e === 0 ? { mode: "exclusive", ifAvailable: true } : { mode: "exclusive", signal: s.signal }, async (n) => {
    if (n) {
      oe.debug && console.log("@supabase/gotrue-js: navigatorLock: acquired", r, n.name);
      try {
        return await t();
      } finally {
        oe.debug && console.log("@supabase/gotrue-js: navigatorLock: released", r, n.name);
      }
    } else {
      if (e === 0) throw oe.debug && console.log("@supabase/gotrue-js: navigatorLock: not immediately available", r), new On(`Acquiring an exclusive Navigator LockManager lock "${r}" immediately failed`);
      if (oe.debug) try {
        const i = await globalThis.navigator.locks.query();
        console.log("@supabase/gotrue-js: Navigator LockManager state", JSON.stringify(i, null, "  "));
      } catch (i) {
        console.warn("@supabase/gotrue-js: Error when querying Navigator LockManager state", i);
      }
      return console.warn("@supabase/gotrue-js: Navigator LockManager returned a null lock when using #request without ifAvailable set to true, it appears this browser is not following the LockManager spec https://developer.mozilla.org/en-US/docs/Web/API/LockManager/request"), await t();
    }
  }));
}
function Rn() {
  if (typeof globalThis != "object") try {
    Object.defineProperty(Object.prototype, "__magic__", { get: function() {
      return this;
    }, configurable: true }), __magic__.globalThis = __magic__, delete Object.prototype.__magic__;
  } catch {
    typeof self < "u" && (self.globalThis = self);
  }
}
function er(r) {
  if (!/^0x[a-fA-F0-9]{40}$/.test(r)) throw new Error(`@supabase/auth-js: Address "${r}" is invalid.`);
  return r.toLowerCase();
}
function Cn(r) {
  return parseInt(r, 16);
}
function $n(r) {
  const e = new TextEncoder().encode(r);
  return "0x" + Array.from(e, (s) => s.toString(16).padStart(2, "0")).join("");
}
function Pn(r) {
  var e;
  const { chainId: t, domain: s, expirationTime: n, issuedAt: i = /* @__PURE__ */ new Date(), nonce: a, notBefore: o, requestId: l, resources: c, scheme: u, uri: h, version: d } = r;
  {
    if (!Number.isInteger(t)) throw new Error(`@supabase/auth-js: Invalid SIWE message field "chainId". Chain ID must be a EIP-155 chain ID. Provided value: ${t}`);
    if (!s) throw new Error('@supabase/auth-js: Invalid SIWE message field "domain". Domain must be provided.');
    if (a && a.length < 8) throw new Error(`@supabase/auth-js: Invalid SIWE message field "nonce". Nonce must be at least 8 characters. Provided value: ${a}`);
    if (!h) throw new Error('@supabase/auth-js: Invalid SIWE message field "uri". URI must be provided.');
    if (d !== "1") throw new Error(`@supabase/auth-js: Invalid SIWE message field "version". Version must be '1'. Provided value: ${d}`);
    if (!((e = r.statement) === null || e === void 0) && e.includes(`
`)) throw new Error(`@supabase/auth-js: Invalid SIWE message field "statement". Statement must not include '\\n'. Provided value: ${r.statement}`);
  }
  const f = er(r.address), p = u ? `${u}://${s}` : s, g = r.statement ? `${r.statement}
` : "", m = `${p} wants you to sign in with your Ethereum account:
${f}

${g}`;
  let v = `URI: ${h}
Version: ${d}
Chain ID: ${t}${a ? `
Nonce: ${a}` : ""}
Issued At: ${i.toISOString()}`;
  if (n && (v += `
Expiration Time: ${n.toISOString()}`), o && (v += `
Not Before: ${o.toISOString()}`), l && (v += `
Request ID: ${l}`), c) {
    let b = `
Resources:`;
    for (const y of c) {
      if (!y || typeof y != "string") throw new Error(`@supabase/auth-js: Invalid SIWE message field "resources". Every resource must be a valid string. Provided value: ${y}`);
      b += `
- ${y}`;
    }
    v += b;
  }
  return `${m}
${v}`;
}
class A extends Error {
  constructor({ message: e, code: t, cause: s, name: n }) {
    var i;
    super(e, { cause: s }), this.__isWebAuthnError = true, this.name = (i = n ?? (s instanceof Error ? s.name : void 0)) !== null && i !== void 0 ? i : "Unknown Error", this.code = t;
  }
}
class Ce extends A {
  constructor(e, t) {
    super({ code: "ERROR_PASSTHROUGH_SEE_CAUSE_PROPERTY", cause: t, message: e }), this.name = "WebAuthnUnknownError", this.originalError = t;
  }
}
function jn({ error: r, options: e }) {
  var t, s, n;
  const { publicKey: i } = e;
  if (!i) throw Error("options was missing required publicKey property");
  if (r.name === "AbortError") {
    if (e.signal instanceof AbortSignal) return new A({ message: "Registration ceremony was sent an abort signal", code: "ERROR_CEREMONY_ABORTED", cause: r });
  } else if (r.name === "ConstraintError") {
    if (((t = i.authenticatorSelection) === null || t === void 0 ? void 0 : t.requireResidentKey) === true) return new A({ message: "Discoverable credentials were required but no available authenticator supported it", code: "ERROR_AUTHENTICATOR_MISSING_DISCOVERABLE_CREDENTIAL_SUPPORT", cause: r });
    if (e.mediation === "conditional" && ((s = i.authenticatorSelection) === null || s === void 0 ? void 0 : s.userVerification) === "required") return new A({ message: "User verification was required during automatic registration but it could not be performed", code: "ERROR_AUTO_REGISTER_USER_VERIFICATION_FAILURE", cause: r });
    if (((n = i.authenticatorSelection) === null || n === void 0 ? void 0 : n.userVerification) === "required") return new A({ message: "User verification was required but no available authenticator supported it", code: "ERROR_AUTHENTICATOR_MISSING_USER_VERIFICATION_SUPPORT", cause: r });
  } else {
    if (r.name === "InvalidStateError") return new A({ message: "The authenticator was previously registered", code: "ERROR_AUTHENTICATOR_PREVIOUSLY_REGISTERED", cause: r });
    if (r.name === "NotAllowedError") return new A({ message: r.message, code: "ERROR_PASSTHROUGH_SEE_CAUSE_PROPERTY", cause: r });
    if (r.name === "NotSupportedError") return i.pubKeyCredParams.filter((o) => o.type === "public-key").length === 0 ? new A({ message: 'No entry in pubKeyCredParams was of type "public-key"', code: "ERROR_MALFORMED_PUBKEYCREDPARAMS", cause: r }) : new A({ message: "No available authenticator supported any of the specified pubKeyCredParams algorithms", code: "ERROR_AUTHENTICATOR_NO_SUPPORTED_PUBKEYCREDPARAMS_ALG", cause: r });
    if (r.name === "SecurityError") {
      const a = window.location.hostname;
      if (tr(a)) {
        if (i.rp.id !== a) return new A({ message: `The RP ID "${i.rp.id}" is invalid for this domain`, code: "ERROR_INVALID_RP_ID", cause: r });
      } else return new A({ message: `${window.location.hostname} is an invalid domain`, code: "ERROR_INVALID_DOMAIN", cause: r });
    } else if (r.name === "TypeError") {
      if (i.user.id.byteLength < 1 || i.user.id.byteLength > 64) return new A({ message: "User ID was not between 1 and 64 characters", code: "ERROR_INVALID_USER_ID_LENGTH", cause: r });
    } else if (r.name === "UnknownError") return new A({ message: "The authenticator was unable to process the specified options, or could not create a new credential", code: "ERROR_AUTHENTICATOR_GENERAL_ERROR", cause: r });
  }
  return new A({ message: "a Non-Webauthn related error has occurred", code: "ERROR_PASSTHROUGH_SEE_CAUSE_PROPERTY", cause: r });
}
function Un({ error: r, options: e }) {
  const { publicKey: t } = e;
  if (!t) throw Error("options was missing required publicKey property");
  if (r.name === "AbortError") {
    if (e.signal instanceof AbortSignal) return new A({ message: "Authentication ceremony was sent an abort signal", code: "ERROR_CEREMONY_ABORTED", cause: r });
  } else {
    if (r.name === "NotAllowedError") return new A({ message: r.message, code: "ERROR_PASSTHROUGH_SEE_CAUSE_PROPERTY", cause: r });
    if (r.name === "SecurityError") {
      const s = window.location.hostname;
      if (tr(s)) {
        if (t.rpId !== s) return new A({ message: `The RP ID "${t.rpId}" is invalid for this domain`, code: "ERROR_INVALID_RP_ID", cause: r });
      } else return new A({ message: `${window.location.hostname} is an invalid domain`, code: "ERROR_INVALID_DOMAIN", cause: r });
    } else if (r.name === "UnknownError") return new A({ message: "The authenticator was unable to process the specified options, or could not create a new assertion signature", code: "ERROR_AUTHENTICATOR_GENERAL_ERROR", cause: r });
  }
  return new A({ message: "a Non-Webauthn related error has occurred", code: "ERROR_PASSTHROUGH_SEE_CAUSE_PROPERTY", cause: r });
}
class Bn {
  createNewAbortSignal() {
    if (this.controller) {
      const t = new Error("Cancelling existing WebAuthn API call for new one");
      t.name = "AbortError", this.controller.abort(t);
    }
    const e = new AbortController();
    return this.controller = e, e.signal;
  }
  cancelCeremony() {
    if (this.controller) {
      const e = new Error("Manually cancelling existing WebAuthn API call");
      e.name = "AbortError", this.controller.abort(e), this.controller = void 0;
    }
  }
}
const Nn = new Bn();
function Dn(r) {
  if (!r) throw new Error("Credential creation options are required");
  if (typeof PublicKeyCredential < "u" && "parseCreationOptionsFromJSON" in PublicKeyCredential && typeof PublicKeyCredential.parseCreationOptionsFromJSON == "function") return PublicKeyCredential.parseCreationOptionsFromJSON(r);
  const { challenge: e, user: t, excludeCredentials: s } = r, n = Pe(r, ["challenge", "user", "excludeCredentials"]), i = fe(e).buffer, a = Object.assign(Object.assign({}, t), { id: fe(t.id).buffer }), o = Object.assign(Object.assign({}, n), { challenge: i, user: a });
  if (s && s.length > 0) {
    o.excludeCredentials = new Array(s.length);
    for (let l = 0; l < s.length; l++) {
      const c = s[l];
      o.excludeCredentials[l] = Object.assign(Object.assign({}, c), { id: fe(c.id).buffer, type: c.type || "public-key", transports: c.transports });
    }
  }
  return o;
}
function Ln(r) {
  if (!r) throw new Error("Credential request options are required");
  if (typeof PublicKeyCredential < "u" && "parseRequestOptionsFromJSON" in PublicKeyCredential && typeof PublicKeyCredential.parseRequestOptionsFromJSON == "function") return PublicKeyCredential.parseRequestOptionsFromJSON(r);
  const { challenge: e, allowCredentials: t } = r, s = Pe(r, ["challenge", "allowCredentials"]), n = fe(e).buffer, i = Object.assign(Object.assign({}, s), { challenge: n });
  if (t && t.length > 0) {
    i.allowCredentials = new Array(t.length);
    for (let a = 0; a < t.length; a++) {
      const o = t[a];
      i.allowCredentials[a] = Object.assign(Object.assign({}, o), { id: fe(o.id).buffer, type: o.type || "public-key", transports: o.transports });
    }
  }
  return i;
}
function Mn(r) {
  var e;
  if ("toJSON" in r && typeof r.toJSON == "function") return r.toJSON();
  const t = r;
  return { id: r.id, rawId: r.id, response: { attestationObject: te(new Uint8Array(r.response.attestationObject)), clientDataJSON: te(new Uint8Array(r.response.clientDataJSON)) }, type: "public-key", clientExtensionResults: r.getClientExtensionResults(), authenticatorAttachment: (e = t.authenticatorAttachment) !== null && e !== void 0 ? e : void 0 };
}
function qn(r) {
  var e;
  if ("toJSON" in r && typeof r.toJSON == "function") return r.toJSON();
  const t = r, s = r.getClientExtensionResults(), n = r.response;
  return { id: r.id, rawId: r.id, response: { authenticatorData: te(new Uint8Array(n.authenticatorData)), clientDataJSON: te(new Uint8Array(n.clientDataJSON)), signature: te(new Uint8Array(n.signature)), userHandle: n.userHandle ? te(new Uint8Array(n.userHandle)) : void 0 }, type: "public-key", clientExtensionResults: s, authenticatorAttachment: (e = t.authenticatorAttachment) !== null && e !== void 0 ? e : void 0 };
}
function tr(r) {
  return r === "localhost" || /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/i.test(r);
}
function Ct() {
  var r, e;
  return !!(j() && "PublicKeyCredential" in window && window.PublicKeyCredential && "credentials" in navigator && typeof ((r = navigator == null ? void 0 : navigator.credentials) === null || r === void 0 ? void 0 : r.create) == "function" && typeof ((e = navigator == null ? void 0 : navigator.credentials) === null || e === void 0 ? void 0 : e.get) == "function");
}
async function Vn(r) {
  try {
    const e = await navigator.credentials.create(r);
    return e ? e instanceof PublicKeyCredential ? { data: e, error: null } : { data: null, error: new Ce("Browser returned unexpected credential type", e) } : { data: null, error: new Ce("Empty credential response", e) };
  } catch (e) {
    return { data: null, error: jn({ error: e, options: r }) };
  }
}
async function Wn(r) {
  try {
    const e = await navigator.credentials.get(r);
    return e ? e instanceof PublicKeyCredential ? { data: e, error: null } : { data: null, error: new Ce("Browser returned unexpected credential type", e) } : { data: null, error: new Ce("Empty credential response", e) };
  } catch (e) {
    return { data: null, error: Un({ error: e, options: r }) };
  }
}
const zn = { hints: ["security-key"], authenticatorSelection: { authenticatorAttachment: "cross-platform", requireResidentKey: false, userVerification: "preferred", residentKey: "discouraged" }, attestation: "direct" }, Hn = { userVerification: "preferred", hints: ["security-key"], attestation: "direct" };
function $e(...r) {
  const e = (n) => n !== null && typeof n == "object" && !Array.isArray(n), t = (n) => n instanceof ArrayBuffer || ArrayBuffer.isView(n), s = {};
  for (const n of r) if (n) for (const i in n) {
    const a = n[i];
    if (a !== void 0) if (Array.isArray(a)) s[i] = a;
    else if (t(a)) s[i] = a;
    else if (e(a)) {
      const o = s[i];
      e(o) ? s[i] = $e(o, a) : s[i] = $e(a);
    } else s[i] = a;
  }
  return s;
}
function Fn(r, e) {
  return $e(zn, r, e || {});
}
function Kn(r, e) {
  return $e(Hn, r, e || {});
}
class Gn {
  constructor(e) {
    this.client = e, this.enroll = this._enroll.bind(this), this.challenge = this._challenge.bind(this), this.verify = this._verify.bind(this), this.authenticate = this._authenticate.bind(this), this.register = this._register.bind(this);
  }
  async _enroll(e) {
    return this.client.mfa.enroll(Object.assign(Object.assign({}, e), { factorType: "webauthn" }));
  }
  async _challenge({ factorId: e, webauthn: t, friendlyName: s, signal: n }, i) {
    try {
      const { data: a, error: o } = await this.client.mfa.challenge({ factorId: e, webauthn: t });
      if (!a) return { data: null, error: o };
      const l = n ?? Nn.createNewAbortSignal();
      if (a.webauthn.type === "create") {
        const { user: c } = a.webauthn.credential_options.publicKey;
        c.name || (c.name = `${c.id}:${s}`), c.displayName || (c.displayName = c.name);
      }
      switch (a.webauthn.type) {
        case "create": {
          const c = Fn(a.webauthn.credential_options.publicKey, i == null ? void 0 : i.create), { data: u, error: h } = await Vn({ publicKey: c, signal: l });
          return u ? { data: { factorId: e, challengeId: a.id, webauthn: { type: a.webauthn.type, credential_response: u } }, error: null } : { data: null, error: h };
        }
        case "request": {
          const c = Kn(a.webauthn.credential_options.publicKey, i == null ? void 0 : i.request), { data: u, error: h } = await Wn(Object.assign(Object.assign({}, a.webauthn.credential_options), { publicKey: c, signal: l }));
          return u ? { data: { factorId: e, challengeId: a.id, webauthn: { type: a.webauthn.type, credential_response: u } }, error: null } : { data: null, error: h };
        }
      }
    } catch (a) {
      return w(a) ? { data: null, error: a } : { data: null, error: new ee("Unexpected error in challenge", a) };
    }
  }
  async _verify({ challengeId: e, factorId: t, webauthn: s }) {
    return this.client.mfa.verify({ factorId: t, challengeId: e, webauthn: s });
  }
  async _authenticate({ factorId: e, webauthn: { rpId: t = typeof window < "u" ? window.location.hostname : void 0, rpOrigins: s = typeof window < "u" ? [window.location.origin] : void 0, signal: n } = {} }, i) {
    if (!t) return { data: null, error: new be("rpId is required for WebAuthn authentication") };
    try {
      if (!Ct()) return { data: null, error: new ee("Browser does not support WebAuthn", null) };
      const { data: a, error: o } = await this.challenge({ factorId: e, webauthn: { rpId: t, rpOrigins: s }, signal: n }, { request: i });
      if (!a) return { data: null, error: o };
      const { webauthn: l } = a;
      return this._verify({ factorId: e, challengeId: a.challengeId, webauthn: { type: l.type, rpId: t, rpOrigins: s, credential_response: l.credential_response } });
    } catch (a) {
      return w(a) ? { data: null, error: a } : { data: null, error: new ee("Unexpected error in authenticate", a) };
    }
  }
  async _register({ friendlyName: e, webauthn: { rpId: t = typeof window < "u" ? window.location.hostname : void 0, rpOrigins: s = typeof window < "u" ? [window.location.origin] : void 0, signal: n } = {} }, i) {
    if (!t) return { data: null, error: new be("rpId is required for WebAuthn registration") };
    try {
      if (!Ct()) return { data: null, error: new ee("Browser does not support WebAuthn", null) };
      const { data: a, error: o } = await this._enroll({ friendlyName: e });
      if (!a) return await this.client.mfa.listFactors().then((u) => {
        var h;
        return (h = u.data) === null || h === void 0 ? void 0 : h.all.find((d) => d.factor_type === "webauthn" && d.friendly_name === e && d.status !== "unverified");
      }).then((u) => u ? this.client.mfa.unenroll({ factorId: u == null ? void 0 : u.id }) : void 0), { data: null, error: o };
      const { data: l, error: c } = await this._challenge({ factorId: a.id, friendlyName: a.friendly_name, webauthn: { rpId: t, rpOrigins: s }, signal: n }, { create: i });
      return l ? this._verify({ factorId: a.id, challengeId: l.challengeId, webauthn: { rpId: t, rpOrigins: s, type: l.webauthn.type, credential_response: l.webauthn.credential_response } }) : { data: null, error: c };
    } catch (a) {
      return w(a) ? { data: null, error: a } : { data: null, error: new ee("Unexpected error in register", a) };
    }
  }
}
Rn();
const Jn = { url: Ws, storageKey: zs, autoRefreshToken: true, persistSession: true, detectSessionInUrl: true, headers: Hs, flowType: "implicit", debug: false, hasCustomAuthorizationHeader: false, throwOnError: false };
async function $t(r, e, t) {
  return await t();
}
const le = {};
class _e {
  get jwks() {
    var e, t;
    return (t = (e = le[this.storageKey]) === null || e === void 0 ? void 0 : e.jwks) !== null && t !== void 0 ? t : { keys: [] };
  }
  set jwks(e) {
    le[this.storageKey] = Object.assign(Object.assign({}, le[this.storageKey]), { jwks: e });
  }
  get jwks_cached_at() {
    var e, t;
    return (t = (e = le[this.storageKey]) === null || e === void 0 ? void 0 : e.cachedAt) !== null && t !== void 0 ? t : Number.MIN_SAFE_INTEGER;
  }
  set jwks_cached_at(e) {
    le[this.storageKey] = Object.assign(Object.assign({}, le[this.storageKey]), { cachedAt: e });
  }
  constructor(e) {
    var t, s, n;
    this.userStorage = null, this.memoryStorage = null, this.stateChangeEmitters = /* @__PURE__ */ new Map(), this.autoRefreshTicker = null, this.visibilityChangedCallback = null, this.refreshingDeferred = null, this.initializePromise = null, this.detectSessionInUrl = true, this.hasCustomAuthorizationHeader = false, this.suppressGetSessionWarning = false, this.lockAcquired = false, this.pendingInLock = [], this.broadcastChannel = null, this.logger = console.log;
    const i = Object.assign(Object.assign({}, Jn), e);
    if (this.storageKey = i.storageKey, this.instanceID = (t = _e.nextInstanceID[this.storageKey]) !== null && t !== void 0 ? t : 0, _e.nextInstanceID[this.storageKey] = this.instanceID + 1, this.logDebugMessages = !!i.debug, typeof i.debug == "function" && (this.logger = i.debug), this.instanceID > 0 && j()) {
      const a = `${this._logPrefix()} Multiple GoTrueClient instances detected in the same browser context. It is not an error, but this should be avoided as it may produce undefined behavior when used concurrently under the same storage key.`;
      console.warn(a), this.logDebugMessages && console.trace(a);
    }
    if (this.persistSession = i.persistSession, this.autoRefreshToken = i.autoRefreshToken, this.admin = new xn({ url: i.url, headers: i.headers, fetch: i.fetch }), this.url = i.url, this.headers = i.headers, this.fetch = Qt(i.fetch), this.lock = i.lock || $t, this.detectSessionInUrl = i.detectSessionInUrl, this.flowType = i.flowType, this.hasCustomAuthorizationHeader = i.hasCustomAuthorizationHeader, this.throwOnError = i.throwOnError, i.lock ? this.lock = i.lock : this.persistSession && j() && (!((s = globalThis == null ? void 0 : globalThis.navigator) === null || s === void 0) && s.locks) ? this.lock = An : this.lock = $t, this.jwks || (this.jwks = { keys: [] }, this.jwks_cached_at = Number.MIN_SAFE_INTEGER), this.mfa = { verify: this._verify.bind(this), enroll: this._enroll.bind(this), unenroll: this._unenroll.bind(this), challenge: this._challenge.bind(this), listFactors: this._listFactors.bind(this), challengeAndVerify: this._challengeAndVerify.bind(this), getAuthenticatorAssuranceLevel: this._getAuthenticatorAssuranceLevel.bind(this), webauthn: new Gn(this) }, this.oauth = { getAuthorizationDetails: this._getAuthorizationDetails.bind(this), approveAuthorization: this._approveAuthorization.bind(this), denyAuthorization: this._denyAuthorization.bind(this), listGrants: this._listOAuthGrants.bind(this), revokeGrant: this._revokeOAuthGrant.bind(this) }, this.persistSession ? (i.storage ? this.storage = i.storage : Xt() ? this.storage = globalThis.localStorage : (this.memoryStorage = {}, this.storage = Rt(this.memoryStorage)), i.userStorage && (this.userStorage = i.userStorage)) : (this.memoryStorage = {}, this.storage = Rt(this.memoryStorage)), j() && globalThis.BroadcastChannel && this.persistSession && this.storageKey) {
      try {
        this.broadcastChannel = new globalThis.BroadcastChannel(this.storageKey);
      } catch (a) {
        console.error("Failed to create a new BroadcastChannel, multi-tab state changes will not be available", a);
      }
      (n = this.broadcastChannel) === null || n === void 0 || n.addEventListener("message", async (a) => {
        this._debug("received broadcast notification from other tab or client", a), await this._notifyAllSubscribers(a.data.event, a.data.session, false);
      });
    }
    this.initialize();
  }
  isThrowOnErrorEnabled() {
    return this.throwOnError;
  }
  _returnResult(e) {
    if (this.throwOnError && e && e.error) throw e.error;
    return e;
  }
  _logPrefix() {
    return `GoTrueClient@${this.storageKey}:${this.instanceID} (${Gt}) ${(/* @__PURE__ */ new Date()).toISOString()}`;
  }
  _debug(...e) {
    return this.logDebugMessages && this.logger(this._logPrefix(), ...e), this;
  }
  async initialize() {
    return this.initializePromise ? await this.initializePromise : (this.initializePromise = (async () => await this._acquireLock(-1, async () => await this._initialize()))(), await this.initializePromise);
  }
  async _initialize() {
    var e;
    try {
      let t = {}, s = "none";
      if (j() && (t = on(window.location.href), this._isImplicitGrantCallback(t) ? s = "implicit" : await this._isPKCECallback(t) && (s = "pkce")), j() && this.detectSessionInUrl && s !== "none") {
        const { data: n, error: i } = await this._getSessionFromURL(t, s);
        if (i) {
          if (this._debug("#_initialize()", "error detecting session from URL", i), Xs(i)) {
            const l = (e = i.details) === null || e === void 0 ? void 0 : e.code;
            if (l === "identity_already_exists" || l === "identity_not_found" || l === "single_identity_not_deletable") return { error: i };
          }
          return await this._removeSession(), { error: i };
        }
        const { session: a, redirectType: o } = n;
        return this._debug("#_initialize()", "detected session in URL", a, "redirect type", o), await this._saveSession(a), setTimeout(async () => {
          o === "recovery" ? await this._notifyAllSubscribers("PASSWORD_RECOVERY", a) : await this._notifyAllSubscribers("SIGNED_IN", a);
        }, 0), { error: null };
      }
      return await this._recoverAndRefresh(), { error: null };
    } catch (t) {
      return w(t) ? this._returnResult({ error: t }) : this._returnResult({ error: new ee("Unexpected error during initialization", t) });
    } finally {
      await this._handleVisibilityChange(), this._debug("#_initialize()", "end");
    }
  }
  async signInAnonymously(e) {
    var t, s, n;
    try {
      const i = await _(this.fetch, "POST", `${this.url}/signup`, { headers: this.headers, body: { data: (s = (t = e == null ? void 0 : e.options) === null || t === void 0 ? void 0 : t.data) !== null && s !== void 0 ? s : {}, gotrue_meta_security: { captcha_token: (n = e == null ? void 0 : e.options) === null || n === void 0 ? void 0 : n.captchaToken } }, xform: L }), { data: a, error: o } = i;
      if (o || !a) return this._returnResult({ data: { user: null, session: null }, error: o });
      const l = a.session, c = a.user;
      return a.session && (await this._saveSession(a.session), await this._notifyAllSubscribers("SIGNED_IN", l)), this._returnResult({ data: { user: c, session: l }, error: null });
    } catch (i) {
      if (w(i)) return this._returnResult({ data: { user: null, session: null }, error: i });
      throw i;
    }
  }
  async signUp(e) {
    var t, s, n;
    try {
      let i;
      if ("email" in e) {
        const { email: u, password: h, options: d } = e;
        let f = null, p = null;
        this.flowType === "pkce" && ([f, p] = await ie(this.storage, this.storageKey)), i = await _(this.fetch, "POST", `${this.url}/signup`, { headers: this.headers, redirectTo: d == null ? void 0 : d.emailRedirectTo, body: { email: u, password: h, data: (t = d == null ? void 0 : d.data) !== null && t !== void 0 ? t : {}, gotrue_meta_security: { captcha_token: d == null ? void 0 : d.captchaToken }, code_challenge: f, code_challenge_method: p }, xform: L });
      } else if ("phone" in e) {
        const { phone: u, password: h, options: d } = e;
        i = await _(this.fetch, "POST", `${this.url}/signup`, { headers: this.headers, body: { phone: u, password: h, data: (s = d == null ? void 0 : d.data) !== null && s !== void 0 ? s : {}, channel: (n = d == null ? void 0 : d.channel) !== null && n !== void 0 ? n : "sms", gotrue_meta_security: { captcha_token: d == null ? void 0 : d.captchaToken } }, xform: L });
      } else throw new xe("You must provide either an email or phone number and a password");
      const { data: a, error: o } = i;
      if (o || !a) return await P(this.storage, `${this.storageKey}-code-verifier`), this._returnResult({ data: { user: null, session: null }, error: o });
      const l = a.session, c = a.user;
      return a.session && (await this._saveSession(a.session), await this._notifyAllSubscribers("SIGNED_IN", l)), this._returnResult({ data: { user: c, session: l }, error: null });
    } catch (i) {
      if (await P(this.storage, `${this.storageKey}-code-verifier`), w(i)) return this._returnResult({ data: { user: null, session: null }, error: i });
      throw i;
    }
  }
  async signInWithPassword(e) {
    try {
      let t;
      if ("email" in e) {
        const { email: i, password: a, options: o } = e;
        t = await _(this.fetch, "POST", `${this.url}/token?grant_type=password`, { headers: this.headers, body: { email: i, password: a, gotrue_meta_security: { captcha_token: o == null ? void 0 : o.captchaToken } }, xform: Ot });
      } else if ("phone" in e) {
        const { phone: i, password: a, options: o } = e;
        t = await _(this.fetch, "POST", `${this.url}/token?grant_type=password`, { headers: this.headers, body: { phone: i, password: a, gotrue_meta_security: { captcha_token: o == null ? void 0 : o.captchaToken } }, xform: Ot });
      } else throw new xe("You must provide either an email or phone number and a password");
      const { data: s, error: n } = t;
      if (n) return this._returnResult({ data: { user: null, session: null }, error: n });
      if (!s || !s.session || !s.user) {
        const i = new ne();
        return this._returnResult({ data: { user: null, session: null }, error: i });
      }
      return s.session && (await this._saveSession(s.session), await this._notifyAllSubscribers("SIGNED_IN", s.session)), this._returnResult({ data: Object.assign({ user: s.user, session: s.session }, s.weak_password ? { weakPassword: s.weak_password } : null), error: n });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: { user: null, session: null }, error: t });
      throw t;
    }
  }
  async signInWithOAuth(e) {
    var t, s, n, i;
    return await this._handleProviderSignIn(e.provider, { redirectTo: (t = e.options) === null || t === void 0 ? void 0 : t.redirectTo, scopes: (s = e.options) === null || s === void 0 ? void 0 : s.scopes, queryParams: (n = e.options) === null || n === void 0 ? void 0 : n.queryParams, skipBrowserRedirect: (i = e.options) === null || i === void 0 ? void 0 : i.skipBrowserRedirect });
  }
  async exchangeCodeForSession(e) {
    return await this.initializePromise, this._acquireLock(-1, async () => this._exchangeCodeForSession(e));
  }
  async signInWithWeb3(e) {
    const { chain: t } = e;
    switch (t) {
      case "ethereum":
        return await this.signInWithEthereum(e);
      case "solana":
        return await this.signInWithSolana(e);
      default:
        throw new Error(`@supabase/auth-js: Unsupported chain "${t}"`);
    }
  }
  async signInWithEthereum(e) {
    var t, s, n, i, a, o, l, c, u, h, d;
    let f, p;
    if ("message" in e) f = e.message, p = e.signature;
    else {
      const { chain: g, wallet: m, statement: v, options: b } = e;
      let y;
      if (j()) if (typeof m == "object") y = m;
      else {
        const W = window;
        if ("ethereum" in W && typeof W.ethereum == "object" && "request" in W.ethereum && typeof W.ethereum.request == "function") y = W.ethereum;
        else throw new Error("@supabase/auth-js: No compatible Ethereum wallet interface on the window object (window.ethereum) detected. Make sure the user already has a wallet installed and connected for this app. Prefer passing the wallet interface object directly to signInWithWeb3({ chain: 'ethereum', wallet: resolvedUserWallet }) instead.");
      }
      else {
        if (typeof m != "object" || !(b == null ? void 0 : b.url)) throw new Error("@supabase/auth-js: Both wallet and url must be specified in non-browser environments.");
        y = m;
      }
      const k = new URL((t = b == null ? void 0 : b.url) !== null && t !== void 0 ? t : window.location.href), $ = await y.request({ method: "eth_requestAccounts" }).then((W) => W).catch(() => {
        throw new Error("@supabase/auth-js: Wallet method eth_requestAccounts is missing or invalid");
      });
      if (!$ || $.length === 0) throw new Error("@supabase/auth-js: No accounts available. Please ensure the wallet is connected.");
      const T = er($[0]);
      let R = (s = b == null ? void 0 : b.signInWithEthereum) === null || s === void 0 ? void 0 : s.chainId;
      if (!R) {
        const W = await y.request({ method: "eth_chainId" });
        R = Cn(W);
      }
      const F = { domain: k.host, address: T, statement: v, uri: k.href, version: "1", chainId: R, nonce: (n = b == null ? void 0 : b.signInWithEthereum) === null || n === void 0 ? void 0 : n.nonce, issuedAt: (a = (i = b == null ? void 0 : b.signInWithEthereum) === null || i === void 0 ? void 0 : i.issuedAt) !== null && a !== void 0 ? a : /* @__PURE__ */ new Date(), expirationTime: (o = b == null ? void 0 : b.signInWithEthereum) === null || o === void 0 ? void 0 : o.expirationTime, notBefore: (l = b == null ? void 0 : b.signInWithEthereum) === null || l === void 0 ? void 0 : l.notBefore, requestId: (c = b == null ? void 0 : b.signInWithEthereum) === null || c === void 0 ? void 0 : c.requestId, resources: (u = b == null ? void 0 : b.signInWithEthereum) === null || u === void 0 ? void 0 : u.resources };
      f = Pn(F), p = await y.request({ method: "personal_sign", params: [$n(f), T] });
    }
    try {
      const { data: g, error: m } = await _(this.fetch, "POST", `${this.url}/token?grant_type=web3`, { headers: this.headers, body: Object.assign({ chain: "ethereum", message: f, signature: p }, !((h = e.options) === null || h === void 0) && h.captchaToken ? { gotrue_meta_security: { captcha_token: (d = e.options) === null || d === void 0 ? void 0 : d.captchaToken } } : null), xform: L });
      if (m) throw m;
      if (!g || !g.session || !g.user) {
        const v = new ne();
        return this._returnResult({ data: { user: null, session: null }, error: v });
      }
      return g.session && (await this._saveSession(g.session), await this._notifyAllSubscribers("SIGNED_IN", g.session)), this._returnResult({ data: Object.assign({}, g), error: m });
    } catch (g) {
      if (w(g)) return this._returnResult({ data: { user: null, session: null }, error: g });
      throw g;
    }
  }
  async signInWithSolana(e) {
    var t, s, n, i, a, o, l, c, u, h, d, f;
    let p, g;
    if ("message" in e) p = e.message, g = e.signature;
    else {
      const { chain: m, wallet: v, statement: b, options: y } = e;
      let k;
      if (j()) if (typeof v == "object") k = v;
      else {
        const T = window;
        if ("solana" in T && typeof T.solana == "object" && ("signIn" in T.solana && typeof T.solana.signIn == "function" || "signMessage" in T.solana && typeof T.solana.signMessage == "function")) k = T.solana;
        else throw new Error("@supabase/auth-js: No compatible Solana wallet interface on the window object (window.solana) detected. Make sure the user already has a wallet installed and connected for this app. Prefer passing the wallet interface object directly to signInWithWeb3({ chain: 'solana', wallet: resolvedUserWallet }) instead.");
      }
      else {
        if (typeof v != "object" || !(y == null ? void 0 : y.url)) throw new Error("@supabase/auth-js: Both wallet and url must be specified in non-browser environments.");
        k = v;
      }
      const $ = new URL((t = y == null ? void 0 : y.url) !== null && t !== void 0 ? t : window.location.href);
      if ("signIn" in k && k.signIn) {
        const T = await k.signIn(Object.assign(Object.assign(Object.assign({ issuedAt: (/* @__PURE__ */ new Date()).toISOString() }, y == null ? void 0 : y.signInWithSolana), { version: "1", domain: $.host, uri: $.href }), b ? { statement: b } : null));
        let R;
        if (Array.isArray(T) && T[0] && typeof T[0] == "object") R = T[0];
        else if (T && typeof T == "object" && "signedMessage" in T && "signature" in T) R = T;
        else throw new Error("@supabase/auth-js: Wallet method signIn() returned unrecognized value");
        if ("signedMessage" in R && "signature" in R && (typeof R.signedMessage == "string" || R.signedMessage instanceof Uint8Array) && R.signature instanceof Uint8Array) p = typeof R.signedMessage == "string" ? R.signedMessage : new TextDecoder().decode(R.signedMessage), g = R.signature;
        else throw new Error("@supabase/auth-js: Wallet method signIn() API returned object without signedMessage and signature fields");
      } else {
        if (!("signMessage" in k) || typeof k.signMessage != "function" || !("publicKey" in k) || typeof k != "object" || !k.publicKey || !("toBase58" in k.publicKey) || typeof k.publicKey.toBase58 != "function") throw new Error("@supabase/auth-js: Wallet does not have a compatible signMessage() and publicKey.toBase58() API");
        p = [`${$.host} wants you to sign in with your Solana account:`, k.publicKey.toBase58(), ...b ? ["", b, ""] : [""], "Version: 1", `URI: ${$.href}`, `Issued At: ${(n = (s = y == null ? void 0 : y.signInWithSolana) === null || s === void 0 ? void 0 : s.issuedAt) !== null && n !== void 0 ? n : (/* @__PURE__ */ new Date()).toISOString()}`, ...!((i = y == null ? void 0 : y.signInWithSolana) === null || i === void 0) && i.notBefore ? [`Not Before: ${y.signInWithSolana.notBefore}`] : [], ...!((a = y == null ? void 0 : y.signInWithSolana) === null || a === void 0) && a.expirationTime ? [`Expiration Time: ${y.signInWithSolana.expirationTime}`] : [], ...!((o = y == null ? void 0 : y.signInWithSolana) === null || o === void 0) && o.chainId ? [`Chain ID: ${y.signInWithSolana.chainId}`] : [], ...!((l = y == null ? void 0 : y.signInWithSolana) === null || l === void 0) && l.nonce ? [`Nonce: ${y.signInWithSolana.nonce}`] : [], ...!((c = y == null ? void 0 : y.signInWithSolana) === null || c === void 0) && c.requestId ? [`Request ID: ${y.signInWithSolana.requestId}`] : [], ...!((h = (u = y == null ? void 0 : y.signInWithSolana) === null || u === void 0 ? void 0 : u.resources) === null || h === void 0) && h.length ? ["Resources", ...y.signInWithSolana.resources.map((R) => `- ${R}`)] : []].join(`
`);
        const T = await k.signMessage(new TextEncoder().encode(p), "utf8");
        if (!T || !(T instanceof Uint8Array)) throw new Error("@supabase/auth-js: Wallet signMessage() API returned an recognized value");
        g = T;
      }
    }
    try {
      const { data: m, error: v } = await _(this.fetch, "POST", `${this.url}/token?grant_type=web3`, { headers: this.headers, body: Object.assign({ chain: "solana", message: p, signature: te(g) }, !((d = e.options) === null || d === void 0) && d.captchaToken ? { gotrue_meta_security: { captcha_token: (f = e.options) === null || f === void 0 ? void 0 : f.captchaToken } } : null), xform: L });
      if (v) throw v;
      if (!m || !m.session || !m.user) {
        const b = new ne();
        return this._returnResult({ data: { user: null, session: null }, error: b });
      }
      return m.session && (await this._saveSession(m.session), await this._notifyAllSubscribers("SIGNED_IN", m.session)), this._returnResult({ data: Object.assign({}, m), error: v });
    } catch (m) {
      if (w(m)) return this._returnResult({ data: { user: null, session: null }, error: m });
      throw m;
    }
  }
  async _exchangeCodeForSession(e) {
    const t = await X(this.storage, `${this.storageKey}-code-verifier`), [s, n] = (t ?? "").split("/");
    try {
      if (!s && this.flowType === "pkce") throw new Qs();
      const { data: i, error: a } = await _(this.fetch, "POST", `${this.url}/token?grant_type=pkce`, { headers: this.headers, body: { auth_code: e, code_verifier: s }, xform: L });
      if (await P(this.storage, `${this.storageKey}-code-verifier`), a) throw a;
      if (!i || !i.session || !i.user) {
        const o = new ne();
        return this._returnResult({ data: { user: null, session: null, redirectType: null }, error: o });
      }
      return i.session && (await this._saveSession(i.session), await this._notifyAllSubscribers("SIGNED_IN", i.session)), this._returnResult({ data: Object.assign(Object.assign({}, i), { redirectType: n ?? null }), error: a });
    } catch (i) {
      if (await P(this.storage, `${this.storageKey}-code-verifier`), w(i)) return this._returnResult({ data: { user: null, session: null, redirectType: null }, error: i });
      throw i;
    }
  }
  async signInWithIdToken(e) {
    try {
      const { options: t, provider: s, token: n, access_token: i, nonce: a } = e, o = await _(this.fetch, "POST", `${this.url}/token?grant_type=id_token`, { headers: this.headers, body: { provider: s, id_token: n, access_token: i, nonce: a, gotrue_meta_security: { captcha_token: t == null ? void 0 : t.captchaToken } }, xform: L }), { data: l, error: c } = o;
      if (c) return this._returnResult({ data: { user: null, session: null }, error: c });
      if (!l || !l.session || !l.user) {
        const u = new ne();
        return this._returnResult({ data: { user: null, session: null }, error: u });
      }
      return l.session && (await this._saveSession(l.session), await this._notifyAllSubscribers("SIGNED_IN", l.session)), this._returnResult({ data: l, error: c });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: { user: null, session: null }, error: t });
      throw t;
    }
  }
  async signInWithOtp(e) {
    var t, s, n, i, a;
    try {
      if ("email" in e) {
        const { email: o, options: l } = e;
        let c = null, u = null;
        this.flowType === "pkce" && ([c, u] = await ie(this.storage, this.storageKey));
        const { error: h } = await _(this.fetch, "POST", `${this.url}/otp`, { headers: this.headers, body: { email: o, data: (t = l == null ? void 0 : l.data) !== null && t !== void 0 ? t : {}, create_user: (s = l == null ? void 0 : l.shouldCreateUser) !== null && s !== void 0 ? s : true, gotrue_meta_security: { captcha_token: l == null ? void 0 : l.captchaToken }, code_challenge: c, code_challenge_method: u }, redirectTo: l == null ? void 0 : l.emailRedirectTo });
        return this._returnResult({ data: { user: null, session: null }, error: h });
      }
      if ("phone" in e) {
        const { phone: o, options: l } = e, { data: c, error: u } = await _(this.fetch, "POST", `${this.url}/otp`, { headers: this.headers, body: { phone: o, data: (n = l == null ? void 0 : l.data) !== null && n !== void 0 ? n : {}, create_user: (i = l == null ? void 0 : l.shouldCreateUser) !== null && i !== void 0 ? i : true, gotrue_meta_security: { captcha_token: l == null ? void 0 : l.captchaToken }, channel: (a = l == null ? void 0 : l.channel) !== null && a !== void 0 ? a : "sms" } });
        return this._returnResult({ data: { user: null, session: null, messageId: c == null ? void 0 : c.message_id }, error: u });
      }
      throw new xe("You must provide either an email or phone number.");
    } catch (o) {
      if (await P(this.storage, `${this.storageKey}-code-verifier`), w(o)) return this._returnResult({ data: { user: null, session: null }, error: o });
      throw o;
    }
  }
  async verifyOtp(e) {
    var t, s;
    try {
      let n, i;
      "options" in e && (n = (t = e.options) === null || t === void 0 ? void 0 : t.redirectTo, i = (s = e.options) === null || s === void 0 ? void 0 : s.captchaToken);
      const { data: a, error: o } = await _(this.fetch, "POST", `${this.url}/verify`, { headers: this.headers, body: Object.assign(Object.assign({}, e), { gotrue_meta_security: { captcha_token: i } }), redirectTo: n, xform: L });
      if (o) throw o;
      if (!a) throw new Error("An error occurred on token verification.");
      const l = a.session, c = a.user;
      return (l == null ? void 0 : l.access_token) && (await this._saveSession(l), await this._notifyAllSubscribers(e.type == "recovery" ? "PASSWORD_RECOVERY" : "SIGNED_IN", l)), this._returnResult({ data: { user: c, session: l }, error: null });
    } catch (n) {
      if (w(n)) return this._returnResult({ data: { user: null, session: null }, error: n });
      throw n;
    }
  }
  async signInWithSSO(e) {
    var t, s, n, i, a;
    try {
      let o = null, l = null;
      this.flowType === "pkce" && ([o, l] = await ie(this.storage, this.storageKey));
      const c = await _(this.fetch, "POST", `${this.url}/sso`, { body: Object.assign(Object.assign(Object.assign(Object.assign(Object.assign({}, "providerId" in e ? { provider_id: e.providerId } : null), "domain" in e ? { domain: e.domain } : null), { redirect_to: (s = (t = e.options) === null || t === void 0 ? void 0 : t.redirectTo) !== null && s !== void 0 ? s : void 0 }), !((n = e == null ? void 0 : e.options) === null || n === void 0) && n.captchaToken ? { gotrue_meta_security: { captcha_token: e.options.captchaToken } } : null), { skip_http_redirect: true, code_challenge: o, code_challenge_method: l }), headers: this.headers, xform: kn });
      return !((i = c.data) === null || i === void 0) && i.url && j() && !(!((a = e.options) === null || a === void 0) && a.skipBrowserRedirect) && window.location.assign(c.data.url), this._returnResult(c);
    } catch (o) {
      if (await P(this.storage, `${this.storageKey}-code-verifier`), w(o)) return this._returnResult({ data: null, error: o });
      throw o;
    }
  }
  async reauthenticate() {
    return await this.initializePromise, await this._acquireLock(-1, async () => await this._reauthenticate());
  }
  async _reauthenticate() {
    try {
      return await this._useSession(async (e) => {
        const { data: { session: t }, error: s } = e;
        if (s) throw s;
        if (!t) throw new B();
        const { error: n } = await _(this.fetch, "GET", `${this.url}/reauthenticate`, { headers: this.headers, jwt: t.access_token });
        return this._returnResult({ data: { user: null, session: null }, error: n });
      });
    } catch (e) {
      if (w(e)) return this._returnResult({ data: { user: null, session: null }, error: e });
      throw e;
    }
  }
  async resend(e) {
    try {
      const t = `${this.url}/resend`;
      if ("email" in e) {
        const { email: s, type: n, options: i } = e, { error: a } = await _(this.fetch, "POST", t, { headers: this.headers, body: { email: s, type: n, gotrue_meta_security: { captcha_token: i == null ? void 0 : i.captchaToken } }, redirectTo: i == null ? void 0 : i.emailRedirectTo });
        return this._returnResult({ data: { user: null, session: null }, error: a });
      } else if ("phone" in e) {
        const { phone: s, type: n, options: i } = e, { data: a, error: o } = await _(this.fetch, "POST", t, { headers: this.headers, body: { phone: s, type: n, gotrue_meta_security: { captcha_token: i == null ? void 0 : i.captchaToken } } });
        return this._returnResult({ data: { user: null, session: null, messageId: a == null ? void 0 : a.message_id }, error: o });
      }
      throw new xe("You must provide either an email or phone number and a type");
    } catch (t) {
      if (w(t)) return this._returnResult({ data: { user: null, session: null }, error: t });
      throw t;
    }
  }
  async getSession() {
    return await this.initializePromise, await this._acquireLock(-1, async () => this._useSession(async (t) => t));
  }
  async _acquireLock(e, t) {
    this._debug("#_acquireLock", "begin", e);
    try {
      if (this.lockAcquired) {
        const s = this.pendingInLock.length ? this.pendingInLock[this.pendingInLock.length - 1] : Promise.resolve(), n = (async () => (await s, await t()))();
        return this.pendingInLock.push((async () => {
          try {
            await n;
          } catch {
          }
        })()), n;
      }
      return await this.lock(`lock:${this.storageKey}`, e, async () => {
        this._debug("#_acquireLock", "lock acquired for storage key", this.storageKey);
        try {
          this.lockAcquired = true;
          const s = t();
          for (this.pendingInLock.push((async () => {
            try {
              await s;
            } catch {
            }
          })()), await s; this.pendingInLock.length; ) {
            const n = [...this.pendingInLock];
            await Promise.all(n), this.pendingInLock.splice(0, n.length);
          }
          return await s;
        } finally {
          this._debug("#_acquireLock", "lock released for storage key", this.storageKey), this.lockAcquired = false;
        }
      });
    } finally {
      this._debug("#_acquireLock", "end");
    }
  }
  async _useSession(e) {
    this._debug("#_useSession", "begin");
    try {
      const t = await this.__loadSession();
      return await e(t);
    } finally {
      this._debug("#_useSession", "end");
    }
  }
  async __loadSession() {
    this._debug("#__loadSession()", "begin"), this.lockAcquired || this._debug("#__loadSession()", "used outside of an acquired lock!", new Error().stack);
    try {
      let e = null;
      const t = await X(this.storage, this.storageKey);
      if (this._debug("#getSession()", "session from storage", t), t !== null && (this._isValidSession(t) ? e = t : (this._debug("#getSession()", "session from storage is not valid"), await this._removeSession())), !e) return { data: { session: null }, error: null };
      const s = e.expires_at ? e.expires_at * 1e3 - Date.now() < Me : false;
      if (this._debug("#__loadSession()", `session has${s ? "" : " not"} expired`, "expires_at", e.expires_at), !s) {
        if (this.userStorage) {
          const a = await X(this.userStorage, this.storageKey + "-user");
          (a == null ? void 0 : a.user) ? e.user = a.user : e.user = We();
        }
        if (this.storage.isServer && e.user && !e.user.__isUserNotAvailableProxy) {
          const a = { value: this.suppressGetSessionWarning };
          e.user = bn(e.user, a), a.value && (this.suppressGetSessionWarning = true);
        }
        return { data: { session: e }, error: null };
      }
      const { data: n, error: i } = await this._callRefreshToken(e.refresh_token);
      return i ? this._returnResult({ data: { session: null }, error: i }) : this._returnResult({ data: { session: n }, error: null });
    } finally {
      this._debug("#__loadSession()", "end");
    }
  }
  async getUser(e) {
    if (e) return await this._getUser(e);
    await this.initializePromise;
    const t = await this._acquireLock(-1, async () => await this._getUser());
    return t.data.user && (this.suppressGetSessionWarning = true), t;
  }
  async _getUser(e) {
    try {
      return e ? await _(this.fetch, "GET", `${this.url}/user`, { headers: this.headers, jwt: e, xform: G }) : await this._useSession(async (t) => {
        var s, n, i;
        const { data: a, error: o } = t;
        if (o) throw o;
        return !(!((s = a.session) === null || s === void 0) && s.access_token) && !this.hasCustomAuthorizationHeader ? { data: { user: null }, error: new B() } : await _(this.fetch, "GET", `${this.url}/user`, { headers: this.headers, jwt: (i = (n = a.session) === null || n === void 0 ? void 0 : n.access_token) !== null && i !== void 0 ? i : void 0, xform: G });
      });
    } catch (t) {
      if (w(t)) return Ys(t) && (await this._removeSession(), await P(this.storage, `${this.storageKey}-code-verifier`)), this._returnResult({ data: { user: null }, error: t });
      throw t;
    }
  }
  async updateUser(e, t = {}) {
    return await this.initializePromise, await this._acquireLock(-1, async () => await this._updateUser(e, t));
  }
  async _updateUser(e, t = {}) {
    try {
      return await this._useSession(async (s) => {
        const { data: n, error: i } = s;
        if (i) throw i;
        if (!n.session) throw new B();
        const a = n.session;
        let o = null, l = null;
        this.flowType === "pkce" && e.email != null && ([o, l] = await ie(this.storage, this.storageKey));
        const { data: c, error: u } = await _(this.fetch, "PUT", `${this.url}/user`, { headers: this.headers, redirectTo: t == null ? void 0 : t.emailRedirectTo, body: Object.assign(Object.assign({}, e), { code_challenge: o, code_challenge_method: l }), jwt: a.access_token, xform: G });
        if (u) throw u;
        return a.user = c.user, await this._saveSession(a), await this._notifyAllSubscribers("USER_UPDATED", a), this._returnResult({ data: { user: a.user }, error: null });
      });
    } catch (s) {
      if (await P(this.storage, `${this.storageKey}-code-verifier`), w(s)) return this._returnResult({ data: { user: null }, error: s });
      throw s;
    }
  }
  async setSession(e) {
    return await this.initializePromise, await this._acquireLock(-1, async () => await this._setSession(e));
  }
  async _setSession(e) {
    try {
      if (!e.access_token || !e.refresh_token) throw new B();
      const t = Date.now() / 1e3;
      let s = t, n = true, i = null;
      const { payload: a } = Ve(e.access_token);
      if (a.exp && (s = a.exp, n = s <= t), n) {
        const { data: o, error: l } = await this._callRefreshToken(e.refresh_token);
        if (l) return this._returnResult({ data: { user: null, session: null }, error: l });
        if (!o) return { data: { user: null, session: null }, error: null };
        i = o;
      } else {
        const { data: o, error: l } = await this._getUser(e.access_token);
        if (l) throw l;
        i = { access_token: e.access_token, refresh_token: e.refresh_token, user: o.user, token_type: "bearer", expires_in: s - t, expires_at: s }, await this._saveSession(i), await this._notifyAllSubscribers("SIGNED_IN", i);
      }
      return this._returnResult({ data: { user: i.user, session: i }, error: null });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: { session: null, user: null }, error: t });
      throw t;
    }
  }
  async refreshSession(e) {
    return await this.initializePromise, await this._acquireLock(-1, async () => await this._refreshSession(e));
  }
  async _refreshSession(e) {
    try {
      return await this._useSession(async (t) => {
        var s;
        if (!e) {
          const { data: a, error: o } = t;
          if (o) throw o;
          e = (s = a.session) !== null && s !== void 0 ? s : void 0;
        }
        if (!(e == null ? void 0 : e.refresh_token)) throw new B();
        const { data: n, error: i } = await this._callRefreshToken(e.refresh_token);
        return i ? this._returnResult({ data: { user: null, session: null }, error: i }) : n ? this._returnResult({ data: { user: n.user, session: n }, error: null }) : this._returnResult({ data: { user: null, session: null }, error: null });
      });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: { user: null, session: null }, error: t });
      throw t;
    }
  }
  async _getSessionFromURL(e, t) {
    try {
      if (!j()) throw new Oe("No browser detected.");
      if (e.error || e.error_description || e.error_code) throw new Oe(e.error_description || "Error in URL with unspecified error_description", { error: e.error || "unspecified_error", code: e.error_code || "unspecified_code" });
      switch (t) {
        case "implicit":
          if (this.flowType === "pkce") throw new _t("Not a valid PKCE flow url.");
          break;
        case "pkce":
          if (this.flowType === "implicit") throw new Oe("Not a valid implicit grant flow url.");
          break;
        default:
      }
      if (t === "pkce") {
        if (this._debug("#_initialize()", "begin", "is PKCE flow", true), !e.code) throw new _t("No code detected.");
        const { data: b, error: y } = await this._exchangeCodeForSession(e.code);
        if (y) throw y;
        const k = new URL(window.location.href);
        return k.searchParams.delete("code"), window.history.replaceState(window.history.state, "", k.toString()), { data: { session: b.session, redirectType: null }, error: null };
      }
      const { provider_token: s, provider_refresh_token: n, access_token: i, refresh_token: a, expires_in: o, expires_at: l, token_type: c } = e;
      if (!i || !o || !a || !c) throw new Oe("No session defined in URL");
      const u = Math.round(Date.now() / 1e3), h = parseInt(o);
      let d = u + h;
      l && (d = parseInt(l));
      const f = d - u;
      f * 1e3 <= ue && console.warn(`@supabase/gotrue-js: Session as retrieved from URL expires in ${f}s, should have been closer to ${h}s`);
      const p = d - h;
      u - p >= 120 ? console.warn("@supabase/gotrue-js: Session as retrieved from URL was issued over 120s ago, URL could be stale", p, d, u) : u - p < 0 && console.warn("@supabase/gotrue-js: Session as retrieved from URL was issued in the future? Check the device clock for skew", p, d, u);
      const { data: g, error: m } = await this._getUser(i);
      if (m) throw m;
      const v = { provider_token: s, provider_refresh_token: n, access_token: i, expires_in: h, expires_at: d, refresh_token: a, token_type: c, user: g.user };
      return window.location.hash = "", this._debug("#_getSessionFromURL()", "clearing window.location.hash"), this._returnResult({ data: { session: v, redirectType: e.type }, error: null });
    } catch (s) {
      if (w(s)) return this._returnResult({ data: { session: null, redirectType: null }, error: s });
      throw s;
    }
  }
  _isImplicitGrantCallback(e) {
    return typeof this.detectSessionInUrl == "function" ? this.detectSessionInUrl(new URL(window.location.href), e) : !!(e.access_token || e.error_description);
  }
  async _isPKCECallback(e) {
    const t = await X(this.storage, `${this.storageKey}-code-verifier`);
    return !!(e.code && t);
  }
  async signOut(e = { scope: "global" }) {
    return await this.initializePromise, await this._acquireLock(-1, async () => await this._signOut(e));
  }
  async _signOut({ scope: e } = { scope: "global" }) {
    return await this._useSession(async (t) => {
      var s;
      const { data: n, error: i } = t;
      if (i) return this._returnResult({ error: i });
      const a = (s = n.session) === null || s === void 0 ? void 0 : s.access_token;
      if (a) {
        const { error: o } = await this.admin.signOut(a, e);
        if (o && !(Js(o) && (o.status === 404 || o.status === 401 || o.status === 403))) return this._returnResult({ error: o });
      }
      return e !== "others" && (await this._removeSession(), await P(this.storage, `${this.storageKey}-code-verifier`)), this._returnResult({ error: null });
    });
  }
  onAuthStateChange(e) {
    const t = an(), s = { id: t, callback: e, unsubscribe: () => {
      this._debug("#unsubscribe()", "state change callback with id removed", t), this.stateChangeEmitters.delete(t);
    } };
    return this._debug("#onAuthStateChange()", "registered callback with id", t), this.stateChangeEmitters.set(t, s), (async () => (await this.initializePromise, await this._acquireLock(-1, async () => {
      this._emitInitialSession(t);
    })))(), { data: { subscription: s } };
  }
  async _emitInitialSession(e) {
    return await this._useSession(async (t) => {
      var s, n;
      try {
        const { data: { session: i }, error: a } = t;
        if (a) throw a;
        await ((s = this.stateChangeEmitters.get(e)) === null || s === void 0 ? void 0 : s.callback("INITIAL_SESSION", i)), this._debug("INITIAL_SESSION", "callback id", e, "session", i);
      } catch (i) {
        await ((n = this.stateChangeEmitters.get(e)) === null || n === void 0 ? void 0 : n.callback("INITIAL_SESSION", null)), this._debug("INITIAL_SESSION", "callback id", e, "error", i), console.error(i);
      }
    });
  }
  async resetPasswordForEmail(e, t = {}) {
    let s = null, n = null;
    this.flowType === "pkce" && ([s, n] = await ie(this.storage, this.storageKey, true));
    try {
      return await _(this.fetch, "POST", `${this.url}/recover`, { body: { email: e, code_challenge: s, code_challenge_method: n, gotrue_meta_security: { captcha_token: t.captchaToken } }, headers: this.headers, redirectTo: t.redirectTo });
    } catch (i) {
      if (await P(this.storage, `${this.storageKey}-code-verifier`), w(i)) return this._returnResult({ data: null, error: i });
      throw i;
    }
  }
  async getUserIdentities() {
    var e;
    try {
      const { data: t, error: s } = await this.getUser();
      if (s) throw s;
      return this._returnResult({ data: { identities: (e = t.user.identities) !== null && e !== void 0 ? e : [] }, error: null });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: null, error: t });
      throw t;
    }
  }
  async linkIdentity(e) {
    return "token" in e ? this.linkIdentityIdToken(e) : this.linkIdentityOAuth(e);
  }
  async linkIdentityOAuth(e) {
    var t;
    try {
      const { data: s, error: n } = await this._useSession(async (i) => {
        var a, o, l, c, u;
        const { data: h, error: d } = i;
        if (d) throw d;
        const f = await this._getUrlForProvider(`${this.url}/user/identities/authorize`, e.provider, { redirectTo: (a = e.options) === null || a === void 0 ? void 0 : a.redirectTo, scopes: (o = e.options) === null || o === void 0 ? void 0 : o.scopes, queryParams: (l = e.options) === null || l === void 0 ? void 0 : l.queryParams, skipBrowserRedirect: true });
        return await _(this.fetch, "GET", f, { headers: this.headers, jwt: (u = (c = h.session) === null || c === void 0 ? void 0 : c.access_token) !== null && u !== void 0 ? u : void 0 });
      });
      if (n) throw n;
      return j() && !(!((t = e.options) === null || t === void 0) && t.skipBrowserRedirect) && window.location.assign(s == null ? void 0 : s.url), this._returnResult({ data: { provider: e.provider, url: s == null ? void 0 : s.url }, error: null });
    } catch (s) {
      if (w(s)) return this._returnResult({ data: { provider: e.provider, url: null }, error: s });
      throw s;
    }
  }
  async linkIdentityIdToken(e) {
    return await this._useSession(async (t) => {
      var s;
      try {
        const { error: n, data: { session: i } } = t;
        if (n) throw n;
        const { options: a, provider: o, token: l, access_token: c, nonce: u } = e, h = await _(this.fetch, "POST", `${this.url}/token?grant_type=id_token`, { headers: this.headers, jwt: (s = i == null ? void 0 : i.access_token) !== null && s !== void 0 ? s : void 0, body: { provider: o, id_token: l, access_token: c, nonce: u, link_identity: true, gotrue_meta_security: { captcha_token: a == null ? void 0 : a.captchaToken } }, xform: L }), { data: d, error: f } = h;
        return f ? this._returnResult({ data: { user: null, session: null }, error: f }) : !d || !d.session || !d.user ? this._returnResult({ data: { user: null, session: null }, error: new ne() }) : (d.session && (await this._saveSession(d.session), await this._notifyAllSubscribers("USER_UPDATED", d.session)), this._returnResult({ data: d, error: f }));
      } catch (n) {
        if (await P(this.storage, `${this.storageKey}-code-verifier`), w(n)) return this._returnResult({ data: { user: null, session: null }, error: n });
        throw n;
      }
    });
  }
  async unlinkIdentity(e) {
    try {
      return await this._useSession(async (t) => {
        var s, n;
        const { data: i, error: a } = t;
        if (a) throw a;
        return await _(this.fetch, "DELETE", `${this.url}/user/identities/${e.identity_id}`, { headers: this.headers, jwt: (n = (s = i.session) === null || s === void 0 ? void 0 : s.access_token) !== null && n !== void 0 ? n : void 0 });
      });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: null, error: t });
      throw t;
    }
  }
  async _refreshAccessToken(e) {
    const t = `#_refreshAccessToken(${e.substring(0, 5)}...)`;
    this._debug(t, "begin");
    try {
      const s = Date.now();
      return await un(async (n) => (n > 0 && await cn(200 * Math.pow(2, n - 1)), this._debug(t, "refreshing attempt", n), await _(this.fetch, "POST", `${this.url}/token?grant_type=refresh_token`, { body: { refresh_token: e }, headers: this.headers, xform: L })), (n, i) => {
        const a = 200 * Math.pow(2, n);
        return i && qe(i) && Date.now() + a - s < ue;
      });
    } catch (s) {
      if (this._debug(t, "error", s), w(s)) return this._returnResult({ data: { session: null, user: null }, error: s });
      throw s;
    } finally {
      this._debug(t, "end");
    }
  }
  _isValidSession(e) {
    return typeof e == "object" && e !== null && "access_token" in e && "refresh_token" in e && "expires_at" in e;
  }
  async _handleProviderSignIn(e, t) {
    const s = await this._getUrlForProvider(`${this.url}/authorize`, e, { redirectTo: t.redirectTo, scopes: t.scopes, queryParams: t.queryParams });
    return this._debug("#_handleProviderSignIn()", "provider", e, "options", t, "url", s), j() && !t.skipBrowserRedirect && window.location.assign(s), { data: { provider: e, url: s }, error: null };
  }
  async _recoverAndRefresh() {
    var e, t;
    const s = "#_recoverAndRefresh()";
    this._debug(s, "begin");
    try {
      const n = await X(this.storage, this.storageKey);
      if (n && this.userStorage) {
        let a = await X(this.userStorage, this.storageKey + "-user");
        !this.storage.isServer && Object.is(this.storage, this.userStorage) && !a && (a = { user: n.user }, await de(this.userStorage, this.storageKey + "-user", a)), n.user = (e = a == null ? void 0 : a.user) !== null && e !== void 0 ? e : We();
      } else if (n && !n.user && !n.user) {
        const a = await X(this.storage, this.storageKey + "-user");
        a && (a == null ? void 0 : a.user) ? (n.user = a.user, await P(this.storage, this.storageKey + "-user"), await de(this.storage, this.storageKey, n)) : n.user = We();
      }
      if (this._debug(s, "session from storage", n), !this._isValidSession(n)) {
        this._debug(s, "session is not valid"), n !== null && await this._removeSession();
        return;
      }
      const i = ((t = n.expires_at) !== null && t !== void 0 ? t : 1 / 0) * 1e3 - Date.now() < Me;
      if (this._debug(s, `session has${i ? "" : " not"} expired with margin of ${Me}s`), i) {
        if (this.autoRefreshToken && n.refresh_token) {
          const { error: a } = await this._callRefreshToken(n.refresh_token);
          a && (console.error(a), qe(a) || (this._debug(s, "refresh failed with a non-retryable error, removing the session", a), await this._removeSession()));
        }
      } else if (n.user && n.user.__isUserNotAvailableProxy === true) try {
        const { data: a, error: o } = await this._getUser(n.access_token);
        !o && (a == null ? void 0 : a.user) ? (n.user = a.user, await this._saveSession(n), await this._notifyAllSubscribers("SIGNED_IN", n)) : this._debug(s, "could not get user data, skipping SIGNED_IN notification");
      } catch (a) {
        console.error("Error getting user data:", a), this._debug(s, "error getting user data, skipping SIGNED_IN notification", a);
      }
      else await this._notifyAllSubscribers("SIGNED_IN", n);
    } catch (n) {
      this._debug(s, "error", n), console.error(n);
      return;
    } finally {
      this._debug(s, "end");
    }
  }
  async _callRefreshToken(e) {
    var t, s;
    if (!e) throw new B();
    if (this.refreshingDeferred) return this.refreshingDeferred.promise;
    const n = `#_callRefreshToken(${e.substring(0, 5)}...)`;
    this._debug(n, "begin");
    try {
      this.refreshingDeferred = new Ue();
      const { data: i, error: a } = await this._refreshAccessToken(e);
      if (a) throw a;
      if (!i.session) throw new B();
      await this._saveSession(i.session), await this._notifyAllSubscribers("TOKEN_REFRESHED", i.session);
      const o = { data: i.session, error: null };
      return this.refreshingDeferred.resolve(o), o;
    } catch (i) {
      if (this._debug(n, "error", i), w(i)) {
        const a = { data: null, error: i };
        return qe(i) || await this._removeSession(), (t = this.refreshingDeferred) === null || t === void 0 || t.resolve(a), a;
      }
      throw (s = this.refreshingDeferred) === null || s === void 0 || s.reject(i), i;
    } finally {
      this.refreshingDeferred = null, this._debug(n, "end");
    }
  }
  async _notifyAllSubscribers(e, t, s = true) {
    const n = `#_notifyAllSubscribers(${e})`;
    this._debug(n, "begin", t, `broadcast = ${s}`);
    try {
      this.broadcastChannel && s && this.broadcastChannel.postMessage({ event: e, session: t });
      const i = [], a = Array.from(this.stateChangeEmitters.values()).map(async (o) => {
        try {
          await o.callback(e, t);
        } catch (l) {
          i.push(l);
        }
      });
      if (await Promise.all(a), i.length > 0) {
        for (let o = 0; o < i.length; o += 1) console.error(i[o]);
        throw i[0];
      }
    } finally {
      this._debug(n, "end");
    }
  }
  async _saveSession(e) {
    this._debug("#_saveSession()", e), this.suppressGetSessionWarning = true, await P(this.storage, `${this.storageKey}-code-verifier`);
    const t = Object.assign({}, e), s = t.user && t.user.__isUserNotAvailableProxy === true;
    if (this.userStorage) {
      !s && t.user && await de(this.userStorage, this.storageKey + "-user", { user: t.user });
      const n = Object.assign({}, t);
      delete n.user;
      const i = It(n);
      await de(this.storage, this.storageKey, i);
    } else {
      const n = It(t);
      await de(this.storage, this.storageKey, n);
    }
  }
  async _removeSession() {
    this._debug("#_removeSession()"), this.suppressGetSessionWarning = false, await P(this.storage, this.storageKey), await P(this.storage, this.storageKey + "-code-verifier"), await P(this.storage, this.storageKey + "-user"), this.userStorage && await P(this.userStorage, this.storageKey + "-user"), await this._notifyAllSubscribers("SIGNED_OUT", null);
  }
  _removeVisibilityChangedCallback() {
    this._debug("#_removeVisibilityChangedCallback()");
    const e = this.visibilityChangedCallback;
    this.visibilityChangedCallback = null;
    try {
      e && j() && (window == null ? void 0 : window.removeEventListener) && window.removeEventListener("visibilitychange", e);
    } catch (t) {
      console.error("removing visibilitychange callback failed", t);
    }
  }
  async _startAutoRefresh() {
    await this._stopAutoRefresh(), this._debug("#_startAutoRefresh()");
    const e = setInterval(() => this._autoRefreshTokenTick(), ue);
    this.autoRefreshTicker = e, e && typeof e == "object" && typeof e.unref == "function" ? e.unref() : typeof Deno < "u" && typeof Deno.unrefTimer == "function" && Deno.unrefTimer(e), setTimeout(async () => {
      await this.initializePromise, await this._autoRefreshTokenTick();
    }, 0);
  }
  async _stopAutoRefresh() {
    this._debug("#_stopAutoRefresh()");
    const e = this.autoRefreshTicker;
    this.autoRefreshTicker = null, e && clearInterval(e);
  }
  async startAutoRefresh() {
    this._removeVisibilityChangedCallback(), await this._startAutoRefresh();
  }
  async stopAutoRefresh() {
    this._removeVisibilityChangedCallback(), await this._stopAutoRefresh();
  }
  async _autoRefreshTokenTick() {
    this._debug("#_autoRefreshTokenTick()", "begin");
    try {
      await this._acquireLock(0, async () => {
        try {
          const e = Date.now();
          try {
            return await this._useSession(async (t) => {
              const { data: { session: s } } = t;
              if (!s || !s.refresh_token || !s.expires_at) {
                this._debug("#_autoRefreshTokenTick()", "no session");
                return;
              }
              const n = Math.floor((s.expires_at * 1e3 - e) / ue);
              this._debug("#_autoRefreshTokenTick()", `access token expires in ${n} ticks, a tick lasts ${ue}ms, refresh threshold is ${Qe} ticks`), n <= Qe && await this._callRefreshToken(s.refresh_token);
            });
          } catch (t) {
            console.error("Auto refresh tick failed with error. This is likely a transient error.", t);
          }
        } finally {
          this._debug("#_autoRefreshTokenTick()", "end");
        }
      });
    } catch (e) {
      if (e.isAcquireTimeout || e instanceof Zt) this._debug("auto refresh token tick lock not available");
      else throw e;
    }
  }
  async _handleVisibilityChange() {
    if (this._debug("#_handleVisibilityChange()"), !j() || !(window == null ? void 0 : window.addEventListener)) return this.autoRefreshToken && this.startAutoRefresh(), false;
    try {
      this.visibilityChangedCallback = async () => await this._onVisibilityChanged(false), window == null ? void 0 : window.addEventListener("visibilitychange", this.visibilityChangedCallback), await this._onVisibilityChanged(true);
    } catch (e) {
      console.error("_handleVisibilityChange", e);
    }
  }
  async _onVisibilityChanged(e) {
    const t = `#_onVisibilityChanged(${e})`;
    this._debug(t, "visibilityState", document.visibilityState), document.visibilityState === "visible" ? (this.autoRefreshToken && this._startAutoRefresh(), e || (await this.initializePromise, await this._acquireLock(-1, async () => {
      if (document.visibilityState !== "visible") {
        this._debug(t, "acquired the lock to recover the session, but the browser visibilityState is no longer visible, aborting");
        return;
      }
      await this._recoverAndRefresh();
    }))) : document.visibilityState === "hidden" && this.autoRefreshToken && this._stopAutoRefresh();
  }
  async _getUrlForProvider(e, t, s) {
    const n = [`provider=${encodeURIComponent(t)}`];
    if ((s == null ? void 0 : s.redirectTo) && n.push(`redirect_to=${encodeURIComponent(s.redirectTo)}`), (s == null ? void 0 : s.scopes) && n.push(`scopes=${encodeURIComponent(s.scopes)}`), this.flowType === "pkce") {
      const [i, a] = await ie(this.storage, this.storageKey), o = new URLSearchParams({ code_challenge: `${encodeURIComponent(i)}`, code_challenge_method: `${encodeURIComponent(a)}` });
      n.push(o.toString());
    }
    if (s == null ? void 0 : s.queryParams) {
      const i = new URLSearchParams(s.queryParams);
      n.push(i.toString());
    }
    return (s == null ? void 0 : s.skipBrowserRedirect) && n.push(`skip_http_redirect=${s.skipBrowserRedirect}`), `${e}?${n.join("&")}`;
  }
  async _unenroll(e) {
    try {
      return await this._useSession(async (t) => {
        var s;
        const { data: n, error: i } = t;
        return i ? this._returnResult({ data: null, error: i }) : await _(this.fetch, "DELETE", `${this.url}/factors/${e.factorId}`, { headers: this.headers, jwt: (s = n == null ? void 0 : n.session) === null || s === void 0 ? void 0 : s.access_token });
      });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: null, error: t });
      throw t;
    }
  }
  async _enroll(e) {
    try {
      return await this._useSession(async (t) => {
        var s, n;
        const { data: i, error: a } = t;
        if (a) return this._returnResult({ data: null, error: a });
        const o = Object.assign({ friendly_name: e.friendlyName, factor_type: e.factorType }, e.factorType === "phone" ? { phone: e.phone } : e.factorType === "totp" ? { issuer: e.issuer } : {}), { data: l, error: c } = await _(this.fetch, "POST", `${this.url}/factors`, { body: o, headers: this.headers, jwt: (s = i == null ? void 0 : i.session) === null || s === void 0 ? void 0 : s.access_token });
        return c ? this._returnResult({ data: null, error: c }) : (e.factorType === "totp" && l.type === "totp" && (!((n = l == null ? void 0 : l.totp) === null || n === void 0) && n.qr_code) && (l.totp.qr_code = `data:image/svg+xml;utf-8,${l.totp.qr_code}`), this._returnResult({ data: l, error: null }));
      });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: null, error: t });
      throw t;
    }
  }
  async _verify(e) {
    return this._acquireLock(-1, async () => {
      try {
        return await this._useSession(async (t) => {
          var s;
          const { data: n, error: i } = t;
          if (i) return this._returnResult({ data: null, error: i });
          const a = Object.assign({ challenge_id: e.challengeId }, "webauthn" in e ? { webauthn: Object.assign(Object.assign({}, e.webauthn), { credential_response: e.webauthn.type === "create" ? Mn(e.webauthn.credential_response) : qn(e.webauthn.credential_response) }) } : { code: e.code }), { data: o, error: l } = await _(this.fetch, "POST", `${this.url}/factors/${e.factorId}/verify`, { body: a, headers: this.headers, jwt: (s = n == null ? void 0 : n.session) === null || s === void 0 ? void 0 : s.access_token });
          return l ? this._returnResult({ data: null, error: l }) : (await this._saveSession(Object.assign({ expires_at: Math.round(Date.now() / 1e3) + o.expires_in }, o)), await this._notifyAllSubscribers("MFA_CHALLENGE_VERIFIED", o), this._returnResult({ data: o, error: l }));
        });
      } catch (t) {
        if (w(t)) return this._returnResult({ data: null, error: t });
        throw t;
      }
    });
  }
  async _challenge(e) {
    return this._acquireLock(-1, async () => {
      try {
        return await this._useSession(async (t) => {
          var s;
          const { data: n, error: i } = t;
          if (i) return this._returnResult({ data: null, error: i });
          const a = await _(this.fetch, "POST", `${this.url}/factors/${e.factorId}/challenge`, { body: e, headers: this.headers, jwt: (s = n == null ? void 0 : n.session) === null || s === void 0 ? void 0 : s.access_token });
          if (a.error) return a;
          const { data: o } = a;
          if (o.type !== "webauthn") return { data: o, error: null };
          switch (o.webauthn.type) {
            case "create":
              return { data: Object.assign(Object.assign({}, o), { webauthn: Object.assign(Object.assign({}, o.webauthn), { credential_options: Object.assign(Object.assign({}, o.webauthn.credential_options), { publicKey: Dn(o.webauthn.credential_options.publicKey) }) }) }), error: null };
            case "request":
              return { data: Object.assign(Object.assign({}, o), { webauthn: Object.assign(Object.assign({}, o.webauthn), { credential_options: Object.assign(Object.assign({}, o.webauthn.credential_options), { publicKey: Ln(o.webauthn.credential_options.publicKey) }) }) }), error: null };
          }
        });
      } catch (t) {
        if (w(t)) return this._returnResult({ data: null, error: t });
        throw t;
      }
    });
  }
  async _challengeAndVerify(e) {
    const { data: t, error: s } = await this._challenge({ factorId: e.factorId });
    return s ? this._returnResult({ data: null, error: s }) : await this._verify({ factorId: e.factorId, challengeId: t.id, code: e.code });
  }
  async _listFactors() {
    var e;
    const { data: { user: t }, error: s } = await this.getUser();
    if (s) return { data: null, error: s };
    const n = { all: [], phone: [], totp: [], webauthn: [] };
    for (const i of (e = t == null ? void 0 : t.factors) !== null && e !== void 0 ? e : []) n.all.push(i), i.status === "verified" && n[i.factor_type].push(i);
    return { data: n, error: null };
  }
  async _getAuthenticatorAssuranceLevel() {
    var e, t;
    const { data: { session: s }, error: n } = await this.getSession();
    if (n) return this._returnResult({ data: null, error: n });
    if (!s) return { data: { currentLevel: null, nextLevel: null, currentAuthenticationMethods: [] }, error: null };
    const { payload: i } = Ve(s.access_token);
    let a = null;
    i.aal && (a = i.aal);
    let o = a;
    ((t = (e = s.user.factors) === null || e === void 0 ? void 0 : e.filter((u) => u.status === "verified")) !== null && t !== void 0 ? t : []).length > 0 && (o = "aal2");
    const c = i.amr || [];
    return { data: { currentLevel: a, nextLevel: o, currentAuthenticationMethods: c }, error: null };
  }
  async _getAuthorizationDetails(e) {
    try {
      return await this._useSession(async (t) => {
        const { data: { session: s }, error: n } = t;
        return n ? this._returnResult({ data: null, error: n }) : s ? await _(this.fetch, "GET", `${this.url}/oauth/authorizations/${e}`, { headers: this.headers, jwt: s.access_token, xform: (i) => ({ data: i, error: null }) }) : this._returnResult({ data: null, error: new B() });
      });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: null, error: t });
      throw t;
    }
  }
  async _approveAuthorization(e, t) {
    try {
      return await this._useSession(async (s) => {
        const { data: { session: n }, error: i } = s;
        if (i) return this._returnResult({ data: null, error: i });
        if (!n) return this._returnResult({ data: null, error: new B() });
        const a = await _(this.fetch, "POST", `${this.url}/oauth/authorizations/${e}/consent`, { headers: this.headers, jwt: n.access_token, body: { action: "approve" }, xform: (o) => ({ data: o, error: null }) });
        return a.data && a.data.redirect_url && j() && !(t == null ? void 0 : t.skipBrowserRedirect) && window.location.assign(a.data.redirect_url), a;
      });
    } catch (s) {
      if (w(s)) return this._returnResult({ data: null, error: s });
      throw s;
    }
  }
  async _denyAuthorization(e, t) {
    try {
      return await this._useSession(async (s) => {
        const { data: { session: n }, error: i } = s;
        if (i) return this._returnResult({ data: null, error: i });
        if (!n) return this._returnResult({ data: null, error: new B() });
        const a = await _(this.fetch, "POST", `${this.url}/oauth/authorizations/${e}/consent`, { headers: this.headers, jwt: n.access_token, body: { action: "deny" }, xform: (o) => ({ data: o, error: null }) });
        return a.data && a.data.redirect_url && j() && !(t == null ? void 0 : t.skipBrowserRedirect) && window.location.assign(a.data.redirect_url), a;
      });
    } catch (s) {
      if (w(s)) return this._returnResult({ data: null, error: s });
      throw s;
    }
  }
  async _listOAuthGrants() {
    try {
      return await this._useSession(async (e) => {
        const { data: { session: t }, error: s } = e;
        return s ? this._returnResult({ data: null, error: s }) : t ? await _(this.fetch, "GET", `${this.url}/user/oauth/grants`, { headers: this.headers, jwt: t.access_token, xform: (n) => ({ data: n, error: null }) }) : this._returnResult({ data: null, error: new B() });
      });
    } catch (e) {
      if (w(e)) return this._returnResult({ data: null, error: e });
      throw e;
    }
  }
  async _revokeOAuthGrant(e) {
    try {
      return await this._useSession(async (t) => {
        const { data: { session: s }, error: n } = t;
        return n ? this._returnResult({ data: null, error: n }) : s ? (await _(this.fetch, "DELETE", `${this.url}/user/oauth/grants`, { headers: this.headers, jwt: s.access_token, query: { client_id: e.clientId }, noResolveJson: true }), { data: {}, error: null }) : this._returnResult({ data: null, error: new B() });
      });
    } catch (t) {
      if (w(t)) return this._returnResult({ data: null, error: t });
      throw t;
    }
  }
  async fetchJwk(e, t = { keys: [] }) {
    let s = t.keys.find((o) => o.kid === e);
    if (s) return s;
    const n = Date.now();
    if (s = this.jwks.keys.find((o) => o.kid === e), s && this.jwks_cached_at + Ks > n) return s;
    const { data: i, error: a } = await _(this.fetch, "GET", `${this.url}/.well-known/jwks.json`, { headers: this.headers });
    if (a) throw a;
    return !i.keys || i.keys.length === 0 || (this.jwks = i, this.jwks_cached_at = n, s = i.keys.find((o) => o.kid === e), !s) ? null : s;
  }
  async getClaims(e, t = {}) {
    try {
      let s = e;
      if (!s) {
        const { data: f, error: p } = await this.getSession();
        if (p || !f.session) return this._returnResult({ data: null, error: p });
        s = f.session.access_token;
      }
      const { header: n, payload: i, signature: a, raw: { header: o, payload: l } } = Ve(s);
      (t == null ? void 0 : t.allowExpired) || yn(i.exp);
      const c = !n.alg || n.alg.startsWith("HS") || !n.kid || !("crypto" in globalThis && "subtle" in globalThis.crypto) ? null : await this.fetchJwk(n.kid, (t == null ? void 0 : t.keys) ? { keys: t.keys } : t == null ? void 0 : t.jwks);
      if (!c) {
        const { error: f } = await this.getUser(s);
        if (f) throw f;
        return { data: { claims: i, header: n, signature: a }, error: null };
      }
      const u = vn(n.alg), h = await crypto.subtle.importKey("jwk", c, u, true, ["verify"]);
      if (!await crypto.subtle.verify(u, h, a, sn(`${o}.${l}`))) throw new tt("Invalid JWT signature");
      return { data: { claims: i, header: n, signature: a }, error: null };
    } catch (s) {
      if (w(s)) return this._returnResult({ data: null, error: s });
      throw s;
    }
  }
}
_e.nextInstanceID = {};
const Yn = _e, Xn = "2.89.0";
let pe = "";
typeof Deno < "u" ? pe = "deno" : typeof document < "u" ? pe = "web" : typeof navigator < "u" && navigator.product === "ReactNative" ? pe = "react-native" : pe = "node";
const Qn = { "X-Client-Info": `supabase-js-${pe}/${Xn}` }, Zn = { headers: Qn }, ei = { schema: "public" }, ti = { autoRefreshToken: true, persistSession: true, detectSessionInUrl: true, flowType: "implicit" }, ri = {};
function Ee(r) {
  "@babel/helpers - typeof";
  return Ee = typeof Symbol == "function" && typeof Symbol.iterator == "symbol" ? function(e) {
    return typeof e;
  } : function(e) {
    return e && typeof Symbol == "function" && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e;
  }, Ee(r);
}
function si(r, e) {
  if (Ee(r) != "object" || !r) return r;
  var t = r[Symbol.toPrimitive];
  if (t !== void 0) {
    var s = t.call(r, e);
    if (Ee(s) != "object") return s;
    throw new TypeError("@@toPrimitive must return a primitive value.");
  }
  return (e === "string" ? String : Number)(r);
}
function ni(r) {
  var e = si(r, "string");
  return Ee(e) == "symbol" ? e : e + "";
}
function ii(r, e, t) {
  return (e = ni(e)) in r ? Object.defineProperty(r, e, { value: t, enumerable: true, configurable: true, writable: true }) : r[e] = t, r;
}
function Pt(r, e) {
  var t = Object.keys(r);
  if (Object.getOwnPropertySymbols) {
    var s = Object.getOwnPropertySymbols(r);
    e && (s = s.filter(function(n) {
      return Object.getOwnPropertyDescriptor(r, n).enumerable;
    })), t.push.apply(t, s);
  }
  return t;
}
function O(r) {
  for (var e = 1; e < arguments.length; e++) {
    var t = arguments[e] != null ? arguments[e] : {};
    e % 2 ? Pt(Object(t), true).forEach(function(s) {
      ii(r, s, t[s]);
    }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(r, Object.getOwnPropertyDescriptors(t)) : Pt(Object(t)).forEach(function(s) {
      Object.defineProperty(r, s, Object.getOwnPropertyDescriptor(t, s));
    });
  }
  return r;
}
const ai = (r) => r ? (...e) => r(...e) : (...e) => fetch(...e), oi = () => Headers, li = (r, e, t) => {
  const s = ai(t), n = oi();
  return async (i, a) => {
    var o;
    const l = (o = await e()) !== null && o !== void 0 ? o : r;
    let c = new n(a == null ? void 0 : a.headers);
    return c.has("apikey") || c.set("apikey", r), c.has("Authorization") || c.set("Authorization", `Bearer ${l}`), s(i, O(O({}, a), {}, { headers: c }));
  };
};
function ci(r) {
  return r.endsWith("/") ? r : r + "/";
}
function ui(r, e) {
  var t, s;
  const { db: n, auth: i, realtime: a, global: o } = r, { db: l, auth: c, realtime: u, global: h } = e, d = { db: O(O({}, l), n), auth: O(O({}, c), i), realtime: O(O({}, u), a), storage: {}, global: O(O(O({}, h), o), {}, { headers: O(O({}, (t = h == null ? void 0 : h.headers) !== null && t !== void 0 ? t : {}), (s = o == null ? void 0 : o.headers) !== null && s !== void 0 ? s : {}) }), accessToken: async () => "" };
  return r.accessToken ? d.accessToken = r.accessToken : delete d.accessToken, d;
}
function di(r) {
  const e = r == null ? void 0 : r.trim();
  if (!e) throw new Error("supabaseUrl is required.");
  if (!e.match(/^https?:\/\//i)) throw new Error("Invalid supabaseUrl: Must be a valid HTTP or HTTPS URL.");
  try {
    return new URL(ci(e));
  } catch {
    throw Error("Invalid supabaseUrl: Provided URL is malformed.");
  }
}
var hi = class extends Yn {
  constructor(r) {
    super(r);
  }
}, fi = class {
  constructor(r, e, t) {
    var s, n;
    this.supabaseUrl = r, this.supabaseKey = e;
    const i = di(r);
    if (!e) throw new Error("supabaseKey is required.");
    this.realtimeUrl = new URL("realtime/v1", i), this.realtimeUrl.protocol = this.realtimeUrl.protocol.replace("http", "ws"), this.authUrl = new URL("auth/v1", i), this.storageUrl = new URL("storage/v1", i), this.functionsUrl = new URL("functions/v1", i);
    const a = `sb-${i.hostname.split(".")[0]}-auth-token`, o = { db: ei, realtime: ri, auth: O(O({}, ti), {}, { storageKey: a }), global: Zn }, l = ui(t ?? {}, o);
    if (this.storageKey = (s = l.auth.storageKey) !== null && s !== void 0 ? s : "", this.headers = (n = l.global.headers) !== null && n !== void 0 ? n : {}, l.accessToken) this.accessToken = l.accessToken, this.auth = new Proxy({}, { get: (u, h) => {
      throw new Error(`@supabase/supabase-js: Supabase Client is configured with the accessToken option, accessing supabase.auth.${String(h)} is not possible`);
    } });
    else {
      var c;
      this.auth = this._initSupabaseAuthClient((c = l.auth) !== null && c !== void 0 ? c : {}, this.headers, l.global.fetch);
    }
    this.fetch = li(e, this._getAccessToken.bind(this), l.global.fetch), this.realtime = this._initRealtimeClient(O({ headers: this.headers, accessToken: this._getAccessToken.bind(this) }, l.realtime)), this.accessToken && this.accessToken().then((u) => this.realtime.setAuth(u)).catch((u) => console.warn("Failed to set initial Realtime auth token:", u)), this.rest = new Hr(new URL("rest/v1", i).href, { headers: this.headers, schema: l.db.schema, fetch: this.fetch }), this.storage = new Vs(this.storageUrl.href, this.headers, this.fetch, t == null ? void 0 : t.storage), l.accessToken || this._listenForAuthEvents();
  }
  get functions() {
    return new Mr(this.functionsUrl.href, { headers: this.headers, customFetch: this.fetch });
  }
  from(r) {
    return this.rest.from(r);
  }
  schema(r) {
    return this.rest.schema(r);
  }
  rpc(r, e = {}, t = { head: false, get: false, count: void 0 }) {
    return this.rest.rpc(r, e, t);
  }
  channel(r, e = { config: {} }) {
    return this.realtime.channel(r, e);
  }
  getChannels() {
    return this.realtime.getChannels();
  }
  removeChannel(r) {
    return this.realtime.removeChannel(r);
  }
  removeAllChannels() {
    return this.realtime.removeAllChannels();
  }
  async _getAccessToken() {
    var r = this, e, t;
    if (r.accessToken) return await r.accessToken();
    const { data: s } = await r.auth.getSession();
    return (e = (t = s.session) === null || t === void 0 ? void 0 : t.access_token) !== null && e !== void 0 ? e : r.supabaseKey;
  }
  _initSupabaseAuthClient({ autoRefreshToken: r, persistSession: e, detectSessionInUrl: t, storage: s, userStorage: n, storageKey: i, flowType: a, lock: o, debug: l, throwOnError: c }, u, h) {
    const d = { Authorization: `Bearer ${this.supabaseKey}`, apikey: `${this.supabaseKey}` };
    return new hi({ url: this.authUrl.href, headers: O(O({}, d), u), storageKey: i, autoRefreshToken: r, persistSession: e, detectSessionInUrl: t, storage: s, userStorage: n, flowType: a, lock: o, debug: l, throwOnError: c, fetch: h, hasCustomAuthorizationHeader: Object.keys(this.headers).some((f) => f.toLowerCase() === "authorization") });
  }
  _initRealtimeClient(r) {
    return new ls(this.realtimeUrl.href, O(O({}, r), {}, { params: O(O({}, { apikey: this.supabaseKey }), r == null ? void 0 : r.params) }));
  }
  _listenForAuthEvents() {
    return this.auth.onAuthStateChange((r, e) => {
      this._handleTokenChanged(r, "CLIENT", e == null ? void 0 : e.access_token);
    });
  }
  _handleTokenChanged(r, e, t) {
    (r === "TOKEN_REFRESHED" || r === "SIGNED_IN") && this.changedAccessToken !== t ? (this.changedAccessToken = t, this.realtime.setAuth(t)) : r === "SIGNED_OUT" && (this.realtime.setAuth(), e == "STORAGE" && this.auth.signOut(), this.changedAccessToken = void 0);
  }
};
const pi = (r, e, t) => new fi(r, e, t);
function gi() {
  if (typeof window < "u" || typeof process > "u") return false;
  const r = process.version;
  if (r == null) return false;
  const e = r.match(/^v(\d+)\./);
  return e ? parseInt(e[1], 10) <= 18 : false;
}
gi() && console.warn("\u26A0\uFE0F  Node.js 18 and below are deprecated and will no longer be supported in future versions of @supabase/supabase-js. Please upgrade to Node.js 20 or later. For more information, visit: https://github.com/orgs/supabase/discussions/37217");
const mi = "https://qyagfghcnzenvbhbtsvd.supabase.co", yi = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5YWdmZ2hjbnplbnZiaGJ0c3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3NDU2NjksImV4cCI6MjA4MzMyMTY2OX0.k_cVE7tLn23NIuuMJlCdWw97F_ZkPpz7SS7d-MleJVc", S = pi(mi, yi, { db: { schema: "startflix" } }), U = { activePage: "dashboard", user: null, users: [], apps: [], plans: [], settings: [], revenueChart: null, realtimeSubscriptions: {} }, jt = document.getElementById("login-overlay"), J = document.getElementById("dynamic-content"), Ut = document.getElementById("dashboard-view"), vi = document.getElementById("page-title"), rr = document.querySelectorAll(".nav-link");
function V() {
  try {
    Dt({ icons: { LayoutDashboard: yr, Users: jr, CreditCard: gr, Monitor: br, Package: _r, Settings: Tr, LogOut: vr, RefreshCw: kr, DollarSign: mr, Zap: Br, ZapOff: Ur, Plus: Sr, Edit: Or, Edit2: Er, Trash2: Ar, UserPlus: $r, Unlink: Cr, User: Pr, AlertCircle: dr, Copy: pr, MessageCircle: wr, Calendar: ur, CheckCircle: hr, XCircle: fr, Signal: xr, SignalLow: Ir, Trash: Rr } });
  } catch (r) {
    console.warn("Lucide Icons error:", r);
  }
}
async function wi() {
  var _a2, _b;
  console.log("Admin Panel: Iniciando..."), console.log("Supabase Client Config:", { url: S.supabaseUrl, schema: ((_b = (_a2 = S.options) == null ? void 0 : _a2.db) == null ? void 0 : _b.schema) || "public (default)" }), V(), bi(), _i(), Ei(), localStorage.getItem("admin_session") === "true" ? (jt.style.display = "none", ot("dashboard")) : jt.style.display = "flex", document.getElementById("login-form").addEventListener("submit", Ri);
}
function bi() {
  rr.forEach((r) => {
    r.addEventListener("click", (e) => {
      e.preventDefault();
      const t = r.getAttribute("data-page");
      ot(t);
    });
  }), document.getElementById("logout-btn").addEventListener("click", () => {
    S.auth.signOut(), localStorage.removeItem("admin_session"), location.reload();
  });
}
function _i() {
  var _a2, _b, _c, _d;
  (_a2 = document.getElementById("user-form")) == null ? void 0 : _a2.addEventListener("submit", xi), (_b = document.getElementById("app-form")) == null ? void 0 : _b.addEventListener("submit", Oi), (_c = document.getElementById("plan-form")) == null ? void 0 : _c.addEventListener("submit", Ai), (_d = document.getElementById("assign-form")) == null ? void 0 : _d.addEventListener("submit", handleAssignSubmit);
  const r = document.getElementById("user-tv-enabled"), e = document.getElementById("tv-fields");
  r == null ? void 0 : r.addEventListener("change", (i) => {
    e.style.display = i.target.checked ? "block" : "none";
  });
  const t = document.getElementById("user-tv-auth-type"), s = document.getElementById("tv-auth-mac"), n = document.getElementById("tv-auth-email");
  t == null ? void 0 : t.addEventListener("change", (i) => {
    i.target.value === "mac" ? (s.style.display = "grid", n.style.display = "none") : (s.style.display = "none", n.style.display = "grid");
  });
}
function Ei() {
  console.log("\u{1F4E1} Setting up realtime subscriptions...");
  const r = S.channel("inventory-changes").on("postgres_changes", { event: "*", schema: "startflix", table: "media_accounts" }, (s) => {
    console.log("\u{1F4E1} Inventory change detected:", s.eventType), U.activePage === "inventory" && (console.log("\u{1F504} Auto-refreshing inventory view..."), Si()), U.activePage === "dashboard" && Ae();
  }).subscribe((s) => {
    console.log("\u{1F4E1} Inventory subscription status:", s);
  });
  U.realtimeSubscriptions.inventory = r;
  const e = S.channel("users-changes").on("postgres_changes", { event: "*", schema: "startflix", table: "profiles" }, (s) => {
    console.log("\u{1F4E1} User change detected:", s.eventType), U.activePage === "users" && (console.log("\u{1F504} Auto-refreshing users view..."), re()), U.activePage === "dashboard" && Ae();
  }).subscribe((s) => {
    console.log("\u{1F4E1} Users subscription status:", s);
  });
  U.realtimeSubscriptions.users = e;
  const t = S.channel("payments-changes").on("postgres_changes", { event: "*", schema: "startflix", table: "payments" }, (s) => {
    console.log("\u{1F4E1} Payment change detected:", s.eventType), U.activePage === "payments" && (console.log("\u{1F504} Auto-refreshing payments view..."), nr()), U.activePage === "dashboard" && Ae();
  }).subscribe((s) => {
    console.log("\u{1F4E1} Payments subscription status:", s);
  });
  U.realtimeSubscriptions.payments = t;
}
async function Si() {
  try {
    const { data: r, error: e } = await S.from("media_accounts").select("*, profiles(email, full_name)").order("created_at", { ascending: false });
    if (e) throw e;
    const t = r.length, s = r.filter((c) => c.user_id).length, n = t - s, i = document.getElementById("inv-total"), a = document.getElementById("inv-free"), o = document.getElementById("inv-used");
    i && (i.innerText = t), a && (a.innerText = n), o && (o.innerText = s);
    const l = document.getElementById("inventory-list");
    if (!l) return;
    if (t === 0) {
      l.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhuma conta cadastrada.</td></tr>';
      return;
    }
    l.innerHTML = r.map((c) => {
      var _a2, _b;
      const u = !!c.user_id, h = ((_a2 = c.profiles) == null ? void 0 : _a2.full_name) || ((_b = c.profiles) == null ? void 0 : _b.email) || (u ? "ID: " + c.user_id.substr(0, 8) : "---");
      return `
        <tr>
          <td>
            <strong style="color: white;">${c.provider_name || "Gen\xE9rico"}</strong>
            <div style="font-size: 0.75rem; color: var(--text-dim);">${c.dns || "Sem DNS"}</div>
          </td>
          <td>
            <div style="font-family: monospace; font-size: 0.9rem;">
              <span style="color: #aaa;">U:</span> ${c.username}<br>
              <span style="color: #aaa;">P:</span> ${c.password}
            </div>
          </td>
          <td>
            <span class="status-pill ${u ? "status-inactive" : "status-active"}" 
                  style="${u ? "background:rgba(245, 158, 11, 0.1); color:#f59e0b;" : ""}">
              ${u ? "EM USO" : "LIVRE"}
            </span>
          </td>
          <td>
            ${u ? `<div style="display:flex; align-items:center; gap:0.5rem;">
                 <i data-lucide="user" style="width:14px;"></i> ${h}
               </div>` : '<span style="opacity:0.3;">---</span>'}
          </td>
          <td>
             <div style="display:flex; gap:0.5rem;">
               ${u ? `<button class="btn-icon-small" onclick="releaseInventoryItem('${c.id}')" title="Liberar (Remover Cliente)" style="color:#f59e0b;"><i data-lucide="unlink"></i></button>` : `<button class="btn-icon-small" onclick="openAssignModal('${c.id}')" title="Vincular a Cliente" style="color:var(--success);"><i data-lucide="user-plus"></i></button>`}
               <button class="btn-icon-small danger" onclick="deleteInventoryItem('${c.id}')" title="Excluir"><i data-lucide="trash-2"></i></button>
             </div>
          </td>
        </tr>
      `;
    }).join(""), V(), showToast("\u{1F504} Lista atualizada automaticamente!", "success");
  } catch (r) {
    console.error("Error refreshing inventory:", r);
  }
}
window.showToast = function(r, e = "info") {
  const t = document.querySelector(".toast-notification");
  t && t.remove();
  const s = document.createElement("div");
  s.className = "toast-notification", s.innerHTML = r, s.style.cssText = `
    position: fixed;
    bottom: 100px;
    right: 20px;
    background: ${e === "success" ? "rgba(16, 185, 129, 0.95)" : e === "error" ? "rgba(239, 68, 68, 0.95)" : "rgba(59, 130, 246, 0.95)"};
    color: white;
    padding: 12px 20px;
    border-radius: 10px;
    font-size: 0.85rem;
    font-weight: 500;
    z-index: 9999;
    animation: slideInRight 0.3s ease, fadeOut 0.3s ease 2.7s forwards;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
  `, document.body.appendChild(s), setTimeout(() => {
    s.remove();
  }, 3e3);
};
const sr = document.createElement("style");
sr.textContent = `
  @keyframes slideInRight {
    from { transform: translateX(100px); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
  }
  @keyframes fadeOut {
    from { opacity: 1; }
    to { opacity: 0; }
  }
`;
document.head.appendChild(sr);
async function ot(r) {
  U.activePage = r, rr.forEach((t) => t.classList.toggle("active", t.getAttribute("data-page") === r)), Ut.style.display = "none", J.style.display = "block";
  const e = { dashboard: "Dashboard", users: "Gest\xE3o de Clientes", payments: "Hist\xF3rico de Pagamentos", apps: "Listas e Aplicativos", inventory: "Estoque / M\xEDdia", settings: "Configura\xE7\xF5es do Sistema" };
  switch (vi.innerText = e[r] || "Painel", r) {
    case "dashboard":
      Ut.style.display = "block", J.style.display = "none", Ae();
      break;
    case "users":
      re();
      break;
    case "apps":
      lt();
      break;
    case "plans":
      ct();
      break;
    case "payments":
      nr();
      break;
    case "inventory":
      ke();
      break;
    default:
      J.innerHTML = `<div class="stat-card"><h3>Em breve: ${r}</h3></div>`;
  }
  V();
}
async function Ae() {
  try {
    const { count: r, error: e } = await S.from("profiles").select("*", { count: "exact", head: true });
    e && (console.error("Erro ao buscar total de usu\xE1rios:", e), showToast("Erro ao carregar total de usu\xE1rios: " + e.message, "error")), document.getElementById("total-users").innerText = r || 0;
    const { data: t, error: s } = await S.from("profiles").select("expiration_date");
    s && console.error("Erro ao buscar status de assinaturas:", s);
    const n = /* @__PURE__ */ new Date(), i = (t == null ? void 0 : t.filter((d) => d.expiration_date && new Date(d.expiration_date) > n).length) || 0, a = (r || 0) - i;
    document.getElementById("active-subs").innerText = i, document.getElementById("expired-subs").innerText = a;
    const o = new Date(n.getFullYear(), n.getMonth(), 1).toISOString(), { data: l, error: c } = await S.from("payments").select("amount, created_at, status").eq("status", "approved").order("created_at", { ascending: true });
    c && console.error("Error fetching payments for dashboard:", c);
    const u = (l == null ? void 0 : l.filter((d) => d.created_at >= o).reduce((d, f) => d + f.amount, 0)) || 0;
    document.getElementById("total-revenue").innerText = `R$ ${u.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}`;
    const { data: h } = await S.from("payments").select("payment_id, amount, created_at, user_id").eq("status", "approved").order("created_at", { ascending: false }).limit(5);
    if (h && h.length > 0) {
      const d = h.map((p) => p.user_id), { data: f } = await S.from("profiles").select("id, full_name, email").in("id", d);
      h.forEach((p) => {
        const g = f == null ? void 0 : f.find((m) => m.id === p.user_id);
        p.user_name = (g == null ? void 0 : g.full_name) || (g == null ? void 0 : g.email) || "Desconhecido";
      });
    }
    Ti(h), ki(l);
  } catch (r) {
    console.error("Erro dashboard:", r), showToast("Erro ao carrergar dados do dashboard: " + r.message, "error");
  }
}
function ki(r) {
  var _a2;
  const e = (_a2 = document.getElementById("revenueChart")) == null ? void 0 : _a2.getContext("2d");
  if (!e || !r) return;
  const t = [...Array(7)].map((n, i) => {
    const a = /* @__PURE__ */ new Date();
    return a.setDate(a.getDate() - (6 - i)), a.toISOString().split("T")[0];
  }), s = t.map((n) => r.filter((i) => i.created_at.startsWith(n)).reduce((i, a) => i + a.amount, 0));
  U.revenueChart && U.revenueChart.destroy(), U.revenueChart = new Chart(e, { type: "line", data: { labels: t.map((n) => new Date(n).toLocaleDateString("pt-BR", { day: "2-digit", month: "2-digit" })), datasets: [{ label: "Receita (R$)", data: s, borderColor: "#e50914", backgroundColor: "rgba(229, 9, 20, 0.1)", fill: true, tension: 0.4, borderWidth: 3, pointRadius: 4, pointBackgroundColor: "#e50914" }] }, options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, grid: { color: "rgba(255, 255, 255, 0.05)" }, ticks: { color: "#94a3b8" } }, x: { grid: { display: false }, ticks: { color: "#94a3b8" } } } } });
}
function Ti(r) {
  const e = document.getElementById("payments-list");
  if (e) {
    if (!r || r.length === 0) {
      e.innerHTML = '<tr><td colspan="3" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhum pagamento.</td></tr>';
      return;
    }
    e.innerHTML = r.map((t) => {
      const s = t.amount ? Number(t.amount) : 0;
      return `
    <tr>
      <td>
        <div style="font-weight: 600;">${t.user_name || "Pix User"}</div>
        <div style="font-size: 0.75rem; color: var(--text-dim);">${t.payment_id || new Date(t.created_at).toLocaleDateString()}</div>
      </td>
      <td>R$ ${s.toFixed(2)}</td>
      <td>
        <i data-lucide="copy" class="copy-btn" onclick="navigator.clipboard.writeText('${t.payment_id}')" title="Copiar ID"></i>
      </td>
    </tr>
  `;
    }).join(""), V();
  }
}
async function re() {
  J.innerHTML = `
    <div class="animate-fade-in">
      <div class="dashboard-header-custom" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
         <div>
            <h2 style="font-size: 1.8rem; margin-bottom: 0.5rem;">Gest\xE3o de Assinantes</h2>
            <p style="color: var(--text-dim);">Controle total de vencimentos e pagamentos.</p>
         </div>
         <button class="btn btn-primary" onclick="confirmMassRenew()" style="background-color: #f59e0b; color: black; margin-right: 10px;">
            <i data-lucide="zap"></i> Renovar Todos (+30d)
         </button>
         <button class="btn btn-primary" onclick="liberarTodos()" style="background-color: #22c55e; color: black; margin-right: 10px;">
            <i data-lucide="zap"></i> Liberar Todos
         </button>
         <button class="btn btn-primary" onclick="document.getElementById('user-modal').style.display='flex'; document.getElementById('user-form').reset(); document.getElementById('user-id').value='';">
            <i data-lucide="plus"></i> Novo Assinante
          </button>
      </div>

      <!-- Stats Summary -->
      <div class="stats-grid" id="client-stats" style="margin-bottom: 2rem;">
         <div style="padding: 2rem; text-align: center;">Carregando estat\xEDsticas...</div>
      </div>

      <!-- Filters/Tabs -->
      <div class="table-header" style="background: transparent; border: none; padding: 0; margin-bottom: 1rem; flex-direction: column; align-items: flex-start; gap: 1rem;">
         <div style="display: flex; gap: 2rem; border-bottom: 1px solid var(--border); width: 100%; padding-bottom: 0;">
            <button class="tab-btn active" onclick="filterUsers('all', this)" id="tab-all">Todos</button>
            <button class="tab-btn" onclick="filterUsers('expired', this)" id="tab-expired">Vencidos <span class="badge-count" id="count-expired">0</span></button>
            <button class="tab-btn" onclick="filterUsers('expiring', this)" id="tab-expiring">Pr\xF3x. Vencimento <span class="badge-count" id="count-expiring">0</span></button>
            <button class="tab-btn" onclick="filterUsers('active', this)" id="tab-active">Em Dia</button>
         </div>
         <input type="text" id="user-search" placeholder="Buscar por nome, email ou status..." style="width: 100%; max-width: 400px; padding: 0.8rem 1rem; background: rgba(255,255,255,0.05); border: 1px solid var(--border); border-radius: 8px; color: white;">
      </div>
      
      <div id="users-grid" class="users-grid">
         <div style="padding: 2rem; grid-column: 1/-1; text-align: center;">Carregando clientes...</div>
      </div>
    </div>
  `, V();
  const { data: r, error: e } = await S.from("profiles").select("*").order("created_at", { ascending: false }), { data: t, error: s } = await S.from("payments").select("*").eq("status", "approved").order("created_at", { ascending: false });
  if (e) {
    console.error(e), document.getElementById("users-grid").innerHTML = `<div style="padding: 2rem; color: var(--danger); grid-column: 1/-1;">Erro ao carregar clientes: ${e.message || JSON.stringify(e)}</div>`, document.getElementById("client-stats").innerHTML = '<div style="padding: 2rem; color: var(--danger);">Falha no Schema/RLS</div>', showToast(`Erro Supabase: ${e.message}`, "error");
    return;
  }
  const n = /* @__PURE__ */ new Date(), i = /* @__PURE__ */ new Date();
  i.setDate(n.getDate() + 5);
  const a = (r || []).map((h) => {
    const d = h.expiration_date ? new Date(h.expiration_date) : null, f = !d || d < n, p = !f && d < i, g = t ? t.filter((b) => b.user_id === h.id) : [], m = g.length > 0 ? g[0] : null;
    let v = "active";
    return f ? v = "expired" : p && (v = "expiring"), { ...h, status: v, expiryDate: d, lastPayment: m, paymentsCount: g.length };
  });
  U.users = a;
  const o = a.length, l = a.filter((h) => h.status === "expired").length, c = a.filter((h) => h.status === "expiring").length, u = a.filter((h) => h.status === "active").length;
  document.getElementById("count-expired").innerText = l, document.getElementById("count-expiring").innerText = c, document.getElementById("client-stats").innerHTML = `
    <div class="stat-card">
      <div class="stat-label">Total Clientes</div>
      <div class="stat-value">${o}</div>
    </div>
    <div class="stat-card">
       <div class="stat-label" style="color: var(--danger);">Vencidos</div>
       <div class="stat-value" style="color: var(--danger);">${l}</div>
    </div>
    <div class="stat-card">
       <div class="stat-label" style="color: #f59e0b;">A Vencer (5 dias)</div>
       <div class="stat-value" style="color: #f59e0b;">${c}</div>
    </div>
    <div class="stat-card">
       <div class="stat-label" style="color: var(--success);">Em Dia</div>
       <div class="stat-value" style="color: var(--success);">${u}</div>
    </div>
  `, document.getElementById("user-search").addEventListener("input", () => {
    const h = document.querySelector(".tab-btn.active"), d = h ? h.id.replace("tab-", "") : "all";
    window.filterUsers(d, h);
  }), window.filterUsers("all", document.getElementById("tab-all"));
}
window.filterUsers = (r, e) => {
  e && (document.querySelectorAll(".tab-btn").forEach((i) => i.classList.remove("active")), e.classList.add("active"));
  const t = document.getElementById("user-search"), s = t ? t.value.toLowerCase() : "", n = U.users.filter((i) => {
    var _a2, _b;
    return (((_a2 = i.full_name) == null ? void 0 : _a2.toLowerCase()) || "").includes(s) || (((_b = i.email) == null ? void 0 : _b.toLowerCase()) || "").includes(s) ? r === "all" ? true : i.status === r : false;
  });
  Ii(n);
};
function Ii(r) {
  const e = document.getElementById("users-grid");
  if (r.length === 0) {
    e.innerHTML = '<div style="padding: 2rem; grid-column: 1/-1; text-align: center; color: var(--text-dim);">Nenhum cliente encontrado nesta categoria.</div>';
    return;
  }
  e.innerHTML = r.map((t) => {
    const s = t.expiryDate ? t.expiryDate.toLocaleDateString("pt-BR") : "Sem data";
    let n = '<span style="color: var(--text-dim); font-size: 0.8rem;">Nunca pagou</span>';
    if (t.lastPayment) {
      const o = new Date(t.lastPayment.created_at), l = o.toLocaleDateString("pt-BR", { month: "long" });
      n = `
                <div style="font-size: 0.85rem; color: #fff;">
                   <i data-lucide="calendar" style="width: 12px; display: inline; margin-right: 4px;"></i>
                   ${o.toLocaleDateString("pt-BR")}
                </div>
                <div style="font-size: 0.75rem; color: var(--success); margin-top: 2px;">
                   Ref: <strong>${l.charAt(0).toUpperCase() + l.slice(1)}</strong>
                </div>
            `;
    }
    let i = "";
    if (t.status === "expired") {
      const o = encodeURIComponent(`Ol\xE1 ${t.full_name || "Cliente"}, sua assinatura venceu em ${s}. Regularize agora para continuar assistindo!`), l = t.phone || "";
      l ? i = `
                <a href="https://wa.me/${l.replace(/\D/g, "")}?text=${o}" target="_blank" class="btn btn-primary" style="width: 100%; justify-content: center; margin-top: 1rem; background: #25D366; border: none;">
                    <i data-lucide="message-circle"></i> Cobrar no WhatsApp
                </a>
                ` : i = `
                <button onclick="promptWhatsApp('${t.full_name}', '${s}')" class="btn btn-primary" style="width: 100%; justify-content: center; margin-top: 1rem; background: #25D366; border: none;">
                    <i data-lucide="message-circle"></i> Cobrar (WhatsApp)
                </button>
                `;
    }
    let a = "";
    return t.status === "expired" ? a = '<span class="status-pill status-inactive">VENCIDO</span>' : t.status === "expiring" ? a = '<span class="status-pill" style="background: rgba(245, 158, 11, 0.2); color: #f59e0b;">A VENCER</span>' : a = '<span class="status-pill status-active">ATIVO</span>', `
            <div class="user-card" style="border-left: 4px solid ${t.status === "expired" ? "var(--danger)" : t.status === "expiring" ? "#f59e0b" : "var(--success)"};">
               <div style="display: flex; justify-content: space-between; margin-bottom: 1rem;">
                  <div style="display: flex; gap: 1rem; align-items: center;">
                      <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(t.full_name || "U")}&background=random" class="user-avatar-small">
                      <div>
                          <div style="font-weight: bold; font-size: 1.1rem;">${t.full_name || "Sem Nome"}</div>
                          <div style="color: var(--text-dim); font-size: 0.85rem;">${t.email}</div>
                      </div>
                  </div>
                  <div class="card-options">
                      <button class="btn-icon-small" onclick="editUser('${t.id}')"><i data-lucide="edit-2"></i></button>
                  </div>
               </div>

               <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; background: rgba(0,0,0,0.2); padding: 1rem; border-radius: 8px;">
                   <div>
                       <div style="font-size: 0.7rem; text-transform: uppercase; color: var(--text-dim); margin-bottom: 4px;">Vencimento</div>
                       <div style="font-size: 1rem; font-weight: bold;">${s}</div>
                       <div style="margin-top: 4px;">${a}</div>
                   </div>
                   <div>
                       <div style="font-size: 0.7rem; text-transform: uppercase; color: var(--text-dim); margin-bottom: 4px;">\xDAltimo Pagamento</div>
                       ${n}
                   </div>
               </div>

               ${i}
               
               <!-- Link M3U Propriet\xE1rio (IBO Player / Outros) -->
               <div style="margin-top: 1rem; border: 1px dashed rgba(255, 255, 255, 0.2); padding: 0.75rem; border-radius: 10px; background: rgba(255, 255, 255, 0.03);">
                   <div style="font-size: 0.65rem; color: var(--text-dim); text-transform: uppercase; margin-bottom: 6px; letter-spacing: 0.05em;">Link M3U (Para IBO Player / SS IPTV)</div>
                   <div style="display: flex; gap: 0.5rem; align-items: center;">
                       <div style="font-family: monospace; font-size: 0.75rem; color: var(--primary-light); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; background: rgba(0,0,0,0.3); padding: 4px 8px; border-radius: 4px;">
                           https://qyagfghcnzenvbhbtsvd.supabase.co/functions/v1/get-m3u/${t.id}.m3u
                       </div>
                       <button class="btn-icon-small" title="Copiar Link" onclick="navigator.clipboard.writeText('https://qyagfghcnzenvbhbtsvd.supabase.co/functions/v1/get-m3u/${t.id}.m3u'); showToast('\u{1F517} Link M3U copiado!', 'success');">
                           <i data-lucide="copy" style="width: 14px;"></i>
                       </button>
                   </div>
                   <div style="font-size: 0.6rem; color: var(--text-muted); margin-top: 5px;">
                       * Formato compat\xEDvel com Smart TVs e TV Boxes.
                   </div>
               </div>

               <div style="display: flex; gap: 0.5rem; margin-top: 1rem;">
                   ${t.has_signal ? `<button onclick="toggleSignal('${t.id}', false)" class="btn btn-ghost" style="flex: 1; color: var(--danger); background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2); justify-content: center; font-size: 0.75rem; padding: 0.6rem;">
                           <i data-lucide="zap-off" style="width: 14px;"></i> Bloquear Sinal
                       </button>` : `<button onclick="toggleSignal('${t.id}', true)" class="btn btn-primary" style="flex: 1; background: var(--success); border: none; justify-content: center; font-size: 0.75rem; padding: 0.6rem;">
                           <i data-lucide="zap" style="width: 14px;"></i> Liberar Sinal
                       </button>`}
               </div>
            </div>
        `;
  }).join(""), V();
}
window.promptWhatsApp = (r, e) => {
  const t = prompt(`Digite o n\xFAmero do WhatsApp para cobrar ${r}:`, "");
  if (t) {
    const s = encodeURIComponent(`Ol\xE1 ${r}, sua assinatura venceu em ${e}. Regularize agora para continuar assistindo!`);
    window.open(`https://wa.me/${t.replace(/\D/g, "")}?text=${s}`, "_blank");
  }
};
window.toggleSignal = async (r, e) => {
  try {
    const { error: t } = await S.from("profiles").update({ has_signal: e }).eq("id", r);
    if (t) throw t;
    e || await S.rpc("release_signal", { p_user_id: r }), showToast(e ? "Sinal liberado para o cliente!" : "Sinal bloqueado!", "success"), re();
  } catch (t) {
    showToast("Erro ao alterar sinal: " + t.message, "error");
  }
};
async function lt() {
  J.innerHTML = `
    <div class="data_container animate-fade-in">
      <div class="table-header">
        <h3>Apps dos Clientes</h3>
        <button class="btn btn-primary" onclick="document.getElementById('app-modal').style.display='flex'; document.getElementById('app-form').reset(); document.getElementById('app-id-field').value='';">
          <i data-lucide="plus"></i> Configurar Novo App
        </button>
      </div>
      <div class="stats-grid" id="apps-grid" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));">
        <div style="padding: 2rem;">Carregando...</div>
      </div>
    </div>
  `;
  try {
    const { data: r, error: e } = await S.from("apps").select("*").order("created_at", { ascending: false });
    if (e) throw e;
    const t = document.getElementById("apps-grid");
    if (!t) return;
    if (!r || r.length === 0) {
      t.innerHTML = '<div style="padding: 2rem;">Nenhum app configurado.</div>';
      return;
    }
    t.innerHTML = r.map((s) => `
      <div class="stat-card app-card">
        <div class="app-banner" style="height: 120px; background: #222; border-radius: 8px; overflow: hidden; display: flex; align-items: center; justify-content: center; position: relative;">
          ${s.image_url ? `<img src="${s.image_url}" style="width: 100%; height: 100%; object-fit: cover;">` : '<i data-lucide="monitor" style="width: 48px; height: 48px; opacity: 0.2;"></i>'}
          <div style="position: absolute; top: 8px; right: 8px; display: flex; gap: 4px;">
             <button class="btn" style="padding: 0.3rem; background: rgba(0,0,0,0.5); border-radius: 6px;" onclick="editApp('${s.id}')"><i data-lucide="edit" style="width: 14px; color: #fff;"></i></button>
             <button class="btn" style="padding: 0.3rem; background: rgba(229, 9, 20, 0.5); border-radius: 6px;" onclick="deleteApp('${s.id}')"><i data-lucide="trash-2" style="width: 14px; color: #fff;"></i></button>
          </div>
        </div>
        <div style="margin-top: 1rem;">
          <div style="display: flex; justify-content: space-between; align-items: start;">
             <strong style="font-size: 1.1rem; color: #e50914;">${s.name}</strong>
             <span class="status-pill status-active" style="font-size: 0.7rem; text-transform: uppercase;">${s.auth_type}</span>
          </div>
          <p style="font-size: 0.8rem; color: var(--text-dim); margin-top: 0.5rem; word-break: break-all;">${s.download_url}</p>
        </div>
      </div>
    `).join(""), V();
  } catch (r) {
    console.error("Error apps:", r);
    const e = document.getElementById("apps-grid");
    e && (e.innerHTML = `<div style="padding: 2rem; color: var(--danger);">Erro: ${r.message}</div>`);
  }
}
async function ke() {
  J.innerHTML = `
    <div class="animate-fade-in">
      <!-- Master Link Global Section -->
      <div style="background: linear-gradient(135deg, rgba(229, 9, 20, 0.1) 0%, rgba(0,0,0,0.4) 100%); border: 1px solid var(--primary); padding: 1.5rem; border-radius: 15px; margin-bottom: 2rem; display: flex; align-items: center; justify-content: space-between; gap: 2rem;">
          <div style="flex: 1;">
              <h3 style="color: var(--primary-light); margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.5rem;">
                <i data-lucide="zap"></i> Link M3U Master (Global)
              </h3>
              <p style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.4;">
                Use este link \xFAnico para qualquer player externo. Ele busca automaticamente uma lista dispon\xEDvel no seu estoque e a libera por <strong>1 hora</strong> para o usu\xE1rio antes de rotacionar.
              </p>
          </div>
          <div style="background: rgba(0,0,0,0.3); padding: 1rem; border-radius: 12px; border: 1px solid rgba(255,255,255,0.1); flex: 1; display: flex; align-items: center; gap: 1rem;">
              <div style="font-family: monospace; font-size: 0.85rem; color: var(--text-main); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1;">
                https://qyagfghcnzenvbhbtsvd.supabase.co/functions/v1/get-m3u/master.m3u
              </div>
              <button class="btn btn-primary btn-sm" onclick="navigator.clipboard.writeText('https://qyagfghcnzenvbhbtsvd.supabase.co/functions/v1/get-m3u/master.m3u'); showToast('\u{1F517} Link Master Copiado!', 'success');">
                <i data-lucide="copy" style="width: 16px;"></i> Copiar
              </button>
          </div>
      </div>

      <div class="table-header">
        <h3>Estoque de Contas (IPTV/M\xEDdia)</h3>
        <button class="btn btn-primary" onclick="openInventoryModal()">
          <i data-lucide="plus"></i> Adicionar Conta
        </button>
      </div>

      <!-- Stats -->
      <div class="stats-grid" style="margin-bottom: 2rem; margin-top: 1rem;">
        <div class="stat-card" style="padding: 1.5rem;">
          <div class="stat-label">Total Contas</div>
          <div class="stat-value" id="inv-total">0</div>
        </div>
        <div class="stat-card" style="padding: 1.5rem;">
          <div class="stat-label" style="color: var(--success);">Dispon\xEDveis</div>
          <div class="stat-value" id="inv-free" style="color: var(--success);">0</div>
        </div>
        <div class="stat-card" style="padding: 1.5rem;">
          <div class="stat-label" style="color: var(--warning);">Em Uso</div>
          <div class="stat-value" id="inv-used" style="color: var(--warning);">0</div>
        </div>
      </div>

      <div class="data-table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Fornecedor</th>
              <th>Login info</th>
              <th>Status</th>
              <th>Cliente Atual</th>
              <th>A\xE7\xF5es</th>
            </tr>
          </thead>
          <tbody id="inventory-list">
            <tr><td colspan="5" style="text-align:center; padding: 2rem;">Carregando...</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  `, V();
  try {
    const { data: r, error: e } = await S.from("media_accounts").select("*, profiles(email, full_name)").order("created_at", { ascending: false });
    if (e) throw e;
    const t = r.length, s = r.filter((a) => a.user_id).length, n = t - s;
    document.getElementById("inv-total").innerText = t, document.getElementById("inv-free").innerText = n, document.getElementById("inv-used").innerText = s;
    const i = document.getElementById("inventory-list");
    if (t === 0) {
      i.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhuma conta cadastrada.</td></tr>';
      return;
    }
    i.innerHTML = r.map((a) => {
      var _a2, _b;
      const o = !!a.user_id, l = ((_a2 = a.profiles) == null ? void 0 : _a2.full_name) || ((_b = a.profiles) == null ? void 0 : _b.email) || (o ? "ID: " + a.user_id.substr(0, 8) : "---");
      return `
        <tr>
          <td>
            <strong style="color: white;">${a.provider_name || "Gen\xE9rico"}</strong>
            <div style="font-size: 0.75rem; color: var(--text-dim);">${a.dns || "Sem DNS"}</div>
          </td>
          <td>
            <div style="font-family: monospace; font-size: 0.9rem;">
              <span style="color: #aaa;">U:</span> ${a.username}<br>
              <span style="color: #aaa;">P:</span> ${a.password}
            </div>
          </td>
          <td>
            <span class="status-pill ${o ? "status-inactive" : "status-active"}" 
                  style="${o ? "background:rgba(245, 158, 11, 0.1); color:#f59e0b;" : ""}">
              ${o ? "EM USO" : "LIVRE"}
            </span>
          </td>
          <td>
            ${o ? `<div style="display:flex; align-items:center; gap:0.5rem;">
                 <i data-lucide="user" style="width:14px;"></i> ${l}
               </div>` : '<span style="opacity:0.3;">---</span>'}
          </td>
          <td>
             <div style="display:flex; gap:0.5rem;">
               ${o ? `<button class="btn-icon-small" onclick="releaseInventoryItem('${a.id}')" title="Liberar (Remover Cliente)" style="color:#f59e0b;"><i data-lucide="unlink"></i></button>` : `<button class="btn-icon-small" onclick="openAssignModal('${a.id}')" title="Vincular a Cliente" style="color:var(--success);"><i data-lucide="user-plus"></i></button>`}
               <button class="btn-icon-small danger" onclick="deleteInventoryItem('${a.id}')" title="Excluir"><i data-lucide="trash-2"></i></button>
             </div>
          </td>
        </tr>
      `;
    }).join(""), V();
  } catch (r) {
    console.error(r), document.getElementById("inventory-list").innerHTML = `<tr><td colspan="5" style="color:red; text-align:center;">Erro: ${r.message}</td></tr>`;
  }
}
window.openInventoryModal = () => {
  document.getElementById("inv-form").reset(), document.getElementById("inventory-modal").style.display = "flex";
};
window.handleInventorySubmit = async (r) => {
  r.preventDefault();
  const e = document.getElementById("inv-provider").value, t = document.getElementById("inv-user").value, s = document.getElementById("inv-pass").value, n = document.getElementById("inv-dns").value;
  try {
    const { error: i } = await S.from("media_accounts").insert({ provider_name: e, username: t, password: s, dns: n });
    if (i) throw i;
    showToast("Conta adicionada ao estoque!", "success"), document.getElementById("inventory-modal").style.display = "none", ke();
  } catch (i) {
    showToast("Erro: " + i.message, "error");
  }
};
window.deleteInventoryItem = async (r) => {
  confirm("Excluir esta conta do estoque?") && (await S.from("media_accounts").delete().eq("id", r), ke());
};
window.releaseInventoryItem = async (r) => {
  confirm("Desvincular cliente desta conta? Ela voltar\xE1 a ficar LIVRE.") && (await S.from("media_accounts").update({ user_id: null }).eq("id", r), ke());
};
window.openAssignModal = async (r) => {
  document.getElementById("assign-account-id").value = r;
  const e = document.getElementById("assign-user-id");
  e.innerHTML = '<option value="">Carregando clientes...</option>', document.getElementById("assign-modal").style.display = "flex";
  try {
    const { data: t } = await S.from("profiles").select("id, full_name, email").order("full_name");
    t && (e.innerHTML = '<option value="">Selecione um Cliente</option>' + t.map((s) => `<option value="${s.id}">${s.full_name || s.email}</option>`).join(""));
  } catch {
    e.innerHTML = '<option value="">Erro ao carregar clientes</option>';
  }
};
window.handleAssignSubmit = async (r) => {
  r.preventDefault();
  const e = document.getElementById("assign-account-id").value, t = document.getElementById("assign-user-id").value;
  if (!t) {
    showToast("Selecione um cliente!", "warning");
    return;
  }
  try {
    const { error: s } = await S.from("media_accounts").update({ user_id: t }).eq("id", e);
    if (s) throw s;
    showToast("Conta vinculada com sucesso!", "success"), document.getElementById("assign-modal").style.display = "none", ke();
  } catch (s) {
    showToast("Erro ao vincular: " + s.message, "error");
  }
};
async function ct() {
  J.innerHTML = `
    <div class="data-table-container animate-fade-in">
      <div class="table-header">
        <h3>Planos de Assinatura</h3>
        <button class="btn btn-primary" onclick="document.getElementById('plan-modal').style.display='flex'; document.getElementById('plan-form').reset(); document.getElementById('plan-id').value='';">
          <i data-lucide="plus"></i> Novo Plano
        </button>
      </div>
      <div class="stats-grid" id="plans-grid" style="grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));">
        <div style="padding: 2rem;">Carregando...</div>
      </div>
    </div>
  `;
  try {
    const { data: r, error: e } = await S.from("plans").select("*").order("price", { ascending: true });
    if (e) throw e;
    const t = document.getElementById("plans-grid");
    if (!t) return;
    if (!r || r.length === 0) {
      t.innerHTML = '<div style="padding: 2rem;">Nenhum plano cadastrado.</div>';
      return;
    }
    t.innerHTML = r.map((s) => {
      const n = s.price ? Number(s.price) : 0;
      return `
      <div class="stat-card">
        <div style="display: flex; justify-content: space-between; align-items: start;">
          <div class="stat-icon" style="background: rgba(229, 9, 20, 0.1); color: #e50914;"><i data-lucide="package"></i></div>
          <div style="display: flex; gap: 0.5rem;">
            <button class="btn" style="padding: 0.2rem; background: transparent;" onclick="editPlan('${s.id}')"><i data-lucide="edit" style="width: 14px; color: #3b82f6;"></i></button>
            <button class="btn" style="padding: 0.2rem; background: transparent;" onclick="deletePlan('${s.id}')"><i data-lucide="trash-2" style="width: 14px; color: #ff4444;"></i></button>
          </div>
        </div>
        <div style="margin-top: 1rem;">
          <h4 style="font-size: 1.25rem; margin-bottom: 0.25rem; text-transform: capitalize;">${s.name}</h4>
          <div style="font-size: 1.5rem; font-weight: bold; color: #fff; margin-bottom: 0.5rem;">
            R$ ${n.toFixed(2)} <span style="font-size: 0.8rem; font-weight: normal; color: #888;">/ ${s.duration_days} dias</span>
          </div>
          <p style="font-size: 0.85rem; color: #888;">${s.description || "Sem descri\xE7\xE3o"}</p>
        </div>
      </div>
    `;
    }).join(""), V();
  } catch (r) {
    console.error("Error plans:", r);
    const e = document.getElementById("plans-grid");
    e && (e.innerHTML = `<div style="padding: 2rem; color: var(--danger);">Erro: ${r.message}</div>`);
  }
}
async function nr() {
  J.innerHTML = `
    <div class="data-table-container animate-fade-in">
      <div class="table-header">
        <h3>Hist\xF3rico Pix</h3>
        <button class="btn btn-ghost btn-icon" onclick="renderPaymentsView()" title="Atualizar Lista">
           <i data-lucide="refresh-cw"></i>
        </button>
      </div>
      <table class="data-table">
        <thead>
          <tr>
            <th>Cliente / Usu\xE1rio</th>
            <th>Valor</th>
            <th>Novo Vencimento</th>
            <th>Status</th>
            <th>Data Pagamento</th>
            <th>Ref.</th>
          </tr>
        </thead>
        <tbody id="full-payments-list">
          <tr><td colspan="6" style="text-align:center; padding: 2rem;">Carregando...</td></tr>
        </tbody>
      </table>
    </div>
  `;
  const { data: r, error: e } = await S.from("payments").select("*").order("created_at", { ascending: false });
  if (e) {
    console.error(e), document.getElementById("full-payments-list").innerHTML = `<tr><td colspan="6" style="text-align:center; color:red;">Erro ao carregar pagamentos: ${e.message}</td></tr>`;
    return;
  }
  const { data: t, error: s } = await S.from("profiles").select("id, full_name, email, expiration_date"), n = {};
  t && t.forEach((a) => {
    n[a.id] = a;
  });
  const i = document.getElementById("full-payments-list");
  i.innerHTML = (r || []).map((a) => {
    const o = n[a.user_id] || {}, l = o.full_name || o.email || "Usu\xE1rio Desconhecido", c = o.email || "Email n/a";
    let u = "---";
    o.expiration_date && (u = new Date(o.expiration_date).toLocaleDateString("pt-BR"));
    const h = new Date(a.created_at), d = a.amount ? Number(a.amount) : 0;
    return `
    <tr>
      <td>
        <div style="font-weight: 600; color: white; font-size: 0.95rem;">${l}</div>
        <div style="font-size: 0.8rem; color: var(--text-dim); margin-top: 2px;">${c}</div>
      </td>
      <td style="font-weight: bold; color: #fff;">R$ ${d.toFixed(2)}</td>
      <td>
        <div style="display: flex; align-items: center; gap: 6px;">
            <i data-lucide="calendar" style="width: 14px; color: var(--success);"></i>
            <span style="color: var(--success); font-weight: 600;">${u}</span>
        </div>
      </td>
      <td>
        <span class="status-pill ${a.status === "approved" ? "status-active" : "status-inactive"}">
            ${a.status || "pending"}
        </span>
      </td>
      <td style="color: var(--text-dim); font-size: 0.9rem;">
        ${h.toLocaleDateString("pt-BR")} <span style="font-size:0.75rem">${h.toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })}</span>
      </td>
      <td>
         <i data-lucide="copy" class="copy-btn" onclick="navigator.clipboard.writeText('${a.payment_id}')" title="Copiar ID: ${a.payment_id}"></i>
      </td>
    </tr>
    `;
  }).join("") || '<tr><td colspan="6" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhum pagamento registrado.</td></tr>', V();
}
async function xi(r) {
  r.preventDefault();
  const e = r.target.querySelector('button[type="submit"]');
  e.innerText = "Salvando...";
  const t = document.getElementById("user-id").value, s = document.getElementById("user-email").value.trim(), n = document.getElementById("user-password-field").value.trim(), i = document.getElementById("user-name").value.trim(), a = document.getElementById("user-phone").value.trim(), o = document.getElementById("user-m3u").value.trim(), l = document.getElementById("user-app-id").value, c = document.getElementById("user-app-image").value.trim(), u = document.getElementById("user-expiry").value, h = document.getElementById("user-status").value === "true";
  try {
    const d = { full_name: i, phone: a, m3u_url: o, app_id: l || null, app_image_url: c, expiration_date: u ? new Date(u).toISOString() : null, is_active: h, has_signal: document.getElementById("user-has-signal").checked, tv_enabled: document.getElementById("user-tv-enabled").checked, tv_app_name: document.getElementById("user-tv-app-name").value, tv_app_image: document.getElementById("user-tv-app-image").value, tv_app_auth_type: document.getElementById("user-tv-auth-type").value, tv_app_mac: document.getElementById("user-tv-mac").value, tv_app_user: document.getElementById("user-tv-user").value, tv_app_pass: document.getElementById("user-tv-pass").value, tv_app_email: document.getElementById("user-tv-email").value, tv_app_pass_email: document.getElementById("user-tv-pass-email").value };
    if (t) {
      console.log("Atualizando perfil:", t, "com lista:", o);
      const { error: f } = await S.from("profiles").update(d).eq("id", t);
      if (f) throw f;
      console.log("Perfil atualizado com sucesso!");
    } else {
      const { data: f, error: p } = await S.auth.signUp({ email: s.includes("@") ? s : `${s}@startflix.app`, password: n || "123456" });
      if (p) throw p;
      await S.from("profiles").update(d).eq("id", f.user.id);
    }
    showToast("Opera\xE7\xE3o conclu\xEDda e Salva!", "success"), document.getElementById("user-modal").style.display = "none", setTimeout(() => re(), 500);
  } catch (d) {
    showToast("Erro: " + d.message, "error");
  } finally {
    e.innerText = "Salvar Cliente";
  }
}
async function Oi(r) {
  r.preventDefault();
  const e = document.getElementById("app-id-field").value, t = document.getElementById("app-name").value, s = document.getElementById("app-image-url").value, n = document.getElementById("app-url").value, i = document.getElementById("app-type").value;
  try {
    if (e) {
      const { error: a } = await S.from("apps").update({ name: t, image_url: s, download_url: n, auth_type: i }).eq("id", e);
      if (a) throw a;
    } else {
      const { error: a } = await S.from("apps").insert([{ name: t, image_url: s, download_url: n, auth_type: i, is_active: true }]);
      if (a) throw a;
    }
    showToast("Opera\xE7\xE3o realizada com sucesso!", "success"), document.getElementById("app-modal").style.display = "none", lt();
  } catch (a) {
    showToast("Erro: " + a.message, "error");
  }
}
async function Ai(r) {
  r.preventDefault();
  const e = document.getElementById("plan-id").value, t = document.getElementById("plan-name").value, s = parseFloat(document.getElementById("plan-price").value), n = parseInt(document.getElementById("plan-days").value), i = document.getElementById("plan-desc").value;
  try {
    if (e) {
      const { error: a } = await S.from("plans").update({ name: t, price: s, duration_days: n, description: i }).eq("id", e);
      if (a) throw a;
    } else {
      const { error: a } = await S.from("plans").insert([{ name: t, price: s, duration_days: n, description: i }]);
      if (a) throw a;
    }
    showToast("Plano salvo com sucesso!", "success"), document.getElementById("plan-modal").style.display = "none", ct();
  } catch (a) {
    showToast("Erro: " + a.message, "error");
  }
}
async function Ri(r) {
  r.preventDefault(), document.getElementById("login-password").value === "01Deus02@@@@" ? (localStorage.setItem("admin_session", "true"), document.getElementById("login-overlay").style.display = "none", ot("dashboard")) : showToast("Senha incorreta!", "error");
}
window.editUser = async (r) => {
  const { data: e } = await S.from("profiles").select("*").eq("id", r).single(), { data: t } = await S.from("apps").select("id, name"), s = document.getElementById("user-app-id");
  if (s && (s.innerHTML = '<option value="">Nenhum (Usar Padr\xE3o)</option>' + ((t == null ? void 0 : t.map((n) => `<option value="${n.id}">${n.name}</option>`).join("")) || "")), e) {
    document.getElementById("user-id").value = e.id, document.getElementById("user-email").value = e.email || "", document.getElementById("user-name").value = e.full_name || "", document.getElementById("user-phone").value = e.phone || "", document.getElementById("user-m3u").value = e.m3u_url || "", document.getElementById("user-app-id").value = e.app_id || "", document.getElementById("user-app-image").value = e.app_image_url || "", document.getElementById("user-expiry").value = e.expiration_date ? e.expiration_date.split("T")[0] : "", document.getElementById("user-status").value = String(e.is_active), document.getElementById("user-has-signal").checked = !!e.has_signal;
    const n = !!e.tv_enabled;
    document.getElementById("user-tv-enabled").checked = n, document.getElementById("tv-fields").style.display = n ? "block" : "none", document.getElementById("user-tv-app-name").value = e.tv_app_name || "", document.getElementById("user-tv-app-image").value = e.tv_app_image || "", document.getElementById("user-tv-auth-type").value = e.tv_app_auth_type || "mac", document.getElementById("user-tv-mac").value = e.tv_app_mac || "", document.getElementById("user-tv-user").value = e.tv_app_user || "", document.getElementById("user-tv-pass").value = e.tv_app_pass || "", document.getElementById("user-tv-email").value = e.tv_app_email || "", document.getElementById("user-tv-pass-email").value = e.tv_app_pass_email || "";
    const i = (e.tv_app_auth_type || "mac") === "mac";
    document.getElementById("tv-auth-mac").style.display = i ? "grid" : "none", document.getElementById("tv-auth-email").style.display = i ? "none" : "grid", document.getElementById("user-modal-title").innerText = "Editar Cliente", document.getElementById("user-modal").style.display = "flex";
  }
};
window.promptWhatsApp = (r, e) => {
  const t = prompt(`Digite o WhatsApp de ${r} (com DDD, somente n\xFAmeros):`);
  if (!t) return;
  const s = t.replace(/\D/g, ""), n = encodeURIComponent(`Ol\xE1 ${r}, sua assinatura venceu em ${e}. Regularize agora para continuar assistindo!`);
  window.open(`https://wa.me/${s}?text=${n}`, "_blank");
};
window.deleteUser = async (r) => {
  if (confirm("Tem certeza que deseja excluir este cliente?")) try {
    await S.from("profiles").delete().eq("id", r), showToast("Cliente exclu\xEDdo com sucesso!", "success"), re();
  } catch (e) {
    showToast("Erro ao excluir cliente: " + e.message, "error");
  }
};
window.deleteApp = async (r) => {
  if (confirm("Excluir esta configura\xE7\xE3o?")) try {
    await S.from("apps").delete().eq("id", r), showToast("Configura\xE7\xE3o exclu\xEDda com sucesso!", "success"), lt();
  } catch (e) {
    showToast("Erro ao excluir configura\xE7\xE3o: " + e.message, "error");
  }
};
window.editApp = async (r) => {
  const { data: e } = await S.from("apps").select("*").eq("id", r).single();
  e && (document.getElementById("app-id-field").value = e.id, document.getElementById("app-name").value = e.name, document.getElementById("app-image-url").value = e.image_url || "", document.getElementById("app-url").value = e.download_url, document.getElementById("app-type").value = e.auth_type, document.getElementById("app-modal-title").innerText = "Editar Configura\xE7\xE3o", document.getElementById("app-modal").style.display = "flex");
};
window.editPlan = async (r) => {
  const { data: e } = await S.from("plans").select("*").eq("id", r).single();
  e && (document.getElementById("plan-id").value = e.id, document.getElementById("plan-name").value = e.name, document.getElementById("plan-price").value = e.price, document.getElementById("plan-days").value = e.duration_days, document.getElementById("plan-desc").value = e.description || "", document.getElementById("plan-modal-title").innerText = "Editar Plano", document.getElementById("plan-modal").style.display = "flex");
};
window.deletePlan = async (r) => {
  if (confirm("Deseja excluir este plano definitivamente?")) try {
    await S.from("plans").delete().eq("id", r), showToast("Plano exclu\xEDdo com sucesso!", "success"), ct();
  } catch (e) {
    showToast("Erro ao excluir plano: " + e.message, "error");
  }
};
(_a = document.getElementById("mobile-logout-btn")) == null ? void 0 : _a.addEventListener("click", () => {
  S.auth.signOut(), localStorage.removeItem("admin_session"), location.reload();
});
"serviceWorker" in navigator && window.addEventListener("load", () => {
  navigator.serviceWorker.register("./sw.js").then((r) => console.log("ServiceWorker registered:", r.scope)).catch((r) => console.log("ServiceWorker registration failed:", r));
});
window.confirmMassRenew = async () => {
  if (confirm(`Tem certeza que deseja renovar TODOS os usu\xE1rios por 30 dias?

- Vencidos: +30 dias a partir de hoje.
- Ativos: +30 dias no vencimento atual.`)) {
    showToast("\u{1F504} Iniciando renova\xE7\xE3o em massa... Aguarde.", "info");
    try {
      const { data: r, error: e } = await S.from("profiles").select("*");
      if (e) throw e;
      let t = 0, s = 0;
      const n = /* @__PURE__ */ new Date();
      for (const i of r) try {
        let a = i.expiration_date ? new Date(i.expiration_date) : /* @__PURE__ */ new Date();
        (isNaN(a.getTime()) || a < n) && (a = /* @__PURE__ */ new Date()), a.setDate(a.getDate() + 30);
        const { error: o } = await S.from("profiles").update({ expiration_date: a.toISOString(), is_active: true }).eq("id", i.id);
        if (o) throw o;
        t++;
      } catch (a) {
        console.error(`Erro ao renovar usu\xE1rio ${i.email}:`, a), s++;
      }
      showToast(`\u2705 Conclu\xEDdo! ${t} renovados. ${s > 0 ? s + " erros." : ""}`, "success"), U.activePage === "users" && re();
    } catch (r) {
      console.error("Erro geral na renova\xE7\xE3o em massa:", r), showToast("\u274C Erro ao processar renova\xE7\xE3o em massa.", "error");
    }
  }
};
window.liberarTodos = async () => {
  if (confirm("Deseja liberar o sinal de TODOS os clientes cadastrados?")) {
    showToast("\u{1F504} Liberando sinal para todos... Aguarde.", "info");
    try {
      const { error: r } = await S.from("profiles").update({ has_signal: true, is_active: true }).neq("id", "00000000-0000-0000-0000-000000000000");
      if (r) throw r;
      showToast("\u2705 Sinal liberado para todos os clientes!", "success"), U.activePage === "users" && re();
    } catch (r) {
      console.error("Erro ao liberar todos:", r), showToast("\u274C Erro ao liberar todos: " + r.message, "error");
    }
  }
};
wi();
