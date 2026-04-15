import Link from "next/link";

import AdminHeader from "@/components/AdminHeader";
import { listResource } from "@/lib/api/client";
import type { CustomerRecord, OrderRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

type CustomerDashboardRecord = {
  id: string;
  businessName: string;
  ownerName: string;
  primaryStore: string;
  openOrders: number;
  status: "Active" | "Needs follow-up";
};

function formatBusinessName(customer: CustomerRecord) {
  if (customer.full_name) {
    return customer.full_name;
  }

  if (customer.email) {
    return customer.email.split("@")[0] ?? customer.customer_id;
  }

  return customer.customer_id;
}

export default async function CustomersPage() {
  const token = await requireAdminAccessToken();
  const [customers, orders] = await Promise.all([
    listResource<CustomerRecord>("customers", token, { limit: 100, offset: 0 }),
    listResource<OrderRecord>("orders", token, { limit: 100, offset: 0 }),
  ]);

  const records: CustomerDashboardRecord[] = customers.data.map((customer) => {
    const customerOrders = orders.data.filter(
      (order) => order.customer_id === customer.customer_id
    );
    const openOrders = customerOrders.filter((order) => order.status !== "DELIVERED").length;
    const primaryStore = customerOrders[0]?.retailer_id ?? "No linked retailer";
    const inactiveOrNeedsReview = customer.is_active !== true || openOrders > 1;

    return {
      id: customer.customer_id,
      businessName: formatBusinessName(customer),
      ownerName: customer.full_name ?? customer.email ?? customer.customer_id,
      primaryStore,
      openOrders,
      status: inactiveOrNeedsReview ? "Needs follow-up" : "Active",
    };
  });

  const totalCustomers = records.length;
  const activeOrders = records.filter((customer) => customer.openOrders > 0).length;
  const needsFollowUp = records.filter((customer) => customer.status === "Needs follow-up").length;

  return (
    <div className="space-y-8">
      <AdminHeader
        title="Customers"
        subtitle="Business owners placing supply orders to partner stores."
      />
      <div className="grid gap-6 md:grid-cols-3">
        <div className="glass-card animate-fade-up rounded-2xl p-6">
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
            Total business owners
          </p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{totalCustomers}</p>
        </div>
        <div
          className="glass-card animate-fade-up rounded-2xl p-6"
          style={{ animationDelay: "0.1s" }}
        >
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
            With open orders
          </p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{activeOrders}</p>
        </div>
        <div
          className="glass-card animate-fade-up rounded-2xl p-6"
          style={{ animationDelay: "0.16s" }}
        >
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
            Needs follow-up
          </p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{needsFollowUp}</p>
        </div>
      </div>

      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <p className="font-display text-lg font-semibold text-white">All customer accounts</p>
          <Link
            href="/users"
            className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]"
          >
            Back to users
          </Link>
        </div>

        <div className="hidden overflow-x-auto md:block">
          <table className="w-full min-w-[760px] text-left text-sm">
            <thead className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]">
              <tr>
                <th className="pb-3 pr-4">Business</th>
                <th className="pb-3 pr-4">Owner</th>
                <th className="pb-3 pr-4">Primary store</th>
                <th className="pb-3 pr-4">Open orders</th>
                <th className="pb-3">Status</th>
              </tr>
            </thead>
            <tbody>
              {records.map((customer) => (
                <tr
                  key={customer.id}
                  className="border-t border-[rgba(255,255,255,0.08)] text-[color:var(--text-muted)]"
                >
                  <td className="py-3 pr-4 text-white">{customer.businessName}</td>
                  <td className="py-3 pr-4">{customer.ownerName}</td>
                  <td className="py-3 pr-4">{customer.primaryStore}</td>
                  <td className="py-3 pr-4">{customer.openOrders}</td>
                  <td className="py-3">
                    <span className="rounded-full border border-[rgba(255,255,255,0.14)] px-3 py-1 text-xs text-white">
                      {customer.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="space-y-3 md:hidden">
          {records.map((customer) => (
            <div
              key={customer.id}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{customer.businessName}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Owner: {customer.ownerName}
              </p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Store: {customer.primaryStore}
              </p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Open orders: {customer.openOrders}
              </p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Status: {customer.status}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
