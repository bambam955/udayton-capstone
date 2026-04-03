"use server";

import { revalidatePath } from "next/cache";

import { ApiClientError, issueRefund, updateOrderStatus } from "@/lib/api/client";
import type { OrderStatus } from "@/lib/api/types";
import { requireAdminAccessToken } from "@/lib/auth/session";

export type OrderActionState = {
  error?: string;
  success?: string;
};

function revalidateOrderViews(orderId: string) {
  revalidatePath("/");
  revalidatePath("/orders");
  revalidatePath(`/orders/${orderId}`);
}

export async function updateOrderStatusAction(
  _previousState: OrderActionState,
  formData: FormData
): Promise<OrderActionState> {
  const orderId = String(formData.get("orderId") ?? "");
  const status = String(formData.get("status") ?? "") as OrderStatus;
  const note = String(formData.get("note") ?? "").trim();

  if (!orderId || !status) {
    return {
      error: "Order ID and status are required."
    };
  }

  const token = await requireAdminAccessToken();

  try {
    await updateOrderStatus(token, orderId, status, note || undefined);
    revalidateOrderViews(orderId);

    return {
      success: "Order status updated."
    };
  } catch (error) {
    if (error instanceof ApiClientError) {
      return {
        error: error.message
      };
    }

    return {
      error: "Unable to update the order status."
    };
  }
}

export async function issueRefundAction(
  _previousState: OrderActionState,
  formData: FormData
): Promise<OrderActionState> {
  const orderId = String(formData.get("orderId") ?? "");
  const amountCents = Number(formData.get("amountCents") ?? NaN);
  const reason = String(formData.get("reason") ?? "").trim();

  if (!orderId || !Number.isInteger(amountCents) || amountCents <= 0 || !reason) {
    return {
      error: "Refund amount and reason are required."
    };
  }

  const token = await requireAdminAccessToken();

  try {
    await issueRefund(token, orderId, amountCents, reason);
    revalidateOrderViews(orderId);

    return {
      success: "Refund recorded."
    };
  } catch (error) {
    if (error instanceof ApiClientError) {
      return {
        error: error.message
      };
    }

    return {
      error: "Unable to record the refund."
    };
  }
}
