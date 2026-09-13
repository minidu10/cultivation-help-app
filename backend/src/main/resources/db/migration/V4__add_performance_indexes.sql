-- PostgreSQL does not create indexes for foreign keys automatically, and the
-- schema shipped without any. Every repository query filters on one of these
-- columns, so each was a sequential scan.
--
-- Composite columns are ordered to match the sort each query already asks for,
-- so the index satisfies both the filter and the ORDER BY. The leading column
-- alone still serves the plain aggregate lookups (leftmost-prefix rule).

-- CropRepository.findByUserIdOrderByCreatedAtDesc / findByIdAndUserId
CREATE INDEX IF NOT EXISTS idx_crops_user_created
    ON crops (user_id, created_at DESC);

-- ExpenseRepository.findByCropIdOrderByExpenseDateDesc + sumAmountByCropId
CREATE INDEX IF NOT EXISTS idx_expenses_crop_date
    ON expenses (crop_id, expense_date DESC);

-- HarvestRepository.findByCropIdOrderByHarvestDateDesc + sumRevenueByCropId
CREATE INDEX IF NOT EXISTS idx_harvests_crop_date
    ON harvests (crop_id, harvest_date DESC);

-- ReminderRepository.findByCropIdAndCropUserIdOrderByReminderAtAsc
CREATE INDEX IF NOT EXISTS idx_reminders_crop_at
    ON reminders (crop_id, reminder_at);

-- Partial index for the "due reminders" query, which only ever looks at rows
-- that are enabled and not yet completed — typically a small slice of the table.
CREATE INDEX IF NOT EXISTS idx_reminders_due
    ON reminders (crop_id, reminder_at)
    WHERE enabled AND NOT completed;
