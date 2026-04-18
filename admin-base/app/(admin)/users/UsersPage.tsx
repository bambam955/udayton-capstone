import Link from "next/link";

import AdminHeader from "@/components/AdminHeader";
import { listResource } from "@/lib/api/client";
import type { AdminRecord, CustomerRecord, DriverRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

type UserSegment = {
  label: string;
  value: string;
  note: string;
  href: string;
};

export default async function UsersPage() {
  const token = await requireAdminAccessToken();
  const [customers, drivers, admins] = await Promise.all([
    listResource<CustomerRecord>("customers", token, { limit: 1, offset: 0 }),
    listResource<DriverRecord>("drivers", token, { limit: 1, offset: 0 }),
    listResource<AdminRecord>("admins", token, { limit: 1, offset: 0 }),
  ]);

  const userSegments: UserSegment[] = [
    {
      label: "Customers",
      value: customers.meta.total.toLocaleString(),
      note: "Business owners placing supply orders",
      href: "/users/customers",
    },
    {
      label: "Drivers",
      value: drivers.meta.total.toLocaleString(),
      note: "Pickup and delivery after store fulfillment",
      href: "/users/drivers",
    },
    {
      label: "Support admins",
      value: admins.meta.total.toLocaleString(),
      note: "Operations support on shift",
      href: "/users/support-admins",
    },
  ];

  return (
    <div className="space-y-8">
      <AdminHeader
        title="Users"
        subtitle="Business owners place store supply orders, and drivers handle pickup and delivery."
      />
      <div className="grid gap-6 md:grid-cols-3">
        {userSegments.map((segment, index) => (
          <Link
            key={segment.label}
            href={segment.href}
            className="glass-card animate-fade-up rounded-2xl p-6"
            style={{ animationDelay: `${0.05 + index * 0.07}s` }}
          >
            <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
              {segment.label}
            </p>
            <p className="mt-4 font-display text-3xl font-semibold text-white">{segment.value}</p>
            <p className="mt-2 text-sm text-[color:var(--text-muted)]">{segment.note}</p>
            <p className="mt-4 text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]">
              Open
            </p>
          </Link>
        ))}
      </div>
    </div>
  );
}
