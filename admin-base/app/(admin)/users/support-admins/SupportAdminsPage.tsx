import Link from "next/link";

import AdminHeader from "@/components/AdminHeader";
import { getDashboard, listResource } from "@/lib/api/client";
import type { AdminProfileRecord, AdminRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

export default async function SupportAdminsPage() {
  const token = await requireAdminAccessToken();
  const [admins, profiles, dashboard] = await Promise.all([
    listResource<AdminRecord>("admins", token, { limit: 100, offset: 0 }),
    listResource<AdminProfileRecord>("admin-profiles", token, { limit: 100, offset: 0 }),
    getDashboard(token),
  ]);

  const profileByAdminId = new Map(profiles.data.map((profile) => [profile.admin_id, profile]));
  const supportStats = [
    { label: "On shift", value: admins.meta.total.toLocaleString() },
    { label: "Open escalations", value: dashboard.metrics.integrationIssues.toLocaleString() },
    {
      label: "Awaiting handoff",
      value: admins.data.filter((admin) => admin.is_active !== true).length.toLocaleString(),
    },
  ];

  const supportQueue = admins.data.slice(0, 3).map((admin, index) => {
    const profile = profileByAdminId.get(admin.admin_id);
    const focusAreas = ["Delivery escalation desk", "Billing support desk", "Driver support desk"];

    return {
      name: admin.full_name ?? admin.email ?? admin.admin_id,
      focus: profile?.title ?? focusAreas[index] ?? "Operations support desk",
    };
  });

  return (
    <div className="space-y-8">
      <AdminHeader title="Support Admins" subtitle="Starter view for operations support." />
      <div className="grid gap-6 md:grid-cols-3">
        {supportStats.map((item, index) => (
          <div
            key={item.label}
            className="glass-card animate-fade-up rounded-2xl p-6"
            style={{ animationDelay: `${0.05 + index * 0.07}s` }}
          >
            <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
              {item.label}
            </p>
            <p className="mt-3 font-display text-3xl font-semibold text-white">{item.value}</p>
          </div>
        ))}
      </div>
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <p className="font-display text-lg font-semibold text-white">Support roster</p>
          <Link
            href="/users"
            className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]"
          >
            Back to users
          </Link>
        </div>
        <div className="space-y-3">
          {supportQueue.map((item) => (
            <div
              key={item.name}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{item.name}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">{item.focus}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
