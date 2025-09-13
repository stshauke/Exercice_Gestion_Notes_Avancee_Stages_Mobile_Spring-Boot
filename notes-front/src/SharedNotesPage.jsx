import React, { useEffect, useState } from "react";
import { Shares } from "./lib/api";
import { Link } from "react-router-dom";
import { Shell } from "./App";

export default function SharedNotesPage() {
  const [notes, setNotes] = useState([]);
  const [searchTitle, setSearchTitle] = useState("");
  const [searchContent, setSearchContent] = useState("");

  useEffect(() => {
    Shares.listAll()
      .then(setNotes)
      .catch((e) => console.error("Erreur chargement notes partagées:", e));
  }, []);

  // ✅ filtre sur le titre ET le contenu
  const filteredNotes = notes.filter((n) => {
    const matchTitle = n.noteTitle
      ?.toLowerCase()
      .includes(searchTitle.toLowerCase());
    const matchContent = n.noteContent
      ?.toLowerCase()
      .includes(searchContent.toLowerCase());

    // On applique les deux filtres séparément : si l'un des champs est vide, on ignore ce critère
    return (
      (searchTitle === "" || matchTitle) &&
      (searchContent === "" || matchContent)
    );
  });

  return (
    <Shell>
      <div className="px-6">
        <div className="mb-4 flex items-center justify-between">
          <div>
            <h2 className="text-xl font-semibold">Notes partagées avec moi</h2>
            <p className="text-sm text-slate-600">
              Voici les notes accessibles soit par partage privé, soit via un lien public.
            </p>
          </div>

          <Link
            to="/app"
            className="rounded-xl border px-3 py-1.5 text-sm hover:bg-slate-50"
          >
            ← Retour aux notes
          </Link>
        </div>

        {/* Champs de recherche */}
        <div className="mb-4 flex gap-2">
          <input
            type="text"
            placeholder="Rechercher par titre..."
            value={searchTitle}
            onChange={(e) => setSearchTitle(e.target.value)}
            className="rounded-xl border px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-slate-300 flex-1"
          />
          <input
            type="text"
            placeholder="Rechercher dans le contenu..."
            value={searchContent}
            onChange={(e) => setSearchContent(e.target.value)}
            className="rounded-xl border px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-slate-300 flex-1"
          />
        </div>

        {filteredNotes.length === 0 ? (
          <div className="rounded-2xl border bg-white p-6 text-center text-slate-600">
            Aucune note partagée trouvée.
          </div>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {filteredNotes.map((n, idx) => (
              <div
                key={n.urlToken ? `public-${n.urlToken}` : `private-${n.id}-${idx}`}
                className="rounded-2xl border bg-white p-4 shadow-sm"
              >
                <h3 className="font-semibold mb-1">{n.noteTitle}</h3>
                <p className="text-sm text-slate-700 whitespace-pre-wrap">
                  {n.noteContent}
                </p>

                {n.urlToken && (
                  <div className="mt-2 text-sm text-blue-600">
                    🔗 Lien public : {window.location.origin}/public/{n.urlToken}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </Shell>
  );
}
