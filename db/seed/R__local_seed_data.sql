-- ============================================================
-- Local-development seed data
-- Loaded by the separate `db-seed` compose service.
-- Keep this out of the Flyway migration path.
-- ============================================================

-- Retailers used by seeded customer and driver flows.
INSERT INTO retailers (retailer_id, name, website, is_enabled, created_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'FreshMart', 'https://freshmart.example', TRUE, NOW()),
  ('11111111-1111-1111-1111-111111111112', 'QuickGrocer', 'https://quickgrocer.example', TRUE, NOW())
ON CONFLICT (retailer_id) DO NOTHING;

-- Platform-owned partnered pickup locations that the mobile apps can browse.
INSERT INTO retailer_locations (
  retailer_location_id, retailer_id, external_store_id, name, address_line1, address_line2,
  city, state, postal_code, country, lat, lng, is_active, created_at, updated_at
)
VALUES
  ('12121212-1212-4212-8212-121212121211', '11111111-1111-1111-1111-111111111111', 'FM-1001', 'FreshMart Downtown', '10 Main St', NULL, 'Dayton', 'OH', '45402', 'USA', 39.7587, -84.1916, TRUE, NOW() - INTERVAL '14 days', NOW()),
  ('12121212-1212-4212-8212-121212121212', '11111111-1111-1111-1111-111111111111', 'FM-1002', 'FreshMart Riverside', '220 Riverside Dr', NULL, 'Dayton', 'OH', '45405', 'USA', 39.7836, -84.2057, TRUE, NOW() - INTERVAL '14 days', NOW()),
  ('13131313-1313-4313-8313-131313131311', '11111111-1111-1111-1111-111111111112', 'QG-2001', 'QuickGrocer Journal Sq', '55 Grove St', NULL, 'Jersey City', 'NJ', '07302', 'USA', 40.7332, -74.0626, TRUE, NOW() - INTERVAL '14 days', NOW()),
  ('13131313-1313-4313-8313-131313131312', '11111111-1111-1111-1111-111111111112', 'QG-2002', 'QuickGrocer Newark', '88 Market St', NULL, 'Newark', 'NJ', '07102', 'USA', 40.7357, -74.1724, TRUE, NOW() - INTERVAL '14 days', NOW())
ON CONFLICT (retailer_location_id) DO NOTHING;

-- Customers use plain-text passwords in the current MVP auth implementation.
INSERT INTO customers (
  customer_id, email, phone, full_name, password_hash, is_active, created_at, updated_at
)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'ava.johnson@example.com', '+1-555-101-0001', 'Ava Johnson', 'customer-pass-1', TRUE, NOW() - INTERVAL '30 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'liam.carter@example.com', '+1-555-101-0002', 'Liam Carter', 'customer-pass-2', TRUE, NOW() - INTERVAL '28 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'mia.nguyen@example.com', '+1-555-101-0003', 'Mia Nguyen', 'customer-pass-3', TRUE, NOW() - INTERVAL '24 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'noah.baker@example.com', '+1-555-101-0004', 'Noah Baker', 'customer-pass-4', TRUE, NOW() - INTERVAL '20 days', NOW()),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'olivia.hernandez@example.com', '+1-555-101-0005', 'Olivia Hernandez', 'customer-pass-5', TRUE, NOW() - INTERVAL '18 days', NOW())
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO addresses (
  address_id, customer_id, label, line1, line2, city, state, postal_code,
  country, instructions, is_default, created_at
)
VALUES
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Head Office', '123 Maple St', 'Apt 4B', 'Brooklyn', 'NY', '11201', 'USA', 'Leave at front desk', TRUE, NOW() - INTERVAL '29 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Studio', '55 King Ave', NULL, 'Jersey City', 'NJ', '07302', 'USA', 'Ring once', TRUE, NOW() - INTERVAL '27 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Warehouse', '880 Pine Rd', NULL, 'Queens', 'NY', '11368', 'USA', 'Call on arrival', TRUE, NOW() - INTERVAL '23 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Bakery', '742 Oak Dr', 'Unit 12', 'Newark', 'NJ', '07102', 'USA', 'Use side entrance', TRUE, NOW() - INTERVAL '19 days'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'Lobby Drop', '91 River Pl', NULL, 'Hoboken', 'NJ', '07030', 'USA', 'Lobby drop-off', TRUE, NOW() - INTERVAL '17 days')
ON CONFLICT (address_id) DO NOTHING;

