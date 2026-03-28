-- ============================================================
-- BizRush Unified Schema (Customer + Driver + Admin)
-- PostgreSQL DDL
-- ============================================================
-- Uses UUID PKs with pgcrypto gen_random_uuid()
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- CUSTOMER CORE
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
  customer_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           TEXT UNIQUE,
  phone           TEXT,
  full_name       TEXT,
  password_hash   TEXT,
  is_active       BOOLEAN,
  created_at      TIMESTAMPTZ,
  updated_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS addresses (
  address_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL,
  label           TEXT,
  line1           TEXT,
  line2           TEXT,
  city            TEXT,
  state           TEXT,
  postal_code     TEXT,
  country         TEXT,
  instructions    TEXT,
  is_default      BOOLEAN,
  created_at      TIMESTAMPTZ,
  CONSTRAINT fk_addresses_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_devices (
  device_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL,
  platform        TEXT,
  push_token      TEXT UNIQUE,
  app_version     TEXT,
  last_seen_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ,
  CONSTRAINT fk_customer_devices_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS customer_sessions (
  session_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL,
  access_token    TEXT UNIQUE,
  expires_at      TIMESTAMPTZ,
  device_info     TEXT,
  created_at      TIMESTAMPTZ,
  CONSTRAINT fk_customer_sessions_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE
);

-- ============================================================
-- RETAIL + CATALOG
-- ============================================================
CREATE TABLE IF NOT EXISTS retailers (
  retailer_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT UNIQUE,
  website         TEXT,
  is_enabled      BOOLEAN,
  created_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS retailer_accounts (
  retailer_account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id         UUID NOT NULL,
  retailer_id         UUID NOT NULL,
  is_connected        BOOLEAN,
  access_token        TEXT,
  refresh_token       TEXT,
  token_expires_at    TIMESTAMPTZ,
  created_at          TIMESTAMPTZ,
  updated_at          TIMESTAMPTZ,
  CONSTRAINT fk_retailer_accounts_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_retailer_accounts_retailer
    FOREIGN KEY (retailer_id) REFERENCES retailers(retailer_id)
    ON DELETE CASCADE,
  CONSTRAINT uq_retailer_accounts_customer_retailer
    UNIQUE (customer_id, retailer_id)
);

CREATE TABLE IF NOT EXISTS product_categories (
  category_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id          UUID NOT NULL,
  name                 TEXT,
  external_category_id TEXT,
  updated_at           TIMESTAMPTZ,
  CONSTRAINT fk_product_categories_retailer
    FOREIGN KEY (retailer_id) REFERENCES retailers(retailer_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS products (
  product_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id       UUID NOT NULL,
  category_id       UUID NOT NULL,
  external_sku      TEXT,
  name              TEXT,
  description       TEXT,
  image_url         TEXT,
  unit_price_cents  INT,
  currency          TEXT,
  is_available      BOOLEAN,
  updated_at        TIMESTAMPTZ,
  CONSTRAINT fk_products_retailer
    FOREIGN KEY (retailer_id) REFERENCES retailers(retailer_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS favorites (
  favorite_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL,
  retailer_id     UUID NOT NULL,
  external_sku    TEXT,
  created_at      TIMESTAMPTZ,
  CONSTRAINT fk_favorites_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_favorites_retailer
    FOREIGN KEY (retailer_id) REFERENCES retailers(retailer_id)
    ON DELETE CASCADE
);

-- ============================================================
-- CART + ORDERING
-- ============================================================
CREATE TABLE IF NOT EXISTS carts (
  cart_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id   UUID NOT NULL,
  retailer_id   UUID NOT NULL,
  status        TEXT,
  created_at    TIMESTAMPTZ,
  updated_at    TIMESTAMPTZ,
  CONSTRAINT fk_carts_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_carts_retailer
    FOREIGN KEY (retailer_id) REFERENCES retailers(retailer_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart_items (
  cart_item_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id                UUID NOT NULL,
  product_id             UUID NOT NULL,
  external_sku           TEXT,
  name_snapshot          TEXT,
  unit_price_cents       INT,
  quantity               INT,
  substitution_allowed   BOOLEAN,
  notes                  TEXT,
  created_at             TIMESTAMPTZ,
  CONSTRAINT fk_cart_items_cart
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS orders (
  order_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id        UUID NOT NULL,
  retailer_id        UUID NOT NULL,
  address_id         UUID NOT NULL,
  external_order_id  TEXT,
  status             TEXT,
  placed_at          TIMESTAMPTZ,
  subtotal_cents     INT,
  fees_cents         INT,
  tip_cents          INT,
  discount_cents     INT,
  total_cents        INT,
  currency           TEXT,
  delivery_notes     TEXT,
  created_at         TIMESTAMPTZ,
  updated_at         TIMESTAMPTZ,
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_orders_retailer
    FOREIGN KEY (retailer_id) REFERENCES retailers(retailer_id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_orders_address
    FOREIGN KEY (address_id) REFERENCES addresses(address_id)
    ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id             UUID NOT NULL,
  product_id           UUID NOT NULL,
  external_sku         TEXT,
  name_snapshot        TEXT,
  unit_price_cents     INT,
  quantity             INT,
  substituted_for_sku  TEXT,
  created_at           TIMESTAMPTZ,
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS order_status_history (
  order_status_history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id                UUID NOT NULL,
  status                  TEXT,
  status_time             TIMESTAMPTZ,
  note                    TEXT,
  CONSTRAINT fk_order_status_history_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
);

-- ============================================================
-- DELIVERY + PAYMENTS (SHARED)
-- ============================================================
CREATE TABLE IF NOT EXISTS delivery_assignments (
  delivery_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id         UUID NOT NULL,
  driver_id        UUID,
  status           TEXT,
  pickup_location  TEXT,
  assigned_at      TIMESTAMPTZ,
  picked_up_at     TIMESTAMPTZ,
  delivered_at     TIMESTAMPTZ,
  CONSTRAINT fk_delivery_assignments_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS delivery_proof (
  proof_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id    UUID NOT NULL,
  proof_type     TEXT,
  proof_url      TEXT,
  metadata_json  TEXT,
  created_at     TIMESTAMPTZ,
  CONSTRAINT fk_delivery_proof_delivery
    FOREIGN KEY (delivery_id) REFERENCES delivery_assignments(delivery_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
  payment_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id       UUID NOT NULL,
  customer_id    UUID NOT NULL,
  provider       TEXT,
  provider_ref   TEXT,
  amount_cents   INT,
  currency       TEXT,
  status         TEXT,
  created_at     TIMESTAMPTZ,
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_payments_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS refunds (
  refund_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id     UUID NOT NULL,
  order_id       UUID NOT NULL,
  amount_cents   INT,
  reason         TEXT,
  status         TEXT,
  created_at     TIMESTAMPTZ,
  CONSTRAINT fk_refunds_payment
    FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_refunds_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
);

-- ============================================================
-- SUPPORT + NOTIFICATIONS + RATINGS (CUSTOMER)
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id     UUID NOT NULL,
  type            TEXT,
  title           TEXT,
  body            TEXT,
  deep_link       TEXT,
  is_read         BOOLEAN,
  created_at      TIMESTAMPTZ,
  read_at         TIMESTAMPTZ,
  CONSTRAINT fk_notifications_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS support_tickets (
  ticket_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id  UUID NOT NULL,
  order_id     UUID,
  issue_type   TEXT,
  message      TEXT,
  status       TEXT,
  created_at   TIMESTAMPTZ,
  updated_at   TIMESTAMPTZ,
  CONSTRAINT fk_support_tickets_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_support_tickets_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS support_attachments (
  attachment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id     UUID NOT NULL,
  file_type     TEXT,
  file_url      TEXT,
  created_at    TIMESTAMPTZ,
  CONSTRAINT fk_support_attachments_ticket
    FOREIGN KEY (ticket_id) REFERENCES support_tickets(ticket_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ratings (
  rating_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id      UUID NOT NULL,
  customer_id   UUID NOT NULL,
  rating_value  INT,
  comment       TEXT,
  created_at    TIMESTAMPTZ,
  CONSTRAINT fk_ratings_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_ratings_customer
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON DELETE CASCADE,
  CONSTRAINT uq_ratings_one_per_order
    UNIQUE (order_id)
);

-- ============================================================
-- DRIVER CORE
-- ============================================================
CREATE TABLE IF NOT EXISTS drivers (
  driver_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email          TEXT UNIQUE,
  phone          TEXT,
  full_name      TEXT,
  password_hash  TEXT,
  is_active      BOOLEAN,
  status         TEXT,
  created_at     TIMESTAMPTZ,
  updated_at     TIMESTAMPTZ
);

ALTER TABLE delivery_assignments
  ADD CONSTRAINT fk_delivery_assignments_driver
  FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
  ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS driver_devices (
  device_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id     UUID NOT NULL,
  platform      TEXT,
  push_token    TEXT UNIQUE,
  app_version   TEXT,
  last_seen_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ,
  CONSTRAINT fk_driver_devices_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_sessions (
  session_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id     UUID NOT NULL,
  access_token  TEXT UNIQUE,
  expires_at    TIMESTAMPTZ,
  device_info   TEXT,
  created_at    TIMESTAMPTZ,
  CONSTRAINT fk_driver_sessions_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_profiles (
  driver_profile_id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id                     UUID NOT NULL,
  date_of_birth                 DATE,
  license_number                TEXT,
  license_state                 TEXT,
  license_expires_at            TIMESTAMPTZ,
  background_check_status       TEXT,
  background_check_completed_at TIMESTAMPTZ,
  updated_at                    TIMESTAMPTZ,
  CONSTRAINT fk_driver_profiles_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_vehicles (
  vehicle_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id       UUID NOT NULL,
  make            TEXT,
  model           TEXT,
  year            INT,
  color           TEXT,
  plate_number    TEXT,
  plate_state     TEXT,
  is_primary      BOOLEAN,
  created_at      TIMESTAMPTZ,
  CONSTRAINT fk_driver_vehicles_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_documents (
  document_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id      UUID NOT NULL,
  doc_type       TEXT,
  file_url       TEXT,
  status         TEXT,
  reviewer_note  TEXT,
  expires_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ,
  CONSTRAINT fk_driver_documents_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_availability (
  availability_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id       UUID NOT NULL,
  is_available    BOOLEAN,
  reason          TEXT,
  started_at      TIMESTAMPTZ,
  ended_at        TIMESTAMPTZ,
  CONSTRAINT fk_driver_availability_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_service_areas (
  service_area_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id       UUID NOT NULL,
  label           TEXT,
  city            TEXT,
  state           TEXT,
  postal_code     TEXT,
  geofence_json   TEXT,
  is_primary      BOOLEAN,
  created_at      TIMESTAMPTZ,
  CONSTRAINT fk_driver_service_areas_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_locations (
  location_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id      UUID NOT NULL,
  lat            DECIMAL,
  lng            DECIMAL,
  accuracy_m     DECIMAL,
  heading        DECIMAL,
  speed_mps      DECIMAL,
  recorded_at    TIMESTAMPTZ,
  source         TEXT,
  CONSTRAINT fk_driver_locations_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_notifications (
  notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id       UUID NOT NULL,
  type            TEXT,
  title           TEXT,
  body            TEXT,
  deep_link       TEXT,
  is_read         BOOLEAN,
  created_at      TIMESTAMPTZ,
  read_at         TIMESTAMPTZ,
  CONSTRAINT fk_driver_notifications_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_earnings (
  earning_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id          UUID NOT NULL,
  delivery_id        UUID NOT NULL,
  base_pay_cents     INT,
  bonus_cents        INT,
  tip_cents          INT,
  adjustments_cents  INT,
  total_pay_cents    INT,
  currency           TEXT,
  status             TEXT,
  created_at         TIMESTAMPTZ,
  CONSTRAINT fk_driver_earnings_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_driver_earnings_delivery
    FOREIGN KEY (delivery_id) REFERENCES delivery_assignments(delivery_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_payouts (
  payout_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id      UUID NOT NULL,
  amount_cents   INT,
  currency       TEXT,
  status         TEXT,
  provider       TEXT,
  provider_ref   TEXT,
  created_at     TIMESTAMPTZ,
  CONSTRAINT fk_driver_payouts_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_support_tickets (
  ticket_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id     UUID NOT NULL,
  delivery_id   UUID,
  order_id      UUID,
  issue_type    TEXT,
  message       TEXT,
  status        TEXT,
  created_at    TIMESTAMPTZ,
  updated_at    TIMESTAMPTZ,
  CONSTRAINT fk_driver_support_tickets_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_driver_support_tickets_delivery
    FOREIGN KEY (delivery_id) REFERENCES delivery_assignments(delivery_id)
    ON DELETE SET NULL,
  CONSTRAINT fk_driver_support_tickets_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS driver_tasks (
  task_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id    UUID NOT NULL,
  driver_id      UUID NOT NULL,
  task_type      TEXT,
  status         TEXT,
  due_at         TIMESTAMPTZ,
  completed_at   TIMESTAMPTZ,
  instructions   TEXT,
  CONSTRAINT fk_driver_tasks_delivery
    FOREIGN KEY (delivery_id) REFERENCES delivery_assignments(delivery_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_driver_tasks_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS delivery_status_events (
  event_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delivery_id  UUID NOT NULL,
  driver_id    UUID,
  status       TEXT,
  event_time   TIMESTAMPTZ,
  note         TEXT,
  lat          DECIMAL,
  lng          DECIMAL,
  CONSTRAINT fk_delivery_status_events_delivery
    FOREIGN KEY (delivery_id) REFERENCES delivery_assignments(delivery_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_delivery_status_events_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS delivery_offers (
  offer_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id        UUID NOT NULL,
  delivery_id     UUID NOT NULL,
  driver_id       UUID NOT NULL,
  status          TEXT,
  offered_at      TIMESTAMPTZ,
  responded_at    TIMESTAMPTZ,
  expires_in_sec  INT,
  decline_reason  TEXT,
  CONSTRAINT fk_delivery_offers_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_delivery_offers_delivery
    FOREIGN KEY (delivery_id) REFERENCES delivery_assignments(delivery_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_delivery_offers_driver
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
    ON DELETE CASCADE
);

-- ============================================================
-- ADMIN: CONFIGURATION + POLICY (these match the readable 400% crops)
-- ============================================================
CREATE TABLE IF NOT EXISTS fee_rules (
  fee_rule_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT,
  applies_to    TEXT,        -- "ORDER|DELIVERY"
  rule_json     TEXT,
  is_active     BOOLEAN,
  created_at    TIMESTAMPTZ,
  updated_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS service_regions (
  region_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT,
  state         TEXT,
  geofence_json TEXT,
  is_active     BOOLEAN,
  created_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS feature_flags (
  flag_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key          TEXT UNIQUE,
  description  TEXT,
  enabled      BOOLEAN,
  rules_json   TEXT,
  expires_at   TIMESTAMPTZ,
  updated_at   TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS notification_templates (
  template_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key             TEXT UNIQUE,
  channel         TEXT,        -- "PUSH|EMAIL|SMS|IN_APP"
  title_template  TEXT,
  body_template   TEXT,
  is_active       BOOLEAN,
  updated_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS sla_policies (
  sla_policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT UNIQUE,
  description   TEXT,
  is_active     BOOLEAN,
  created_at    TIMESTAMPTZ
);

-- ============================================================
-- ADMIN: OUTBOUND COMMUNICATIONS (ties to templates/targets)
-- ============================================================
CREATE TABLE IF NOT EXISTS outbound_messages (
  message_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_type     TEXT,              -- "ADMIN|SYSTEM"
  actor_id       UUID,              -- admin_id when actor_type=ADMIN
  target_type    TEXT,              -- "CUSTOMER|DRIVER"
  target_id      UUID,
  channel        TEXT,              -- "PUSH|EMAIL|SMS|IN_APP"
  template_id    UUID,              -- notification_templates.template_id
  title          TEXT,
  body           TEXT,
  deep_link      TEXT,
  status         TEXT,              -- "DRAFT|QUEUED|SENT|FAILED"
  created_at     TIMESTAMPTZ,
  sent_at        TIMESTAMPTZ,
  CONSTRAINT fk_outbound_messages_template
    FOREIGN KEY (template_id) REFERENCES notification_templates(template_id)
    ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS message_delivery_logs (
  message_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id     UUID NOT NULL,
  provider       TEXT,
  provider_ref   TEXT,
  status         TEXT,
  error          TEXT,
  created_at     TIMESTAMPTZ,
  CONSTRAINT fk_message_delivery_logs_message
    FOREIGN KEY (message_id) REFERENCES outbound_messages(message_id)
    ON DELETE CASCADE
);

-- ============================================================
-- ADMIN: AUTH + ROLES
-- ============================================================
CREATE TABLE IF NOT EXISTS admin_roles (
  role_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT UNIQUE,
  description  TEXT,
  created_at   TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS admin_permissions (
  permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key           TEXT UNIQUE,
  description   TEXT,
  created_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS admin_role_permissions (
  role_permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id            UUID NOT NULL,
  permission_id      UUID NOT NULL,
  created_at         TIMESTAMPTZ,
  CONSTRAINT fk_admin_role_permissions_role
    FOREIGN KEY (role_id) REFERENCES admin_roles(role_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_admin_role_permissions_permission
    FOREIGN KEY (permission_id) REFERENCES admin_permissions(permission_id)
    ON DELETE CASCADE,
  CONSTRAINT uq_admin_role_permissions
    UNIQUE (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS admins (
  admin_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         TEXT UNIQUE,
  full_name     TEXT,
  password_hash TEXT,
  is_active     BOOLEAN,
  created_at    TIMESTAMPTZ,
  updated_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS admin_profiles (
  admin_profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id         UUID NOT NULL,
  role_id          UUID NOT NULL,
  title            TEXT,
  phone            TEXT,
  last_login_at    TIMESTAMPTZ,
  updated_at       TIMESTAMPTZ,
  CONSTRAINT fk_admin_profiles_admin
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_admin_profiles_role
    FOREIGN KEY (role_id) REFERENCES admin_roles(role_id)
    ON DELETE RESTRICT,
  CONSTRAINT uq_admin_profiles_admin
    UNIQUE (admin_id)
);

CREATE TABLE IF NOT EXISTS admin_sessions (
  session_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id     UUID NOT NULL,
  access_token TEXT UNIQUE,
  expires_at   TIMESTAMPTZ,
  created_at   TIMESTAMPTZ,
  CONSTRAINT fk_admin_sessions_admin
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id)
    ON DELETE CASCADE
);

-- ============================================================
-- ADMIN: CASE MANAGEMENT (queue + case objects)
-- ============================================================
CREATE TABLE IF NOT EXISTS queues (
  queue_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT UNIQUE,
  description  TEXT,
  is_active    BOOLEAN,
  created_at   TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS queue_items (
  queue_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  queue_id      UUID NOT NULL,
  source_type   TEXT,          -- "CASE|TICKET|DISPUTE|REFUND|ORDER|DELIVERY"
  source_id     UUID,
  priority      TEXT,          -- keep TEXT (diagram shows enum-ish)
  status        TEXT,
  sla_policy_id UUID,
  due_at        TIMESTAMPTZ,
  created_at    TIMESTAMPTZ,
  updated_at    TIMESTAMPTZ,
  CONSTRAINT fk_queue_items_queue
    FOREIGN KEY (queue_id) REFERENCES queues(queue_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_queue_items_sla
    FOREIGN KEY (sla_policy_id) REFERENCES sla_policies(sla_policy_id)
    ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS cases (
  case_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_type     TEXT,
  status        TEXT,
  priority      TEXT,
  queue_id      UUID,
  customer_id   UUID,
  driver_id     UUID,
  order_id      UUID,
  delivery_id   UUID,
  refund_id     UUID,
  ticket_id     UUID,
  opened_by     UUID,      -- admin_id
  assigned_to   UUID,      -- admin_id
  summary       TEXT,
  details       TEXT,
  created_at    TIMESTAMPTZ,
  updated_at    TIMESTAMPTZ,
  CONSTRAINT fk_cases_queue      FOREIGN KEY (queue_id)    REFERENCES queues(queue_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_customer   FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_driver     FOREIGN KEY (driver_id)   REFERENCES drivers(driver_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_order      FOREIGN KEY (order_id)    REFERENCES orders(order_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_delivery   FOREIGN KEY (delivery_id) REFERENCES delivery_assignments(delivery_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_refund     FOREIGN KEY (refund_id)   REFERENCES refunds(refund_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_ticket     FOREIGN KEY (ticket_id)   REFERENCES support_tickets(ticket_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_opened_by  FOREIGN KEY (opened_by)   REFERENCES admins(admin_id) ON DELETE SET NULL,
  CONSTRAINT fk_cases_assigned_to FOREIGN KEY (assigned_to) REFERENCES admins(admin_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS case_notes (
  note_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id     UUID NOT NULL,
  admin_id    UUID,
  note        TEXT,
  created_at  TIMESTAMPTZ,
  CONSTRAINT fk_case_notes_case
    FOREIGN KEY (case_id) REFERENCES cases(case_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_case_notes_admin
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id)
    ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS case_attachments (
  attachment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id       UUID NOT NULL,
  file_type     TEXT,
  file_url      TEXT,
  created_at    TIMESTAMPTZ,
  CONSTRAINT fk_case_attachments_case
    FOREIGN KEY (case_id) REFERENCES cases(case_id)
    ON DELETE CASCADE
);

-- ============================================================
-- AUDIT + SYSTEM OBSERVABILITY
-- ============================================================
CREATE TABLE IF NOT EXISTS webhooks (
  webhook_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider     TEXT,
  event_type   TEXT,
  status       TEXT,
  payload_json TEXT,
  created_at   TIMESTAMPTZ,
  received_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS system_events (
  system_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type      TEXT,
  source          TEXT,
  level           TEXT,
  message         TEXT,
  meta_json       TEXT,
  occurred_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS audit_logs (
  audit_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_type   TEXT,     -- "ADMIN|SYSTEM"
  actor_id     UUID,
  action       TEXT,
  entity_type  TEXT,
  entity_id    UUID,
  details_json TEXT,
  created_at   TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS integration_health (
  health_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  integration      TEXT,
  status           TEXT,
  last_checked_at  TIMESTAMPTZ,
  error            TEXT,
  details_json     TEXT
);

-- ============================================================
-- INDEXES (core)
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_addresses_customer_id               ON addresses(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_devices_customer_id        ON customer_devices(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_sessions_customer_id       ON customer_sessions(customer_id);

CREATE INDEX IF NOT EXISTS idx_products_retailer_id                ON products(retailer_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id                ON products(category_id);

CREATE INDEX IF NOT EXISTS idx_carts_customer_id                   ON carts(customer_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id                  ON cart_items(cart_id);

CREATE INDEX IF NOT EXISTS idx_orders_customer_id                  ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_retailer_id                  ON orders(retailer_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id                ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id       ON order_status_history(order_id);

CREATE INDEX IF NOT EXISTS idx_delivery_assignments_order_id       ON delivery_assignments(order_id);
CREATE INDEX IF NOT EXISTS idx_delivery_assignments_driver_id      ON delivery_assignments(driver_id);

CREATE INDEX IF NOT EXISTS idx_payments_order_id                   ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_refunds_payment_id                  ON refunds(payment_id);

CREATE INDEX IF NOT EXISTS idx_notifications_customer_id           ON notifications(customer_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_customer_id         ON support_tickets(customer_id);
CREATE INDEX IF NOT EXISTS idx_support_attachments_ticket_id       ON support_attachments(ticket_id);

CREATE INDEX IF NOT EXISTS idx_driver_locations_driver_id          ON driver_locations(driver_id);
CREATE INDEX IF NOT EXISTS idx_driver_tasks_delivery_id            ON driver_tasks(delivery_id);
CREATE INDEX IF NOT EXISTS idx_delivery_status_events_delivery_id  ON delivery_status_events(delivery_id);
CREATE INDEX IF NOT EXISTS idx_delivery_offers_driver_id           ON delivery_offers(driver_id);

CREATE INDEX IF NOT EXISTS idx_queue_items_queue_id                ON queue_items(queue_id);
CREATE INDEX IF NOT EXISTS idx_cases_status                        ON cases(status);
CREATE INDEX IF NOT EXISTS idx_cases_order_id                      ON cases(order_id);
CREATE INDEX IF NOT EXISTS idx_cases_delivery_id                   ON cases(delivery_id);
