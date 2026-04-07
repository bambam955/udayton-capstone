import type { ColumnType } from 'kysely';

// Timestamp columns accept strings on writes and normalize to Date on reads.
export type DBTimestamp = ColumnType<Date, Date | string, Date | string>;

// DATE columns are handled as plain ISO strings for API-friendly transport.
export type DBDate = ColumnType<string, Date | string, Date | string>;

// PostgreSQL DECIMAL values are commonly returned as strings by `pg`.
export type DBNumeric = ColumnType<string, number | string, number | string>;

export interface CustomersTable {
  customer_id: string;
  email: string | null;
  phone: string | null;
  full_name: string | null;
  password_hash: string | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface AddressesTable {
  address_id: string;
  customer_id: string;
  label: string | null;
  line1: string | null;
  line2: string | null;
  city: string | null;
  state: string | null;
  postal_code: string | null;
  country: string | null;
  instructions: string | null;
  is_default: boolean | null;
  created_at: DBTimestamp | null;
}

export interface CustomerDevicesTable {
  device_id: string;
  customer_id: string;
  platform: string | null;
  push_token: string | null;
  app_version: string | null;
  last_seen_at: DBTimestamp | null;
  created_at: DBTimestamp | null;
}

export interface CustomerSessionsTable {
  session_id: string;
  customer_id: string;
  access_token: string | null;
  expires_at: DBTimestamp | null;
  device_info: string | null;
  created_at: DBTimestamp | null;
}

export interface RetailersTable {
  retailer_id: string;
  name: string | null;
  website: string | null;
  is_enabled: boolean | null;
  created_at: DBTimestamp | null;
}

export interface RetailerAccountsTable {
  retailer_account_id: string;
  customer_id: string;
  retailer_id: string;
  is_connected: boolean | null;
  access_token: string | null;
  refresh_token: string | null;
  token_expires_at: DBTimestamp | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface RetailerLocationsTable {
  retailer_location_id: string;
  retailer_id: string;
  external_store_id: string | null;
  name: string | null;
  address_line1: string | null;
  address_line2: string | null;
  city: string | null;
  state: string | null;
  postal_code: string | null;
  country: string | null;
  lat: DBNumeric | null;
  lng: DBNumeric | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

// The product/catalog tables below back the new mobile browse and checkout
// flows added on this branch.
export interface ProductCategoriesTable {
  category_id: string;
  retailer_id: string;
  name: string | null;
  external_category_id: string | null;
  updated_at: DBTimestamp | null;
}

export interface ProductsTable {
  product_id: string;
  retailer_id: string;
  category_id: string;
  external_sku: string | null;
  name: string | null;
  description: string | null;
  image_url: string | null;
  unit_price_cents: number | null;
  currency: string | null;
  is_available: boolean | null;
  updated_at: DBTimestamp | null;
}

export interface FavoritesTable {
  favorite_id: string;
  customer_id: string;
  retailer_id: string;
  external_sku: string | null;
  created_at: DBTimestamp | null;
}

export interface CartsTable {
  cart_id: string;
  customer_id: string;
  retailer_id: string;
  retailer_location_id: string | null;
  checked_out_order_id: string | null;
  status: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface CartItemsTable {
  cart_item_id: string;
  cart_id: string;
  product_id: string;
  external_sku: string | null;
  name_snapshot: string | null;
  unit_price_cents: number | null;
  quantity: number | null;
  substitution_allowed: boolean | null;
  notes: string | null;
  created_at: DBTimestamp | null;
}

export interface OrdersTable {
  order_id: string;
  customer_id: string;
  retailer_id: string;
  retailer_location_id: string | null;
  address_id: string;
  external_order_id: string | null;
  status: string | null;
  placed_at: DBTimestamp | null;
  subtotal_cents: number | null;
  fees_cents: number | null;
  tip_cents: number | null;
  discount_cents: number | null;
  total_cents: number | null;
  currency: string | null;
  delivery_notes: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

// Delivery and earnings tables below power the driver bootstrap and delivery
// lifecycle endpoints.
export interface OrderItemsTable {
  order_item_id: string;
  order_id: string;
  product_id: string;
  external_sku: string | null;
  name_snapshot: string | null;
  unit_price_cents: number | null;
  quantity: number | null;
  substituted_for_sku: string | null;
  created_at: DBTimestamp | null;
}

export interface OrderStatusHistoryTable {
  order_status_history_id: string;
  order_id: string;
  status: string | null;
  status_time: DBTimestamp | null;
  note: string | null;
}

export interface DeliveryAssignmentsTable {
  delivery_id: string;
  order_id: string;
  driver_id: string | null;
  status: string | null;
  pickup_location: string | null;
  assigned_at: DBTimestamp | null;
  picked_up_at: DBTimestamp | null;
  delivered_at: DBTimestamp | null;
}

export interface DeliveryProofTable {
  proof_id: string;
  delivery_id: string;
  proof_type: string | null;
  proof_url: string | null;
  metadata_json: string | null;
  created_at: DBTimestamp | null;
}

export interface PaymentsTable {
  payment_id: string;
  order_id: string;
  customer_id: string;
  provider: string | null;
  provider_ref: string | null;
  amount_cents: number | null;
  currency: string | null;
  status: string | null;
  created_at: DBTimestamp | null;
}

export interface RefundsTable {
  refund_id: string;
  payment_id: string;
  order_id: string;
  amount_cents: number | null;
  reason: string | null;
  status: string | null;
  created_at: DBTimestamp | null;
}

export interface NotificationsTable {
  notification_id: string;
  customer_id: string;
  type: string | null;
  title: string | null;
  body: string | null;
  deep_link: string | null;
  is_read: boolean | null;
  created_at: DBTimestamp | null;
  read_at: DBTimestamp | null;
}

export interface SupportTicketsTable {
  ticket_id: string;
  customer_id: string;
  order_id: string | null;
  issue_type: string | null;
  message: string | null;
  status: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface SupportAttachmentsTable {
  attachment_id: string;
  ticket_id: string;
  file_type: string | null;
  file_url: string | null;
  created_at: DBTimestamp | null;
}

export interface RatingsTable {
  rating_id: string;
  order_id: string;
  customer_id: string;
  rating_value: number | null;
  comment: string | null;
  created_at: DBTimestamp | null;
}

export interface DriversTable {
  driver_id: string;
  email: string | null;
  phone: string | null;
  full_name: string | null;
  password_hash: string | null;
  is_active: boolean | null;
  status: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface DriverDevicesTable {
  device_id: string;
  driver_id: string;
  platform: string | null;
  push_token: string | null;
  app_version: string | null;
  last_seen_at: DBTimestamp | null;
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

export interface DriverProfilesTable {
  driver_profile_id: string;
  driver_id: string;
  date_of_birth: DBDate | null;
  license_number: string | null;
  license_state: string | null;
  license_expires_at: DBTimestamp | null;
  background_check_status: string | null;
  background_check_completed_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface DriverVehiclesTable {
  vehicle_id: string;
  driver_id: string;
  make: string | null;
  model: string | null;
  year: number | null;
  color: string | null;
  plate_number: string | null;
  plate_state: string | null;
  is_primary: boolean | null;
  created_at: DBTimestamp | null;
}

export interface DriverDocumentsTable {
  document_id: string;
  driver_id: string;
  doc_type: string | null;
  file_url: string | null;
  status: string | null;
  reviewer_note: string | null;
  expires_at: DBTimestamp | null;
  created_at: DBTimestamp | null;
}

export interface DriverServiceAreasTable {
  service_area_id: string;
  driver_id: string;
  label: string | null;
  city: string | null;
  state: string | null;
  postal_code: string | null;
  geofence_json: string | null;
  is_primary: boolean | null;
  created_at: DBTimestamp | null;
}

export interface DriverLocationsTable {
  location_id: string;
  driver_id: string;
  lat: DBNumeric | null;
  lng: DBNumeric | null;
  accuracy_m: DBNumeric | null;
  heading: DBNumeric | null;
  speed_mps: DBNumeric | null;
  recorded_at: DBTimestamp | null;
  source: string | null;
}

export interface DriverNotificationsTable {
  notification_id: string;
  driver_id: string;
  type: string | null;
  title: string | null;
  body: string | null;
  deep_link: string | null;
  is_read: boolean | null;
  created_at: DBTimestamp | null;
  read_at: DBTimestamp | null;
}

export interface DriverEarningsTable {
  earning_id: string;
  driver_id: string;
  delivery_id: string;
  base_pay_cents: number | null;
  bonus_cents: number | null;
  tip_cents: number | null;
  adjustments_cents: number | null;
  total_pay_cents: number | null;
  currency: string | null;
  status: string | null;
  created_at: DBTimestamp | null;
}

export interface DriverPayoutsTable {
  payout_id: string;
  driver_id: string;
  amount_cents: number | null;
  currency: string | null;
  status: string | null;
  provider: string | null;
  provider_ref: string | null;
  created_at: DBTimestamp | null;
}

export interface DriverSupportTicketsTable {
  ticket_id: string;
  driver_id: string;
  delivery_id: string | null;
  order_id: string | null;
  issue_type: string | null;
  message: string | null;
  status: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface DriverTasksTable {
  task_id: string;
  delivery_id: string;
  driver_id: string;
  task_type: string | null;
  status: string | null;
  due_at: DBTimestamp | null;
  completed_at: DBTimestamp | null;
  instructions: string | null;
}

export interface DeliveryStatusEventsTable {
  event_id: string;
  delivery_id: string;
  driver_id: string | null;
  status: string | null;
  event_time: DBTimestamp | null;
  note: string | null;
  lat: DBNumeric | null;
  lng: DBNumeric | null;
}

export interface DeliveryOffersTable {
  offer_id: string;
  order_id: string;
  delivery_id: string;
  status: string | null;
  offered_at: DBTimestamp | null;
  responded_at: DBTimestamp | null;
  expires_in_sec: number | null;
  decline_reason: string | null;
}

export interface FeeRulesTable {
  fee_rule_id: string;
  name: string | null;
  applies_to: string | null;
  rule_json: string | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface ServiceRegionsTable {
  region_id: string;
  name: string | null;
  state: string | null;
  geofence_json: string | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
}

export interface FeatureFlagsTable {
  flag_id: string;
  key: string | null;
  description: string | null;
  enabled: boolean | null;
  rules_json: string | null;
  expires_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface NotificationTemplatesTable {
  template_id: string;
  key: string | null;
  channel: string | null;
  title_template: string | null;
  body_template: string | null;
  is_active: boolean | null;
  updated_at: DBTimestamp | null;
}

export interface SlaPoliciesTable {
  sla_policy_id: string;
  name: string | null;
  description: string | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
}

export interface OutboundMessagesTable {
  message_id: string;
  actor_type: string | null;
  actor_id: string | null;
  target_type: string | null;
  target_id: string | null;
  channel: string | null;
  template_id: string | null;
  title: string | null;
  body: string | null;
  deep_link: string | null;
  status: string | null;
  created_at: DBTimestamp | null;
  sent_at: DBTimestamp | null;
}

export interface MessageDeliveryLogsTable {
  message_log_id: string;
  message_id: string;
  provider: string | null;
  provider_ref: string | null;
  status: string | null;
  error: string | null;
  created_at: DBTimestamp | null;
}

export interface AdminRolesTable {
  role_id: string;
  name: string | null;
  description: string | null;
  created_at: DBTimestamp | null;
}

export interface AdminPermissionsTable {
  permission_id: string;
  key: string | null;
  description: string | null;
  created_at: DBTimestamp | null;
}

export interface AdminRolePermissionsTable {
  role_permission_id: string;
  role_id: string;
  permission_id: string;
  created_at: DBTimestamp | null;
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

export interface AdminProfilesTable {
  admin_profile_id: string;
  admin_id: string;
  role_id: string;
  title: string | null;
  phone: string | null;
  last_login_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface AdminSessionsTable {
  session_id: string;
  admin_id: string;
  access_token: string | null;
  expires_at: DBTimestamp | null;
  created_at: DBTimestamp | null;
}

export interface QueuesTable {
  queue_id: string;
  name: string | null;
  description: string | null;
  is_active: boolean | null;
  created_at: DBTimestamp | null;
}

export interface QueueItemsTable {
  queue_item_id: string;
  queue_id: string;
  source_type: string | null;
  source_id: string | null;
  priority: string | null;
  status: string | null;
  sla_policy_id: string | null;
  due_at: DBTimestamp | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface CasesTable {
  case_id: string;
  case_type: string | null;
  status: string | null;
  priority: string | null;
  queue_id: string | null;
  customer_id: string | null;
  driver_id: string | null;
  order_id: string | null;
  delivery_id: string | null;
  refund_id: string | null;
  ticket_id: string | null;
  opened_by: string | null;
  assigned_to: string | null;
  summary: string | null;
  details: string | null;
  created_at: DBTimestamp | null;
  updated_at: DBTimestamp | null;
}

export interface CaseNotesTable {
  note_id: string;
  case_id: string;
  admin_id: string | null;
  note: string | null;
  created_at: DBTimestamp | null;
}

export interface CaseAttachmentsTable {
  attachment_id: string;
  case_id: string;
  file_type: string | null;
  file_url: string | null;
  created_at: DBTimestamp | null;
}

export interface WebhooksTable {
  webhook_id: string;
  provider: string | null;
  event_type: string | null;
  status: string | null;
  payload_json: string | null;
  created_at: DBTimestamp | null;
  received_at: DBTimestamp | null;
}

export interface SystemEventsTable {
  system_event_id: string;
  event_type: string | null;
  source: string | null;
  level: string | null;
  message: string | null;
  meta_json: string | null;
  occurred_at: DBTimestamp | null;
  created_at: DBTimestamp | null;
}

export interface AuditLogsTable {
  audit_id: string;
  actor_type: string | null;
  actor_id: string | null;
  action: string | null;
  entity_type: string | null;
  entity_id: string | null;
  details_json: string | null;
  created_at: DBTimestamp | null;
}

export interface IntegrationHealthTable {
  health_id: string;
  integration: string | null;
  status: string | null;
  last_checked_at: DBTimestamp | null;
  error: string | null;
  details_json: string | null;
}

export interface Database {
  customers: CustomersTable;
  addresses: AddressesTable;
  customer_devices: CustomerDevicesTable;
  customer_sessions: CustomerSessionsTable;
  retailers: RetailersTable;
  retailer_accounts: RetailerAccountsTable;
  retailer_locations: RetailerLocationsTable;
  product_categories: ProductCategoriesTable;
  products: ProductsTable;
  favorites: FavoritesTable;
  carts: CartsTable;
  cart_items: CartItemsTable;
  orders: OrdersTable;
  order_items: OrderItemsTable;
  order_status_history: OrderStatusHistoryTable;
  delivery_assignments: DeliveryAssignmentsTable;
  delivery_proof: DeliveryProofTable;
  payments: PaymentsTable;
  refunds: RefundsTable;
  notifications: NotificationsTable;
  support_tickets: SupportTicketsTable;
  support_attachments: SupportAttachmentsTable;
  ratings: RatingsTable;
  drivers: DriversTable;
  driver_devices: DriverDevicesTable;
  driver_sessions: DriverSessionsTable;
  driver_profiles: DriverProfilesTable;
  driver_vehicles: DriverVehiclesTable;
  driver_documents: DriverDocumentsTable;
  driver_service_areas: DriverServiceAreasTable;
  driver_locations: DriverLocationsTable;
  driver_notifications: DriverNotificationsTable;
  driver_earnings: DriverEarningsTable;
  driver_payouts: DriverPayoutsTable;
  driver_support_tickets: DriverSupportTicketsTable;
  driver_tasks: DriverTasksTable;
  delivery_status_events: DeliveryStatusEventsTable;
  delivery_offers: DeliveryOffersTable;
  fee_rules: FeeRulesTable;
  service_regions: ServiceRegionsTable;
  feature_flags: FeatureFlagsTable;
  notification_templates: NotificationTemplatesTable;
  sla_policies: SlaPoliciesTable;
  outbound_messages: OutboundMessagesTable;
  message_delivery_logs: MessageDeliveryLogsTable;
  admin_roles: AdminRolesTable;
  admin_permissions: AdminPermissionsTable;
  admin_role_permissions: AdminRolePermissionsTable;
  admins: AdminsTable;
  admin_profiles: AdminProfilesTable;
  admin_sessions: AdminSessionsTable;
  queues: QueuesTable;
  queue_items: QueueItemsTable;
  cases: CasesTable;
  case_notes: CaseNotesTable;
  case_attachments: CaseAttachmentsTable;
  webhooks: WebhooksTable;
  system_events: SystemEventsTable;
  audit_logs: AuditLogsTable;
  integration_health: IntegrationHealthTable;
}
