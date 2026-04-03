type StatusBadgeProps = {
  value: string | null | undefined;
};

const toneByStatus: Record<string, string> = {
  DELIVERED: "border-emerald-400/30 text-emerald-200",
  OUT_FOR_DELIVERY: "border-sky-400/30 text-sky-200",
  READY_FOR_PICKUP: "border-amber-400/30 text-amber-200",
  PICKING: "border-orange-400/30 text-orange-200",
  SUBMITTED: "border-white/20 text-white",
  HEALTHY: "border-emerald-400/30 text-emerald-200",
  DEGRADED: "border-amber-400/30 text-amber-200",
  ONLINE: "border-emerald-400/30 text-emerald-200",
  BUSY: "border-sky-400/30 text-sky-200",
  OFFLINE: "border-white/20 text-[color:var(--text-muted)]",
  ACTIVE: "border-emerald-400/30 text-emerald-200",
  INACTIVE: "border-white/20 text-[color:var(--text-muted)]",
  COMPLETED: "border-emerald-400/30 text-emerald-200",
  CAPTURED: "border-emerald-400/30 text-emerald-200"
};

export default function StatusBadge({ value }: StatusBadgeProps) {
  const label = value ?? "Unknown";
  const tone = toneByStatus[label] ?? "border-white/15 text-white";

  return (
    <span className={`rounded-full border px-3 py-1 text-xs font-semibold uppercase tracking-[0.16em] ${tone}`}>
      {label.replaceAll("_", " ")}
    </span>
  );
}
