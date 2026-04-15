import type { AuthPrincipal } from '../../app/types.js';
import type { OrderStatus } from '../orders/statuses.js';

export interface DashboardMetricSummary {
  totalOrders: number;
  activeDrivers: number;
  readyForPickupOrders: number;
  integrationIssues: number;
}

export interface DashboardOrderSummary {
  order_id: string;
  customer_id: string;
  retailer_id: string;
  status: string | null;
  total_cents: number | null;
  currency: string | null;
  placed_at: Date | null;
  updated_at: Date | null;
}

export interface IntegrationHealthSummary {
  health_id: string;
  integration: string | null;
  status: string | null;
  last_checked_at: Date | null;
  error: string | null;
  details_json: string | null;
}

export interface DashboardResult {
  metrics: DashboardMetricSummary;
  recentOrders: DashboardOrderSummary[];
  integrationHealth: IntegrationHealthSummary[];
}

export interface UpdateOrderStatusInput {
  status: OrderStatus;
  note?: string;
}

export interface UpdateOrderStatusResult {
  order: Record<string, unknown>;
  historyEntry: Record<string, unknown>;
}

export interface IssueRefundInput {
  amountCents: number;
  reason: string;
}

export interface IssueRefundResult {
  refund: Record<string, unknown>;
}

export interface AdminOperationsRepository {
  getDashboard(): Promise<DashboardResult>;
  findOrderById(orderId: string): Promise<Record<string, unknown> | null>;
  updateOrderStatus(
    principal: AuthPrincipal,
    orderId: string,
    input: UpdateOrderStatusInput
  ): Promise<UpdateOrderStatusResult>;
  findLatestPaymentForOrder(orderId: string): Promise<Record<string, unknown> | null>;
  getRefundedAmount(paymentId: string): Promise<number>;
  createRefund(
    principal: AuthPrincipal,
    orderId: string,
    paymentId: string,
    input: IssueRefundInput
  ): Promise<IssueRefundResult>;
}
