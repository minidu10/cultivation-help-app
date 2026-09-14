-- Caches the AI insight for each crop.
--
-- The dashboard previously asked the model for an insight on every load, once
-- per crop, so opening the page ten times cost forty AI calls and returned the
-- same text each time. The fingerprint below is a digest of the figures the
-- insight is derived from; while it is unchanged the stored text is still
-- correct and no tokens are spent.

CREATE TABLE IF NOT EXISTS crop_insights (
    crop_id      BIGINT PRIMARY KEY REFERENCES crops(id) ON DELETE CASCADE,
    fingerprint  VARCHAR(64) NOT NULL,
    content      TEXT        NOT NULL,
    generated_at TIMESTAMP   NOT NULL DEFAULT NOW()
);
