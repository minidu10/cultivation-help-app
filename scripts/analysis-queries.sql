-- Starter queries for the pgAdmin Query Tool.
-- Connect to: localhost:5434, database "cultivation", user "postgres".
-- Run one statement at a time (highlight it and press F5).


-- 1. Profit and loss per crop.
--    Mirrors what the app computes in ExpenseService.calculateProfitLoss,
--    but for every crop at once instead of one at a time.
SELECT c.name,
       c.status,
       COALESCE(e.spent, 0)                          AS expenses,
       COALESCE(h.revenue, 0)                        AS revenue,
       COALESCE(h.revenue, 0) - COALESCE(e.spent, 0) AS profit,
       ROUND(
           CASE WHEN COALESCE(e.spent, 0) = 0 THEN NULL
                ELSE (COALESCE(h.revenue, 0) - e.spent) / e.spent * 100
           END, 1)                                   AS margin_pct
FROM crops c
LEFT JOIN (SELECT crop_id, SUM(amount) AS spent
             FROM expenses GROUP BY crop_id) e ON e.crop_id = c.id
LEFT JOIN (SELECT crop_id, SUM(quantity * price_per_unit) AS revenue
             FROM harvests GROUP BY crop_id) h ON h.crop_id = c.id
ORDER BY profit DESC;


-- 2. Where the money goes: spend by category across all crops.
SELECT category,
       COUNT(*)      AS entries,
       SUM(amount)   AS total,
       ROUND(AVG(amount), 2) AS avg_entry,
       ROUND(100.0 * SUM(amount) / SUM(SUM(amount)) OVER (), 1) AS pct_of_spend
FROM expenses
GROUP BY category
ORDER BY total DESC;


-- 3. Monthly cash burn - the shape behind the dashboard's time series.
SELECT date_trunc('month', expense_date)::date AS month,
       SUM(amount)                             AS spent
FROM expenses
GROUP BY 1
ORDER BY 1;


-- 4. Monthly expenses against monthly revenue, side by side.
SELECT month,
       COALESCE(SUM(spent), 0)   AS expenses,
       COALESCE(SUM(earned), 0)  AS revenue,
       COALESCE(SUM(earned), 0) - COALESCE(SUM(spent), 0) AS net
FROM (
    SELECT date_trunc('month', expense_date)::date AS month, amount AS spent, 0 AS earned
      FROM expenses
    UNION ALL
    SELECT date_trunc('month', harvest_date)::date, 0, quantity * price_per_unit
      FROM harvests
) t
GROUP BY month
ORDER BY month;


-- 5. Yield and realised price per crop - useful for spotting which crop
--    actually pays per acre rather than in absolute terms.
SELECT c.name,
       c.field_size_acres,
       SUM(h.quantity)                                          AS total_qty,
       h.unit,
       ROUND(AVG(h.price_per_unit), 2)                          AS avg_price,
       ROUND(SUM(h.quantity) / NULLIF(c.field_size_acres, 0), 1) AS qty_per_acre,
       ROUND(SUM(h.quantity * h.price_per_unit)
             / NULLIF(c.field_size_acres, 0), 2)                AS revenue_per_acre
FROM crops c
JOIN harvests h ON h.crop_id = c.id
GROUP BY c.id, c.name, c.field_size_acres, h.unit
ORDER BY revenue_per_acre DESC;


-- 6. Price decay within a single crop - shows how much the market moved
--    between the first and last pick.
SELECT c.name,
       h.harvest_date,
       h.quantity,
       h.price_per_unit,
       h.price_per_unit - FIRST_VALUE(h.price_per_unit)
           OVER (PARTITION BY c.id ORDER BY h.harvest_date) AS vs_first_pick,
       h.buyer_name
FROM harvests h
JOIN crops c ON c.id = h.crop_id
ORDER BY c.name, h.harvest_date;


-- 7. Crops running at a loss right now (includes in-progress ones).
SELECT c.name, c.status, c.planting_date,
       COALESCE(e.spent, 0) - COALESCE(h.revenue, 0) AS loss_so_far
FROM crops c
LEFT JOIN (SELECT crop_id, SUM(amount) AS spent
             FROM expenses GROUP BY crop_id) e ON e.crop_id = c.id
LEFT JOIN (SELECT crop_id, SUM(quantity * price_per_unit) AS revenue
             FROM harvests GROUP BY crop_id) h ON h.crop_id = c.id
WHERE COALESCE(e.spent, 0) > COALESCE(h.revenue, 0)
ORDER BY loss_so_far DESC;


-- 8. Confirm the V4 indexes are being used rather than sequential scans.
--    Look for "Index Scan" / "Index Only Scan" in the output.
EXPLAIN ANALYZE
SELECT SUM(amount) FROM expenses WHERE crop_id = 1;


-- 9. Migration ledger - confirms V0 through V4 applied cleanly.
SELECT version, description, success, installed_on
FROM flyway_schema_history
ORDER BY installed_rank;
