import React, { useEffect, useState } from "react";
import { Routes, Route, Navigate, Link, useNavigate } from "react-router-dom";
import { Plus, StickyNote, LogOut, Pencil, Trash2, Share2 } from "lucide-react";
import PublicNotePage from "./PublicNotePage";
import SharedNotesPage from "./SharedNotesPage";
import { login, register, Notes, PublicLinks, Shares } from "./lib/api";

export function Protected({ children }) {
  const hasToken = !!localStorage.getItem("token");
  return hasToken ? children : <Navigate to="/login" replace />;
}

export function Shell({ children }) {
  const navigate = useNavigate();
  const logout = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };
  return (
    <div className="min-h-full">
      <header className="sticky top-0 z-10 border-b bg-white/70 backdrop-blur">
        <div className="mx-auto max-w-5xl px-4 py-3 flex items-center justify-between">
          <Link to="/app" className="inline-flex items-center gap-2 font-semibold">
            <StickyNote className="size-5" />
            Notes
          </Link>
          <div className="flex gap-2">
            <Link to="/shared" className="rounded-xl border px-3 py-1.5 text-sm hover:bg-slate-50">
              Partagées
            </Link>
            <button
              onClick={logout}
              className="inline-flex items-center gap-2 rounded-xl border px-3 py-1.5 text-sm hover:bg-slate-50"
            >
              <LogOut className="size-4" />
              Logout
            </button>
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-5xl p-4">{children}</main>
    </div>
  );
}

