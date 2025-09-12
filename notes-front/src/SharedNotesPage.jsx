import React, { useEffect, useState } from "react";
import { Shares } from "./lib/api";
import { StickyNote } from "lucide-react";
import { Shell } from "./App";

export default function SharedNotesPage() {
  const [shares, setShares] = useState([]);
  const [loading, setLoading] = useState(true);

  const refresh = async () => {
    setLoading(true);
    try {
      const data = await Shares.listMine();
      setShares(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { refresh(); }, []);

  return (
    <Shell>
      <div className="mb-4">
        <h2 className="text-xl font-semibold flex items-center gap-2">
          <StickyNote className="size-5" />
          Notes partagées avec moi
        </h2>
        <p className="text-sm text-slate-600">
          Voici les notes auxquelles d'autres utilisateurs t'ont donné accès en lecture seule.
        </p>
      </div>

      {loading ? (
        <div className="text-slate-600">Chargement…</div>
      ) : shares.length === 0 ? (
        <div className="rounded-2xl border bg-white p-6 text-center text-slate-600">
          Aucune note partagée pour l'instant.
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {shares.map((s) => (
            <div key={s.id} className="rounded-2xl border bg-white p-4 shadow-sm">
              <h3 className="font-semibold mb-2">{s.noteTitle}</h3>
              <p className="text-sm text-slate-700 whitespace-pre-wrap">
                {s.noteContent}
              </p>
              <p className="text-xs text-slate-500 mt-2">
                Partagé par {s.ownerEmail}
              </p>
            </div>
          ))}
        </div>
      )}
    </Shell>
  );
}