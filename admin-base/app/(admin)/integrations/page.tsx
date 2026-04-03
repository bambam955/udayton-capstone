import AdminHeader from "@/components/AdminHeader";
import StatusBadge from "@/components/StatusBadge";
import { listIntegrations } from "@/lib/api/client";
import { requireAdminAccessToken } from "@/lib/auth/session";
import { formatDateTime } from "@/lib/format";

export default async function IntegrationsPage() {
  const token = await requireAdminAccessToken();
  const integrations = await listIntegrations(token);

  return (
    <div className="space-y-8">
      <AdminHeader title="Integrations" subtitle="Backend integration health surfaced through the admin resource API." />
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <div>
            <p className="font-display text-lg font-semibold text-white">Integration checks</p>
            <p className="mt-1 text-sm text-[color:var(--text-muted)]">
              Showing {integrations.data.length} of {integrations.meta.total} health rows.
            </p>
          </div>
        </div>
        <div className="space-y-4">
          {integrations.data.map((integration) => (
            <div
              key={integration.health_id}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <div className="flex flex-wrap items-start justify-between gap-4">
                <div>
                  <p className="text-sm font-semibold text-white">{integration.integration ?? "Unknown integration"}</p>
                  <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                    Last checked {formatDateTime(integration.last_checked_at)}
                  </p>
                </div>
                <StatusBadge value={integration.status} />
              </div>
              <p className="mt-3 text-sm text-white">{integration.error || "No active error reported."}</p>
              {integration.details_json ? (
                <pre className="mt-3 overflow-x-auto rounded-2xl bg-[rgba(0,0,0,0.24)] px-4 py-3 text-xs text-[color:var(--text-muted)]">
                  {integration.details_json}
                </pre>
              ) : null}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
