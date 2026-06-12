-- Customer Behaviour Analysis 👥

-- How many unique customers do we have?
-- How many customers buy more than once?
-- Which cities/states have the most customers?
-- What's the average time between order and delivery?
-- What payment methods do customers prefer

-- Unique Customers vs Repeat Buyers
-- How loyal are Olist's customers?
SELECT
    COUNT(DISTINCT customer_unique_id)          AS unique_customers,
    COUNT(DISTINCT customer_id)                 AS total_customer_records,
    COUNT(DISTINCT customer_id) -
    COUNT(DISTINCT customer_unique_id)          AS repeat_buyer_records,
    ROUND(
        (COUNT(DISTINCT customer_id) -
         COUNT(DISTINCT customer_unique_id))
        * 100.0 / COUNT(DISTINCT customer_unique_id)
    , 2)                                        AS repeat_rate_pct
FROM customers;

-- Only 3.48% of customers come back. 
-- That means 96.52% buy once and never return. This is a critical weakness — acquiring new customers is expensive. Retaining them is cheap.


--  Top 10 States by Customers
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id)      AS unique_customers,
    ROUND(COUNT(DISTINCT customer_unique_id) * 100.0 /
        (SELECT COUNT(DISTINCT customer_unique_id) FROM customers), 2) AS pct_of_total
FROM customers
GROUP BY customer_state
ORDER BY unique_customers DESC
LIMIT 10;

-- 💡 São Paulo alone = 42% of all customers. 
-- Top 3 states = 66% of all customers. Olist is heavily concentrated in Southeast Brazil. Huge growth opportunity exists in northern states.

-- Average Delivery Time
-- How fast does Olist deliver?
SELECT
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )), 1)                          AS avg_delivery_days,

    ROUND(MIN(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )), 1)                          AS fastest_delivery_days,

    ROUND(MAX(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )), 1)                          AS slowest_delivery_days,

    -- On time vs late
    SUM(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 1 ELSE 0
    END)                            AS delivered_on_time,

    SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1 ELSE 0
    END)                            AS delivered_late

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
  
  -- 💡 91.9% on-time delivery is actually good for Brazil — the country has massive geography and logistics challenges. 
  -- The 210-day delivery is clearly an outlier, probably a lost package that eventually arrived.
  
  
  -- Payment Method Preferences
  SELECT
    payment_type,
    COUNT(*)                                        AS total_transactions,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM order_payments), 2)  AS percentage,
    ROUND(AVG(payment_value), 2)                   AS avg_payment_value,
    ROUND(AVG(payment_installments), 1)            AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;

-- Two uniquely Brazilian insights:

-- 1. Boleto = a printed payment slip used at banks/shops. 19% of 
--    Brazilians still pay this way — no credit card needed. Very Brazilian!
-- 2. 3.5 average installments on credit cards — Brazilians commonly split purchases
--    into monthly payments. Credit card users spend MORE (R$163 vs R$145) because installments make it feel affordable.