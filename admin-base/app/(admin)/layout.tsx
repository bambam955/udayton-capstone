import AdminClientGate from "@/components/AdminClientGate";
import Sidebar from "@/components/Sidebar";
import LogoutButton from "@/components/LogoutButton";
import { ToastProvider } from "@/components/ToastProvider";
import { AdminSessionProvider } from "@/components/AdminSessionProvider";

const demoAdmin = {
  id: 1,
  username: "Admin",
  email: "admin@bizrush.local",
  role: "Owner"
};

export default function AdminLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <AdminSessionProvider initialAdmin={demoAdmin}>
      <ToastProvider>
        <div className="relative min-h-screen">
          <AdminClientGate />
          <div className="mx-auto flex w-full max-w-7xl gap-6 px-6 py-10">
            <div className="hidden w-64 lg:block">
              <Sidebar />
            </div>
            <div className="flex-1 space-y-8">
              <div className="glass-card animate-fade-up flex flex-col gap-4 rounded-3xl px-6 py-5 md:flex-row md:items-center md:justify-between">
                <div>
                  <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Biz Rush Admin</p>
                  <p className="font-display text-lg font-semibold text-white">Operations Center</p>
                </div>
                <div className="flex items-center gap-4">
                  <div className="rounded-full border border-[rgba(255,255,255,0.18)] px-4 py-2 text-xs text-[color:var(--text-muted)]">
                    {demoAdmin.email || demoAdmin.username || "Admin"}
                  </div>
                  {demoAdmin.role ? (
                    <div className="rounded-full border border-[rgba(255,255,255,0.18)] px-3 py-2 text-[10px] uppercase tracking-[0.2em] text-[color:var(--text-subtle)]">
                      {demoAdmin.role}
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
