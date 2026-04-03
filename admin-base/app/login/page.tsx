import { redirect } from "next/navigation";

import LoginForm from "@/components/LoginForm";
import { getOptionalAdminSession } from "@/lib/auth/session";

export default async function AdminLoginPage() {
  const session = await getOptionalAdminSession();

  if (session) {
    redirect("/");
  }

  return (
    <div className="min-h-screen text-white">
      <div className="mx-auto flex min-h-screen w-full max-w-5xl items-center justify-center px-6">
        <div className="glass-card animate-fade-up w-full max-w-md rounded-3xl p-8">
          <div className="space-y-3">
            <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Biz Rush Admin</p>
            <h1 className="font-display text-2xl font-semibold">Sign in</h1>
            <p className="text-sm text-[color:var(--text-muted)]">Access the Biz Rush operations center.</p>
          </div>
          <LoginForm />
        </div>
      </div>
    </div>
  );
}
