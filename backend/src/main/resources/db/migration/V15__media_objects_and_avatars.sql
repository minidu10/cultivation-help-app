-- Photos need somewhere to live. In production they go to S3; this table backs
-- the same interface when no bucket is configured (local development, tests).
CREATE TABLE IF NOT EXISTS media_objects (
    object_key   VARCHAR(255) PRIMARY KEY,
    content_type VARCHAR(100) NOT NULL,
    data         BYTEA        NOT NULL
);

-- NULL means no profile picture. Also the cache-busting version of the URL.
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_updated_at TIMESTAMP;
