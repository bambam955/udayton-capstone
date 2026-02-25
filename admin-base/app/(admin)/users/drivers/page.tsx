import Link from "next/link";
import AdminHeader from "@/components/AdminHeader";

type DriverRecord = {
  id: string;
  name: string;
  serviceZone: string;
  activePickup: string;
  availability: "Available" | "On delivery" | "Offline";
  verificationStatus: "Verified" | "Review";
};

const driverRecords: DriverRecord[] = [
  { id: "D-001", name: "Maya Brooks", serviceZone: "Midtown", activePickup: "Target - Midtown", availability: "On delivery", verificationStatus: "Verified" },
  { id: "D-002", name: "Leo Turner", serviceZone: "Eastgate", activePickup: "Walmart - Eastgate", availability: "On delivery", verificationStatus: "Verified" },
  { id: "D-003", name: "Eli Morgan", serviceZone: "Harbor", activePickup: "None", availability: "Available", verificationStatus: "Verified" },
  { id: "D-004", name: "Nora Singh", serviceZone: "South Bay", activePickup: "Target - South Bay", availability: "On delivery", verificationStatus: "Verified" },
  { id: "D-005", name: "Chris Vega", serviceZone: "West End", activePickup: "None", availability: "Available", verificationStatus: "Verified" },
  { id: "D-006", name: "Aiden Cole", serviceZone: "Central", activePickup: "Walmart - Central", availability: "On delivery", verificationStatus: "Verified" },
  { id: "D-007", name: "Rae Nolan", serviceZone: "Riverbend", activePickup: "None", availability: "Available", verificationStatus: "Review" },
  { id: "D-008", name: "Noah Cruz", serviceZone: "Summit", activePickup: "Target - Summit", availability: "On delivery", verificationStatus: "Verified" },
  { id: "D-009", name: "Liam Park", serviceZone: "Greenline", activePickup: "None", availability: "Offline", verificationStatus: "Verified" },
  { id: "D-010", name: "Zoe Kim", serviceZone: "Beacon", activePickup: "Walmart - Beacon", availability: "On delivery", verificationStatus: "Verified" },
  { id: "D-011", name: "Ivy Ward", serviceZone: "Westfield", activePickup: "None", availability: "Available", verificationStatus: "Verified" }
];

const totalDrivers = driverRecords.length;
const availableNow = driverRecords.filter((driver) => driver.availability === "Available").length;
const onDelivery = driverRecords.filter((driver) => driver.availability === "On delivery").length;

export default function DriversPage() {
  return (
    <div className="space-y-8">
      <AdminHeader
        title="Drivers"
        subtitle="Couriers who pick up after store fulfillment and deliver supplies."
      />
      <div className="grid gap-6 md:grid-cols-3">
        <div className="glass-card animate-fade-up rounded-2xl p-6">
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Total drivers</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{totalDrivers}</p>
        </div>
        <div className="glass-card animate-fade-up rounded-2xl p-6" style={{ animationDelay: "0.1s" }}>
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">Available now</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{availableNow}</p>
        </div>
        <div className="glass-card animate-fade-up rounded-2xl p-6" style={{ animationDelay: "0.16s" }}>
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">On delivery</p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{onDelivery}</p>
        </div>
      </div>

      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <p className="font-display text-lg font-semibold text-white">All driver accounts</p>
          <Link href="/users" className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]">
            Back to users
          </Link>
        </div>

        <div className="hidden overflow-x-auto md:block">
          <table className="w-full min-w-[760px] text-left text-sm">
            <thead className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]">
              <tr>
                <th className="pb-3 pr-4">Driver</th>
                <th className="pb-3 pr-4">Zone</th>
                <th className="pb-3 pr-4">Active pickup</th>
                <th className="pb-3 pr-4">Availability</th>
                <th className="pb-3">Verification</th>
              </tr>
            </thead>
            <tbody>
              {driverRecords.map((driver) => (
                <tr key={driver.id} className="border-t border-[rgba(255,255,255,0.08)] text-[color:var(--text-muted)]">
                  <td className="py-3 pr-4 text-white">{driver.name}</td>
                  <td className="py-3 pr-4">{driver.serviceZone}</td>
                  <td className="py-3 pr-4">{driver.activePickup}</td>
                  <td className="py-3 pr-4">{driver.availability}</td>
                  <td className="py-3">
                    <span className="rounded-full border border-[rgba(255,255,255,0.14)] px-3 py-1 text-xs text-white">
                      {driver.verificationStatus}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="space-y-3 md:hidden">
          {driverRecords.map((driver) => (
            <div
              key={driver.id}
              className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
            >
              <p className="text-sm font-semibold text-white">{driver.name}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Zone: {driver.serviceZone}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Active pickup: {driver.activePickup}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Availability: {driver.availability}</p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">Verification: {driver.verificationStatus}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
