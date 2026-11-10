-- Expenses and harvests recorded offline on a phone are queued and sent once
-- the signal is back. A request whose response was lost is sent again, so
-- each carries a UUID the phone generated, and the second copy must not
-- become a second row.
--
-- The guarantee is this unique index, not application logic: two copies
-- arriving at the same moment cannot both insert.
ALTER TABLE IF EXISTS expenses ADD COLUMN IF NOT EXISTS client_ref UUID;
ALTER TABLE IF EXISTS harvests ADD COLUMN IF NOT EXISTS client_ref UUID;

CREATE UNIQUE INDEX IF NOT EXISTS uq_expenses_client_ref
    ON expenses (crop_id, client_ref) WHERE client_ref IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_harvests_client_ref
    ON harvests (crop_id, client_ref) WHERE client_ref IS NOT NULL;