function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState("USER");
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");
  const [isRegisterMode, setIsRegisterMode] = useState(false);

  const handleRegister = async (e) => {
    e.preventDefault();
    setBusy(true);
    setErr("");
    try {
      await register(email, password, role);
      await login(email, password);
      navigate("/app", { replace: true });
    } catch (e) {
      console.error(e);
      setErr("Erreur lors de l'inscription: " + e.message);
    } finally {
      setBusy(false);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setBusy(true);
    setErr("");
    try {
      await login(email, password);
      navigate("/app", { replace: true });
    } catch (e) {
      console.error(e);
      setErr("Identifiants invalides");
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="min-h-full grid place-items-center p-6">
      <div className="w-full max-w-md rounded-2xl border bg-white/70 backdrop-blur p-6 shadow-sm">
        <div className="mb-4">
          <h1 className="text-2xl font-semibold">
            {isRegisterMode ? "Créer un compte" : "Connexion"}
          </h1>
          <p className="text-sm text-slate-600">
            {isRegisterMode ? "Créez votre compte" : "Connectez-vous pour gérer vos notes"}
          </p>
        </div>

        <form onSubmit={isRegisterMode ? handleRegister : handleLogin} className="grid gap-3">
          <label className="grid gap-1 text-sm">
            <span className="text-slate-600">Email</span>
            <input
              type="email"
              className="rounded-xl border px-3 py-2 outline-none focus:ring-2 focus:ring-slate-300"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </label>

          <label className="grid gap-1 text-sm">
            <span className="text-slate-600">Mot de passe</span>
            <input
              type="password"
              className="rounded-xl border px-3 py-2 outline-none focus:ring-2 focus:ring-slate-300"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </label>

          {isRegisterMode && (
            <label className="grid gap-1 text-sm">
              <span className="text-slate-600">Rôle</span>
              <select
                className="rounded-xl border px-3 py-2 outline-none focus:ring-2 focus:ring-slate-300"
                value={role}
                onChange={(e) => setRole(e.target.value)}
                required
              >
                <option value="USER">Utilisateur</option>
                <option value="ADMIN">Administrateur</option>
              </select>
            </label>
          )}

          {err && <div className="text-red-600 text-sm">{err}</div>}

          <button
            type="submit"
            disabled={busy}
            className="mt-2 inline-flex items-center justify-center gap-2 rounded-xl bg-slate-900 px-4 py-2 text-white hover:bg-slate-800 disabled:opacity-60"
          >
            {isRegisterMode ? "S'inscrire" : "Se connecter"}
          </button>

          <button
            type="button"
            onClick={() => {
              setIsRegisterMode(!isRegisterMode);
              setErr("");
            }}
            className="text-sm text-slate-600 hover:text-slate-800 underline"
          >
            {isRegisterMode ? "Déjà un compte ? Se connecter" : "Pas de compte ? S'inscrire"}
          </button>
        </form>
      </div>
    </div>
  );
}

function NoteModal({ open, onClose, initial, onSave }) {
  const [title, setTitle] = useState(initial?.title ?? "");
  const [content, setContent] = useState(initial?.contentMd ?? ""); // ⚠️ ici

  useEffect(() => {
    if (open) {
      setTitle(initial?.title ?? "");
      setContent(initial?.contentMd ?? ""); // ⚠️ ici aussi
    }
  }, [open, initial]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 bg-black/20 backdrop-blur-sm grid place-items-center p-4">
      <div className="w-full max-w-lg rounded-2xl border bg-white p-5 shadow-lg">
        <h3 className="text-lg font-semibold mb-3">
          {initial ? "Modifier la note" : "Nouvelle note"}
        </h3>
        <div className="grid gap-3">
          <input
            className="rounded-xl border px-3 py-2 outline-none focus:ring-2 focus:ring-slate-300"
            placeholder="Titre"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
          />
          <textarea
            className="min-h-32 rounded-xl border px-3 py-2 outline-none focus:ring-2 focus:ring-slate-300"
            placeholder="Contenu"
            value={content}
            onChange={(e) => setContent(e.target.value)}
          />
          <div className="flex justify-end gap-2 pt-1">
            <button
              onClick={onClose}
              className="rounded-xl border px-3 py-1.5 hover:bg-slate-50"
            >
              Annuler
            </button>
            <button
              onClick={() =>
                onSave({
                  title: title.trim(),
                  contentMd: content.trim(), // ✅ maintenant c'est bien défini
                  visibility: "PRIVATE",
                })
              }
              className="inline-flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-1.5 text-white hover:bg-slate-800"
            >
              <Plus className="size-4" /> Enregistrer
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}


function NotesPage() {
  const [notes, setNotes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState(null);

  const refresh = async () => {
    setLoading(true);
    try {
      const data = await Notes.list();
      setNotes(data);
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => {
    refresh();
  }, []);

  const createNote = async (n) => {
    console.log("🚀 Payload envoyé au backend:", n); // 👀 debug
    if (!n.title) return;
    const created = await Notes.create(n);
    setNotes((prev) => [created, ...prev]);
    setModalOpen(false);
  };
  const updateNote = async (id, n) => {
    const updated = await Notes.update(id, n);
    setNotes((prev) => prev.map((x) => (x.id === id ? updated : x)));
    setEditing(null);
  };
  const deleteNote = async (id) => {
  try {
    await Notes.remove(id); // pas besoin de vérifier res.status
    setNotes((prev) => prev.filter((x) => x.id !== id));
  } catch (e) {
    alert("Suppression refusée (" + e.message + ")");
  }
};

const shareNote = async (id) => {
  const email = prompt(
    "👉 Entrez l'email de l'utilisateur avec qui partager (laisser vide pour créer un lien public)"
  );

  if (!email) {
    // 🔗 Partage public
    const pl = await PublicLinks.create(id);
    alert("Lien public: " + window.location.origin + "/public/" + pl.urlToken);
  } else {
    // 👥 Partage privé
    await Shares.shareWith(id, email);
    alert("✅ Note partagée en privé avec " + email);
  }
};




  return (
    <Shell>
      <div className="mb-4 flex items-center justify-between gap-3">
        <div>
          <h2 className="text-xl font-semibold">Mes notes</h2>
          <p className="text-sm text-slate-600">Créer, modifier, supprimer, partager vos notes.</p>
        </div>
        <button
          onClick={() => {
            setEditing(null);
            setModalOpen(true);
          }}
          className="inline-flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-2 text-white hover:bg-slate-800"
        >
          <Plus className="size-4" /> Nouvelle note
        </button>
      </div>
      {loading ? (
        <div className="text-slate-600">Chargement…</div>
      ) : notes.length === 0 ? (
        <div className="rounded-2xl border bg-white p-6 text-center text-slate-600">Aucune note.</div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {notes.map((n) => (
  <div
    key={n.urlToken ? `public-${n.urlToken}` : `private-${n.id}`} // ✅ clé unique
    className="group rounded-2xl border bg-white p-4 shadow-sm hover:shadow-md transition-shadow"
  >
    <div className="mb-2 flex items-start justify-between gap-3">
      <h3 className="font-semibold truncate">{n.title}</h3>
      <div className="opacity-80 group-hover:opacity-100 flex gap-1">
        <button
          title="Modifier"
          className="rounded-lg border p-1.5 hover:bg-slate-50"
          onClick={() => {
            setEditing(n);
            setModalOpen(true);
          }}
        >
          <Pencil className="size-4" />
        </button>
        <button
          title="Supprimer"
          className="rounded-lg border p-1.5 hover:bg-red-50"
          onClick={() => deleteNote(n.id)}
        >
          <Trash2 className="size-4" />
        </button>
        <button
          title="Partager"
          className="rounded-lg border p-1.5 hover:bg-blue-50"
          onClick={() => shareNote(n.id)}
        >
          <Share2 className="size-4" />
        </button>
      </div>
    </div>
    <p className="text-sm text-slate-700 whitespace-pre-wrap">{n.contentMd}</p>

    {/* ✅ Petit badge pour montrer si c’est public ou privé */}
    <div className="mt-2 text-xs">
      {n.urlToken ? (
        <span className="text-blue-600">🔗 Partage public</span>
      ) : (
        <span className="text-green-600">👥 Partage privé</span>
      )}
    </div>
  </div>
))}

        </div>
      )}
      <NoteModal
  open={modalOpen}
  onClose={() => setModalOpen(false)}
  initial={editing}
  onSave={(payload) => {
    const dto = {
      title: payload.title,
      contentMd: payload.contentMd, // ✅ garder contentMd
      visibility: "PRIVATE",        // ✅ valeur par défaut
    };
    editing ? updateNote(editing.id, dto) : createNote(dto);
  }}
/>

    </Shell>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/app"
        element={
          <Protected>
            <NotesPage />
          </Protected>
        }
      />
      <Route path="/public/:token" element={<PublicNotePage />} />
      <Route
        path="/shared"
        element={
          <Protected>
            <SharedNotesPage />
          </Protected>
        }
      />
      <Route path="*" element={<Navigate to="/app" replace />} />
    </Routes>
  );
}
