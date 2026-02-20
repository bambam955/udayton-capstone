import Link from "next/link";
import AdminHeader from "@/components/AdminHeader";

type CustomerRecord = {
  id: string;
  businessName: string;
  ownerName: string;
  primaryStore: string;
  openOrders: number;
  status: "Active" | "Needs follow-up";
};

const customerRecords: CustomerRecord[] = [
  { id: "C-001", businessName: "Northside Deli", ownerName: "Jordan Lee", primaryStore: "Target - Midtown", openOrders: 3, status: "Active" },
  { id: "C-002", businessName: "Elm Street Cafe", ownerName: "Taylor Reed", primaryStore: "Walmart - Eastgate", openOrders: 2, status: "Active" },
  { id: "C-003", businessName: "Harbor Print Shop", ownerName: "Avery Kim", primaryStore: "Target - Harbor", openOrders: 1, status: "Needs follow-up" },
  { id: "C-004", businessName: "Bayside Bakery", ownerName: "Morgan Park", primaryStore: "Walmart - South Bay", openOrders: 2, status: "Active" },
  { id: "C-005", businessName: "Central Auto Care", ownerName: "Casey Noor", primaryStore: "Target - Central", openOrders: 0, status: "Active" },
  { id: "C-006", businessName: "Oakline Flowers", ownerName: "Drew Patel", primaryStore: "Target - West End", openOrders: 2, status: "Active" },
  { id: "C-007", businessName: "Metro Hardware", ownerName: "Reese Flynn", primaryStore: "Walmart - Metro", openOrders: 4, status: "Needs follow-up" },
  { id: "C-008", businessName: "Summit Pet Supply", ownerName: "Quinn Scott", primaryStore: "Target - Summit", openOrders: 1, status: "Active" },
  { id: "C-009", businessName: "Riverbend Office Co.", ownerName: "Sky Rivera", primaryStore: "Walmart - Riverbend", openOrders: 2, status: "Active" },
  { id: "C-010", businessName: "Westfield Market", ownerName: "Riley Chen", primaryStore: "Target - Westfield", openOrders: 3, status: "Active" },
  { id: "C-011", businessName: "Greenline Gym", ownerName: "Nico Hall", primaryStore: "Walmart - Greenline", openOrders: 1, status: "Active" },
  { id: "C-012", businessName: "Beacon Bookstore", ownerName: "Jamie Ross", primaryStore: "Target - Beacon", openOrders: 0, status: "Active" }
];

const totalCustomers = customerRecords.length;
const activeOrders = customerRecords.filter((customer) => customer.openOrders > 0).length;
const needsFollowUp = customerRecords.filter((customer) => customer.status === "Needs follow-up").length;

export default function CustomersPage() {
  return (
    <div className="space-y-8">
      <AdminHeader
        title="Customers"
        subtitle="Business owners placing supply orders to partner stores."
      />
      <div className="grid gap-6 md:grid-cols-3">
        <div className="glass-card animate-fade-up rounded-2xl p-6">
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Total business owners</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{totalCustomers}</p>
        </div>
        <div className="glass-card animate-fade-up rounded-2xl p-6" style={{ animationDelay: "0.1s" }}>
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">With open orders</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{activeOrders}</p>
        </div>
        <div className="glass-card animate-fade-up rounded-2xl p-6" style={{ animationDelay: "0.16s" }}>
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Needs follow-up</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{needsFollowUp}</p>
        </div>
      </div>

      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <p className="font-display text-lg font-semibold text-white">All customer accounts</p>
          <Link href="/users" className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]">
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
              {customerRecords.map((customer) => (
                <tr key={customer.id} className="border-t border-[rgba(255,255,255,0.08)] text-[color:var(--text-muted)]">
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
          {customerRecords.map((customer) => (
            <div
              key={customer.id}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{customer.businessName}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Owner: {customer.ownerName}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Store: {customer.primaryStore}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Open orders: {customer.openOrders}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Status: {customer.status}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
