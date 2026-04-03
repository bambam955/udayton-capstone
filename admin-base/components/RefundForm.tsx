"use client";

import { useActionState } from "react";

import { issueRefundAction, type OrderActionState } from "@/lib/actions/orders";

const initialState: OrderActionState = {};

type RefundFormProps = {
  orderId: string;
  maxAmountCents: number;
  currency: string | null;
};

export default function RefundForm({ orderId, maxAmountCents, currency }: RefundFormProps) {
  const [state, formAction, pending] = useActionState(issueRefundAction, initialState);

  return (
    <form action={formAction} className="space-y-4">
      <input type="hidden" name="orderId" value={orderId} />
      <div className="space-y-2">
        <label
          htmlFor="amountCents"
          className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]"
        >
          Refund amount ({currency ?? "USD"}, cents)
        </label>
        <input
          id="amountCents"
          name="amountCents"
          type="number"
          min={1}
          max={maxAmountCents}
          defaultValue={maxAmountCents}
          className="w-full rounded-xl border border-[rgba(255,255,255,0.15)] bg-[rgba(12,14,20,0.6)] px-4 py-3 text-sm text-white placeholder:text-[color:var(--text-subtle)] focus:outline-none focus:ring-2 focus:ring-[color:var(--accent)]"
        />
      </div>
      <div className="space-y-2">
        <label htmlFor="reason" className="text-xs uppercase tracking-[0.2em] text-[color:var(--text-subtle)]">
          Reason
        </label>
        <textarea
          id="reason"
          name="reason"
          rows={3}
          placeholder="Explain why the refund is being issued."
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
        className="w-full rounded-xl border border-[rgba(255,255,255,0.18)] px-5 py-3 text-sm font-semibold text-white transition hover:border-[color:var(--accent)] hover:text-[color:var(--accent)] disabled:opacity-60"
      >
        {pending ? "Recording..." : "Issue refund"}
      </button>
    </form>
  );
}
