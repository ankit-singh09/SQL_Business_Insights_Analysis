import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns

# ── 1. Connect to MySQL ──────────────────────────────────────
conn = mysql.connector.connect(
    host     = "localhost",
    user     = "root",
    password = "ankitsingh",   
    database = "olist_ecommerce"
)
print("✅ Connected to MySQL!")

# ── 2. Helper function ───────────────────────────────────────
def run_query(sql):
    return pd.read_sql(sql, conn)

# ── 3. Load all data we need ─────────────────────────────────

# Monthly revenue
monthly_rev = run_query("""
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        ROUND(SUM(oi.price + oi.freight_value), 2)       AS total_revenue,
        COUNT(DISTINCT o.order_id)                        AS total_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
    ORDER BY order_month
""")

# Top 10 categories
top_categories = run_query("""
    SELECT
        COALESCE(t.product_category_name_english, 'Uncategorized') AS category,
        ROUND(SUM(oi.price), 2) AS total_revenue
    FROM order_items oi
    JOIN orders o   ON oi.order_id   = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_translation t
              ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY category
    ORDER BY total_revenue DESC
    LIMIT 10
""")

# Payment method distribution
payments = run_query("""
    SELECT payment_type, COUNT(*) AS count
    FROM order_payments
    GROUP BY payment_type
    ORDER BY count DESC
""")

# Review score distribution
reviews = run_query("""
    SELECT review_score, COUNT(*) AS count
    FROM order_reviews
    GROUP BY review_score
    ORDER BY review_score
""")

# RFM Segments
rfm_segments = run_query("""
    WITH customer_orders AS (
        SELECT c.customer_unique_id,
            MAX(o.order_purchase_timestamp)            AS last_purchase_date,
            COUNT(DISTINCT o.order_id)                 AS frequency,
            ROUND(SUM(oi.price + oi.freight_value), 2) AS monetary
        FROM customers c
        JOIN orders o       ON c.customer_id = o.customer_id
        JOIN order_items oi ON o.order_id    = oi.order_id
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
        SELECT customer_unique_id,
            NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
            NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
            NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
        FROM rfm_raw
    )
    SELECT
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                  THEN 'New Customers'
            WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
            WHEN r_score = 1  AND f_score <= 2                  THEN 'Lost Customers'
            ELSE 'Potential Loyalists'
        END AS segment,
        COUNT(*) AS count
    FROM rfm_scores
    GROUP BY segment
    ORDER BY count DESC
""")

print("✅ All data loaded!")

# ── 4. Plot all charts ───────────────────────────────────────
fig, axes = plt.subplots(2, 2, figsize=(18, 12))
fig.suptitle('Olist Brazilian E-Commerce — Business Intelligence Dashboard',
             fontsize=16, fontweight='bold', y=1.01)

sns.set_style("whitegrid")
colors = sns.color_palette("Blues_d", 10)

# Chart 1: Monthly Revenue Trend
ax1 = axes[0, 0]
ax1.plot(monthly_rev['order_month'],
         monthly_rev['total_revenue'],
         color='steelblue', linewidth=2.5, marker='o', markersize=4)
ax1.fill_between(monthly_rev['order_month'],
                 monthly_rev['total_revenue'], alpha=0.2, color='steelblue')
ax1.set_title('Monthly Revenue Trend (2016–2018)', fontweight='bold')
ax1.set_xlabel('Month')
ax1.set_ylabel('Revenue (R$)')
ax1.tick_params(axis='x', rotation=45)
ax1.yaxis.set_major_formatter(mticker.FuncFormatter(
    lambda x, _: f'R${x:,.0f}'))

# Chart 2: Top 10 Categories by Revenue
ax2 = axes[0, 1]
bars = ax2.barh(top_categories['category'],
                top_categories['total_revenue'],
                color=colors)
ax2.set_title('Top 10 Product Categories by Revenue', fontweight='bold')
ax2.set_xlabel('Revenue (R$)')
ax2.invert_yaxis()
ax2.xaxis.set_major_formatter(mticker.FuncFormatter(
    lambda x, _: f'R${x:,.0f}'))

# Chart 3: Payment Method Distribution
ax3 = axes[1, 0]
ax3.pie(payments['count'],
        labels=payments['payment_type'],
        autopct='%1.1f%%',
        colors=sns.color_palette("Set2"),
        startangle=90)
ax3.set_title('Payment Method Distribution', fontweight='bold')

# Chart 4: RFM Customer Segments
ax4 = axes[1, 1]
seg_colors = ['#2ecc71','#3498db','#f39c12','#e74c3c','#9b59b6','#1abc9c']
ax4.bar(rfm_segments['segment'],
        rfm_segments['count'],
        color=seg_colors[:len(rfm_segments)])
ax4.set_title('RFM Customer Segmentation', fontweight='bold')
ax4.set_xlabel('Segment')
ax4.set_ylabel('Number of Customers')
ax4.tick_params(axis='x', rotation=25)

plt.tight_layout()
plt.savefig('olist_dashboard.png', dpi=150, bbox_inches='tight')
plt.show()
print("✅ Dashboard saved as olist_dashboard.png")

conn.close()