-- Drivers also use plain-text passwords until hashing is wired in.
INSERT INTO drivers (
  driver_id, email, phone, full_name, password_hash, is_active, status, created_at, updated_at
)
VALUES
  ('cccccccc-cccc-cccc-cccc-ccccccccccc1', 'ethan.driver@example.com', '+1-555-202-0001', 'Ethan Brooks', 'driver-pass-1', TRUE, 'ONLINE', NOW() - INTERVAL '40 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc2', 'sophia.driver@example.com', '+1-555-202-0002', 'Sophia Patel', 'driver-pass-2', TRUE, 'ONLINE', NOW() - INTERVAL '35 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc3', 'jacob.driver@example.com', '+1-555-202-0003', 'Jacob Kim', 'driver-pass-3', TRUE, 'OFFLINE', NOW() - INTERVAL '31 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc4', 'isabella.driver@example.com', '+1-555-202-0004', 'Isabella Reed', 'driver-pass-4', TRUE, 'ONLINE', NOW() - INTERVAL '26 days', NOW()),
  ('cccccccc-cccc-cccc-cccc-ccccccccccc5', 'mason.driver@example.com', '+1-555-202-0005', 'Mason Flores', 'driver-pass-5', TRUE, 'BUSY', NOW() - INTERVAL '21 days', NOW())
ON CONFLICT (driver_id) DO NOTHING;

