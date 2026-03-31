-- ============================================================
-- Local-development seed data (efficient, deterministic, idempotent)
-- Loaded by the separate `db-seed` compose service.
-- ============================================================

-- Deterministic UUID helper for repeatable seeds.
CREATE OR REPLACE FUNCTION pg_temp.seed_uuid(seed TEXT)
RETURNS UUID
LANGUAGE SQL
IMMUTABLE
AS $$
  SELECT (
    substr(md5(seed), 1, 8) || '-' ||
    substr(md5(seed), 9, 4) || '-' ||
    substr(md5(seed), 13, 4) || '-' ||
    substr(md5(seed), 17, 4) || '-' ||
    substr(md5(seed), 21, 12)
  )::uuid;
$$;

-- Retailers (20 total)
CREATE TEMP TABLE seed_retailers ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, '11111111-1111-1111-1111-111111111113'::uuid, 'Walmart',    'https://www.walmart.com',     TRUE, NOW() - INTERVAL '18 days'),
    (2, '11111111-1111-1111-1111-111111111114'::uuid, 'Target',     'https://www.target.com',      TRUE, NOW() - INTERVAL '17 days')
) AS base(n, retailer_id, name, website, is_enabled, created_at)
UNION ALL
SELECT
  n + 2,
  pg_temp.seed_uuid('retailer-extra-' || n::text),
  CASE WHEN n % 2 = 0 THEN 'Walmart Mock Store ' ELSE 'Target Mock Store ' END || lpad(n::text, 2, '0'),
  CASE WHEN n % 2 = 0 THEN 'https://walmart-mock-' ELSE 'https://target-mock-' END || n::text || '.example',
  TRUE,
  NOW() - make_interval(days => 18 - n)
FROM generate_series(1, 18) AS gs(n);

INSERT INTO retailers (retailer_id, name, website, is_enabled, created_at)
SELECT retailer_id, name, website, is_enabled, created_at
FROM seed_retailers
ON CONFLICT DO NOTHING;

