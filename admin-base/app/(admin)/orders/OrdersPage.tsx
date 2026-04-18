import Link from "next/link";

import AdminHeader from "@/components/AdminHeader";
import StatusBadge from "@/components/StatusBadge";
import { listResource } from "@/lib/api/client";
import { orderStatuses, type OrderRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";
import { formatDateTime, formatMoney } from "@/lib/format";

type OrdersPageProps = {
  searchParams: Promise<{
    status?: string;
  }>;
};

export default async function OrdersPage({ searchParams }: OrdersPageProps) {
  const token = await requireAdminAccessToken();
  const { status } = await searchParams;
  const activeStatus = orderStatuses.includes(status as (typeof orderStatuses)[number])
    ? status
    : undefined;
  const response = await listResource<OrderRecord>("orders", token, {
    limit: 50,
    offset: 0,
    ...(activeStatus ? { status: activeStatus } : {}),
  });

  return (
    <div className="space-y-8">
      <AdminHeader
        title="Orders"
        subtitle="Monitor live order state and drill into refunds or status changes."
      />

      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="flex flex-wrap gap-3">
          <Link
            href="/orders"
            className={`rounded-full border px-4 py-2 text-xs font-semibold uppercase tracking-[0.18em] ${
              !activeStatus
                ? "border-[rgba(255,255,255,0.2)] bg-[rgba(255,255,255,0.08)] text-white"
                : "border-transparent bg-[rgba(255,255,255,0.03)] text-[color:var(--text-muted)] hover:text-white"
            }`}
          >
            All
          </Link>
          {orderStatuses.map((value) => (
            <Link
              key={value}
              href={`/orders?status=${value}`}
              className={`rounded-full border px-4 py-2 text-xs font-semibold uppercase tracking-[0.18em] ${
                activeStatus === value
                  ? "border-[rgba(255,255,255,0.2)] bg-[rgba(255,255,255,0.08)] text-white"
                  : "border-transparent bg-[rgba(255,255,255,0.03)] text-[color:var(--text-muted)] hover:text-white"
              }`}
            >
              {value.replaceAll("_", " ")}
            </Link>
          ))}
        </div>
      </div>

      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <div>
            <p className="font-display text-lg font-semibold text-white">Orders table</p>
            <p className="mt-1 text-sm text-[color:var(--text-muted)]">
              Showing {response.data.length} of {response.meta.total} orders.
            </p>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full min-w-[860px] text-left text-sm">
            <thead className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]">
              <tr>
                <th className="pb-3 pr-4">Order</th>
                <th className="pb-3 pr-4">Customer</th>
                <th className="pb-3 pr-4">Retailer</th>
                <th className="pb-3 pr-4">Status</th>
                <th className="pb-3 pr-4">Placed</th>
                <th className="pb-3 pr-4">Updated</th>
                <th className="pb-3">Total</th>
              </tr>
            </thead>
            <tbody>
              {response.data.map((order) => (
                <tr
                  key={order.order_id}
                  className="border-t border-[rgba(255,255,255,0.08)] text-[color:var(--text-muted)]"
                >
                  <td className="py-3 pr-4 text-white">
                    <Link
                      href={`/orders/${order.order_id}`}
                      className="hover:text-[color:var(--accent)]"
                    >
                      {order.external_order_id ?? order.order_id}
                    </Link>
                  </td>
                  <td className="py-3 pr-4">{order.customer_id}</td>
                  <td className="py-3 pr-4">{order.retailer_id}</td>
                  <td className="py-3 pr-4">
                    <StatusBadge value={order.status} />
                  </td>
                  <td className="py-3 pr-4">{formatDateTime(order.placed_at)}</td>
                  <td className="py-3 pr-4">{formatDateTime(order.updated_at)}</td>
                  <td className="py-3 text-white">
                    {formatMoney(order.total_cents, order.currency ?? "USD")}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
