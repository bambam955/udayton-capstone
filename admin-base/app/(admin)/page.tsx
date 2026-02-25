import AdminHeader from "@/components/AdminHeader";

const stats = [
  { label: "Active drivers", value: "184", note: "Currently online" },
  { label: "Ready pickups", value: "72", note: "Awaiting dispatch" },
  { label: "Deliveries today", value: "1,248", note: "Completed runs" }
];

const activity = [
  { title: "Retailer queue", detail: "12 staged orders need assignment" },
  { title: "Support escalations", detail: "4 tickets flagged as urgent" },
  { title: "System health", detail: "All critical services operational" }
];

export default function AdminDashboard() {
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
