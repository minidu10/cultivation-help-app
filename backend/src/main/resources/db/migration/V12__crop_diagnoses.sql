-- Crop doctor: one row per photo checked.
--
-- The full photo is never stored, only what the farmer needs to recognise it
-- later: a ~320 px thumbnail. Thumbnails live in their own table so listing a
-- crop's history never drags image bytes out of the database.
CREATE TABLE IF NOT EXISTS crop_diagnoses (
    id BIGSERIAL PRIMARY KEY,
    crop_id BIGINT NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
    is_plant BOOLEAN NOT NULL,
    crop_guess VARCHAR(100),
    condition VARCHAR(100) NOT NULL,
    confidence DOUBLE PRECISION NOT NULL,
    severity VARCHAR(20) NOT NULL,
    see_expert BOOLEAN NOT NULL,
    -- symptoms, treatments and prevention: lists whose length varies per answer
    details JSONB NOT NULL,
    note VARCHAR(300),
    model VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_crop_diagnoses_crop ON crop_diagnoses (crop_id, created_at DESC);

CREATE TABLE IF NOT EXISTS crop_diagnosis_thumbnails (
    diagnosis_id BIGINT PRIMARY KEY REFERENCES crop_diagnoses(id) ON DELETE CASCADE,
    image BYTEA NOT NULL
);
