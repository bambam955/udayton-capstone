// Slim order shape returned by customer "order history" endpoint.
export interface OrderListItem {
  orderId: string;
  customerId: string;
  retailerId: string;
  status: string;
  totalCents: number;
  currency: string;
  placedAt: Date | null;
}

export interface ListOrdersInput {
  limit: number;
  customerId?: string;
}
