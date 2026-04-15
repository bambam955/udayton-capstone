import Link from "next/link";

import AdminHeader from "@/components/AdminHeader";
import { listResource } from "@/lib/api/client";
import type { DeliveryAssignmentRecord, DriverRecord } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

type DriverDashboardRecord = {
  id: string;
  name: string;
  serviceZone: string;
  activePickup: string;
  availability: "Available" | "On delivery" | "Offline";
  verificationStatus: "Verified" | "Review";
};

function zoneFromPickup(pickupLocation: string | null | undefined) {
  if (!pickupLocation) {
    return "Unassigned";
  }

  const parts = pickupLocation.split(" - ");
  return parts[parts.length - 1] ?? pickupLocation;
}

export default async function DriversPage() {
  const token = await requireAdminAccessToken();
  const [drivers, deliveries] = await Promise.all([
    listResource<DriverRecord>("drivers", token, { limit: 100, offset: 0 }),
    listResource<DeliveryAssignmentRecord>("delivery-assignments", token, {
      limit: 100,
      offset: 0,
    }),
  ]);

  const driverRecords: DriverDashboardRecord[] = drivers.data.map((driver) => {
    const activeDelivery = deliveries.data.find(
      (delivery) =>
        delivery.driver_id === driver.driver_id &&
        delivery.status &&
        delivery.status !== "DELIVERED"
    );

    const availability: DriverDashboardRecord["availability"] =
      driver.status === "OFFLINE"
        ? "Offline"
        : driver.status === "BUSY" || activeDelivery
          ? "On delivery"
          : "Available";

    return {
      id: driver.driver_id,
      name: driver.full_name ?? driver.email ?? driver.driver_id,
      serviceZone: zoneFromPickup(activeDelivery?.pickup_location),
      activePickup: activeDelivery?.pickup_location ?? "None",
      availability,
      verificationStatus: driver.is_active === true ? "Verified" : "Review",
    };
  });

  const totalDrivers = driverRecords.length;
  const availableNow = driverRecords.filter((driver) => driver.availability === "Available").length;
  const onDelivery = driverRecords.filter((driver) => driver.availability === "On delivery").length;

  return (
    <div className="space-y-8">
      <AdminHeader
        title="Drivers"
        subtitle="Couriers who pick up after store fulfillment and deliver supplies."
      />
      <div className="grid gap-6 md:grid-cols-3">
        <div className="glass-card animate-fade-up rounded-2xl p-6">
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
            Total drivers
          </p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{totalDrivers}</p>
        </div>
        <div
          className="glass-card animate-fade-up rounded-2xl p-6"
          style={{ animationDelay: "0.1s" }}
        >
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
            Available now
          </p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{availableNow}</p>
        </div>
        <div
          className="glass-card animate-fade-up rounded-2xl p-6"
          style={{ animationDelay: "0.16s" }}
        >
          <p className="text-xs uppercase tracking-[0.3em] text-[color:var(--text-subtle)]">
            On delivery
          </p>
          <p className="mt-3 font-display text-3xl font-semibold text-white">{onDelivery}</p>
        </div>
      </div>

      <div className="glass-card animate-fade-up rounded-2xl p-6">
        <div className="mb-4 flex items-center justify-between">
          <p className="font-display text-lg font-semibold text-white">All driver accounts</p>
          <Link
            href="/users"
            className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]"
          >
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
                <tr
                  key={driver.id}
                  className="border-t border-[rgba(255,255,255,0.08)] text-[color:var(--text-muted)]"
                >
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
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Zone: {driver.serviceZone}
              </p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Active pickup: {driver.activePickup}
              </p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Availability: {driver.availability}
              </p>
              <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                Verification: {driver.verificationStatus}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
