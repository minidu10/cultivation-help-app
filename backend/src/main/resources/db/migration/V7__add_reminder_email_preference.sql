-- Farmers opt out of reminder emails from the settings page.
-- Defaults to TRUE so existing accounts keep the behaviour they have now.
ALTER TABLE IF EXISTS users
    ADD COLUMN IF NOT EXISTS reminder_emails_enabled BOOLEAN NOT NULL DEFAULT TRUE;
