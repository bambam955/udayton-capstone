import "server-only";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { getAdminSession } from "@/lib/api/client";
import { ADMIN_ACCESS_TOKEN_COOKIE } from "@/lib/auth/constants";

export async function getAdminAccessToken() {
  const cookieStore = await cookies();
  return cookieStore.get(ADMIN_ACCESS_TOKEN_COOKIE)?.value ?? null;
}

export async function requireAdminAccessToken() {
  const token = await getAdminAccessToken();

  if (!token) {
    redirect("/login");
  }

  return token;
}

export async function getOptionalAdminSession() {
  const token = await getAdminAccessToken();

  if (!token) {
    return null;
  }

  return getAdminSession(token);
}

export async function requireAdminSession() {
  const session = await getOptionalAdminSession();

  if (!session) {
    redirect("/login");
  }

  return session;
}
