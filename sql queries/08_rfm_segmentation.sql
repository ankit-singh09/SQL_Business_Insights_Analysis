--  Product & Category Performance

-- Which product categories generate the most revenue?
-- Which categories have the worst reviews?
--  Which sellers are top performers?
-- Are expensive products rated differently?

USE olist_ecommerce;
 -- Revenue by Product Category
 -- Join 4 tables: orders + order_items + products + translation
SELECT
    COALESCE(t.product_category_name_english, 'Uncategorized') AS category,
    COUNT(DISTINCT oi.order_id)                                 AS total_orders,
    ROUND(SUM(oi.price), 2)                                     AS total_revenue,
    ROUND(AVG(oi.price), 2)                                     AS avg_price,
    COUNT(DISTINCT oi.product_id)                               AS unique_products
FROM order_items oi
JOIN orders o        ON oi.order_id   = o.order_id
JOIN products p      ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
                     ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- Which categories make customers most unhappy?
SELECT
    COALESCE(t.product_category_name_english, 'Uncategorized') AS category,
    COUNT(r.review_id)                  AS total_reviews,
    ROUND(AVG(r.review_score), 2)       AS avg_review_score,
    SUM(CASE WHEN r.review_score <= 2
        THEN 1 ELSE 0 END)              AS bad_reviews,
    ROUND(SUM(CASE WHEN r.review_score <= 2
        THEN 1 ELSE 0 END) * 100.0
        / COUNT(r.review_id), 1)        AS bad_review_pct
FROM order_reviews r
JOIN orders o       ON r.order_id    = o.order_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t
                    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
HAVING COUNT(r.review_id) > 100     -- only categories with enough reviews
ORDER BY avg_review_score ASC
LIMIT 10;


-- Top 10 Sellers by Revenue
SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)         AS total_orders,
    ROUND(SUM(oi.price), 2)             AS total_revenue,
    ROUND(AVG(oi.price), 2)             AS avg_item_price,
    COUNT(DISTINCT oi.product_id)       AS products_sold
FROM order_items oi
JOIN orders o   ON oi.order_id  = o.order_id
JOIN sellers s  ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;