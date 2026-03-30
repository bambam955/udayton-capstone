-- Relax support ticket order links so general account/help tickets do not
-- require an order reference in already-provisioned environments.
ALTER TABLE support_tickets
  ALTER COLUMN order_id DROP NOT NULL;
