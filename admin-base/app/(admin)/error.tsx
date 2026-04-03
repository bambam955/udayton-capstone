"use client";

type AdminErrorPageProps = {
  error: Error & { digest?: string };
  reset: () => void;
};

export default function AdminErrorPage({ error, reset }: AdminErrorPageProps) {
  return (
    <div className="glass-card animate-fade-up rounded-2xl p-8 text-white">
      <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Admin error</p>
      <h2 className="mt-3 font-display text-2xl font-semibold">Unable to load this view</h2>
      <p className="mt-3 max-w-2xl text-sm text-[color:var(--text-muted)]">
        {error.message || "The admin interface hit an unexpected error while talking to the backend API."}
      </p>
      <button
        type="button"
        onClick={reset}
        className="mt-6 rounded-xl bg-[color:var(--accent)] px-5 py-3 text-sm font-semibold text-white transition hover:brightness-110"
      >
        Retry
      </button>
    </div>
  );
}
