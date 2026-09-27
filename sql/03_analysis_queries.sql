-- ============================================================
-- Query 1: How is revenue changing month to month, and which
-- months broke the trend?
-- ============================================================
WITH monthly AS (
  SELECT DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
         ROUND(SUM(oi.price)::numeric, 2) AS revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT month, revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;


-- ============================================================
-- Query 2: Which product categories generate the revenue, and
-- how concentrated is it?
-- ============================================================
SELECT COALESCE(t.product_category_name_english, 'unknown') AS category,
       ROUND(SUM(oi.price)::numeric, 0) AS revenue,
       ROUND((100 * SUM(oi.price) / SUM(SUM(oi.price)) OVER ())::numeric, 1) AS revenue_share_pct,
       RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- Query 3: What share of customers ever buy a second time?
-- ============================================================
WITH cust_orders AS (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT o.order_id) AS orders
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT COUNT(*) AS customers,
       COUNT(*) FILTER (WHERE orders >= 2) AS repeat_customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE orders >= 2) / COUNT(*), 2) AS repeat_rate_pct
FROM cust_orders;


-- ============================================================
-- Query 4: Do late deliveries hurt customer satisfaction, and
-- by how much?
-- ============================================================
WITH order_score AS (
  SELECT order_id, AVG(review_score) AS score
  FROM order_reviews
  GROUP BY order_id
)
SELECT CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On time' ELSE 'Late' END AS delivery,
       COUNT(*) AS orders,
       ROUND(AVG(s.score), 2) AS avg_review_score
FROM orders o
JOIN order_score s ON s.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1;


-- ============================================================
-- Query 5: How much of total spend comes from the top 10% of
-- customers?
-- ============================================================
WITH spend AS (
  SELECT c.customer_unique_id,
         SUM(pay.payment_value) AS total_spend
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  JOIN order_payments pay ON pay.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY 1
),
ranked AS (
  SELECT *, NTILE(10) OVER (ORDER BY total_spend DESC) AS decile
  FROM spend
)
SELECT decile, COUNT(*) AS customers,
       ROUND(SUM(total_spend)::numeric, 0) AS spend,
       ROUND((100 * SUM(total_spend) / SUM(SUM(total_spend)) OVER ())::numeric, 1) AS spend_share_pct
FROM ranked
GROUP BY decile
ORDER BY decile;


-- ============================================================
-- Query 6: Which sellers drive the most revenue?
-- ============================================================
SELECT s.seller_id, s.seller_state,
       COUNT(DISTINCT oi.order_id) AS orders,
       ROUND(SUM(oi.price)::numeric, 0) AS revenue,
       ROUND(AVG(oi.price)::numeric, 2) AS avg_item_price
FROM order_items oi
JOIN sellers s ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) > 10
ORDER BY revenue DESC
LIMIT 10;


-- ============================================================
-- Query 7: How many customers spend above the platform average?
-- ============================================================
SELECT COUNT(*) AS above_avg_customers
FROM (
  SELECT c.customer_unique_id, SUM(pay.payment_value) AS total_spend
  FROM customers c
  JOIN orders o ON o.customer_id = c.customer_id
  JOIN order_payments pay ON pay.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY 1
) sub
WHERE sub.total_spend > (
  SELECT AVG(payment_value) FROM order_payments
);


-- ============================================================
-- Query 8: Does seller state relate to delivery lateness?
-- (Testing Query 6's finding that revenue is SP-concentrated)
-- ============================================================
WITH order_delivery AS (
  SELECT oi.order_id, oi.seller_id, s.seller_state,
         CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
              THEN 0 ELSE 1 END AS is_late
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN sellers s ON s.seller_id = oi.seller_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
)
SELECT seller_state, COUNT(*) AS orders, SUM(is_late) AS late_orders,
       ROUND(100.0 * SUM(is_late) / COUNT(*), 1) AS late_pct
FROM order_delivery
GROUP BY seller_state
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;
