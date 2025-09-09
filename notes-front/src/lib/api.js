const BASE = import.meta.env.VITE_API_BASE || "";

export async function api(path, opts = {}) {
  const token = localStorage.getItem("token");
  const headers = { "Content-Type": "application/json", ...(opts.headers || {}) };
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(`${BASE}${path}`, { ...opts, headers });

  if (res.status === 401) {
    // token invalide/expiré -> logout & redirect
    localStorage.removeItem("token");
    if (!location.pathname.startsWith("/login")) location.href = "/login";
    throw new Error("Unauthorized");
  }
  return res;
}

export async function login(email, password) {
  const r = await api("/api/v1/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
  const js = await r.json();
  localStorage.setItem("token", js.token);
  return js;
}

export async function register(email, password, role = "USER") {
  // on ignore volontairement l’échec 400 si l’utilisateur existe déjà
  await api("/api/v1/auth/register", {
    method: "POST",
    body: JSON.stringify({ email, password, role }),
  }).catch(() => {});
}

export const Notes = {
  list: async () => (await api("/api/v1/notes")).json(),
  create: async (note) => (await api("/api/v1/notes", { method: "POST", body: JSON.stringify(note) })).json(),
  update: async (id, note) => (await api(`/api/v1/notes/${id}`, { method: "PUT", body: JSON.stringify(note) })).json(),
  remove: async (id) => api(`/api/v1/notes/${id}`, { method: "DELETE" }),
};
