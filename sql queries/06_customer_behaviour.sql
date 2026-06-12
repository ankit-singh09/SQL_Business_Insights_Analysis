-- LAG() looks at the PREVIOUS ROW's value
-- Much cleaner than self-joining

SELECT
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month)  AS prev_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
        * 100.0 /
        LAG(total_revenue) OVER (ORDER BY order_month)
    , 2)                                             AS growth_pct
FROM (
    -- Inner query: get monthly revenue first
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')    AS order_month,
        ROUND(SUM(oi.price + oi.freight_value), 2)          AS total_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
) AS monthly_data

ORDER BY order_month ASC;