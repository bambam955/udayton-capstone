export interface ResourceListMeta {
  total: number;
  limit: number;
  offset: number;
}

export interface ResourceListResponse<T> {
  data: T[];
  meta: ResourceListMeta;
}

export interface ResourceMutationResponse<T> {
  data: T;
}

export interface LoginResponse {
  accessToken: string;
  expiresAt: string;
  user: {
    id: string;
    role: string;
    email: string;
  };
}

export interface AuthMeResponse {
  principal: {
    userId: string;
    role: string;
    sessionId: string;
  };
}

export interface AdminRecord {
  admin_id: string;
  email: string | null;
  full_name: string | null;
  is_active: boolean | null;
  created_at: string | null;
  updated_at: string | null;
}

export interface AdminProfileRecord {
  admin_profile_id: string;
  admin_id: string;
  role_id: string;
  title: string | null;
  phone: string | null;
  last_login_at: string | null;
  updated_at: string | null;
}

export interface AdminRoleRecord {
  role_id: string;
  name: string | null;
  description: string | null;
  created_at: string | null;
}

export interface CustomerRecord {
  customer_id: string;
  email: string | null;
  phone: string | null;
  full_name: string | null;
  is_active: boolean | null;
  created_at: string | null;
  updated_at: string | null;
}

export interface DriverRecord {
  driver_id: string;
  email: string | null;
  phone: string | null;
  full_name: string | null;
  is_active: boolean | null;
  status: string | null;
  created_at: string | null;
  updated_at: string | null;
}

export interface OrderRecord {
  order_id: string;
  customer_id: string;
  retailer_id: string;
  address_id: string;
  external_order_id: string | null;
  status: string | null;
  placed_at: string | null;
  subtotal_cents: number | null;
  fees_cents: number | null;
  tip_cents: number | null;
  discount_cents: number | null;
  total_cents: number | null;
  currency: string | null;
  delivery_notes: string | null;
  created_at: string | null;
  updated_at: string | null;
}

export interface OrderItemRecord {
  order_item_id: string;
  order_id: string;
  product_id: string;
  external_sku: string | null;
  name_snapshot: string | null;
  unit_price_cents: number | null;
  quantity: number | null;
  substituted_for_sku: string | null;
  created_at: string | null;
}

export interface OrderStatusHistoryRecord {
  order_status_history_id: string;
  order_id: string;
  status: string | null;
  status_time: string | null;
  note: string | null;
}

export interface DeliveryAssignmentRecord {
  delivery_id: string;
  order_id: string;
  driver_id: string | null;
  status: string | null;
  pickup_location: string | null;
  assigned_at: string | null;
  picked_up_at: string | null;
  delivered_at: string | null;
}

export interface PaymentRecord {
  payment_id: string;
  order_id: string;
  customer_id: string;
  provider: string | null;
  provider_ref: string | null;
  amount_cents: number | null;
  currency: string | null;
  status: string | null;
  created_at: string | null;
}

export interface RefundRecord {
  refund_id: string;
  payment_id: string;
  order_id: string;
  amount_cents: number | null;
  reason: string | null;
  status: string | null;
  created_at: string | null;
}

export interface IntegrationHealthRecord {
  health_id: string;
  integration: string | null;
  status: string | null;
  last_checked_at: string | null;
  error: string | null;
  details_json: string | null;
}

export interface DashboardMetrics {
  totalOrders: number;
  activeDrivers: number;
  readyForPickupOrders: number;
  integrationIssues: number;
}

export interface DashboardRecentOrder {
  order_id: string;
  customer_id: string;
  retailer_id: string;
  status: string | null;
  total_cents: number | null;
  currency: string | null;
  placed_at: string | null;
  updated_at: string | null;
}

export interface DashboardPayload {
  metrics: DashboardMetrics;
  recentOrders: DashboardRecentOrder[];
  integrationHealth: IntegrationHealthRecord[];
}

export const orderStatuses = [
  "SUBMITTED",
  "PICKING",
  "READY_FOR_PICKUP",
  "OUT_FOR_DELIVERY",
  "DELIVERED",
] as const;

export type OrderStatus = (typeof orderStatuses)[number];

export interface UpdateOrderStatusResponse {
  order: OrderRecord;
  historyEntry: OrderStatusHistoryRecord;
}

export interface IssueRefundResponse {
  refund: RefundRecord;
}

export interface AdminSession {
  id: string;
  email: string;
  role: "admin";
  fullName?: string;
  title?: string;
}
