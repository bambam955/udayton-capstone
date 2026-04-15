import AdminHeader from "@/components/AdminHeader";
import { getDashboard } from "@/lib/api/client";
import { requireAdminAccessToken } from "@/lib/auth/session";

export default async function SettingsPage() {
  const token = await requireAdminAccessToken();
  const dashboard = await getDashboard(token);

  const settingsGroups = [
    {
      title: "Dispatch rules",
      detail:
        dashboard.metrics.readyForPickupOrders > 0
          ? `${dashboard.metrics.readyForPickupOrders} ready pickups are waiting on dispatch.`
          : "No ready-pickup backlog right now.",
    },
    {
      title: "Support alerts",
      detail:
        dashboard.metrics.integrationIssues > 0
          ? `${dashboard.metrics.integrationIssues} active alerts route to operations managers.`
          : "No current alerting escalations.",
    },
    {
      title: "Retailer integrations",
      detail:
        dashboard.integrationHealth.length > 0
          ? `${dashboard.integrationHealth.length} integration checks are available in the backend admin API.`
          : "No integration health rows are currently available.",
    },
  ];

  return (
    <div className="space-y-8">
      <AdminHeader title="Settings" subtitle="Platform controls and operational defaults." />
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="space-y-4">
          {settingsGroups.map((group) => (
            <div
              key={group.title}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{group.title}</p>
              <p className="mt-2 text-xs text-[color:var(--text-muted)]">{group.detail}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
