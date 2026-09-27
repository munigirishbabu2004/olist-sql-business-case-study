-- Cleaning decisions made after import, in the order they were found

-- 1. order_purchase_timestamp imported as text; converted to timestamp
ALTER TABLE orders
ALTER COLUMN order_purchase_timestamp TYPE TIMESTAMP
USING NULLIF(order_purchase_timestamp, '')::timestamp;

-- 2. order_approved_at had 160 blank values (orders never approved,
--    e.g. cancelled before payment). Converted to NULL rather than dropped,
--    since the order rows themselves are still valid.
ALTER TABLE orders
ALTER COLUMN order_approved_at TYPE TIMESTAMP
USING NULLIF(order_approved_at, '')::timestamp;

SELECT COUNT(*) FROM orders WHERE order_approved_at IS NULL;
-- Result: 160

-- 3. order_reviews: DBeaver's CSV import wizard could not correctly parse
--    multi-line review comments (rows shifted columns, e.g. review text
--    landing in review_id). Verified the source file was clean using
--    pandas, then generated a direct SQL INSERT script (99,224 rows)
--    that bypasses CSV parsing entirely.

-- 4. review_comment_title and review_comment_message were capped at
--    VARCHAR(256) by default, which rejected longer reviews.
--    Widened to unlimited TEXT (see table definition in 01_schema_and_load.sql).
