-- Lets a password reset invalidate tokens issued before it.
--
-- JWTs here are stateless with a 24 hour life, so a stolen token previously
-- survived the victim resetting their password: the one action a worried user
-- knows to take did nothing. JwtFilter now rejects any token issued earlier
-- than this timestamp.
ALTER TABLE IF EXISTS users
    ADD COLUMN IF NOT EXISTS password_changed_at TIMESTAMP;
