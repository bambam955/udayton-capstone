import AdminHeader from "@/components/AdminHeader";

const settingsGroups = [
  { title: "Dispatch rules", detail: "Auto-assign nearest eligible driver within configured radius." },
  { title: "Support alerts", detail: "Escalations route to on-call operations managers." },
  { title: "Retailer integrations", detail: "Endpoint checks and retry thresholds managed here." }
];

export default function SettingsPage() {
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
