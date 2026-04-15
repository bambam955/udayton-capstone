import AdminHeader from "@/components/AdminHeader";

const reports = [
  { title: "Fulfillment velocity", detail: "Pickup-ready SLA: 93.2%" },
  { title: "Delivery success", detail: "On-time completion: 97.1%" },
  { title: "Incident trend", detail: "Down 12% week-over-week" },
];

export default function ReportsPage() {
  return (
    <div className="space-y-8">
      <AdminHeader
        title="Reports"
        subtitle="Snapshot of key Biz Rush logistics metrics."
      />
      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="grid gap-4 md:grid-cols-3">
          {reports.map((report) => (
            <div
              key={report.title}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{report.title}</p>
              <p className="mt-2 text-xs text-[color:var(--text-muted)]">
                {report.detail}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
