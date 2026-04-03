-- ============================================================
-- Local-development seed data
-- Loaded by the separate `db-seed` compose service.
-- Keep this out of the Flyway migration path.
-- The local admin password is injected by psql from ADMIN_SEED_PASSWORD.
-- ============================================================

-- Admin roles and local admin bootstrap
INSERT INTO admin_roles (role_id, name, description, created_at)
VALUES
  ('99999999-9999-9999-9999-999999999901', 'Operations Lead', 'Local development admin role', NOW())
ON CONFLICT (role_id) DO NOTHING;

INSERT INTO admins (admin_id, email, full_name, password_hash, is_active, created_at, updated_at)
VALUES
  (
    '99999999-9999-9999-9999-999999999001',
    'admin@bizrush.local',
    'BizRush Admin',
    crypt(:'admin_seed_password', gen_salt('bf', 10)),
    TRUE,
    NOW() - INTERVAL '12 days',
    NOW()
  )
ON CONFLICT (admin_id) DO UPDATE
SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  password_hash = EXCLUDED.password_hash,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

INSERT INTO admin_profiles (admin_profile_id, admin_id, role_id, title, phone, last_login_at, updated_at)
VALUES
  ('99999999-9999-9999-9999-999999999101', '99999999-9999-9999-9999-999999999001', '99999999-9999-9999-9999-999999999901', 'Operations Manager', '+1-555-303-0001', NOW() - INTERVAL '2 hours', NOW())
ON CONFLICT (admin_profile_id) DO NOTHING;

-- Retailers used by seeded orders/moves
INSERT INTO retailers (retailer_id, name, website, is_enabled, created_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'FreshMart', 'https://freshmart.example', TRUE, NOW()),
  ('11111111-1111-1111-1111-111111111112', 'QuickGrocer', 'https://quickgrocer.example', TRUE, NOW())
ON CONFLICT (retailer_id) DO NOTHING;

-- Customers
INSERT INTO customers (customer_id, email, phone, full_name, password_hash, is_active, created_at, updated_at)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'ava.johnson@example.com', '+1-555-101-0001', 'Ava Johnson', '$2b$10$dummyhashcustomer01', TRUE, NOW() - INTERVAL '30 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'liam.carter@example.com', '+1-555-101-0002', 'Liam Carter', '$2b$10$dummyhashcustomer02', TRUE, NOW() - INTERVAL '28 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'mia.nguyen@example.com', '+1-555-101-0003', 'Mia Nguyen', '$2b$10$dummyhashcustomer03', TRUE, NOW() - INTERVAL '24 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'noah.baker@example.com', '+1-555-101-0004', 'Noah Baker', '$2b$10$dummyhashcustomer04', TRUE, NOW() - INTERVAL '20 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'olivia.hernandez@example.com', '+1-555-101-0005', 'Olivia Hernandez', '$2b$10$dummyhashcustomer05', TRUE, NOW() - INTERVAL '18 days', NOW())
ON CONFLICT (customer_id) DO NOTHING;

-- Customer addresses
INSERT INTO addresses (address_id, customer_id, label, line1, line2, city, state, postal_code, country, instructions, is_default, created_at)
VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Home', '123 Maple St', 'Apt 4B', 'Brooklyn', 'NY', '11201', 'USA', 'Leave at front desk', TRUE, NOW() - INTERVAL '29 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Home', '55 King Ave', NULL, 'Jersey City', 'NJ', '07302', 'USA', 'Ring once', TRUE, NOW() - INTERVAL '27 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Home', '880 Pine Rd', NULL, 'Queens', 'NY', '11368', 'USA', 'Call on arrival', TRUE, NOW() - INTERVAL '23 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Home', '742 Oak Dr', 'Unit 12', 'Newark', 'NJ', '07102', 'USA', 'Use side entrance', TRUE, NOW() - INTERVAL '19 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Home', '91 River Pl', NULL, 'Hoboken', 'NJ', '07030', 'USA', 'Lobby drop-off', TRUE, NOW() - INTERVAL '17 days')
ON CONFLICT (address_id) DO NOTHING;

