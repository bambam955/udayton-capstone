import AdminHeader from "@/components/AdminHeader";
import { getDashboard, listResource } from "@/lib/api/client";
import type { OrderRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

export default async function AdminDashboard() {
  const token = await requireAdminAccessToken();
  const [dashboard, deliveredOrders] = await Promise.all([
    getDashboard(token),
    listResource<OrderRecord>("orders", token, {
      status: "DELIVERED",
      limit: 1,
      offset: 0
    })
  ]);

  const stats = [
    {
      label: "Active drivers",
      value: dashboard.metrics.activeDrivers.toLocaleString(),
      note: "Currently online"
    },
    {
      label: "Ready pickups",
      value: dashboard.metrics.readyForPickupOrders.toLocaleString(),
      note: "Awaiting dispatch"
    },
    {
      label: "Deliveries today",
      value: deliveredOrders.meta.total.toLocaleString(),
      note: "Completed runs"
    }
  ];

  const degradedIntegrations = dashboard.integrationHealth.filter(
    (integration) => integration.status && !["HEALTHY", "OK"].includes(integration.status)
  );
  const activity = [
    {
      title: "Retailer queue",
      detail: `${dashboard.metrics.readyForPickupOrders} staged orders need assignment`
    },
    {
      title: "Support escalations",
      detail: `${dashboard.metrics.integrationIssues} systems flagged for review`
    },
    {
      title: "System health",
      detail:
        degradedIntegrations.length > 0
          ? `${degradedIntegrations.length} integration checks need attention`
          : "All critical services operational"
    }
  ];

  return (
    <div className="space-y-8">
      <AdminHeader title="Dashboard" subtitle="Quick pulse on Biz Rush operations." />
      <div className="grid gap-6 md:grid-cols-3">
        {stats.map((item, index) => (
          <div
            key={item.label}
            className="glass-card animate-fade-up rounded-2xl p-6"
            style={{ animationDelay: `${0.05 + index * 0.07}s` }}
          >
            <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">{item.label}</p>
            <p className="mt-4 font-display text-3xl font-semibold text-white">{item.value}</p>
            <p className="mt-2 text-sm text-[color:var(--text-muted)]">{item.note}</p>
          </div>
        ))}
      </div>
      <div className="glass-card animate-fade-up space-y-4 rounded-2xl p-6">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Operations queue</p>
          <p className="mt-2 font-display text-lg font-semibold text-white">Attention needed</p>
        </div>
        <div className="grid gap-4 md:grid-cols-3">
          {activity.map((item) => (
            <div
              key={item.title}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{item.title}</p>
              <p className="mt-2 text-xs text-[color:var(--text-muted)]">{item.detail}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
