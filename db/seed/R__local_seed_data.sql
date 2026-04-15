-- ============================================================
-- Local-development seed data (efficient, deterministic, idempotent)
-- Loaded by the separate `db-seed` compose service.
-- ============================================================

-- Keep ON COMMIT DROP temp tables alive until all dependent inserts finish.
BEGIN;

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
    (1, '11111111-1111-1111-1111-111111111111'::uuid, 'FreshMart',    'https://freshmart.example',     TRUE, NOW() - INTERVAL '20 days'),
    (2, '11111111-1111-1111-1111-111111111112'::uuid, 'QuickGrocer',  'https://quickgrocer.example',   TRUE, NOW() - INTERVAL '19 days'),
    (3, '11111111-1111-1111-1111-111111111113'::uuid, 'Walmart',      'https://www.walmart.com',       TRUE, NOW() - INTERVAL '18 days'),
    (4, '11111111-1111-1111-1111-111111111114'::uuid, 'Target',       'https://www.target.com',        TRUE, NOW() - INTERVAL '17 days')
) AS base(n, retailer_id, name, website, is_enabled, created_at)
UNION ALL
SELECT
  n + 4,
  pg_temp.seed_uuid('retailer-extra-' || n::text),
  CASE WHEN n % 2 = 0 THEN 'Walmart Mock Store ' ELSE 'Target Mock Store ' END || lpad(n::text, 2, '0'),
  CASE WHEN n % 2 = 0 THEN 'https://walmart-mock-' ELSE 'https://target-mock-' END || n::text || '.example',
  TRUE,
  NOW() - make_interval(days => 16 - n)
FROM generate_series(1, 16) AS gs(n);

INSERT INTO retailers (retailer_id, name, website, is_enabled, created_at)
SELECT retailer_id, name, website, is_enabled, created_at
FROM seed_retailers
ON CONFLICT DO NOTHING;

-- Platform-owned partnered pickup locations that the mobile apps can browse.
CREATE TEMP TABLE seed_retailer_locations ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, '12121212-1212-4212-8212-121212121211'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'FM-1001', 'FreshMart Downtown', '10 Main St', NULL::text, 'Dayton', 'OH', '45402', 'USA', 39.7587, -84.1916, TRUE, NOW() - INTERVAL '14 days', NOW()),
    (2, '12121212-1212-4212-8212-121212121212'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, 'FM-1002', 'FreshMart Riverside', '220 Riverside Dr', NULL::text, 'Dayton', 'OH', '45405', 'USA', 39.7836, -84.2057, TRUE, NOW() - INTERVAL '14 days', NOW()),
    (3, '13131313-1313-4313-8313-131313131311'::uuid, '11111111-1111-1111-1111-111111111112'::uuid, 'QG-2001', 'QuickGrocer Journal Sq', '55 Grove St', NULL::text, 'Jersey City', 'NJ', '07302', 'USA', 40.7332, -74.0626, TRUE, NOW() - INTERVAL '14 days', NOW()),
    (4, '13131313-1313-4313-8313-131313131312'::uuid, '11111111-1111-1111-1111-111111111112'::uuid, 'QG-2002', 'QuickGrocer Newark', '88 Market St', NULL::text, 'Newark', 'NJ', '07102', 'USA', 40.7357, -74.1724, TRUE, NOW() - INTERVAL '14 days', NOW()),
    (5, '14141414-1414-4414-8414-141414141411'::uuid, '11111111-1111-1111-1111-111111111113'::uuid, 'WM-3001', 'Walmart Mock Pickup Hub', '410 Commerce Blvd', NULL::text, 'Brooklyn', 'NY', '11201', 'USA', 40.6950, -73.9900, TRUE, NOW() - INTERVAL '14 days', NOW()),
    (6, '15151515-1515-4515-8515-151515151511'::uuid, '11111111-1111-1111-1111-111111111114'::uuid, 'TGT-4001', 'Target Mock Pickup Hub', '900 Market Ave', NULL::text, 'Jersey City', 'NJ', '07302', 'USA', 40.7282, -74.0776, TRUE, NOW() - INTERVAL '14 days', NOW())
) AS base(
  n, retailer_location_id, retailer_id, external_store_id, name, address_line1, address_line2,
  city, state, postal_code, country, lat, lng, is_active, created_at, updated_at
)
UNION ALL
SELECT
  r.n + 6,
  pg_temp.seed_uuid('retailer-location-' || r.n::text),
  r.retailer_id,
  'MOCK-' || lpad(r.n::text, 4, '0'),
  r.name || ' Pickup Hub',
  (500 + r.n)::text || ' Partner Way',
  NULL::text,
  CASE WHEN r.n % 2 = 0 THEN 'Brooklyn' ELSE 'Jersey City' END,
  CASE WHEN r.n % 2 = 0 THEN 'NY' ELSE 'NJ' END,
  lpad((10000 + r.n * 11)::text, 5, '0'),
  'USA',
  40.6000 + (r.n * 0.01),
  -74.2000 + (r.n * 0.01),
  TRUE,
  NOW() - make_interval(days => r.n),
  NOW() - make_interval(hours => r.n)