-- Customer retailer connections used by the customer account tab and checkout flow.
INSERT INTO retailer_accounts (
  retailer_account_id, customer_id, retailer_id, is_connected, access_token,
  refresh_token, token_expires_at, created_at, updated_at
)
VALUES
  ('17171717-1717-4717-8717-171717171711', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', TRUE, 'mock-freshmart-cust-1', 'refresh-freshmart-cust-1', NOW() + INTERVAL '12 hours', NOW() - INTERVAL '10 days', NOW()),
  ('17171717-1717-4717-8717-171717171712', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111112', TRUE, 'mock-quickgrocer-cust-1', 'refresh-quickgrocer-cust-1', NOW() + INTERVAL '12 hours', NOW() - INTERVAL '10 days', NOW()),
  ('17171717-1717-4717-8717-171717171713', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111112', TRUE, 'mock-quickgrocer-cust-2', 'refresh-quickgrocer-cust-2', NOW() + INTERVAL '12 hours', NOW() - INTERVAL '9 days', NOW())
ON CONFLICT (retailer_account_id) DO NOTHING;

-- Product catalog cache. Categories are retailer-specific because the current schema is retailer-scoped.
INSERT INTO product_categories (category_id, retailer_id, name, external_category_id, updated_at)
VALUES
  ('18181818-1818-4818-8818-181818181811', '11111111-1111-1111-1111-111111111111', 'Pantry', 'FM-PANTRY', NOW()),
  ('18181818-1818-4818-8818-181818181812', '11111111-1111-1111-1111-111111111111', 'Produce', 'FM-PRODUCE', NOW()),
  ('18181818-1818-4818-8818-181818181813', '11111111-1111-1111-1111-111111111111', 'Cleaning', 'FM-CLEANING', NOW()),
  ('19191919-1919-4919-8919-191919191911', '11111111-1111-1111-1111-111111111112', 'Pantry', 'QG-PANTRY', NOW()),
  ('19191919-1919-4919-8919-191919191912', '11111111-1111-1111-1111-111111111112', 'Beverages', 'QG-BEVERAGES', NOW()),
  ('19191919-1919-4919-8919-191919191913', '11111111-1111-1111-1111-111111111112', 'Produce', 'QG-PRODUCE', NOW())
ON CONFLICT (category_id) DO NOTHING;

INSERT INTO products (
  product_id, retailer_id, category_id, external_sku, name, description,
  image_url, unit_price_cents, currency, is_available, updated_at
)
VALUES
  ('20202020-2020-4020-8020-202020202011', '11111111-1111-1111-1111-111111111111', '18181818-1818-4818-8818-181818181811', 'FM-OLIVE-OIL', 'Premium Olive Oil', 'Cold-pressed extra virgin olive oil.', 'https://images.example/fm-olive-oil.png', 1299, 'USD', TRUE, NOW()),
  ('20202020-2020-4020-8020-202020202012', '11111111-1111-1111-1111-111111111111', '18181818-1818-4818-8818-181818181811', 'FM-FLOUR', 'All-Purpose Flour', 'Kitchen staple for cafes and bakeries.', 'https://images.example/fm-flour.png', 449, 'USD', TRUE, NOW()),
  ('20202020-2020-4020-8020-202020202013', '11111111-1111-1111-1111-111111111111', '18181818-1818-4818-8818-181818181812', 'FM-TOMATO', 'Fresh Roma Tomatoes', 'Crate-ready produce for prep lines.', 'https://images.example/fm-tomato.png', 329, 'USD', TRUE, NOW()),
  ('20202020-2020-4020-8020-202020202014', '11111111-1111-1111-1111-111111111111', '18181818-1818-4818-8818-181818181813', 'FM-DISH-SOAP', 'Dish Soap Refill', 'Commercial sink refill pack.', 'https://images.example/fm-dish-soap.png', 599, 'USD', TRUE, NOW()),
  ('21212121-2121-4121-8121-212121212011', '11111111-1111-1111-1111-111111111112', '19191919-1919-4919-8919-191919191911', 'QG-PAPER-TOWELS', 'Paper Towels Pack', 'Bulk six-roll paper towel pack.', 'https://images.example/qg-paper-towels.png', 1059, 'USD', TRUE, NOW()),
  ('21212121-2121-4121-8121-212121212012', '11111111-1111-1111-1111-111111111112', '19191919-1919-4919-8919-191919191912', 'QG-SPARKLING-WATER', 'Sparkling Water Case', 'Twelve-can flavored water case.', 'https://images.example/qg-sparkling-water.png', 899, 'USD', TRUE, NOW()),
  ('21212121-2121-4121-8121-212121212013', '11111111-1111-1111-1111-111111111112', '19191919-1919-4919-8919-191919191912', 'QG-WHOLE-MILK', 'Whole Milk', 'One-gallon whole milk.', 'https://images.example/qg-whole-milk.png', 399, 'USD', TRUE, NOW()),
  ('21212121-2121-4121-8121-212121212014', '11111111-1111-1111-1111-111111111112', '19191919-1919-4919-8919-191919191913', 'QG-BANANAS', 'Bananas', 'Produce bunch for office kitchens.', 'https://images.example/qg-bananas.png', 179, 'USD', TRUE, NOW())
ON CONFLICT (product_id) DO NOTHING;

-- Active carts help the customer app show real cart totals on first load.
INSERT INTO carts (
  cart_id, customer_id, retailer_id, retailer_location_id, status, created_at, updated_at
)
VALUES
  ('22222222-2222-4222-8222-222222222220', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', '12121212-1212-4212-8212-121212121211', 'ACTIVE', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '15 minutes'),
  ('22222222-2222-4222-8222-222222222221', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111112', '13131313-1313-4313-8313-131313131311', 'ACTIVE', NOW() - INTERVAL '90 minutes', NOW() - INTERVAL '30 minutes')
ON CONFLICT (cart_id) DO NOTHING;

INSERT INTO cart_items (
  cart_item_id, cart_id, product_id, external_sku, name_snapshot,
  unit_price_cents, quantity, substitution_allowed, notes, created_at
)
VALUES
  ('23232323-2323-4232-8232-232323232311', '22222222-2222-4222-8222-222222222220', '20202020-2020-4020-8020-202020202011', 'FM-OLIVE-OIL', 'Premium Olive Oil', 1299, 2, TRUE, 'No substitutions please.', NOW() - INTERVAL '2 hours'),
  ('23232323-2323-4232-8232-232323232312', '22222222-2222-4222-8222-222222222220', '20202020-2020-4020-8020-202020202013', 'FM-TOMATO', 'Fresh Roma Tomatoes', 329, 4, TRUE, NULL, NOW() - INTERVAL '90 minutes'),
  ('23232323-2323-4232-8232-232323232313', '22222222-2222-4222-8222-222222222221', '21212121-2121-4121-8121-212121212012', 'QG-SPARKLING-WATER', 'Sparkling Water Case', 899, 1, TRUE, NULL, NOW() - INTERVAL '75 minutes')
ON CONFLICT (cart_item_id) DO NOTHING;

-- Orders cover delivered, active, and newly-submitted states for both apps.
INSERT INTO orders (
  order_id, customer_id, retailer_id, retailer_location_id, address_id, external_order_id, status,
  placed_at, subtotal_cents, fees_cents, tip_cents, discount_cents, total_cents,
  currency, delivery_notes, created_at, updated_at
)
VALUES
  ('dddddddd-dddd-dddd-dddd-ddddddddddd1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', '12121212-1212-4212-8212-121212121211', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'ORD-10001', 'DELIVERED', NOW() - INTERVAL '3 hours', 5200, 799, 500, 0, 6499, 'USD', 'Please leave at concierge', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '2 hours'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '11111111-1111-1111-1111-111111111112', '13131313-1313-4313-8313-131313131311', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'ORD-10002', 'DELIVERED', NOW() - INTERVAL '1 day', 3800, 599, 300, 0, 4699, 'USD', 'Contactless dropoff', NOW() - INTERVAL '1 day', NOW() - INTERVAL '23 hours'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', '11111111-1111-1111-1111-111111111111', '12121212-1212-4212-8212-121212121212', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'ORD-10003', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '90 minutes', 6400, 899, 700, 500, 7499, 'USD', 'Text before arrival', NOW() - INTERVAL '90 minutes', NOW() - INTERVAL '25 minutes'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', '11111111-1111-1111-1111-111111111112', '13131313-1313-4313-8313-131313131312', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4', 'ORD-10004', 'ASSIGNED', NOW() - INTERVAL '70 minutes', 4700, 699, 500, 0, 5899, 'USD', 'Use side door', NOW() - INTERVAL '70 minutes', NOW() - INTERVAL '35 minutes'),
  ('dddddddd-dddd-dddd-dddd-ddddddddddd5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', '11111111-1111-1111-1111-111111111111', '12121212-1212-4212-8212-121212121211', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5', 'ORD-10005', 'SUBMITTED', NOW() - INTERVAL '35 minutes', 3000, 499, 300, 0, 3799, 'USD', 'Leave in lobby', NOW() - INTERVAL '35 minutes', NOW() - INTERVAL '35 minutes')
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO order_items (
  order_item_id, order_id, product_id, external_sku, name_snapshot,
  unit_price_cents, quantity, substituted_for_sku, created_at
)
VALUES
  ('24242424-2424-4242-8242-242424242411', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', '20202020-2020-4020-8020-202020202011', 'FM-OLIVE-OIL', 'Premium Olive Oil', 1299, 2, NULL, NOW() - INTERVAL '3 hours'),
  ('24242424-2424-4242-8242-242424242412', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', '20202020-2020-4020-8020-202020202013', 'FM-TOMATO', 'Fresh Roma Tomatoes', 329, 4, NULL, NOW() - INTERVAL '3 hours'),
  ('24242424-2424-4242-8242-242424242413', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', '21212121-2121-4121-8121-212121212011', 'QG-PAPER-TOWELS', 'Paper Towels Pack', 1059, 2, NULL, NOW() - INTERVAL '1 day'),
  ('24242424-2424-4242-8242-242424242414', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', '21212121-2121-4121-8121-212121212013', 'QG-WHOLE-MILK', 'Whole Milk', 399, 4, NULL, NOW() - INTERVAL '1 day'),
  ('24242424-2424-4242-8242-242424242415', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', '20202020-2020-4020-8020-202020202014', 'FM-DISH-SOAP', 'Dish Soap Refill', 599, 3, NULL, NOW() - INTERVAL '85 minutes'),
  ('24242424-2424-4242-8242-242424242416', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', '20202020-2020-4020-8020-202020202012', 'FM-FLOUR', 'All-Purpose Flour', 449, 6, NULL, NOW() - INTERVAL '85 minutes'),
  ('24242424-2424-4242-8242-242424242417', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', '21212121-2121-4121-8121-212121212012', 'QG-SPARKLING-WATER', 'Sparkling Water Case', 899, 2, NULL, NOW() - INTERVAL '65 minutes'),
  ('24242424-2424-4242-8242-242424242418', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', '21212121-2121-4121-8121-212121212014', 'QG-BANANAS', 'Bananas', 179, 6, NULL, NOW() - INTERVAL '65 minutes'),
  ('24242424-2424-4242-8242-242424242419', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', '20202020-2020-4020-8020-202020202012', 'FM-FLOUR', 'All-Purpose Flour', 449, 4, NULL, NOW() - INTERVAL '35 minutes'),
  ('24242424-2424-4242-8242-242424242420', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', '20202020-2020-4020-8020-202020202013', 'FM-TOMATO', 'Fresh Roma Tomatoes', 329, 2, NULL, NOW() - INTERVAL '35 minutes')
ON CONFLICT (order_item_id) DO NOTHING;

INSERT INTO order_status_history (order_status_history_id, order_id, status, status_time, note)
VALUES
  ('25252525-2525-4252-8252-252525252511', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'SUBMITTED', NOW() - INTERVAL '3 hours', 'Order submitted through mobile checkout.'),
  ('25252525-2525-4252-8252-252525252512', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'DELIVERED', NOW() - INTERVAL '2 hours', 'Delivered to concierge.'),
  ('25252525-2525-4252-8252-252525252513', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', 'SUBMITTED', NOW() - INTERVAL '1 day', 'Order submitted through mobile checkout.'),
  ('25252525-2525-4252-8252-252525252514', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', 'DELIVERED', NOW() - INTERVAL '23 hours', 'Left at lobby desk.'),
  ('25252525-2525-4252-8252-252525252515', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'SUBMITTED', NOW() - INTERVAL '90 minutes', 'Order submitted through mobile checkout.'),
  ('25252525-2525-4252-8252-252525252516', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '25 minutes', 'Driver is approaching destination.'),
  ('25252525-2525-4252-8252-252525252517', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'SUBMITTED', NOW() - INTERVAL '70 minutes', 'Order submitted through mobile checkout.'),
  ('25252525-2525-4252-8252-252525252518', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'ASSIGNED', NOW() - INTERVAL '35 minutes', 'Driver accepted the job.'),
  ('25252525-2525-4252-8252-252525252519', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'SUBMITTED', NOW() - INTERVAL '35 minutes', 'Waiting for driver assignment.')
ON CONFLICT (order_status_history_id) DO NOTHING;

INSERT INTO delivery_assignments (
  delivery_id, order_id, driver_id, status, pickup_location, assigned_at, picked_up_at, delivered_at
)
VALUES
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'DELIVERED', 'FreshMart Downtown', NOW() - INTERVAL '2 hours 40 minutes', NOW() - INTERVAL '2 hours 15 minutes', NOW() - INTERVAL '2 hours'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', 'DELIVERED', 'QuickGrocer Journal Sq', NOW() - INTERVAL '23 hours 30 minutes', NOW() - INTERVAL '23 hours', NOW() - INTERVAL '22 hours 40 minutes'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'OUT_FOR_DELIVERY', 'FreshMart Riverside', NOW() - INTERVAL '70 minutes', NOW() - INTERVAL '40 minutes', NULL),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'cccccccc-cccc-cccc-cccc-ccccccccccc5', 'ASSIGNED', 'QuickGrocer Newark', NOW() - INTERVAL '35 minutes', NULL, NULL),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', NULL, 'PENDING_ASSIGNMENT', 'FreshMart Downtown', NULL, NULL, NULL)
ON CONFLICT (delivery_id) DO NOTHING;

INSERT INTO delivery_offers (
  offer_id, order_id, delivery_id, driver_id, status, offered_at, responded_at, expires_in_sec, decline_reason
)
VALUES
  ('26262626-2626-4262-8262-262626262611', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'OFFERED', NOW() - INTERVAL '15 minutes', NULL, 300, NULL),
  ('26262626-2626-4262-8262-262626262612', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', 'OFFERED', NOW() - INTERVAL '15 minutes', NULL, 300, NULL),
  ('26262626-2626-4262-8262-262626262613', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'OFFERED', NOW() - INTERVAL '15 minutes', NULL, 300, NULL)
ON CONFLICT (offer_id) DO NOTHING;

INSERT INTO delivery_status_events (event_id, delivery_id, driver_id, status, event_time, note, lat, lng)
VALUES
  ('ffffffff-ffff-ffff-ffff-fffffffffff1', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'ASSIGNED', NOW() - INTERVAL '2 hours 40 minutes', 'Driver accepted offer', 39.7587, -84.1916),
  ('ffffffff-ffff-ffff-ffff-fffffffffff2', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'DELIVERED', NOW() - INTERVAL '2 hours', 'Delivered to concierge', 40.7090, -74.0112),
  ('ffffffff-ffff-ffff-ffff-fffffffffff3', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', 'DELIVERED', NOW() - INTERVAL '22 hours 40 minutes', 'Completed at the front desk', 40.7332, -74.0626),
  ('ffffffff-ffff-ffff-ffff-fffffffffff4', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '25 minutes', 'Approaching destination', 40.7526, -73.9772),
  ('ffffffff-ffff-ffff-ffff-fffffffffff5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4', 'cccccccc-cccc-cccc-cccc-ccccccccccc5', 'ASSIGNED', NOW() - INTERVAL '35 minutes', 'Waiting for pickup', 40.7357, -74.1724)
ON CONFLICT (event_id) DO NOTHING;

INSERT INTO payments (
  payment_id, order_id, customer_id, provider, provider_ref, amount_cents, currency, status, created_at
)
VALUES
  ('27272727-2727-4272-8272-272727272711', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'mock', 'pay-10001', 6499, 'USD', 'AUTHORIZED', NOW() - INTERVAL '3 hours'),
  ('27272727-2727-4272-8272-272727272712', 'dddddddd-dddd-dddd-dddd-ddddddddddd2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'mock', 'pay-10002', 4699, 'USD', 'AUTHORIZED', NOW() - INTERVAL '1 day'),
  ('27272727-2727-4272-8272-272727272713', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'mock', 'pay-10003', 7499, 'USD', 'AUTHORIZED', NOW() - INTERVAL '90 minutes'),
  ('27272727-2727-4272-8272-272727272714', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'mock', 'pay-10004', 5899, 'USD', 'AUTHORIZED', NOW() - INTERVAL '70 minutes'),
  ('27272727-2727-4272-8272-272727272715', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'mock', 'pay-10005', 3799, 'USD', 'AUTHORIZED', NOW() - INTERVAL '35 minutes')
ON CONFLICT (payment_id) DO NOTHING;

INSERT INTO support_tickets (
  ticket_id, customer_id, order_id, issue_type, message, status, created_at, updated_at
)
VALUES
  ('28282828-2828-4282-8282-282828282811', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'dddddddd-dddd-dddd-dddd-ddddddddddd1', 'DELIVERY_CONFIRMATION', 'Customer requested confirmation that the concierge received the order.', 'Resolved', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '90 minutes'),
  ('28282828-2828-4282-8282-282828282812', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'LATE_DELIVERY', 'Traffic is causing delivery concern on the current route.', 'Open', NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '20 minutes')
ON CONFLICT (ticket_id) DO NOTHING;

INSERT INTO driver_support_tickets (
  ticket_id, driver_id, delivery_id, order_id, issue_type, message, status, created_at, updated_at
)
VALUES
  ('29292929-2929-4292-8292-292929292911', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3', 'dddddddd-dddd-dddd-dddd-ddddddddddd3', 'TRAFFIC_DELAY', 'Heavy midtown traffic is slowing the active route.', 'In review', NOW() - INTERVAL '20 minutes', NOW() - INTERVAL '10 minutes'),
  ('29292929-2929-4292-8292-292929292912', 'cccccccc-cccc-cccc-cccc-ccccccccccc5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4', 'dddddddd-dddd-dddd-dddd-ddddddddddd4', 'PICKUP_READINESS', 'Store staging team is still wrapping the order.', 'Open', NOW() - INTERVAL '18 minutes', NOW() - INTERVAL '12 minutes')
ON CONFLICT (ticket_id) DO NOTHING;

INSERT INTO driver_earnings (
  earning_id, driver_id, delivery_id, base_pay_cents, bonus_cents, tip_cents,
  adjustments_cents, total_pay_cents, currency, status, created_at
)
VALUES
  ('30303030-3030-4030-8030-303030303011', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 1800, 200, 500, 0, 2500, 'USD', 'PENDING', NOW() - INTERVAL '90 minutes'),
  ('30303030-3030-4030-8030-303030303012', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2', 1700, 0, 300, 0, 2000, 'USD', 'PAID', NOW() - INTERVAL '23 hours')
ON CONFLICT (earning_id) DO NOTHING;

INSERT INTO driver_payouts (
  payout_id, driver_id, amount_cents, currency, status, provider, provider_ref, created_at
)
VALUES
  ('31313131-3131-4131-8131-313131313111', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 2500, 'USD', 'PENDING', 'mock', 'payout-10001', NOW() - INTERVAL '45 minutes'),
  ('31313131-3131-4131-8131-313131313112', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', 2000, 'USD', 'PAID', 'mock', 'payout-10002', NOW() - INTERVAL '20 hours')
ON CONFLICT (payout_id) DO NOTHING;
