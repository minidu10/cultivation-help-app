-- Local demo data for analysis. NOT a Flyway migration on purpose:
-- anything in db/migration/ would also run against production.
--
-- Register an account in the UI first, then:
--   docker compose exec -T db psql -U postgres -d cultivation < scripts/seed-local.sql
--
-- Re-running replaces the seeded crops (and their expenses/harvests/reminders,
-- via ON DELETE CASCADE) but leaves your user and hand-made rows untouched.

DO $$
DECLARE
    uid    BIGINT;
    paddy  BIGINT;   -- harvested, clearly profitable
    chilli BIGINT;   -- harvested, thin margin
    onion  BIGINT;   -- failed: costs, no revenue
    tomato BIGINT;   -- still growing: costs, no harvest yet
BEGIN
    SELECT id INTO uid FROM users ORDER BY id LIMIT 1;
    IF uid IS NULL THEN
        RAISE EXCEPTION 'No users found. Register an account at http://localhost:5173 first.';
    END IF;

    DELETE FROM crops
     WHERE user_id = uid
       AND name IN ('Paddy (Nadu)', 'Green Chilli', 'Big Onion', 'Tomato');

    INSERT INTO crops (user_id, name, variety, field_location, field_size_acres,
                       planting_date, expected_harvest_date, status, notes)
    VALUES
      (uid, 'Paddy (Nadu)', 'BG 300', 'Polonnaruwa - North field', 2.5,
       DATE '2025-10-15', DATE '2026-02-10', 'HARVESTED',
       'Maha season. Best yield so far.'),
      (uid, 'Green Chilli', 'MI-2', 'Polonnaruwa - East plot', 0.75,
       DATE '2025-11-01', DATE '2026-02-20', 'HARVESTED',
       'Priced low at market; margin was thin.'),
      (uid, 'Big Onion', 'Rathnapura Red', 'Dambulla - leased land', 1.0,
       DATE '2025-09-20', DATE '2026-01-15', 'FAILED',
       'Lost to downy mildew after heavy rain.'),
      (uid, 'Tomato', 'Thilina', 'Polonnaruwa - greenhouse', 0.4,
       DATE '2026-01-05', DATE '2026-04-12', 'GROWING',
       'First greenhouse trial.');

    SELECT id INTO paddy  FROM crops WHERE user_id = uid AND name = 'Paddy (Nadu)';
    SELECT id INTO chilli FROM crops WHERE user_id = uid AND name = 'Green Chilli';
    SELECT id INTO onion  FROM crops WHERE user_id = uid AND name = 'Big Onion';
    SELECT id INTO tomato FROM crops WHERE user_id = uid AND name = 'Tomato';

    -- ---------------------------------------------------------------- PADDY
    INSERT INTO expenses (crop_id, category, description, amount, expense_date) VALUES
      (paddy, 'SEEDS',         'Certified BG 300 paddy seed, 125kg',   31250.00, DATE '2025-10-12'),
      (paddy, 'EQUIPMENT',     'Tractor hire - land preparation',      42000.00, DATE '2025-10-14'),
      (paddy, 'LABOR',         'Transplanting crew (8 workers)',       64000.00, DATE '2025-10-18'),
      (paddy, 'FERTILIZER',    'Urea basal dressing, 150kg',           28500.00, DATE '2025-10-28'),
      (paddy, 'IRRIGATION',    'Channel water fee - Maha season',      12000.00, DATE '2025-11-05'),
      (paddy, 'FERTILIZER',    'TDM top dressing, 100kg',              21000.00, DATE '2025-11-22'),
      (paddy, 'PESTICIDES',    'Brown planthopper spray',              15800.00, DATE '2025-12-06'),
      (paddy, 'LABOR',         'Weeding round',                        18000.00, DATE '2025-12-15'),
      (paddy, 'FERTILIZER',    'Potash before flowering, 75kg',        16500.00, DATE '2026-01-04'),
      (paddy, 'EQUIPMENT',     'Combine harvester hire',               55000.00, DATE '2026-02-08'),
      (paddy, 'LABOR',         'Harvest handling and bagging',         26000.00, DATE '2026-02-09'),
      (paddy, 'TRANSPORT',     'Lorry to Polonnaruwa mill',            18500.00, DATE '2026-02-10');

    INSERT INTO harvests (crop_id, harvest_date, quantity, unit, price_per_unit, buyer_name, notes) VALUES
      (paddy, DATE '2026-02-10', 4800.000, 'KG', 118.00, 'Polonnaruwa Rice Mill', 'Graded A, paid on delivery.'),
      (paddy, DATE '2026-02-12', 1650.000, 'KG', 112.00, 'Local collector',       'Slightly higher moisture.');

    -- --------------------------------------------------------------- CHILLI
    INSERT INTO expenses (crop_id, category, description, amount, expense_date) VALUES
      (chilli, 'SEEDS',         'MI-2 chilli seedlings, 3200 plants',  27000.00, DATE '2025-10-30'),
      (chilli, 'LABOR',         'Bed preparation and planting',        22500.00, DATE '2025-11-01'),
      (chilli, 'FERTILIZER',    'Compost and NPK mix',                 19800.00, DATE '2025-11-10'),
      (chilli, 'IRRIGATION',    'Drip line rental',                    14500.00, DATE '2025-11-12'),
      (chilli, 'PESTICIDES',    'Thrips control - two rounds',         23400.00, DATE '2025-12-02'),
      (chilli, 'MISCELLANEOUS', 'Crates and packaging',                 7400.00, DATE '2026-01-17'),
      (chilli, 'LABOR',         'Picking crew - first flush',          31000.00, DATE '2026-01-18'),
      (chilli, 'LABOR',         'Picking crew - second flush',         28000.00, DATE '2026-02-08'),
      (chilli, 'TRANSPORT',     'Trips to Dambulla economic centre',   16200.00, DATE '2026-02-20');

    INSERT INTO harvests (crop_id, harvest_date, quantity, unit, price_per_unit, buyer_name, notes) VALUES
      (chilli, DATE '2026-01-20', 620.000, 'KG', 240.00, 'Dambulla Economic Centre', 'Good price early in the flush.'),
      (chilli, DATE '2026-02-10', 540.000, 'KG', 185.00, 'Dambulla Economic Centre', 'Market flooded, price dropped.'),
      (chilli, DATE '2026-02-22', 310.000, 'KG', 150.00, 'Local retailer',           'Tail end, lower grade.');

    -- ---------------------------------------------------------------- ONION
    -- Total loss: full cost base, zero revenue.
    INSERT INTO expenses (crop_id, category, description, amount, expense_date) VALUES
      (onion, 'MISCELLANEOUS', 'Land lease - one season',              65000.00, DATE '2025-09-15'),
      (onion, 'SEEDS',         'Big onion sets, 400kg',                88000.00, DATE '2025-09-18'),
      (onion, 'EQUIPMENT',     'Rotavator hire',                       24000.00, DATE '2025-09-19'),
      (onion, 'LABOR',         'Planting crew',                        36000.00, DATE '2025-09-22'),
      (onion, 'FERTILIZER',    'Basal NPK application',                25500.00, DATE '2025-10-02'),
      (onion, 'PESTICIDES',    'Preventive fungicide',                 13200.00, DATE '2025-10-20'),
      (onion, 'PESTICIDES',    'Emergency mildew treatment',           29500.00, DATE '2025-11-14'),
      (onion, 'LABOR',         'Salvage attempt - removing infection', 17000.00, DATE '2025-11-18');

    -- --------------------------------------------------------------- TOMATO
    -- In progress: costs accruing, revenue still zero.
    INSERT INTO expenses (crop_id, category, description, amount, expense_date) VALUES
      (tomato, 'EQUIPMENT',    'Polytunnel repair and netting',        48000.00, DATE '2026-01-03'),
      (tomato, 'SEEDS',        'Thilina hybrid seedlings',             18500.00, DATE '2026-01-05'),
      (tomato, 'FERTILIZER',   'Coir and fertigation starter',         21000.00, DATE '2026-01-09'),
      (tomato, 'IRRIGATION',   'Drip fertigation setup',               32000.00, DATE '2026-01-11'),
      (tomato, 'LABOR',        'Training and pruning',                 14000.00, DATE '2026-02-02'),
      (tomato, 'PESTICIDES',   'Whitefly management',                  11500.00, DATE '2026-02-19');

    -- ------------------------------------------------------------ REMINDERS
    INSERT INTO reminders (crop_id, title, type, reminder_at, enabled, ai_recommended, completed, note) VALUES
      (tomato, 'Second fertigation dose', 'FERTILIZER',   TIMESTAMP '2026-03-01 07:00', TRUE, FALSE, FALSE, 'Half-strength NPK.'),
      (tomato, 'Check drip emitters',     'IRRIGATION',   TIMESTAMP '2026-02-25 06:30', TRUE, FALSE, FALSE, 'Two lines ran dry last week.'),
      (tomato, 'Whitefly scouting',       'PEST_CONTROL', TIMESTAMP '2026-03-05 16:00', TRUE, TRUE,  FALSE, 'Yellow sticky traps.'),
      (tomato, 'Expected first pick',     'HARVEST',      TIMESTAMP '2026-04-12 06:00', TRUE, FALSE, FALSE, NULL),
      (paddy,  'Mill payment follow-up',  'OTHER',        TIMESTAMP '2026-02-18 09:00', TRUE, FALSE, TRUE,  'Settled.');

    RAISE NOTICE 'Seeded 4 crops, 35 expenses, 5 harvests, 5 reminders for user_id %', uid;
END $$;
