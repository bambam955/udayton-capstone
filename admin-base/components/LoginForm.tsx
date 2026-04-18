"use client";

import { useActionState } from "react";

import { loginAction, type AuthActionState } from "@/lib/actions/auth";

const initialState: AuthActionState = {};

export default function LoginForm() {
  const [state, formAction, pending] = useActionState(loginAction, initialState);

  return (
    <form action={formAction} className="mt-8 space-y-4">
      <input
        id="email"
        name="email"
        type="email"
        autoComplete="email"
        placeholder="Email"
        className="w-full rounded-xl border border-[rgba(255,255,255,0.15)] bg-[rgba(12,14,20,0.6)] px-4 py-3 text-sm text-white placeholder:text-[color:var(--text-subtle)] focus:outline-none focus:ring-2 focus:ring-[color:var(--accent)]"
      />
      <input
        id="password"
        name="password"
        type="password"
        autoComplete="current-password"
        placeholder="Password"
        className="w-full rounded-xl border border-[rgba(255,255,255,0.15)] bg-[rgba(12,14,20,0.6)] px-4 py-3 text-sm text-white placeholder:text-[color:var(--text-subtle)] focus:outline-none focus:ring-2 focus:ring-[color:var(--accent)]"
      />
      {state.error ? (
        <p className="rounded-2xl border border-rose-400/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-100">
          {state.error}
        </p>
      ) : null}
      <button
        type="submit"
        disabled={pending}
        className="w-full rounded-xl bg-[color:var(--accent)] px-5 py-3 text-sm font-semibold text-white transition hover:brightness-110 disabled:opacity-60"
      >
        {pending ? "Signing in..." : "Sign in"}
      </button>
    </form>
  );
}