-- Customers (25 total)
CREATE TEMP TABLE seed_customers ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'::uuid, 'ava.johnson@example.com',      '+1-555-101-0001', 'Ava Johnson',       '$2b$10$dummyhashcustomer01', TRUE, NOW() - INTERVAL '30 days', NOW()),
    (2, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'::uuid, 'liam.carter@example.com',      '+1-555-101-0002', 'Liam Carter',       '$2b$10$dummyhashcustomer02', TRUE, NOW() - INTERVAL '28 days', NOW()),
    (3, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3'::uuid, 'mia.nguyen@example.com',       '+1-555-101-0003', 'Mia Nguyen',        '$2b$10$dummyhashcustomer03', TRUE, NOW() - INTERVAL '24 days', NOW()),
    (4, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4'::uuid, 'noah.baker@example.com',       '+1-555-101-0004', 'Noah Baker',        '$2b$10$dummyhashcustomer04', TRUE, NOW() - INTERVAL '20 days', NOW()),
    (5, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5'::uuid, 'olivia.hernandez@example.com', '+1-555-101-0005', 'Olivia Hernandez',  '$2b$10$dummyhashcustomer05', TRUE, NOW() - INTERVAL '18 days', NOW())
) AS base(n, customer_id, email, phone, full_name, password_hash, is_active, created_at, updated_at)
UNION ALL
SELECT
  n,
  pg_temp.seed_uuid('customer-' || n::text),
  'seed.customer' || lpad(n::text, 2, '0') || '@example.com',
  '+1-555-101-' || lpad((1000 + n)::text, 4, '0'),
  'Seed Customer ' || lpad(n::text, 2, '0'),
  '$2b$10$seedhashcustomer' || lpad(n::text, 2, '0'),
  TRUE,
  NOW() - make_interval(days => n),
  NOW() - make_interval(hours => n)
FROM generate_series(6, 25) AS gs(n);

INSERT INTO customers (customer_id, email, phone, full_name, password_hash, is_active, created_at, updated_at)
SELECT customer_id, email, phone, full_name, password_hash, is_active, created_at, updated_at
FROM seed_customers
ON CONFLICT DO NOTHING;

-- Addresses (25 total)
CREATE TEMP TABLE seed_addresses ON COMMIT DROP AS
SELECT
  c.n,
  CASE c.n
    WHEN 1 THEN 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1'::uuid
    WHEN 2 THEN 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2'::uuid
    WHEN 3 THEN 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3'::uuid
    WHEN 4 THEN 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4'::uuid
    WHEN 5 THEN 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5'::uuid
    ELSE pg_temp.seed_uuid('address-' || c.n::text)
  END AS address_id,
  c.customer_id,
  'Home'::text AS label,
  (100 + c.n)::text || ' Seedline Ave' AS line1,
  CASE WHEN c.n % 3 = 0 THEN 'Unit ' || (10 + c.n)::text ELSE NULL END AS line2,
  CASE WHEN c.n % 2 = 0 THEN 'Brooklyn' ELSE 'Jersey City' END AS city,
  CASE WHEN c.n % 2 = 0 THEN 'NY' ELSE 'NJ' END AS state,
  lpad((10000 + c.n * 7)::text, 5, '0') AS postal_code,
  'USA'::text AS country,
  CASE WHEN c.n % 2 = 0 THEN 'Leave at door' ELSE 'Ring bell once' END AS instructions,
  TRUE AS is_default,
  NOW() - make_interval(days => c.n - 1) AS created_at
FROM seed_customers c;

INSERT INTO addresses (address_id, customer_id, label, line1, line2, city, state, postal_code, country, instructions, is_default, created_at)
SELECT address_id, customer_id, label, line1, line2, city, state, postal_code, country, instructions, is_default, created_at
FROM seed_addresses
ON CONFLICT DO NOTHING;

-- Drivers (25 total)
CREATE TEMP TABLE seed_drivers ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, 'cccccccc-cccc-cccc-cccc-ccccccccccc1'::uuid, 'ethan.driver@example.com',    '+1-555-202-0001', 'Ethan Brooks',  '$2b$10$dummyhashdriver01', TRUE, 'ONLINE',  NOW() - INTERVAL '40 days', NOW()),
    (2, 'cccccccc-cccc-cccc-cccc-ccccccccccc2'::uuid, 'sophia.driver@example.com',   '+1-555-202-0002', 'Sophia Patel',  '$2b$10$dummyhashdriver02', TRUE, 'ONLINE',  NOW() - INTERVAL '35 days', NOW()),
    (3, 'cccccccc-cccc-cccc-cccc-ccccccccccc3'::uuid, 'jacob.driver@example.com',    '+1-555-202-0003', 'Jacob Kim',     '$2b$10$dummyhashdriver03', TRUE, 'OFFLINE', NOW() - INTERVAL '31 days', NOW()),
    (4, 'cccccccc-cccc-cccc-cccc-ccccccccccc4'::uuid, 'isabella.driver@example.com', '+1-555-202-0004', 'Isabella Reed', '$2b$10$dummyhashdriver04', TRUE, 'ONLINE',  NOW() - INTERVAL '26 days', NOW()),
    (5, 'cccccccc-cccc-cccc-cccc-ccccccccccc5'::uuid, 'mason.driver@example.com',    '+1-555-202-0005', 'Mason Flores',  '$2b$10$dummyhashdriver05', TRUE, 'BUSY',    NOW() - INTERVAL '21 days', NOW())
) AS base(n, driver_id, email, phone, full_name, password_hash, is_active, status, created_at, updated_at)
UNION ALL
SELECT
  n,
  pg_temp.seed_uuid('driver-' || n::text),
  'seed.driver' || lpad(n::text, 2, '0') || '@example.com',
  '+1-555-202-' || lpad((2000 + n)::text, 4, '0'),
  'Seed Driver ' || lpad(n::text, 2, '0'),
  '$2b$10$seedhashdriver' || lpad(n::text, 2, '0'),
  TRUE,
  CASE n % 3 WHEN 0 THEN 'OFFLINE' WHEN 1 THEN 'ONLINE' ELSE 'BUSY' END,
  NOW() - make_interval(days => n + 2),
  NOW() - make_interval(hours => n)
FROM generate_series(6, 25) AS gs(n);

INSERT INTO drivers (driver_id, email, phone, full_name, password_hash, is_active, status, created_at, updated_at)
SELECT driver_id, email, phone, full_name, password_hash, is_active, status, created_at, updated_at
FROM seed_drivers
ON CONFLICT DO NOTHING;

-- Retailer accounts (20 total)
CREATE TEMP TABLE seed_retailer_accounts ON COMMIT DROP AS
SELECT
  n,
  CASE n
    WHEN 1 THEN 'abababab-abab-abab-abab-abababababa1'::uuid
    WHEN 2 THEN 'abababab-abab-abab-abab-abababababa2'::uuid
    WHEN 3 THEN 'abababab-abab-abab-abab-abababababa3'::uuid
    WHEN 4 THEN 'abababab-abab-abab-abab-abababababa4'::uuid
    ELSE pg_temp.seed_uuid('retailer-account-' || n::text)
  END AS retailer_account_id,
  c.customer_id,
  CASE WHEN n % 2 = 0 THEN '11111111-1111-1111-1111-111111111113'::uuid ELSE '11111111-1111-1111-1111-111111111114'::uuid END AS retailer_id,
  (n % 5) <> 0 AS is_connected,
  CASE
    WHEN (n % 5) = 0 THEN NULL
    WHEN n % 2 = 0 THEN 'wmrt-dev-key'
    ELSE 'tgt-dev-key'
  END AS access_token,
  CASE WHEN (n % 5) <> 0 THEN 'mock-refresh-token-' || n::text ELSE NULL END AS refresh_token,
  CASE WHEN (n % 5) <> 0 THEN NOW() + make_interval(days => 14 + n) ELSE NULL END AS token_expires_at,
  NOW() - make_interval(days => n) AS created_at,
  NOW() - make_interval(hours => n) AS updated_at
FROM seed_customers c
WHERE c.n <= 20;

INSERT INTO retailer_accounts (
  retailer_account_id, customer_id, retailer_id, is_connected, access_token, refresh_token,
  token_expires_at, created_at, updated_at
)
SELECT
  retailer_account_id, customer_id, retailer_id, is_connected, access_token, refresh_token,
  token_expires_at, created_at, updated_at
FROM seed_retailer_accounts
ON CONFLICT DO NOTHING;

-- Product categories (30 total)
CREATE TEMP TABLE seed_categories ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, '22222222-2222-2222-2222-222222222221'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, 'Produce',       'WM-PRODUCE',      NOW() - INTERVAL '1 day'),
    (2, '22222222-2222-2222-2222-222222222222'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, 'Dairy & Eggs',  'WM-DAIRY',        NOW() - INTERVAL '1 day'),
    (3, '22222222-2222-2222-2222-222222222223'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, 'Pantry Staples','WM-PANTRY',       NOW() - INTERVAL '1 day'),
    (4, '22222222-2222-2222-2222-222222222224'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, 'Fresh Produce', 'TGT-PRODUCE',     NOW() - INTERVAL '1 day'),
    (5, '22222222-2222-2222-2222-222222222225'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, 'Snacks',        'TGT-SNACKS',      NOW() - INTERVAL '1 day'),
    (6, '22222222-2222-2222-2222-222222222226'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, 'Beverages',     'TGT-BEVERAGES',   NOW() - INTERVAL '1 day')
) AS base(n, category_id, retailer_id, name, external_category_id, updated_at)
UNION ALL
SELECT
  n,
  pg_temp.seed_uuid('category-' || n::text),
  CASE WHEN n % 2 = 0 THEN '11111111-1111-1111-1111-111111111113'::uuid ELSE '11111111-1111-1111-1111-111111111114'::uuid END,
  'Mock Category ' || lpad(n::text, 2, '0'),
  'MOCK-CAT-' || lpad(n::text, 3, '0'),
  NOW() - make_interval(hours => n)