-- Drivers
INSERT INTO drivers (driver_id, email, phone, full_name, password_hash, is_active, status, created_at, updated_at)
VALUES
  ('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'ethan.driver@example.com', '+1-555-202-0001', 'Ethan Brooks', '$2b$10$dummyhashdriver01', TRUE, 'ONLINE', NOW() - INTERVAL '40 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc2', 'sophia.driver@example.com', '+1-555-202-0002', 'Sophia Patel', '$2b$10$dummyhashdriver02', TRUE, 'ONLINE', NOW() - INTERVAL '35 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc3', 'jacob.driver@example.com', '+1-555-202-0003', 'Jacob Kim', '$2b$10$dummyhashdriver03', TRUE, 'OFFLINE', NOW() - INTERVAL '31 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc4', 'isabella.driver@example.com', '+1-555-202-0004', 'Isabella Reed', '$2b$10$dummyhashdriver04', TRUE, 'ONLINE', NOW() - INTERVAL '26 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc5', 'mason.driver@example.com', '+1-555-202-0005', 'Mason Flores', '$2b$10$dummyhashdriver05', TRUE, 'ONLINE', NOW() - INTERVAL '21 days', NOW())
ON CONFLICT (driver_id) DO NOTHING;

-- Moves represented as orders
INSERT INTO orders (
  order_id, customer_id, retailer_id, address_id, external_order_id, status, placed_at,
  subtotal_cents, fees_cents, tip_cents, discount_cents, total_cents, currency, delivery_notes, created_at, updated_at
)
VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddddd1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'ORD-10001', 'DELIVERED', NOW() - INTERVAL '5 days', 5200, 799, 500, 0, 6499, 'USD', 'Please leave at concierge', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111112', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'ORD-10002', 'SUBMITTED', NOW() - INTERVAL '4 days', 3800, 599, 300, 0, 4699, 'USD', 'Contactless dropoff', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'ORD-10003', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '3 hours', 6400, 899, 700, 500, 7499, 'USD', 'Text before arrival', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '30 minutes'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', '11111111-1111-1111-1111-111111111112', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4', 'ORD-10004', 'READY_FOR_PICKUP', NOW() - INTERVAL '2 hours', 4700, 699, 500, 0, 5899, 'USD', 'Use side door', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '45 minutes'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', '11111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5', 'ORD-10005', 'PICKING', NOW() - INTERVAL '45 minutes', 3000, 499, 300, 0, 3799, 'USD', 'Leave in lobby', NOW() - INTERVAL '45 minutes', NOW() - INTERVAL '45 minutes')
ON CONFLICT (order_id) DO NOTHING;

-- Moves represented as delivery assignments
INSERT INTO delivery_assignments (
  delivery_id, order_id, driver_id, status, pickup_location, assigned_at, picked_up_at, delivered_at
)
VALUES
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'DELIVERED', 'FreshMart - Downtown', NOW() - INTERVAL '5 days' + INTERVAL '10 minutes', NOW() - INTERVAL '5 days' + INTERVAL '35 minutes', NOW() - INTERVAL '5 days' + INTERVAL '58 minutes'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', NULL, 'PENDING_ASSIGNMENT', 'QuickGrocer - Journal Sq', NULL, NULL, NULL),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'OUT_FOR_DELIVERY', 'FreshMart - Astoria', NOW() - INTERVAL '2 hours 40 minutes', NOW() - INTERVAL '1 hour 55 minutes', NULL),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'cccccccc-cccc-cccc-cccc-ccccccccccc5', 'ASSIGNED', 'QuickGrocer - Newark', NOW() - INTERVAL '1 hour 45 minutes', NULL, NULL),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', NULL, 'PENDING_ASSIGNMENT', 'FreshMart - Hoboken', NULL, NULL, NULL)
ON CONFLICT (delivery_id) DO NOTHING;

-- Delivery timeline events for seeded moves
INSERT INTO delivery_status_events (event_id, delivery_id, driver_id, status, event_time, note, lat, lng)
VALUES
  ('ffffffff-ffff-ffff-ffff-fffffffffff1', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'ASSIGNED', NOW() - INTERVAL '5 days' + INTERVAL '10 minutes', 'Driver accepted offer', 40.7128, -74.0060),
  ('ffffffff-ffff-ffff-ffff-fffffffffff2', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'DELIVERED', NOW() - INTERVAL '5 days' + INTERVAL '58 minutes', 'Delivered to concierge', 40.7090, -74.0112),
  ('ffffffff-ffff-ffff-ffff-fffffffffff3', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'PICKED_UP', NOW() - INTERVAL '1 hour 55 minutes', 'Order picked up', 40.7590, -73.9845),
  ('ffffffff-ffff-ffff-ffff-fffffffffff4', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '20 minutes', 'Approaching destination', 40.7526, -73.9772),
  ('ffffffff-ffff-ffff-ffff-fffffffffff5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4', 'cccccccc-cccc-cccc-cccc-ccccccccccc5', 'ASSIGNED', NOW() - INTERVAL '1 hour 45 minutes', 'Waiting for pickup', 40.7357, -74.1724)
