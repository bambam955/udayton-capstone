import AdminHeader from "@/components/AdminHeader";

const teamRows = [
  { name: "Dispatch Operations", owner: "N. Hall", status: "Healthy" },
  { name: "Driver Onboarding", owner: "R. Gupta", status: "Reviewing backlog" },
  { name: "Support Escalations", owner: "M. Lopez", status: "High priority" }
];

export default function TeamPage() {
  return (
    <div className="space-y-8">
      <AdminHeader title="Team" subtitle="Operational teams and ownership overview." />
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="space-y-4">
          {teamRows.map((row) => (
            <div
              key={row.name}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{row.name}</p>
              <p className="mt-2 text-xs text-[color:var(--text-muted)]">Lead: {row.owner}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Status: {row.status}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
