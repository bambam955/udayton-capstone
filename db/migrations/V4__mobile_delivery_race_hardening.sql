ALTER TABLE carts
  ADD COLUMN IF NOT EXISTS checked_out_order_id UUID;

ALTER TABLE carts
  ADD CONSTRAINT fk_carts_checked_out_order
  FOREIGN KEY (checked_out_order_id) REFERENCES orders(order_id)
  ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_carts_checked_out_order_id
  ON carts (checked_out_order_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_driver_earnings_delivery_id_unique
  ON driver_earnings (delivery_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_delivery_offers_delivery_driver_unique
  ON delivery_offers (delivery_id, driver_id);
