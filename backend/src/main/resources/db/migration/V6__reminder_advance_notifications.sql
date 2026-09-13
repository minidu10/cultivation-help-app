-- Reminder emails move from "one mail per reminder, when it falls due" to
-- "one digest per user per day, sent in advance".
--
-- A single notified_at timestamp cannot express this: each reminder is now
-- announced more than once (two days ahead, then one day ahead), so what has
-- to be recorded is which advance notice has already gone out.

CREATE TABLE IF NOT EXISTS reminder_notifications (
    id          BIGSERIAL PRIMARY KEY,
    reminder_id BIGINT NOT NULL REFERENCES reminders(id) ON DELETE CASCADE,
    lead_days   INT    NOT NULL,
    sent_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    -- The guarantee that a farmer is never emailed the same notice twice,
    -- enforced by the database rather than by job logic.
    CONSTRAINT uq_reminder_notification UNIQUE (reminder_id, lead_days)
);

CREATE INDEX IF NOT EXISTS idx_reminder_notifications_reminder
    ON reminder_notifications (reminder_id);

-- Superseded by the table above.
DROP INDEX IF EXISTS idx_reminders_pending_notification;
ALTER TABLE IF EXISTS reminders DROP COLUMN IF EXISTS notified_at;

-- The job scans a narrow forward date window of active reminders.
CREATE INDEX IF NOT EXISTS idx_reminders_upcoming
    ON reminders (reminder_at)
    WHERE enabled AND NOT completed;
