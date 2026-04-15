"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

const AUTH_KEY = "admin-auth";

export default function AdminClientGate() {
  const router = useRouter();

  useEffect(() => {
    const hasAuth =
      typeof window !== "undefined" &&
      window.localStorage.getItem(AUTH_KEY) === "1";

    if (!hasAuth) {
      router.replace("/login");
    }
  }, [router]);

  return null;
}
