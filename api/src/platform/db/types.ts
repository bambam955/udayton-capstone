import type { ColumnType } from 'kysely';

export type DBTimestamp = ColumnType<Date, Date | string, Date | string>;

export interface CustomersTable {
  customer_id: string;
  email: string | null;
  full_name: string | null;
  password_hash: string | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface DriversTable {
  driver_id: string;
  email: string | null;
  full_name: string | null;
  password_hash: string | null;
  is_active: boolean | null;
  status: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface AdminsTable {
  admin_id: string;
  email: string | null;
  full_name: string | null;
  password_hash: string | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface CustomerSessionsTable {
  session_id: string;
  customer_id: string;
  access_token: string | null;
  expires_at: DBTimestamp | null;
  device_info: string | null;
  created_at: DBTimestamp | null;
}

export interface DriverSessionsTable {
  session_id: string;
  driver_id: string;
  access_token: string | null;
  expires_at: DBTimestamp | null;
  device_info: string | null;
  created_at: DBTimestamp | null;
}

export interface AdminSessionsTable {
  session_id: string;
  admin_id: string;
  access_token: string | null;
  expires_at: DBTimestamp | null;
  created_at: DBTimestamp | null;
}

export interface OrdersTable {
  order_id: string;
  customer_id: string;
  retailer_id: string;
  address_id: string;
  status: string | null;
  placed_at: DBTimestamp | null;
  subtotal_cents: number | null;
  fees_cents: number | null;
  tip_cents: number | null;
  discount_cents: number | null;
  total_cents: number | null;
  currency: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface OrderStatusHistoryTable {
  order_status_history_id: string;
  order_id: string;
  status: string | null;
  status_time: DBTimestamp | null;
  note: string | null;
}

export interface Database {
  customers: CustomersTable;
  drivers: DriversTable;
  admins: AdminsTable;
  customer_sessions: CustomerSessionsTable;
  driver_sessions: DriverSessionsTable;
  admin_sessions: AdminSessionsTable;
  orders: OrdersTable;
  order_status_history: OrderStatusHistoryTable;
}
