"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

const AUTH_KEY = "admin-auth";

export default function AdminLoginPage() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setLoading(true);
    window.localStorage.setItem(AUTH_KEY, "1");
    router.replace("/");
  };

  return (
    <div className="min-h-screen text-white">
      <div className="mx-auto flex min-h-screen w-full max-w-5xl items-center justify-center px-6">
        <div className="glass-card animate-fade-up w-full max-w-md rounded-3xl p-8">
          <div className="space-y-3">
            <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Biz Rush Admin</p>
            <h1 className="font-display text-2xl font-semibold">Sign in</h1>
            <p className="text-sm text-[color:var(--text-muted)]">Access the Biz Rush operations center.</p>
          </div>
          <form onSubmit={handleSubmit} className="mt-8 space-y-4">
            <input
              type="text"
              placeholder="Username"
              value={username}
              onChange={(event) => setUsername(event.target.value)}
              className="w-full rounded-xl border border-[rgba(255,255,255,0.15)] bg-[rgba(12,14,20,0.6)] px-4 py-3 text-sm text-white placeholder:text-[color:var(--text-subtle)] focus:outline-none focus:ring-2 focus:ring-[color:var(--accent)]"
            />
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className="w-full rounded-xl border border-[rgba(255,255,255,0.15)] bg-[rgba(12,14,20,0.6)] px-4 py-3 text-sm text-white placeholder:text-[color:var(--text-subtle)] focus:outline-none focus:ring-2 focus:ring-[color:var(--accent)]"
            />
            <button
              type="submit"
              disabled={loading}
              className="w-full rounded-xl bg-[color:var(--accent)] px-5 py-3 text-sm font-semibold text-white transition hover:brightness-110 disabled:opacity-60"
            >
              {loading ? "Signing in..." : "Sign in"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