FROM seed_retailers r
WHERE r.n > 4;

INSERT INTO retailer_locations (
  retailer_location_id, retailer_id, external_store_id, name, address_line1, address_line2,
  city, state, postal_code, country, lat, lng, is_active, created_at, updated_at
)
SELECT
  retailer_location_id, retailer_id, external_store_id, name, address_line1, address_line2,
  city, state, postal_code, country, lat, lng, is_active, created_at, updated_at
FROM seed_retailer_locations
ON CONFLICT DO NOTHING;

-- Customers (25 total)
-- The first seeded logins use plain-text passwords while MVP hashing is pending.
CREATE TEMP TABLE seed_customers ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'::uuid, 'ava.johnson@example.com',      '+1-555-101-0001', 'Ava Johnson',       'customer-pass-1', TRUE, NOW() - INTERVAL '30 days', NOW()),
    (2, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'::uuid, 'liam.carter@example.com',      '+1-555-101-0002', 'Liam Carter',       'customer-pass-2', TRUE, NOW() - INTERVAL '28 days', NOW()),
    (3, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3'::uuid, 'mia.nguyen@example.com',       '+1-555-101-0003', 'Mia Nguyen',        'customer-pass-3', TRUE, NOW() - INTERVAL '24 days', NOW()),
    (4, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4'::uuid, 'noah.baker@example.com',       '+1-555-101-0004', 'Noah Baker',        'customer-pass-4', TRUE, NOW() - INTERVAL '20 days', NOW()),
    (5, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5'::uuid, 'olivia.hernandez@example.com', '+1-555-101-0005', 'Olivia Hernandez',  'customer-pass-5', TRUE, NOW() - INTERVAL '18 days', NOW())
) AS base(n, customer_id, email, phone, full_name, password_hash, is_active, created_at, updated_at)
UNION ALL
SELECT
  n,
  pg_temp.seed_uuid('customer-' || n::text),
  'seed.customer' || lpad(n::text, 2, '0') || '@example.com',
  '+1-555-101-' || lpad((1000 + n)::text, 4, '0'),
  'Seed Customer ' || lpad(n::text, 2, '0'),
  'customer-pass-' || n::text,
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
  CASE c.n
    WHEN 1 THEN 'Head Office'
    WHEN 2 THEN 'Studio'
    WHEN 3 THEN 'Warehouse'
    WHEN 4 THEN 'Bakery'
    WHEN 5 THEN 'Lobby Drop'
    ELSE 'Home'
  END AS label,
  CASE c.n
    WHEN 1 THEN '123 Maple St'
    WHEN 2 THEN '55 King Ave'
    WHEN 3 THEN '880 Pine Rd'
    WHEN 4 THEN '742 Oak Dr'
    WHEN 5 THEN '91 River Pl'
    ELSE (100 + c.n)::text || ' Seedline Ave'
  END AS line1,
  CASE c.n
    WHEN 1 THEN 'Apt 4B'
    WHEN 4 THEN 'Unit 12'
    ELSE CASE WHEN c.n % 3 = 0 THEN 'Unit ' || (10 + c.n)::text ELSE NULL END
  END AS line2,
  CASE c.n
    WHEN 1 THEN 'Brooklyn'
    WHEN 2 THEN 'Jersey City'
    WHEN 3 THEN 'Queens'
    WHEN 4 THEN 'Newark'
    WHEN 5 THEN 'Hoboken'
    ELSE CASE WHEN c.n % 2 = 0 THEN 'Brooklyn' ELSE 'Jersey City' END
  END AS city,
  CASE c.n
    WHEN 1 THEN 'NY'
    WHEN 2 THEN 'NJ'
    WHEN 3 THEN 'NY'
    WHEN 4 THEN 'NJ'
    WHEN 5 THEN 'NJ'
    ELSE CASE WHEN c.n % 2 = 0 THEN 'NY' ELSE 'NJ' END
  END AS state,
  CASE c.n
    WHEN 1 THEN '11201'
    WHEN 2 THEN '07302'
    WHEN 3 THEN '11368'
    WHEN 4 THEN '07102'
    WHEN 5 THEN '07030'
    ELSE lpad((10000 + c.n * 7)::text, 5, '0')
  END AS postal_code,
  'USA'::text AS country,
  CASE c.n
    WHEN 1 THEN 'Leave at front desk'
    WHEN 2 THEN 'Ring once'
    WHEN 3 THEN 'Call on arrival'
    WHEN 4 THEN 'Use side entrance'
    WHEN 5 THEN 'Lobby drop-off'
    ELSE CASE WHEN c.n % 2 = 0 THEN 'Leave at door' ELSE 'Ring bell once' END
  END AS instructions,
  TRUE AS is_default,
  NOW() - make_interval(days => c.n - 1) AS created_at
FROM seed_customers c;

INSERT INTO addresses (address_id, customer_id, label, line1, line2, city, state, postal_code, country, instructions, is_default, created_at)
SELECT address_id, customer_id, label, line1, line2, city, state, postal_code, country, instructions, is_default, created_at
FROM seed_addresses
ON CONFLICT DO NOTHING;

-- Drivers (25 total)
-- Driver status is constrained to ONLINE/OFFLINE after V5.
CREATE TEMP TABLE seed_drivers ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, 'cccccccc-cccc-cccc-cccc-ccccccccccc1'::uuid, 'ethan.driver@example.com',    '+1-555-202-0001', 'Ethan Brooks',  'driver-pass-1', TRUE, 'ONLINE',  NOW() - INTERVAL '40 days', NOW()),
    (2, 'cccccccc-cccc-cccc-cccc-ccccccccccc2'::uuid, 'sophia.driver@example.com',   '+1-555-202-0002', 'Sophia Patel',  'driver-pass-2', TRUE, 'ONLINE',  NOW() - INTERVAL '35 days', NOW()),
    (3, 'cccccccc-cccc-cccc-cccc-ccccccccccc3'::uuid, 'jacob.driver@example.com',    '+1-555-202-0003', 'Jacob Kim',     'driver-pass-3', TRUE, 'OFFLINE', NOW() - INTERVAL '31 days', NOW()),
    (4, 'cccccccc-cccc-cccc-cccc-ccccccccccc4'::uuid, 'isabella.driver@example.com', '+1-555-202-0004', 'Isabella Reed', 'driver-pass-4', TRUE, 'ONLINE',  NOW() - INTERVAL '26 days', NOW()),
    (5, 'cccccccc-cccc-cccc-cccc-ccccccccccc5'::uuid, 'mason.driver@example.com',    '+1-555-202-0005', 'Mason Flores',  'driver-pass-5', TRUE, 'ONLINE',  NOW() - INTERVAL '21 days', NOW())
) AS base(n, driver_id, email, phone, full_name, password_hash, is_active, status, created_at, updated_at)
UNION ALL
SELECT
  n,
  pg_temp.seed_uuid('driver-' || n::text),
  'seed.driver' || lpad(n::text, 2, '0') || '@example.com',
  '+1-555-202-' || lpad((2000 + n)::text, 4, '0'),
  'Seed Driver ' || lpad(n::text, 2, '0'),
  'driver-pass-' || n::text,
  TRUE,
  CASE WHEN n % 3 = 0 THEN 'OFFLINE' ELSE 'ONLINE' END,
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
  NOW() - make_interval(mins => n * 3)
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
SELECT *
FROM (
  VALUES
    (1, 'dddddddd-dddd-dddd-dddd-ddddddddddd1'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1'::uuid, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '12121212-1212-4212-8212-121212121211'::uuid, 'ORD-10001', 'DELIVERED', NOW() - INTERVAL '3 hours', 5200, 799, 500, 0, 6499, 'USD', 'Please leave at concierge', NOW() - INTERVAL '3 hours', NOW() - INTERVAL '2 hours'),
    (2, 'dddddddd-dddd-dddd-dddd-ddddddddddd2'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2'::uuid, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2'::uuid, '11111111-1111-1111-1111-111111111112'::uuid, '13131313-1313-4313-8313-131313131311'::uuid, 'ORD-10002', 'DELIVERED', NOW() - INTERVAL '1 day', 3800, 599, 300, 0, 4699, 'USD', 'Contactless dropoff', NOW() - INTERVAL '1 day', NOW() - INTERVAL '23 hours'),
    (3, 'dddddddd-dddd-dddd-dddd-ddddddddddd3'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3'::uuid, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '12121212-1212-4212-8212-121212121212'::uuid, 'ORD-10003', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '90 minutes', 6400, 899, 700, 500, 7499, 'USD', 'Text before arrival', NOW() - INTERVAL '90 minutes', NOW() - INTERVAL '25 minutes'),
    (4, 'dddddddd-dddd-dddd-dddd-ddddddddddd4'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4'::uuid, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4'::uuid, '11111111-1111-1111-1111-111111111112'::uuid, '13131313-1313-4313-8313-131313131312'::uuid, 'ORD-10004', 'ASSIGNED', NOW() - INTERVAL '70 minutes', 4700, 699, 500, 0, 5899, 'USD', 'Use side door', NOW() - INTERVAL '70 minutes', NOW() - INTERVAL '35 minutes'),
    (5, 'dddddddd-dddd-dddd-dddd-ddddddddddd5'::uuid, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5'::uuid, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5'::uuid, '11111111-1111-1111-1111-111111111111'::uuid, '12121212-1212-4212-8212-121212121211'::uuid, 'ORD-10005', 'SUBMITTED', NOW() - INTERVAL '35 minutes', 3000, 499, 300, 0, 3799, 'USD', 'Leave in lobby', NOW() - INTERVAL '35 minutes', NOW() - INTERVAL '35 minutes')
) AS base(
  n, order_id, customer_id, address_id, retailer_id, retailer_location_id, external_order_id,
  status, placed_at, subtotal_cents, fees_cents, tip_cents, discount_cents, total_cents,
  currency, delivery_notes, created_at, updated_at
)
UNION ALL
SELECT
  c.n,
  pg_temp.seed_uuid('order-' || c.n::text),
  c.customer_id,
  a.address_id,
  CASE
    WHEN c.n % 2 = 0 THEN '11111111-1111-1111-1111-111111111113'::uuid
    ELSE '11111111-1111-1111-1111-111111111114'::uuid
  END AS retailer_id,
  rl.retailer_location_id,
  CASE (c.n % 4)
    WHEN 3 THEN 'WM-PO-' || lpad((700000 + c.n)::text, 7, '0')
    WHEN 0 THEN 'TGT-' || upper(substr(md5('tgt-order-' || c.n::text), 1, 10))
    ELSE 'ORD-' || lpad((10000 + c.n)::text, 5, '0')
  END AS external_order_id,
  CASE c.n % 5 WHEN 0 THEN 'PLACED' WHEN 1 THEN 'ASSIGNED' WHEN 2 THEN 'IN_TRANSIT' WHEN 3 THEN 'DELIVERED' ELSE 'SUBMITTED' END AS status,
  NOW() - make_interval(hours => c.n * 2) AS placed_at,
  2500 + (c.n * 125) AS subtotal_cents,
  399 + (c.n * 12) AS fees_cents,
  200 + (c.n * 15) AS tip_cents,
  CASE WHEN c.n % 4 = 0 THEN 300 ELSE 0 END AS discount_cents,
  (2500 + (c.n * 125)) + (399 + (c.n * 12)) + (200 + (c.n * 15)) - CASE WHEN c.n % 4 = 0 THEN 300 ELSE 0 END AS total_cents,
  'USD'::text AS currency,
  'Generated seed order #' || c.n::text AS delivery_notes,
  NOW() - make_interval(hours => c.n * 2) AS created_at,
  NOW() - make_interval(mins => c.n * 5) AS updated_at
FROM seed_customers c
JOIN seed_addresses a ON a.n = c.n
JOIN LATERAL (
  SELECT retailer_location_id
  FROM seed_retailer_locations
  WHERE retailer_id = CASE
    WHEN c.n % 2 = 0 THEN '11111111-1111-1111-1111-111111111113'::uuid
    ELSE '11111111-1111-1111-1111-111111111114'::uuid
  END
  ORDER BY n
  LIMIT 1
) rl ON TRUE
WHERE c.n BETWEEN 6 AND 25;

INSERT INTO orders (
  order_id, customer_id, retailer_id, retailer_location_id, address_id, external_order_id, status, placed_at,
  subtotal_cents, fees_cents, tip_cents, discount_cents, total_cents, currency, delivery_notes, created_at, updated_at
)
SELECT
  order_id, customer_id, retailer_id, retailer_location_id, address_id, external_order_id, status, placed_at,
  subtotal_cents, fees_cents, tip_cents, discount_cents, total_cents, currency, delivery_notes, created_at, updated_at
FROM seed_orders
ON CONFLICT DO NOTHING;

-- Delivery assignments (25 total)
CREATE TEMP TABLE seed_deliveries ON COMMIT DROP AS
SELECT *
FROM (
  VALUES
    (1, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1'::uuid, 'dddddddd-dddd-dddd-dddd-ddddddddddd1'::uuid, 'cccccccc-cccc-cccc-cccc-ccccccccccc1'::uuid, 'DELIVERED', 'FreshMart Downtown', NOW() - INTERVAL '2 hours 40 minutes', NOW() - INTERVAL '2 hours 15 minutes', NOW() - INTERVAL '2 hours'),
    (2, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2'::uuid, 'dddddddd-dddd-dddd-dddd-ddddddddddd2'::uuid, 'cccccccc-cccc-cccc-cccc-ccccccccccc2'::uuid, 'DELIVERED', 'QuickGrocer Journal Sq', NOW() - INTERVAL '23 hours 30 minutes', NOW() - INTERVAL '23 hours', NOW() - INTERVAL '22 hours 40 minutes'),
    (3, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3'::uuid, 'dddddddd-dddd-dddd-dddd-ddddddddddd3'::uuid, 'cccccccc-cccc-cccc-cccc-ccccccccccc4'::uuid, 'OUT_FOR_DELIVERY', 'FreshMart Riverside', NOW() - INTERVAL '70 minutes', NOW() - INTERVAL '40 minutes', NULL::timestamptz),
    (4, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4'::uuid, 'dddddddd-dddd-dddd-dddd-ddddddddddd4'::uuid, 'cccccccc-cccc-cccc-cccc-ccccccccccc5'::uuid, 'ASSIGNED', 'QuickGrocer Newark', NOW() - INTERVAL '35 minutes', NULL::timestamptz, NULL::timestamptz),
    (5, 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5'::uuid, 'dddddddd-dddd-dddd-dddd-ddddddddddd5'::uuid, NULL::uuid, 'PENDING_ASSIGNMENT', 'FreshMart Downtown', NULL::timestamptz, NULL::timestamptz, NULL::timestamptz)
) AS base(n, delivery_id, order_id, driver_id, status, pickup_location, assigned_at, picked_up_at, delivered_at)
UNION ALL
SELECT
  o.n,
  pg_temp.seed_uuid('delivery-' || o.n::text),
  o.order_id,
  CASE WHEN o.n % 5 = 0 THEN NULL ELSE d.driver_id END AS driver_id,
  CASE o.n % 5 WHEN 0 THEN 'PENDING_ASSIGNMENT' WHEN 1 THEN 'ASSIGNED' WHEN 2 THEN 'PICKED_UP' WHEN 3 THEN 'IN_TRANSIT' ELSE 'DELIVERED' END AS status,
  coalesce(rl.name, 'Partner Pickup Hub') AS pickup_location,
  NOW() - make_interval(hours => o.n * 2 - 1) AS assigned_at,
  CASE WHEN o.n % 5 IN (2, 3, 4) THEN NOW() - make_interval(hours => o.n * 2 - 2) ELSE NULL END AS picked_up_at,
  CASE WHEN o.n % 5 = 4 THEN NOW() - make_interval(hours => o.n * 2 - 3) ELSE NULL END AS delivered_at
FROM seed_orders o
JOIN seed_drivers d ON d.n = o.n
LEFT JOIN seed_retailer_locations rl ON rl.retailer_location_id = o.retailer_location_id
WHERE o.n BETWEEN 6 AND 25;

INSERT INTO delivery_assignments (
  delivery_id, order_id, driver_id, status, pickup_location, assigned_at, picked_up_at, delivered_at
)
SELECT
  delivery_id, order_id, driver_id, status, pickup_location, assigned_at, picked_up_at, delivered_at
FROM seed_deliveries
ON CONFLICT DO NOTHING;

-- Delivery status events (25 total)
INSERT INTO delivery_status_events (event_id, delivery_id, driver_id, status, event_time, note, lat, lng)
VALUES
  ('ffffffff-ffff-ffff-ffff-fffffffffff1', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'ASSIGNED', NOW() - INTERVAL '2 hours 40 minutes', 'Driver accepted offer', 39.7587, -84.1916),
  ('ffffffff-ffff-ffff-ffff-fffffffffff2', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1', 'cccccccc-cccc-cccc-cccc-ccccccccccc1', 'DELIVERED', NOW() - INTERVAL '2 hours', 'Delivered to concierge', 40.7090, -74.0112),
  ('ffffffff-ffff-ffff-ffff-fffffffffff3', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee2', 'cccccccc-cccc-cccc-cccc-ccccccccccc2', 'DELIVERED', NOW() - INTERVAL '22 hours 40 minutes', 'Completed at the front desk', 40.7332, -74.0626),
  ('ffffffff-ffff-ffff-ffff-fffffffffff4', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee3', 'cccccccc-cccc-cccc-cccc-ccccccccccc4', 'OUT_FOR_DELIVERY', NOW() - INTERVAL '25 minutes', 'Approaching destination', 40.7526, -73.9772),
  ('ffffffff-ffff-ffff-ffff-fffffffffff5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee4', 'cccccccc-cccc-cccc-cccc-ccccccccccc5', 'ASSIGNED', NOW() - INTERVAL '35 minutes', 'Waiting for pickup', 40.7357, -74.1724)
ON CONFLICT DO NOTHING;

INSERT INTO delivery_status_events (event_id, delivery_id, driver_id, status, event_time, note, lat, lng)
SELECT
  pg_temp.seed_uuid('event-' || n::text) AS event_id,
  delivery_id,
  driver_id,
  status,
  NOW() - make_interval(hours => n) AS event_time,
  'Generated seed event for delivery #' || n::text AS note,
  40.6000 + (n * 0.01) AS lat,
  -74.2000 + (n * 0.01) AS lng
FROM seed_deliveries
WHERE n BETWEEN 6 AND 25
ON CONFLICT DO NOTHING;

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

INSERT INTO delivery_offers (
  offer_id, order_id, delivery_id, status, offered_at, responded_at, expires_in_sec, decline_reason
)
VALUES
  ('26262626-2626-4262-8262-262626262611', 'dddddddd-dddd-dddd-dddd-ddddddddddd5', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee5', 'OFFERED', NOW() - INTERVAL '15 minutes', NULL, 300, NULL)
ON CONFLICT (offer_id) DO NOTHING;

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

COMMIT;
