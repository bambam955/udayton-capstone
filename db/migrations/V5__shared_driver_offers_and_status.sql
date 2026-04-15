-- Availability is now modeled directly on `drivers.status`, so normalize the
-- legacy values before tightening the schema.
UPDATE drivers
SET status = 'ONLINE'
WHERE upper(coalesce(status, '')) IN ('ONLINE', 'AVAILABLE', 'BUSY');

UPDATE drivers
SET status = 'OFFLINE'
WHERE upper(coalesce(status, '')) NOT IN ('ONLINE');

ALTER TABLE drivers
  ALTER COLUMN status SET DEFAULT 'OFFLINE';

ALTER TABLE drivers
  DROP CONSTRAINT IF EXISTS chk_drivers_status_online_offline;

ALTER TABLE drivers
  ADD CONSTRAINT chk_drivers_status_online_offline
  CHECK (status IN ('ONLINE', 'OFFLINE'));

-- The product no longer keeps a separate availability-history table, so drop
-- it before the application code stops referencing the resource entirely.
DROP TABLE IF EXISTS driver_availability;

-- Shared offers are now one row per delivery rather than one row per driver.
WITH ranked_offers AS (
  SELECT
    offer_id,
    row_number() OVER (
      PARTITION BY delivery_id
      ORDER BY
        CASE upper(coalesce(status, ''))
          WHEN 'ACCEPTED' THEN 0
          WHEN 'OFFERED' THEN 1
          WHEN 'EXPIRED' THEN 2
          ELSE 3
        END,
        responded_at DESC NULLS LAST,
        offered_at DESC NULLS LAST,
        offer_id DESC
    ) AS row_number
  FROM delivery_offers
)
DELETE FROM delivery_offers AS offer
USING ranked_offers
WHERE offer.offer_id = ranked_offers.offer_id
  AND ranked_offers.row_number > 1;

DROP INDEX IF EXISTS idx_delivery_offers_delivery_driver_unique;

ALTER TABLE delivery_offers
  DROP CONSTRAINT IF EXISTS fk_delivery_offers_driver;

ALTER TABLE delivery_offers
  DROP COLUMN IF EXISTS driver_id;

CREATE UNIQUE INDEX IF NOT EXISTS idx_delivery_offers_delivery_unique
  ON delivery_offers (delivery_id);
