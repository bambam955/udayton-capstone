import Link from "next/link";
import AdminHeader from "@/components/AdminHeader";

const supportStats = [
  { label: "On shift", value: "7" },
  { label: "Open escalations", value: "5" },
  { label: "Awaiting handoff", value: "2" }
];

const supportQueue = [
  { name: "Quinn Scott", focus: "Delivery escalation desk" },
  { name: "Reese Flynn", focus: "Billing support desk" },
  { name: "Sky Rivera", focus: "Driver support desk" }
];

export default function SupportAdminsPage() {
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
            <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">{item.label}</p>
            <p className="mt-3 font-display text-3xl font-semibold text-white">{item.value}</p>
          </div>
        ))}
      </div>
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <p className="font-display text-lg font-semibold text-white">Support roster</p>
          <Link href="/users" className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]">
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
