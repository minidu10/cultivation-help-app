-- Email verification codes, used for two purposes:
--   REGISTRATION   - prove the address is real before an account is created
--   PASSWORD_RESET - prove ownership before changing a password
--
-- There is no user_id: for REGISTRATION the user does not exist yet.
-- The code itself is never stored, only SHA-256(email + ':' + code).

CREATE TABLE IF NOT EXISTS email_verifications (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(100) NOT NULL,
    code_hash   VARCHAR(64)  NOT NULL,
    purpose     VARCHAR(30)  NOT NULL,
    expires_at  TIMESTAMP    NOT NULL,
    attempts    INT          NOT NULL DEFAULT 0,
    verified_at TIMESTAMP,
    consumed_at TIMESTAMP,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- Every lookup is "latest code for this email and purpose".
CREATE INDEX IF NOT EXISTS idx_email_verifications_lookup
    ON email_verifications (email, purpose, created_at DESC);

-- Reminder e-mail notifications: without notified_at the scheduler would
-- re-send the same reminder on every run.
ALTER TABLE IF EXISTS reminders
    ADD COLUMN IF NOT EXISTS notified_at TIMESTAMP;

CREATE INDEX IF NOT EXISTS idx_reminders_pending_notification
    ON reminders (reminder_at)
    WHERE enabled AND NOT completed AND notified_at IS NULL;
