ALTER TABLE IF EXISTS crops
ADD COLUMN IF NOT EXISTS ai_insights_enabled BOOLEAN NOT NULL DEFAULT TRUE;

CREATE TABLE IF NOT EXISTS reminders (
    id BIGSERIAL PRIMARY KEY,
    crop_id BIGINT NOT NULL,
    title VARCHAR(150) NOT NULL,
    type VARCHAR(40) NOT NULL DEFAULT 'OTHER',
    reminder_at TIMESTAMP NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    ai_recommended BOOLEAN NOT NULL DEFAULT FALSE,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    note VARCHAR(400),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
    IF to_regclass('public.reminders') IS NOT NULL
       AND to_regclass('public.crops') IS NOT NULL
       AND NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_reminders_crop'
    ) THEN
        ALTER TABLE reminders
        ADD CONSTRAINT fk_reminders_crop
        FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE;
    END IF;
END $$;