FROM generate_series(7, 30) AS gs(n);

INSERT INTO product_categories (category_id, retailer_id, name, external_category_id, updated_at)
SELECT category_id, retailer_id, name, external_category_id, updated_at
FROM seed_categories
ON CONFLICT DO NOTHING;

-- Products (60 total, local image paths)
CREATE TEMP TABLE seed_products ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1,  '33333333-3333-3333-3333-333333333331'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, '22222222-2222-2222-2222-222222222221'::uuid, 'WM-TOM-001', 'Roma Tomatoes (1 lb)',               'Fresh roma tomatoes sold by the pound.',           '/images/products/mock-product-01.png', 229, 'USD', TRUE,  NOW() - INTERVAL '2 hours'),
    (2,  '33333333-3333-3333-3333-333333333332'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, '22222222-2222-2222-2222-222222222221'::uuid, 'WM-BAN-001', 'Bananas (2 lb bunch)',                'Sweet bananas, average 2 lb bunch.',               '/images/products/mock-product-02.png', 189, 'USD', TRUE,  NOW() - INTERVAL '2 hours'),
    (3,  '33333333-3333-3333-3333-333333333333'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'WM-EGG-018', 'Large Eggs (18 ct)',                 'Grade A large eggs, 18 count.',                    '/images/products/mock-product-03.png', 499, 'USD', TRUE,  NOW() - INTERVAL '90 minutes'),
    (4,  '33333333-3333-3333-3333-333333333334'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, '22222222-2222-2222-2222-222222222223'::uuid, 'WM-RIC-005', 'Long Grain Rice (5 lb)',             'Enriched long grain white rice.',                  '/images/products/mock-product-04.png', 879, 'USD', TRUE,  NOW() - INTERVAL '90 minutes'),
    (5,  '33333333-3333-3333-3333-333333333335'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, '22222222-2222-2222-2222-222222222223'::uuid, 'WM-PAS-001', 'Spaghetti Pasta (16 oz)',            'Durum wheat spaghetti pasta.',                     '/images/products/mock-product-05.png', 169, 'USD', TRUE,  NOW() - INTERVAL '90 minutes'),
    (6,  '33333333-3333-3333-3333-333333333336'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, '22222222-2222-2222-2222-222222222222'::uuid, 'WM-MIL-1G',  'Whole Milk (1 gal)',                 'Vitamin D whole milk.',                            '/images/products/mock-product-06.png', 429, 'USD', FALSE, NOW() - INTERVAL '1 hour'),
    (7,  '33333333-3333-3333-3333-333333333337'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, '22222222-2222-2222-2222-222222222224'::uuid, '10000001',    'Laundry Detergent 92oz',            'Target mock inventory item (tcin 10000001).',     '/images/products/mock-product-07.png', 1499, 'USD', TRUE,  NOW() - INTERVAL '2 hours'),
    (8,  '33333333-3333-3333-3333-333333333338'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, '22222222-2222-2222-2222-222222222225'::uuid, '10000002',    'Trash Bags 40ct',                   'Target mock inventory item (tcin 10000002).',     '/images/products/mock-product-08.png', 1149, 'USD', TRUE,  NOW() - INTERVAL '2 hours'),
    (9,  '33333333-3333-3333-3333-333333333339'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, '22222222-2222-2222-2222-222222222226'::uuid, '10000003',    'Dish Soap 2-Pack',                  'Target mock inventory item (tcin 10000003).',     '/images/products/mock-product-09.png', 679, 'USD', FALSE, NOW() - INTERVAL '70 minutes'),
    (10, '33333333-3333-3333-3333-33333333333a'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, '22222222-2222-2222-2222-222222222225'::uuid, 'TGT-GRA-006', 'Granola Bars Variety (12 ct)',       'Chewy granola bars assortment pack.',              '/images/products/mock-product-10.png', 629, 'USD', TRUE,  NOW() - INTERVAL '70 minutes'),
    (11, '33333333-3333-3333-3333-33333333333b'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, '22222222-2222-2222-2222-222222222226'::uuid, 'TGT-SPK-008', 'Sparkling Water Lime (8 pk)',        'Lime flavored sparkling water.',                   '/images/products/mock-product-11.png', 469, 'USD', TRUE,  NOW() - INTERVAL '50 minutes'),
    (12, '33333333-3333-3333-3333-33333333333c'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, '22222222-2222-2222-2222-222222222226'::uuid, 'TGT-COL-12',  'Cola (12 pack)',                     '12-pack canned cola beverage.',                    '/images/products/mock-product-12.png', 799, 'USD', FALSE, NOW() - INTERVAL '50 minutes')
) AS base(n, product_id, retailer_id, category_id, external_sku, name, description, image_url, unit_price_cents, currency, is_available, updated_at)
UNION ALL
SELECT
  n,
  pg_temp.seed_uuid('product-' || n::text),
  c.retailer_id,
  c.category_id,
  CASE
    WHEN c.retailer_id = '11111111-1111-1111-1111-111111111114'::uuid
      THEN lpad((10000000 + n)::text, 8, '0')
    ELSE 'WM-SKU-' || lpad(n::text, 4, '0')
  END,
  'Mock Product ' || lpad(n::text, 3, '0'),
  'Generated seed item for mock retailer browsing and checkout flows.',
  '/images/products/mock-product-' || lpad((((n - 1) % 12) + 1)::text, 2, '0') || '.png',
  149 + (n * 37),
  'USD',
  (n % 9) <> 0,
  NOW() - make_interval(minutes => n * 3)
