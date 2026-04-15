CREATE TABLE IF NOT EXISTS retailer_locations (
  retailer_location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id          UUID NOT NULL,
  external_store_id    TEXT,
  name                 TEXT,
  address_line1        TEXT,
  address_line2        TEXT,
  city                 TEXT,
  state                TEXT,
  postal_code          TEXT,
  country              TEXT,
  lat                  DECIMAL,
  lng                  DECIMAL,
  is_active            BOOLEAN,
  created_at           TIMESTAMPTZ,
  updated_at           TIMESTAMPTZ,
  CONSTRAINT fk_retailer_locations_retailer
    FOREIGN KEY (retailer_id) REFERENCES retailers(retailer_id)
    ON DELETE CASCADE
);

ALTER TABLE carts
  ADD COLUMN IF NOT EXISTS retailer_location_id UUID;

ALTER TABLE carts
  ADD CONSTRAINT fk_carts_retailer_location
  FOREIGN KEY (retailer_location_id) REFERENCES retailer_locations(retailer_location_id)
  ON DELETE SET NULL;

ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS retailer_location_id UUID;

ALTER TABLE orders
  ADD CONSTRAINT fk_orders_retailer_location
  FOREIGN KEY (retailer_location_id) REFERENCES retailer_locations(retailer_location_id)
  ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_retailer_locations_retailer_id
  ON retailer_locations (retailer_id);

CREATE INDEX IF NOT EXISTS idx_carts_retailer_location_id
  ON carts (retailer_location_id);

CREATE INDEX IF NOT EXISTS idx_orders_retailer_location_id
  ON orders (retailer_location_id);
