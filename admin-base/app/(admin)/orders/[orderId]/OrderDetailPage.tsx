import Link from "next/link";
import { notFound } from "next/navigation";

import AdminHeader from "@/components/AdminHeader";
import OrderStatusForm from "@/components/OrderStatusForm";
import RefundForm from "@/components/RefundForm";
import StatusBadge from "@/components/StatusBadge";
import { ApiClientError, getResource, listResource } from "@/lib/api/client";
import type {
  DeliveryAssignmentRecord,
  OrderItemRecord,
  OrderRecord,
  OrderStatusHistoryRecord,
  PaymentRecord,
  RefundRecord,
} from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";
import { formatDateTime, formatMoney } from "@/lib/format";

type OrderDetailPageProps = {
  params: Promise<{
    orderId: string;
  }>;
};

function sortByNewest<T extends { created_at?: string | null; status_time?: string | null }>(
  rows: T[]
) {
  return [...rows].sort((left, right) => {
    const leftTime = new Date(left.status_time ?? left.created_at ?? 0).getTime();
    const rightTime = new Date(right.status_time ?? right.created_at ?? 0).getTime();
    return rightTime - leftTime;
  });
}

export default async function OrderDetailPage({ params }: OrderDetailPageProps) {
  const token = await requireAdminAccessToken();
  const { orderId } = await params;

  let order: OrderRecord;

  try {
    const orderResponse = await getResource<OrderRecord>("orders", orderId, token);
    order = orderResponse.data;
  } catch (error) {
    if (error instanceof ApiClientError && error.status === 404) {
      notFound();
    }

    throw error;
  }

  const [itemsResponse, historyResponse, deliveriesResponse, paymentsResponse, refundsResponse] =
    await Promise.all([
      listResource<OrderItemRecord>("order-items", token, {
        order_id: orderId,
        limit: 50,
        offset: 0,
      }),
      listResource<OrderStatusHistoryRecord>("order-status-history", token, {
        order_id: orderId,
        limit: 50,
        offset: 0,
      }),
      listResource<DeliveryAssignmentRecord>("delivery-assignments", token, {
        order_id: orderId,
        limit: 10,
        offset: 0,
      }),
      listResource<PaymentRecord>("payments", token, {
        order_id: orderId,
        limit: 10,
        offset: 0,
      }),
      listResource<RefundRecord>("refunds", token, {
        order_id: orderId,
        limit: 20,
        offset: 0,
      }),
    ]);

  const history = sortByNewest(historyResponse.data);
  const refunds = sortByNewest(refundsResponse.data);
  const latestPayment = paymentsResponse.data[0];
  const refundedAmount = refunds.reduce(
    (total, refund) => total + Number(refund.amount_cents ?? 0),
    0
  );
  const refundableAmount = Math.max(Number(latestPayment?.amount_cents ?? 0) - refundedAmount, 0);

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between gap-4">
        <AdminHeader
          title={`Order ${order.external_order_id ?? order.order_id}`}
          subtitle="Inspect the full order record, adjust status, and issue refunds."
        />
        <Link
          href="/orders"
          className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--accent)]"
        >
          Back to orders
        </Link>
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.4fr,1fr]">
        <div className="space-y-6">
          <div className="glass-card animate-fade-up rounded-2xl p-6">
            <div className="mb-5 flex flex-wrap items-center justify-between gap-4">
              <div>
                <p className="font-display text-lg font-semibold text-white">Order summary</p>
                <p className="mt-1 text-sm text-[color:var(--text-muted)]">
                  Canonical record returned from the backend.
                </p>
              </div>
              <StatusBadge value={order.status} />
            </div>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Customer
                </p>
                <p className="mt-2 text-sm text-white">{order.customer_id}</p>
              </div>
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Retailer
                </p>
                <p className="mt-2 text-sm text-white">{order.retailer_id}</p>
              </div>
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Placed
                </p>
                <p className="mt-2 text-sm text-white">{formatDateTime(order.placed_at)}</p>
              </div>
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Total
                </p>
                <p className="mt-2 text-sm text-white">
                  {formatMoney(order.total_cents, order.currency ?? "USD")}
                </p>
              </div>
            </div>
            <div className="mt-5 grid gap-4 md:grid-cols-4">
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Subtotal
                </p>
                <p className="mt-2 text-sm text-white">
                  {formatMoney(order.subtotal_cents, order.currency ?? "USD")}
                </p>
              </div>
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Fees
                </p>
                <p className="mt-2 text-sm text-white">
                  {formatMoney(order.fees_cents, order.currency ?? "USD")}
                </p>
              </div>
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Tip
                </p>
                <p className="mt-2 text-sm text-white">
                  {formatMoney(order.tip_cents, order.currency ?? "USD")}
                </p>
              </div>
              <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] p-4">
                <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                  Discount
                </p>
                <p className="mt-2 text-sm text-white">
                  {formatMoney(order.discount_cents, order.currency ?? "USD")}
                </p>
              </div>
            </div>
            <div className="mt-5 rounded-2xl border border-[rgba(255,255,255,0.08)] p-4">
              <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                Delivery notes
              </p>
              <p className="mt-2 text-sm text-white">
                {order.delivery_notes || "No delivery notes recorded."}
              </p>
            </div>
          </div>

          <div className="glass-card animate-fade-up rounded-2xl p-6">
            <div className="mb-4">
              <p className="font-display text-lg font-semibold text-white">Status history</p>
              <p className="mt-1 text-sm text-[color:var(--text-muted)]">
                Order timeline entries from the backend history resource.
              </p>
            </div>
            <div className="space-y-3">
              {history.length > 0 ? (
                history.map((entry) => (
                  <div
                    key={entry.order_status_history_id}
                    className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
                  >
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <StatusBadge value={entry.status} />
                      <p className="text-xs text-[color:var(--text-muted)]">
                        {formatDateTime(entry.status_time)}
                      </p>
                    </div>
                    <p className="mt-3 text-sm text-white">{entry.note || "No note attached."}</p>
                  </div>
                ))
              ) : (
                <p className="text-sm text-[color:var(--text-muted)]">
                  No status history rows are seeded for this order.
                </p>
              )}
            </div>
          </div>

          <div className="grid gap-6 lg:grid-cols-2">
            <div className="glass-card animate-fade-up rounded-2xl p-6">
              <div className="mb-4">
                <p className="font-display text-lg font-semibold text-white">Order items</p>
                <p className="mt-1 text-sm text-[color:var(--text-muted)]">
                  Current item rows tied to this order.
                </p>
              </div>
              <div className="space-y-3">
                {itemsResponse.data.length > 0 ? (
                  itemsResponse.data.map((item) => (
                    <div
                      key={item.order_item_id}
                      className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
                    >
                      <p className="text-sm font-semibold text-white">
                        {item.name_snapshot || item.product_id}
                      </p>
                      <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                        Quantity: {item.quantity ?? "—"}
                      </p>
                      <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                        Unit price: {formatMoney(item.unit_price_cents, order.currency ?? "USD")}
                      </p>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-[color:var(--text-muted)]">
                    No item rows are currently seeded for this order.
                  </p>
                )}
              </div>
            </div>

            <div className="glass-card animate-fade-up rounded-2xl p-6">
              <div className="mb-4">
                <p className="font-display text-lg font-semibold text-white">Delivery assignment</p>
                <p className="mt-1 text-sm text-[color:var(--text-muted)]">
                  Courier-side assignment state for the order.
                </p>
              </div>
              <div className="space-y-3">
                {deliveriesResponse.data.length > 0 ? (
                  deliveriesResponse.data.map((delivery) => (
                    <div
                      key={delivery.delivery_id}
                      className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
                    >
                      <div className="flex flex-wrap items-center justify-between gap-3">
                        <p className="text-sm font-semibold text-white">{delivery.delivery_id}</p>
                        <StatusBadge value={delivery.status} />
                      </div>
                      <p className="mt-2 text-xs text-[color:var(--text-muted)]">
                        Driver: {delivery.driver_id ?? "Unassigned"}
                      </p>
                      <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                        Pickup: {delivery.pickup_location ?? "No pickup location"}
                      </p>
                      <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                        Assigned: {formatDateTime(delivery.assigned_at)}
                      </p>
                    </div>
                  ))
                ) : (
                  <p className="text-sm text-[color:var(--text-muted)]">
                    No delivery assignment exists for this order.
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>

        <div className="space-y-6">
          <div className="glass-card animate-fade-up rounded-2xl p-6">
            <div className="mb-4">
              <p className="font-display text-lg font-semibold text-white">Update order status</p>
              <p className="mt-1 text-sm text-[color:var(--text-muted)]">
                Writes through the admin status action endpoint.
              </p>
            </div>
            <OrderStatusForm orderId={order.order_id} currentStatus={order.status} />
          </div>

          <div className="glass-card animate-fade-up rounded-2xl p-6">
            <div className="mb-4">
              <p className="font-display text-lg font-semibold text-white">Payment and refunds</p>
              <p className="mt-1 text-sm text-[color:var(--text-muted)]">
                Latest payment, refunded balance, and manual refund action.
              </p>
            </div>
            {latestPayment ? (
              <div className="space-y-4">
                <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4">
                  <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                    Latest payment
                  </p>
                  <p className="mt-2 text-sm text-white">{latestPayment.payment_id}</p>
                  <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                    {formatMoney(latestPayment.amount_cents, latestPayment.currency ?? "USD")} •{" "}
                    {latestPayment.status ?? "Unknown"}
                  </p>
                  <p className="mt-1 text-xs text-[color:var(--text-muted)]">
                    Created {formatDateTime(latestPayment.created_at)}
                  </p>
                </div>
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] p-4">
                    <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                      Refunded so far
                    </p>
                    <p className="mt-2 text-sm text-white">
                      {formatMoney(refundedAmount, latestPayment.currency ?? "USD")}
                    </p>
                  </div>
                  <div className="rounded-2xl border border-[rgba(255,255,255,0.08)] p-4">
                    <p className="text-xs uppercase tracking-[0.18em] text-[color:var(--text-subtle)]">
                      Remaining refundable
                    </p>
                    <p className="mt-2 text-sm text-white">
                      {formatMoney(refundableAmount, latestPayment.currency ?? "USD")}
                    </p>
                  </div>
                </div>
                {refundableAmount > 0 ? (
                  <RefundForm
                    orderId={order.order_id}
                    maxAmountCents={refundableAmount}
                    currency={latestPayment.currency}
                  />
                ) : (
                  <p className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] px-4 py-3 text-sm text-[color:var(--text-muted)]">
                    No refundable balance remains on this payment.
                  </p>
                )}
                <div className="space-y-3">
                  {refunds.length > 0 ? (
                    refunds.map((refund) => (
                      <div
                        key={refund.refund_id}
                        className="rounded-2xl border border-[rgba(255,255,255,0.08)] bg-[rgba(255,255,255,0.03)] p-4"
                      >
                        <div className="flex flex-wrap items-center justify-between gap-3">
                          <p className="text-sm font-semibold text-white">{refund.refund_id}</p>
                          <StatusBadge value={refund.status} />
                        </div>
                        <p className="mt-2 text-xs text-[color:var(--text-muted)]">
                          {formatMoney(refund.amount_cents, latestPayment.currency ?? "USD")} •{" "}
                          {formatDateTime(refund.created_at)}
                        </p>
                        <p className="mt-2 text-sm text-white">
                          {refund.reason || "No reason recorded."}
                        </p>
                      </div>
                    ))
                  ) : (
                    <p className="text-sm text-[color:var(--text-muted)]">
                      No refunds recorded for this order yet.
                    </p>
                  )}
                </div>
              </div>
            ) : (
              <p className="text-sm text-[color:var(--text-muted)]">
                No payment record exists for this order yet.
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
