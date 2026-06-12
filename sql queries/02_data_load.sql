USE olist_ecommerce;

-- 1. customers (load first — orders depends on it)
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. sellers
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. product_category_translation
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/product_category_name_translation.csv'
INTO TABLE product_category_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 4. products
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 5. orders
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 6. order_items
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 7. order_payments
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 8. order_reviews
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 9. geolocation (biggest file — ~1 million rows, takes 30-60 sec, be patient)
LOAD DATA LOCAL INFILE 'E:/DA-/Projects/SQL_Business_Insights_Analysis/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;