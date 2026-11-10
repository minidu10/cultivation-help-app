-- Long-lived refresh tokens so a phone stays signed in without a 24 hour JWT.
--
-- Only a SHA-256 of each token is stored: a leaked table cannot be replayed.
-- Tokens are single-use. Each refresh marks the presented token used and
-- issues the next one in the same family. A used token turning up again means
-- it was copied, so the whole family is revoked and both the thief and the
-- real owner must sign in again (refresh token reuse detection).
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,
    family_id UUID NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    revoked_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_refresh_tokens_hash ON refresh_tokens (token_hash);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_family ON refresh_tokens (family_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens (user_id);
