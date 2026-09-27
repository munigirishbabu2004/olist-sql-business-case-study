# Olist Marketplace: SQL Business Case Study

A PostgreSQL analysis of ~99K orders from a Brazilian e-commerce marketplace, tracing a single connected problem across revenue, retention, delivery, and sellers — using 8 queries that cover joins, CTEs, window functions, subqueries, and CASE logic.

## Business Problem
The marketplace has uneven monthly revenue, and most customers never return.

## Project Objectives
1. How is revenue changing month to month, and which months broke the trend?
2. Which product categories generate the revenue, and how concentrated is it?
3. What share of customers ever buy a second time?
4. Do late deliveries hurt customer satisfaction, and by how much?
5. How much of total spend comes from the top 10% of customers?
6. Which sellers drive the most revenue?
7. How many customers spend above the platform average?
8. Does seller state relate to delivery lateness?

## Dataset
[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) — real, anonymized orders, Sept 2016–Oct 2018. See `data/README.md` for load instructions.

## Tools Used
PostgreSQL, DBeaver

## Data Cleaning
- Converted `order_purchase_timestamp` and `order_approved_at` from text to proper TIMESTAMP columns.
- Found and handled 160 blank approval timestamps (orders never approved) as NULL rather than dropping the rows.
- Worked around a DBeaver CSV-parsing failure on multi-line review comments by generating a direct SQL INSERT script for all 99,224 review rows.
- Widened review comment columns from VARCHAR(256) to TEXT to stop truncation errors on longer reviews.

Full details in `sql/02_data_cleaning.sql`.

## Analysis Process
Loaded 8 tables (99,441 orders, 112,650 order items, 99,224 reviews, 3,095 sellers, and more), cleaned and validated the data, then wrote 8 SQL queries answering the questions above. Each query's output is screenshotted in `images/`.

## Key Insights
1. Revenue grew from $111,798 (Jan 2017) to a peak of $987,752 (Nov 2017), then plateaued through mid-2018.
2. Revenue is spread across 72 categories — no single one dominates (top 10 = 62.4%).
3. Only 3% of customers (2,801 of 93,358) ever place a second order.
4. Late deliveries average 2.57-star reviews vs 4.29 for on-time — a 40% drop.
5. The top 10% of customers drive 38.3% of total spend.
6. 9 of the top 10 sellers by revenue are based in São Paulo.
7. 32.6% of customers spend above the platform average.
8. São Paulo's 8.5% late-delivery rate is worse than 9 of the other 12 states, despite carrying ~82% of order volume.

Full five-part insights in `docs/insights_and_recommendations.md`.

## Recommendations
- **Fix delivery reliability in São Paulo first** — it carries the most volume and an above-average late rate.
- **Build a retention offer for first-time buyers** — even 3% → 5% adds ~1,900 repeat customers.
- **Create a top-decile customer program** — protect the segment already driving 38.3% of spend.

Full detail, including the metric to watch for each, in `docs/insights_and_recommendations.md`.

## Files Included
- `sql/01_schema_and_load.sql` — table setup and row-count verification
- `sql/02_data_cleaning.sql` — cleaning decisions
- `sql/03_analysis_queries.sql` — all 8 analysis queries
- `images/` — query result screenshots
- `docs/insights_and_recommendations.md` — full insights and recommendations
- `data/README.md` — dataset source and load steps

## How to Use This Project
See `data/README.md` for loading the dataset, then run the SQL files in order: `01_schema_and_load.sql`, `02_data_cleaning.sql`, `03_analysis_queries.sql`.
