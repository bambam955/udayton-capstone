"use client";

import { useFormStatus } from "react-dom";

import { logoutAction } from "@/lib/actions/auth";

export default function LogoutButton() {
  return (
    <form action={logoutAction}>
      <SubmitButton />
    </form>
  );
}

function SubmitButton() {
  const { pending } = useFormStatus();

  return (
    <button
      type="submit"
      disabled={pending}
      className="rounded-full border border-[rgba(255,255,255,0.18)] px-4 py-2 text-xs font-semibold text-white transition hover:border-[color:var(--accent)] hover:text-[color:var(--accent)] disabled:opacity-60"
    >
      {pending ? "Signing out..." : "Sign out"}
    </button>
  );
}