ON CONFLICT (event_id) DO NOTHING;

INSERT INTO order_status_history (order_status_history_id, order_id, status, status_time, note)
VALUES
  ('abababab-abab-abab-abab-ababababab01', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'SUBMITTED', NOW() - INTERVAL '5 days', 'Order submitted by customer'),
  ('abababab-abab-abab-abab-ababababab02', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'PICKING', NOW() - INTERVAL '4 days 23 hours', 'Retailer started fulfillment'),
  ('abababab-abab-abab-abab-ababababab03', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'READY_FOR_PICKUP', NOW() - INTERVAL '4 days 22 hours', 'Order staged for driver pickup'),
  ('abababab-abab-abab-abab-ababababab04', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '4 days 21 hours', 'Driver departed retailer'),
  ('abababab-abab-abab-abab-ababababab05', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'DELIVERED', NOW() - INTERVAL '4 days 20 hours', 'Order delivered successfully'),
  ('abababab-abab-abab-abab-ababababab06', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', 'SUBMITTED', NOW() - INTERVAL '4 days', 'Awaiting retailer acceptance'),
  ('abababab-abab-abab-abab-ababababab07', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '25 minutes', 'Driver is en route to customer'),
  ('abababab-abab-abab-abab-ababababab08', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'READY_FOR_PICKUP', NOW() - INTERVAL '40 minutes', 'Retailer marked order ready'),
  ('abababab-abab-abab-abab-ababababab09', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'PICKING', NOW() - INTERVAL '20 minutes', 'Retailer is picking items')
ON CONFLICT (order_status_history_id) DO NOTHING;

INSERT INTO payments (payment_id, order_id, customer_id, provider, provider_ref, amount_cents, currency, status, created_at)
VALUES
  ('cdcdcdcd-cdcd-cdcd-cdcd-cdcdcdcdcd01', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'MOCKPAY', 'PAY-10001', 6499, 'USD', 'CAPTURED', NOW() - INTERVAL '5 days'),
  ('cdcdcdcd-cdcd-cdcd-cdcd-cdcdcdcdcd02', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'MOCKPAY', 'PAY-10002', 4699, 'USD', 'CAPTURED', NOW() - INTERVAL '4 days'),
  ('cdcdcdcd-cdcd-cdcd-cdcd-cdcdcdcdcd03', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'MOCKPAY', 'PAY-10003', 7499, 'USD', 'CAPTURED', NOW() - INTERVAL '3 hours'),
  ('cdcdcdcd-cdcd-cdcd-cdcd-cdcdcdcdcd04', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'MOCKPAY', 'PAY-10004', 5899, 'USD', 'CAPTURED', NOW() - INTERVAL '2 hours'),
  ('cdcdcdcd-cdcd-cdcd-cdcd-cdcdcdcdcd05', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'MOCKPAY', 'PAY-10005', 3799, 'USD', 'CAPTURED', NOW() - INTERVAL '45 minutes')
ON CONFLICT (payment_id) DO NOTHING;

INSERT INTO integration_health (health_id, integration, status, last_checked_at, error, details_json)
VALUES
  ('edededed-eded-eded-eded-ededededed01', 'Target Catalog Sync', 'HEALTHY', NOW() - INTERVAL '8 minutes', NULL, '{"latencyMs":120}'),
  ('edededed-eded-eded-eded-ededededed02', 'Walmart Catalog Sync', 'DEGRADED', NOW() - INTERVAL '15 minutes', 'Slow upstream response times', '{"latencyMs":920}'),
  ('edededed-eded-eded-eded-ededededed03', 'Mockoon Retailer Bridge', 'HEALTHY', NOW() - INTERVAL '3 minutes', NULL, '{"mode":"demo"}')
ON CONFLICT (health_id) DO NOTHING;
