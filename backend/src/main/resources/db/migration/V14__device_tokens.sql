-- Phones that should get push notifications. One row per install: a farmer
-- with two phones has two rows, and a token FCM reports as gone is deleted.
CREATE TABLE IF NOT EXISTS device_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(512) NOT NULL,
    platform VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- A token belongs to one install, so to one account at a time.
CREATE UNIQUE INDEX IF NOT EXISTS uq_device_tokens_token ON device_tokens (token);
CREATE INDEX IF NOT EXISTS idx_device_tokens_user ON device_tokens (user_id);
