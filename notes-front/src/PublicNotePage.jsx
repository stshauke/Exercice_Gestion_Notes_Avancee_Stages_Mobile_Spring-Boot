import React, { useEffect, useState } from "react";
import { useParams, Link } from "react-router-dom";
import { StickyNote, ArrowLeft } from "lucide-react";
import { PublicLinks } from "./lib/api";

export default function PublicNotePage() {
  const { token } = useParams();
  const [note, setNote] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchNote() {
      try {
        const n = await PublicLinks.get(token);
        setNote(n);
      } catch (e) {
        console.error(e);
        setNote(null);
      } finally {
        setLoading(false);
      }
    }
    fetchNote();
  }, [token]);

  if (loading) {
    return <div className="min-h-screen grid place-items-center text-slate-600">Chargement…</div>;
  }

  if (!note) {
    return (
      <div className="min-h-screen grid place-items-center">
        <div className="text-center text-slate-600">
          <p>Note introuvable ou lien expiré.</p>
          <Link to="/login" className="inline-flex mt-3 items-center gap-2 rounded-xl border px-3 py-1.5 hover:bg-slate-50">
            <ArrowLeft className="size-4" /> Retour
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 p-6">
      <div className="max-w-2xl mx-auto bg-white rounded-2xl border shadow-sm p-6">
        <div className="flex items-center gap-2 mb-4">
          <StickyNote className="size-5" />
          <h1 className="text-xl font-semibold">Note partagée</h1>
        </div>
        <h2 className="text-lg font-semibold mb-2">{note.title}</h2>
        <p className="text-slate-700 whitespace-pre-wrap">{note.content}</p>
      </div>
    </div>
  );
}