FROM generate_series(13, 60) AS gs(n)
JOIN LATERAL (
  SELECT category_id, retailer_id
  FROM seed_categories sc
  WHERE sc.n = ((n - 1) % 30) + 1
) c ON TRUE;

INSERT INTO products (
  product_id, retailer_id, category_id, external_sku, name, description, image_url,
  unit_price_cents, currency, is_available, updated_at
)
SELECT
  product_id, retailer_id, category_id, external_sku, name, description, image_url,
  unit_price_cents, currency, is_available, updated_at
FROM seed_products
ON CONFLICT DO NOTHING;

-- Orders (25 total)
CREATE TEMP TABLE seed_orders ON COMMIT DROP AS
SELECT
  n,
  CASE n
    WHEN 1 THEN 'dddddddd-dddd-dddd-dddd-ddddddddddd1'::uuid
    WHEN 2 THEN 'dddddddd-dddd-dddd-dddd-ddddddddddd2'::uuid
    WHEN 3 THEN 'dddddddd-dddd-dddd-dddd-ddddddddddd3'::uuid
    WHEN 4 THEN 'dddddddd-dddd-dddd-dddd-ddddddddddd4'::uuid
    WHEN 5 THEN 'dddddddd-dddd-dddd-dddd-ddddddddddd5'::uuid
    ELSE pg_temp.seed_uuid('order-' || n::text)
  END AS order_id,
  c.customer_id,
  a.address_id,
  CASE
    WHEN n % 2 = 0 THEN '11111111-1111-1111-1111-111111111113'::uuid
    ELSE '11111111-1111-1111-1111-111111111114'::uuid
  END AS retailer_id,
  CASE (n % 4)
    WHEN 3 THEN 'WM-PO-' || lpad((700000 + n)::text, 7, '0')
    WHEN 0 THEN 'TGT-' || upper(substr(md5('tgt-order-' || n::text), 1, 10))
    ELSE 'ORD-' || lpad((10000 + n)::text, 5, '0')
  END AS external_order_id,
  CASE n % 5 WHEN 0 THEN 'PLACED' WHEN 1 THEN 'ASSIGNED' WHEN 2 THEN 'IN_TRANSIT' WHEN 3 THEN 'DELIVERED' ELSE 'SUBMITTED' END AS status,
  NOW() - make_interval(hours => n * 2) AS placed_at,
  2500 + (n * 125) AS subtotal_cents,
  399 + (n * 12) AS fees_cents,
  200 + (n * 15) AS tip_cents,
  CASE WHEN n % 4 = 0 THEN 300 ELSE 0 END AS discount_cents,
  (2500 + (n * 125)) + (399 + (n * 12)) + (200 + (n * 15)) - CASE WHEN n % 4 = 0 THEN 300 ELSE 0 END AS total_cents,
  'USD'::text AS currency,
  'Generated seed order #' || n::text AS delivery_notes,
  NOW() - make_interval(hours => n * 2) AS created_at,
  NOW() - make_interval(minutes => n * 5) AS updated_at
