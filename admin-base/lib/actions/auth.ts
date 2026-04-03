"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { ApiClientError, loginAdmin, logoutAdmin } from "@/lib/api/client";
import {
  ADMIN_ACCESS_TOKEN_COOKIE,
  ADMIN_ACCESS_TOKEN_MAX_AGE_SECONDS
} from "@/lib/auth/constants";

export type AuthActionState = {
  error?: string;
};

export async function loginAction(
  _previousState: AuthActionState,
  formData: FormData
): Promise<AuthActionState> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return {
      error: "Email and password are required."
    };
  }

  try {
    const result = await loginAdmin(email, password);
    const cookieStore = await cookies();

    cookieStore.set(ADMIN_ACCESS_TOKEN_COOKIE, result.accessToken, {
      httpOnly: true,
      sameSite: "lax",
      secure: process.env.NODE_ENV === "production",
      path: "/",
      maxAge: ADMIN_ACCESS_TOKEN_MAX_AGE_SECONDS,
      expires: new Date(result.expiresAt)
    });
  } catch (error) {
    if (error instanceof ApiClientError) {
      return {
        error: error.message
      };
    }

    return {
      error: "Unable to sign in right now."
    };
  }

  redirect("/");
}

export async function logoutAction() {
  const cookieStore = await cookies();
  const token = cookieStore.get(ADMIN_ACCESS_TOKEN_COOKIE)?.value;

  if (token) {
    try {
      await logoutAdmin(token);
    } catch {
      // Clear the local cookie even if the upstream session is already gone.
    }
  }

  cookieStore.delete(ADMIN_ACCESS_TOKEN_COOKIE);
  redirect("/login");
}
