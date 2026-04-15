"use client";

import { useActionState } from "react";

import { updateOrderStatusAction, type OrderActionState } from "@/lib/actions/orders";
import { orderStatuses } from "@/lib/api/types";

const initialState: OrderActionState = {};

type OrderStatusFormProps = {
  orderId: string;
  currentStatus: string | null;
};

export default function OrderStatusForm({ orderId, currentStatus }: OrderStatusFormProps) {
  const [state, formAction, pending] = useActionState(updateOrderStatusAction, initialState);

  return (
    <form action={formAction} className="space-y-4">
      <input type="hidden" name="orderId" value={orderId} />
      <div className="space-y-2">
        <label
          htmlFor="status"
          className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]"
        >
          Order status
        </label>
        <select
          id="status"
          name="status"
          defaultValue={currentStatus ?? orderStatuses[0]}
          className="w-full rounded-xl border border-[rgba(255,255,255,0.15)] bg-[rgba(12,14,20,0.6)] px-4 py-3 text-sm text-white focus:outline-none focus:ring-2 focus:ring-[color:var(--accent)]"
        >
          {orderStatuses.map((status) => (
            <option key={status} value={status}>
              {status.replaceAll("_", " ")}
            </option>
          ))}
        </select>
      </div>
      <div className="space-y-2">
        <label
          htmlFor="note"
          className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]"
        >
          Note
        </label>
        <textarea
          id="note"
          name="note"
          rows={3}
          placeholder="Optional internal note for the timeline."
          className="w-full rounded-xl border border-[rgba(255,255,255,0.15)] bg-[rgba(12,14,20,0.6)] px-4 py-3 text-sm text-white placeholder:text-[color:var(--text-subtle)] focus:outline-none focus:ring-2 focus:ring-[color:var(--accent)]"
        />
      </div>
      {state.error ? (
        <p className="rounded-2xl border border-rose-400/20 bg-rose-500/10 px-4 py-3 text-sm text-rose-100">
          {state.error}
        </p>
      ) : null}
      {state.success ? (
        <p className="rounded-2xl border border-emerald-400/20 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-100">
          {state.success}
        </p>
      ) : null}
      <button
        type="submit"
        disabled={pending}
        className="w-full rounded-xl bg-[color:var(--accent)] px-5 py-3 text-sm font-semibold text-white transition hover:brightness-110 disabled:opacity-60"
      >
        {pending ? "Updating..." : "Update status"}
      </button>
    </form>
  );
}