FROM seed_customers c
JOIN seed_addresses a ON a.n = c.n
WHERE c.n <= 25;

INSERT INTO orders (
  order_id, customer_id, retailer_id, address_id, external_order_id, status, placed_at,
  subtotal_cents, fees_cents, tip_cents, discount_cents, total_cents, currency, delivery_notes, created_at, updated_at
)
SELECT
  order_id, customer_id, retailer_id, address_id, external_order_id, status, placed_at,
  subtotal_cents, fees_cents, tip_cents, discount_cents, total_cents, currency, delivery_notes, created_at, updated_at
FROM seed_orders
ON CONFLICT DO NOTHING;

-- Delivery assignments (25 total)
CREATE TEMP TABLE seed_deliveries ON COMMIT DROP AS
SELECT
  n,
  CASE n
    WHEN 1 THEN 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1'::uuid
    WHEN 2 THEN 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2'::uuid
    WHEN 3 THEN 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3'::uuid
    WHEN 4 THEN 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4'::uuid
    WHEN 5 THEN 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5'::uuid
    ELSE pg_temp.seed_uuid('delivery-' || n::text)
  END AS delivery_id,
  o.order_id,
  CASE WHEN n % 5 = 0 THEN NULL ELSE d.driver_id END AS driver_id,
  CASE n % 5 WHEN 0 THEN 'PENDING_ASSIGNMENT' WHEN 1 THEN 'ASSIGNED' WHEN 2 THEN 'PICKED_UP' WHEN 3 THEN 'IN_TRANSIT' ELSE 'DELIVERED' END AS status,
  CASE WHEN o.retailer_id = '11111111-1111-1111-1111-111111111113'::uuid
    THEN 'Walmart Mock Pickup Hub'
    ELSE 'Target Mock Pickup Hub'
  END AS pickup_location,
  NOW() - make_interval(hours => n * 2 - 1) AS assigned_at,
  CASE WHEN n % 5 IN (2, 3, 4) THEN NOW() - make_interval(hours => n * 2 - 2) ELSE NULL END AS picked_up_at,
  CASE WHEN n % 5 = 4 THEN NOW() - make_interval(hours => n * 2 - 3) ELSE NULL END AS delivered_at
