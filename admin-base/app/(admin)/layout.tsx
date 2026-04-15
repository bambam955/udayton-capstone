import Sidebar from "@/components/Sidebar";
import LogoutButton from "@/components/LogoutButton";
import { ToastProvider } from "@/components/ToastProvider";
import { AdminSessionProvider } from "@/components/AdminSessionProvider";
import { requireAdminSession } from "@/lib/auth/session";

export default async function AdminLayout({
  children
}: {
  children: React.ReactNode;
}) {
  const admin = await requireAdminSession();

  return (
    <AdminSessionProvider initialAdmin={admin}>
      <ToastProvider>
        <div className="relative min-h-screen">
          <div className="mx-auto flex w-full max-w-7xl gap-6 px-6 py-10">
            <div className="hidden w-64 lg:block">
              <Sidebar />
            </div>
            <div className="flex-1 space-y-8">
              <div className="glass-card animate-fade-up flex flex-col gap-4 rounded-3xl px-6 py-5 md:flex-row md:items-center md:justify-between">
                <div>
                  <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
                    Biz Rush Admin
                  </p>
                  <p className="font-display text-lg font-semibold text-white">
                    Operations Center
                  </p>
                </div>
                <div className="flex items-center gap-4">
                  <div className="rounded-full border border-[rgba(255,255,255,0.18)] px-4 py-2 text-xs text-[color:var(--text-muted)]">
                    {admin.email || admin.fullName || "Admin"}
                  </div>
                  {admin.title ? (
                    <div className="rounded-full border border-[rgba(255,255,255,0.18)] px-3 py-2 text-[10px] uppercase tracking-[0.2em] text-[color:var(--text-subtle)]">
                      {admin.title}
                    </div>
                  ) : null}
                  <LogoutButton />
                </div>
              </div>
              {children}
            </div>
          </div>
        </div>
      </ToastProvider>
    </AdminSessionProvider>
  );
}
