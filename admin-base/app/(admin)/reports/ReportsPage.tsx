import AdminHeader from "@/components/AdminHeader";
import { getDashboard, listResource } from "@/lib/api/client";
import type { OrderRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

export default async function ReportsPage() {
  const token = await requireAdminAccessToken();
  const [dashboard, deliveredOrders] = await Promise.all([
    getDashboard(token),
    listResource<OrderRecord>("orders", token, { status: "DELIVERED", limit: 1, offset: 0 }),
  ]);

  const totalOrders = Math.max(dashboard.metrics.totalOrders, 1);
  const readyForPickupRate = ((dashboard.metrics.readyForPickupOrders / totalOrders) * 100).toFixed(
    1
  );
  const deliveredRate = ((deliveredOrders.meta.total / totalOrders) * 100).toFixed(1);
  const reports = [
    {
      title: "Fulfillment velocity",
      detail: `Pickup-ready share: ${readyForPickupRate}%`,
    },
    {
      title: "Delivery success",
      detail: `Delivered orders: ${deliveredRate}%`,
    },
    {
      title: "Incident trend",
      detail:
        dashboard.metrics.integrationIssues > 0
          ? `${dashboard.metrics.integrationIssues} active platform issues`
          : "No active operational incidents",
    },
  ];

  return (
    <div className="space-y-8">
      <AdminHeader title="Reports" subtitle="Snapshot of key Biz Rush logistics metrics." />
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="grid gap-4 md:grid-cols-3">
          {reports.map((report) => (
            <div
              key={report.title}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{report.title}</p>
              <p className="mt-2 text-xs text-[color:var(--text-muted)]">{report.detail}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
