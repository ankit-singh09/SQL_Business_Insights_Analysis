-- RFM CUSTOMER SEGMENTATION
USE olist_ecommerce;

USE olist_ecommerce;

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)             AS last_purchase_date,
        COUNT(DISTINCT o.order_id)                  AS frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2)  AS monetary
    FROM customers c
    JOIN orders o       ON c.customer_id  = o.customer_id   -- ✅ FIXED
    JOIN order_items oi ON o.order_id     = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_raw AS (
    SELECT
        customer_unique_id,
        DATEDIFF('2018-10-17', last_purchase_date)  AS recency_days,
        frequency,
        monetary
    FROM customer_orders
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM rfm_raw
)
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score)   AS total_rfm_score,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
        WHEN r_score = 1  AND f_score <= 2                  THEN 'Lost Customers'
        ELSE 'Potential Loyalists'
    END                             AS customer_segment
FROM rfm_scores
ORDER BY total_rfm_score DESC
LIMIT 20;


-- SEGMENT SUMMARY
WITH customer_orders AS (
    SELECT c.customer_unique_id,
        MAX(o.order_purchase_timestamp)            AS last_purchase_date,
        COUNT(DISTINCT o.order_id)                 AS frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS monetary
    FROM customers c
    JOIN orders o       ON c.customer_id  = o.customer_id
    JOIN order_items oi ON o.order_id     = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_raw AS (
    SELECT customer_unique_id,
        DATEDIFF('2018-10-17', last_purchase_date) AS recency_days,
        frequency, monetary
    FROM customer_orders
),
rfm_scores AS (
    SELECT customer_unique_id, recency_days, frequency, monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
    FROM rfm_raw
),
rfm_segments AS (
    SELECT CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
        WHEN r_score = 1  AND f_score <= 2                  THEN 'Lost Customers'
        ELSE 'Potential Loyalists'
    END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*)                                           AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM rfm_segments
GROUP BY customer_segment
ORDER BY customer_count DESC;