export interface OrderListItem {
  orderId: string;
  customerId: string;
  retailerId: string;
  status: string;
  totalCents: number;
  currency: string;
  placedAt: Date | null;
}
