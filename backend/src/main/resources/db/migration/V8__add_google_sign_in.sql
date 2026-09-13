-- Accounts can now be created through Google, which issues no password.
ALTER TABLE IF EXISTS users ALTER COLUMN password DROP NOT NULL;

-- LOCAL = email + password, GOOGLE = created via Google Sign-In.
-- An account that starts as GOOGLE and later sets a password stays usable both ways.
ALTER TABLE IF EXISTS users
    ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) NOT NULL DEFAULT 'LOCAL';

-- Google's subject claim: stable per user, never reused, unlike the email.
ALTER TABLE IF EXISTS users
    ADD COLUMN IF NOT EXISTS google_id VARCHAR(64);

CREATE UNIQUE INDEX IF NOT EXISTS uq_users_google_id
    ON users (google_id) WHERE google_id IS NOT NULL;
