import AdminHeader from "@/components/AdminHeader";
import { getDashboard, listResource } from "@/lib/api/client";
import type { AdminRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

export default async function TeamPage() {
  const token = await requireAdminAccessToken();
  const [dashboard, admins] = await Promise.all([
    getDashboard(token),
    listResource<AdminRecord>("admins", token, { limit: 100, offset: 0 }),
  ]);

  const leadNames = admins.data.map((admin) => admin.full_name ?? admin.email ?? admin.admin_id);
  const teamRows = [
    {
      name: "Dispatch Operations",
      owner: leadNames[0] ?? "Unassigned",
      status: dashboard.metrics.readyForPickupOrders > 0 ? "Reviewing backlog" : "Healthy",
    },
    {
      name: "Driver Onboarding",
      owner: leadNames[1] ?? leadNames[0] ?? "Unassigned",
      status: dashboard.metrics.activeDrivers > 0 ? "Healthy" : "Needs coverage",
    },
    {
      name: "Support Escalations",
      owner: leadNames[2] ?? leadNames[0] ?? "Unassigned",
      status: dashboard.metrics.integrationIssues > 0 ? "High priority" : "Healthy",
    },
  ];

  return (
    <div className="space-y-8">
      <AdminHeader title="Team" subtitle="Operational teams and ownership overview." />
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="space-y-4">
          {teamRows.map((row) => (
            <div
              key={row.name}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{row.name}</p>
              <p className="mt-2 text-xs text-[color:var(--text-muted)]">Lead: {row.owner}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Status: {row.status}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
