-- Table creation for the Olist Brazilian E-Commerce dataset
-- Source: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
-- Load method: CSV import via DBeaver for most tables;
-- order_reviews loaded via generated INSERT script due to a CSV parsing
-- issue with multi-line review comments (see 02_data_cleaning.sql)

-- orders, order_items, order_payments, customers, products, category_translation, sellers
-- were imported via DBeaver's Import Data wizard from their respective CSV files.

CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
-- Loaded via 99,224 generated INSERT statements (see project README for why)

-- Row count verification
SELECT 'orders' AS tbl, COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers;
