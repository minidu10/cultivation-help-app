CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS crops (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    variety VARCHAR(100),
    field_location VARCHAR(200),
    field_size_acres DOUBLE PRECISION,
    planting_date DATE NOT NULL,
    expected_harvest_date DATE,
    status VARCHAR(40) NOT NULL DEFAULT 'PLANTED',
    notes VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
    IF to_regclass('public.crops') IS NOT NULL
       AND to_regclass('public.users') IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = 'fk_crops_user'
       ) THEN
        ALTER TABLE crops
            ADD CONSTRAINT fk_crops_user
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS expenses (
    id BIGSERIAL PRIMARY KEY,
    crop_id BIGINT NOT NULL,
    category VARCHAR(40) NOT NULL,
    description VARCHAR(200) NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    expense_date DATE NOT NULL,
    notes VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
    IF to_regclass('public.expenses') IS NOT NULL
       AND to_regclass('public.crops') IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = 'fk_expenses_crop'
       ) THEN
        ALTER TABLE expenses
            ADD CONSTRAINT fk_expenses_crop
            FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE;
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS harvests (
    id BIGSERIAL PRIMARY KEY,
    crop_id BIGINT NOT NULL,
    harvest_date DATE NOT NULL,
    quantity NUMERIC(12,3) NOT NULL,
    unit VARCHAR(40) NOT NULL,
    price_per_unit NUMERIC(12,2) NOT NULL,
    buyer_name VARCHAR(200),
    notes VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
    IF to_regclass('public.harvests') IS NOT NULL
       AND to_regclass('public.crops') IS NOT NULL
       AND NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = 'fk_harvests_crop'
       ) THEN
        ALTER TABLE harvests
            ADD CONSTRAINT fk_harvests_crop
            FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE;
    END IF;
END $$;