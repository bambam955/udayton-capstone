"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

const AUTH_KEY = "admin-auth";

export default function LogoutButton() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleLogout = () => {
    setLoading(true);
    window.localStorage.removeItem(AUTH_KEY);
    router.replace("/login");
  };

  return (
    <button
      type="button"
      onClick={handleLogout}
      disabled={loading}
      className="rounded-full border border-[rgba(255,255,255,0.18)] px-4 py-2 text-xs font-semibold text-white transition hover:border-[color:var(--accent)] hover:text-[color:var(--accent)] disabled:opacity-60"
    >
      {loading ? "Signing out..." : "Sign out"}
    </button>
  );
}
