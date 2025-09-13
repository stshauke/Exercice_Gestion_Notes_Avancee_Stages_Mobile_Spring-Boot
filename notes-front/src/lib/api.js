const BASE = "http://localhost:8080/api/v1";

/**
 * Construit les en-têtes d’authentification avec le JWT stocké
 */
function authHeaders() {
  const t = localStorage.getItem("token");
  console.log("🔑 Token from localStorage:", t); // Vérifiez que le token est bien là
  return t ? { Authorization: `Bearer ${t}` } : {};
}

/**
 * Wrapper fetch JSON avec gestion des erreurs
 */
async function jsonFetch(path, opts = {}) {
  // 👇 Debug complet de la requête envoyée
  console.log("🚀 Request:", BASE + path, opts.method || "GET", {
    ...opts,
    headers: {
      "Content-Type": "application/json",
      ...(authHeaders()),
      ...(opts.headers || {}),
    },
  });

  const res = await fetch(BASE + path, {
    ...opts,
    headers: {
      "Content-Type": "application/json",
      ...(authHeaders()),     // ✅ toujours inclure le token
      ...(opts.headers || {}), // ✅ puis les éventuels headers custom
    },
  });


  if (!res.ok) {
    // Essaye de récupérer un message d’erreur plus clair du backend
    let msg = `HTTP ${res.status}`;
    try {
      const err = await res.json();
      if (err.message) msg += ` - ${err.message}`;
    } catch (_) {}
    throw new Error(msg);
  }

  if (res.status === 204) return {}; // pas de contenu
  return res.json();
}

// ---- AUTH ----
export async function register(email, password, role = "USER") {
  console.log("Register payload:", { email, password, role }); // Debug
  
  return jsonFetch("/auth/register", {
    method: "POST",
    body: JSON.stringify({ email, password, role }),
  });
}

export async function login(email, password) {
  console.log("🔐 Tentative de connexion avec:", { email });
  
  try {
    const data = await jsonFetch("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
    
    console.log("✅ Connexion réussie, token reçu");
    localStorage.setItem("token", data.token);
    return data;
    
  } catch (error) {
    console.error("❌ Erreur de connexion:", error.message);
    throw error;
  }
}

// ---- NOTES ----
export const Notes = {
  list: () => jsonFetch("/notes", { headers: authHeaders() }),
  create: (n) =>
    jsonFetch("/notes", {
      method: "POST",
      headers: authHeaders(),
      body: JSON.stringify(n),
    }),
  update: (id, n) =>
    jsonFetch(`/notes/${id}`, {
      method: "PUT",
      headers: authHeaders(),
      body: JSON.stringify(n),
    }),
  remove: async (id) => {
  const res = await fetch(`${BASE}/notes/${id}`, {
    method: "DELETE",
    headers: authHeaders(),
  });
  if (!res.ok && res.status !== 204) {
    throw new Error(`HTTP ${res.status} lors de la suppression`);
  }
  return true;
},

};

// ---- PUBLIC LINKS ----
// ---- PUBLIC LINKS ----
export const PublicLinks = {
  create: (noteId) =>
    jsonFetch(`/shares/public/${noteId}`, {
      method: "POST",
      headers: authHeaders(),
    }),
  get: (token) => jsonFetch(`/shares/public/view/${token}`),
};







// ---- PRIVATE SHARES ----
// ---- PRIVATE SHARES ----
export const Shares = {
  listMine: () => 
    jsonFetch("/shares/mine", { headers: authHeaders() }),

shareWith: (noteId, email) =>
  jsonFetch(`/notes/${noteId}/shares?email=${encodeURIComponent(email)}&permission=READ`, {
    method: "POST",
    headers: authHeaders(),
  }),


  listAll: () =>
    jsonFetch("/shares/all", { headers: authHeaders() }), // ✅ fix ici
};




