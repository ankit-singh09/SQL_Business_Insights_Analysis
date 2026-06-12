USE olist_ecommerce;

-- NULLs in orders (most important table)
SELECT
    COUNT(*)                                        AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)                       AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)                    AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END)                   AS null_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END)       AS null_purchase_ts,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END)              AS null_approved,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END)   AS null_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END)  AS null_delivery_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END)  AS null_estimated_date
FROM orders;

-- NULLs in order_items
SELECT
    COUNT(*)                                                    AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)          AS null_order_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)        AS null_product_id,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END)         AS null_seller_id,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END)             AS null_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END)     AS null_freight
FROM order_items;


-- NULLs in products (products often have missing category)
SELECT
    COUNT(*)                                                            AS total_rows,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END)    AS null_category,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END)         AS null_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END)        AS null_length
FROM products;


-- NULLs in order_reviews
SELECT
    COUNT(*)                                                                AS total_rows,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END)               AS null_score,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END)     AS null_comment
FROM order_reviews;


-- Check duplicate order_ids in orders table (should be 0)
SELECT order_id, COUNT(*) AS count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check duplicate customer entries (same person, multiple IDs — this is expected)
SELECT customer_unique_id, COUNT(*) AS order_count
FROM customers
GROUP BY customer_unique_id
ORDER BY order_count DESC
LIMIT 10;


-- CHACKING DATA RANGE
-- What time period does our data cover?
SELECT
    MIN(order_purchase_timestamp)   AS earliest_order,
    MAX(order_purchase_timestamp)   AS latest_order,
    DATEDIFF(
        MAX(order_purchase_timestamp),
        MIN(order_purchase_timestamp)
    )                               AS total_days_of_data
FROM orders;


-- ORDER STATUS BREAKDOWN
-- What order statuses exist and how many?
SELECT
    order_status,
    COUNT(*)                            AS count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY count DESC;


-- QUICK SANITY check
-- Highest and lowest order values
SELECT
    MIN(price)      AS cheapest_item,
    MAX(price)      AS most_expensive_item,
    AVG(price)      AS avg_price,
    MIN(freight_value)  AS min_freight,
    MAX(freight_value)  AS max_freight
FROM order_items;



-- Review score distribution
SELECT
    review_score,
    COUNT(*)                                        AS count,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM order_reviews), 2)   AS percentage
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


SELECT COUNT(*) AS empty_category
FROM products
WHERE product_category_name = '' 
   OR product_category_name IS NULL;
   
   
SELECT COUNT(*) AS empty_comments
FROM order_reviews
WHERE review_comment_message = ''; 
   