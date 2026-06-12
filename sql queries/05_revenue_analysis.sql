-- "How much money did Olist make, when, and is it growing?"

USE olist_ecommerce;

-- Total revenue across all time
-- We JOIN orders + order_items because:
-- orders tells us STATUS (delivered/cancelled etc.)
-- order_items tells us PRICE
SELECT
    COUNT(DISTINCT o.order_id)          AS total_orders,
    SUM(oi.price)                       AS total_product_revenue,
    SUM(oi.freight_value)               AS total_freight_revenue,
    SUM(oi.price + oi.freight_value)    AS total_revenue,
    ROUND(AVG(oi.price), 2)             AS avg_item_price,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';  -- only count completed orders

-- 💡 Key insight: Freight is 14.3% of total revenue — customers are paying significantly for shipping.
--  This is a pain point worth flagging in your business recommendations later.


-- Monthly revenue breakdown
-- DATE_FORMAT(date, '%Y-%m') converts '2017-11-24 12:30:00' → '2017-11'
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')    AS order_month,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(SUM(oi.price), 2)                             AS product_revenue,
    ROUND(SUM(oi.freight_value), 2)                     AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2)          AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2)          AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY order_month ASC;

-- 💡 From January 2017 to November 2017 — orders grew 10x in just 10 months. That is explosive e-commerce growth.



-- Year over year revenue
SELECT
    YEAR(o.order_purchase_timestamp)            AS order_year,
    COUNT(DISTINCT o.order_id)                  AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)  AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2)  AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY order_year ASC;

-- 💡 2017→2018 revenue grew 22% with orders growing 21.5%. Consistent, healthy growth — the platform matured.



-- Top 5 best revenue months
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')    AS order_month,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)          AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY total_revenue DESC
LIMIT 5;

-- 💡 November 2017 is the #1 month — Black Friday is massive in Brazil too.
-- And notice all top 5 spots except one are from 2018 — the platform got consistently stronger.



-- Top 5 worst revenue months (excluding first/last partial months)
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')    AS order_month,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)          AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'  -- exclude partial 2016 data
  AND o.order_purchase_timestamp < '2018-10-01'   -- exclude partial Oct 2018
GROUP BY order_month
ORDER BY total_revenue ASC
LIMIT 5;

-- 💡 All 5 worst months are from early 2017 — the platform's startup phase.
-- This is actually great news — it shows there are NO bad months in 2018. The business recovered completely.

