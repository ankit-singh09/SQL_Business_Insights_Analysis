-- Turn OFF safe update mode temporarily
SET SQL_SAFE_UPDATES = 0;
USE olist_ecommerce;

-- Fix 1: Empty product categories → NULL
UPDATE products
SET product_category_name = NULL
WHERE product_category_name = '';

-- Fix 2: Empty review comments → NULL
UPDATE order_reviews
SET review_comment_message = NULL
WHERE review_comment_message = '';

-- Fix 3: Empty review titles → NULL
UPDATE order_reviews
SET review_comment_title = NULL
WHERE review_comment_title = '';

-- Turn safe mode back ON (good practice)
SET SQL_SAFE_UPDATES = 1;


-- Should return 0
SELECT COUNT(*) AS still_empty FROM products
WHERE product_category_name = '';

-- Should return 0
SELECT COUNT(*) AS still_empty FROM order_reviews
WHERE review_comment_message = '';


-- Check if products category is already clean
SELECT
    COUNT(*) AS total_products,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS proper_nulls,
    SUM(CASE WHEN product_category_name = '' THEN 1 ELSE 0 END)    AS empty_strings,
    SUM(CASE WHEN product_category_name IS NOT NULL 
             AND product_category_name != '' THEN 1 ELSE 0 END)    AS has_category
FROM products;