FROM seed_orders o
JOIN seed_drivers d ON d.n = o.n
WHERE o.n <= 25;

INSERT INTO delivery_assignments (
  delivery_id, order_id, driver_id, status, pickup_location, assigned_at, picked_up_at, delivered_at
)
SELECT
  delivery_id, order_id, driver_id, status, pickup_location, assigned_at, picked_up_at, delivered_at
FROM seed_deliveries
ON CONFLICT DO NOTHING;

-- Delivery status events (25 total)
INSERT INTO delivery_status_events (event_id, delivery_id, driver_id, status, event_time, note, lat, lng)
SELECT
  CASE n
    WHEN 1 THEN 'ffffffff-ffff-ffff-ffff-fffffffffff1'::uuid
    WHEN 2 THEN 'ffffffff-ffff-ffff-ffff-fffffffffff2'::uuid
    WHEN 3 THEN 'ffffffff-ffff-ffff-ffff-fffffffffff3'::uuid
    WHEN 4 THEN 'ffffffff-ffff-ffff-ffff-fffffffffff4'::uuid
    WHEN 5 THEN 'ffffffff-ffff-ffff-ffff-fffffffffff5'::uuid
    ELSE pg_temp.seed_uuid('event-' || n::text)
  END AS event_id,
  delivery_id,
  driver_id,
  status,
  NOW() - make_interval(hours => n) AS event_time,
  'Generated seed event for delivery #' || n::text AS note,
  40.6000 + (n * 0.01) AS lat,
  -74.2000 + (n * 0.01) AS lng
FROM seed_deliveries
ON CONFLICT DO NOTHING;
