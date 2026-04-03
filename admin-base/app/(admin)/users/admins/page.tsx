import Link from "next/link";

import AdminHeader from "@/components/AdminHeader";
import StatusBadge from "@/components/StatusBadge";
import { getResource, listResource } from "@/lib/api/client";
import type { AdminProfileRecord, AdminRecord, AdminRoleRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";
import { formatDate } from "@/lib/format";

export default async function AdminsPage() {
  const token = await requireAdminAccessToken();
  const admins = await listResource<AdminRecord>("admins", token, {
    limit: 50,
    offset: 0
  });

  const profiles = await listResource<AdminProfileRecord>("admin-profiles", token, {
    limit: 50,
    offset: 0
  });
  const profileByAdminId = new Map(profiles.data.map((profile) => [profile.admin_id, profile]));

  const uniqueRoleIds = [...new Set(profiles.data.map((profile) => profile.role_id))];
  const roles = await Promise.all(uniqueRoleIds.map((roleId) => getResource<AdminRoleRecord>("admin-roles", roleId, token)));
  const roleById = new Map(roles.map((role) => [role.data.role_id, role.data]));

  return (
    <div className="space-y-8">
      <AdminHeader title="Admins" subtitle="Operational admin accounts, roles, and profile data." />
      <div className="grid gap-6 md:grid-cols-3">
        <div className="glass-card animate-fade-up rounded-2xl p-6">
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Admin accounts</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{admins.meta.total}</p>
        </div>
        <div className="glass-card animate-fade-up rounded-2xl p-6" style={{ animationDelay: "0.1s" }}>
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Profiles</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{profiles.meta.total}</p>
        </div>
        <div className="glass-card animate-fade-up rounded-2xl p-6" style={{ animationDelay: "0.16s" }}>
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Roles in use</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{uniqueRoleIds.length}</p>
        </div>
      </div>

      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <p className="font-display text-lg font-semibold text-white">Admin directory</p>
          <Link href="/users" className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]">
            Back to users
          </Link>
        </div>

        <div className="hidden overflow-x-auto md:block">
          <table className="w-full min-w-[760px] text-left text-sm">
            <thead className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]">
              <tr>
                <th className="pb-3 pr-4">Admin</th>
                <th className="pb-3 pr-4">Email</th>
                <th className="pb-3 pr-4">Title</th>
                <th className="pb-3 pr-4">Role</th>
                <th className="pb-3">Status</th>
              </tr>
            </thead>
            <tbody>
              {admins.data.map((admin) => {
                const profile = profileByAdminId.get(admin.admin_id);
                const role = profile ? roleById.get(profile.role_id) : undefined;

                return (
                  <tr key={admin.admin_id} className="border-t border-[rgba(255,255,255,0.08)] text-[color:var(--text-muted)]">
                    <td className="py-3 pr-4 text-white">{admin.full_name || admin.admin_id}</td>
                    <td className="py-3 pr-4">{admin.email || "—"}</td>
                    <td className="py-3 pr-4">{profile?.title || "—"}</td>
                    <td className="py-3 pr-4">{role?.name || "—"}</td>
                    <td className="py-3">
                      <StatusBadge value={admin.is_active ? "ACTIVE" : "INACTIVE"} />
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        <div className="space-y-3 md:hidden">
          {admins.data.map((admin) => {
            const profile = profileByAdminId.get(admin.admin_id);
            const role = profile ? roleById.get(profile.role_id) : undefined;

            return (
              <div
                key={admin.admin_id}
                className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
              >
                <p className="text-sm font-semibold text-white">{admin.full_name || admin.admin_id}</p>
                <p className="mt-1 text-xs text-[color:var(--text-muted)]">Email: {admin.email || "—"}</p>
                <p className="mt-1 text-xs text-[color:var(--text-muted)]">Title: {profile?.title || "—"}</p>
                <p className="mt-1 text-xs text-[color:var(--text-muted)]">Role: {role?.name || "—"}</p>
                <p className="mt-1 text-xs text-[color:var(--text-muted)]">Created: {formatDate(admin.created_at)}</p>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
