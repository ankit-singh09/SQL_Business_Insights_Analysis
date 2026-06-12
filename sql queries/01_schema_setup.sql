USE olist_ecommerce;

CREATE TABLE customers (
    customer_id              VARCHAR(50)  NOT NULL,
    customer_unique_id       VARCHAR(50)  NOT NULL,
    customer_zip_code_prefix VARCHAR(10)  NOT NULL,
    customer_city            VARCHAR(100) NOT NULL,
    customer_state           CHAR(2)      NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE sellers (
    seller_id               VARCHAR(50)  NOT NULL,
    seller_zip_code_prefix  VARCHAR(10)  NOT NULL,
    seller_city             VARCHAR(100) NOT NULL,
    seller_state            CHAR(2)      NOT NULL,
    PRIMARY KEY (seller_id)
);

CREATE TABLE product_category_translation (
    product_category_name          VARCHAR(100) NOT NULL,
    product_category_name_english  VARCHAR(100) NOT NULL,
    PRIMARY KEY (product_category_name)
);

CREATE TABLE products (
    product_id                  VARCHAR(50)  NOT NULL,
    product_category_name       VARCHAR(100) NULL,
    product_name_lenght         INT          NULL,
    product_description_lenght  INT          NULL,
    product_photos_qty          INT          NULL,
    product_weight_g            INT          NULL,
    product_length_cm           INT          NULL,
    product_height_cm           INT          NULL,
    product_width_cm            INT          NULL,
    PRIMARY KEY (product_id)
);

CREATE TABLE orders (
    order_id                       VARCHAR(50) NOT NULL,
    customer_id                    VARCHAR(50) NOT NULL,
    order_status                   VARCHAR(20) NOT NULL,
    order_purchase_timestamp       DATETIME    NULL,
    order_approved_at              DATETIME    NULL,
    order_delivered_carrier_date   DATETIME    NULL,
    order_delivered_customer_date  DATETIME    NULL,
    order_estimated_delivery_date  DATETIME    NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id            VARCHAR(50)    NOT NULL,
    order_item_id       INT            NOT NULL,
    product_id          VARCHAR(50)    NOT NULL,
    seller_id           VARCHAR(50)    NOT NULL,
    shipping_limit_date DATETIME       NULL,
    price               DECIMAL(10,2)  NOT NULL,
    freight_value       DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id)  REFERENCES sellers(seller_id)
);

CREATE TABLE order_payments (
    order_id             VARCHAR(50)    NOT NULL,
    payment_sequential   INT            NOT NULL,
    payment_type         VARCHAR(30)    NOT NULL,
    payment_installments INT            NOT NULL,
    payment_value        DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_reviews (
    review_id               VARCHAR(50)  NOT NULL,
    order_id                VARCHAR(50)  NOT NULL,
    review_score            TINYINT      NOT NULL,
    review_comment_title    VARCHAR(255) NULL,
    review_comment_message  TEXT         NULL,
    review_creation_date    DATETIME     NULL,
    review_answer_timestamp DATETIME     NULL,
    PRIMARY KEY (review_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10)    NOT NULL,
    geolocation_lat             DECIMAL(10,6)  NOT NULL,
    geolocation_lng             DECIMAL(10,6)  NOT NULL,
    geolocation_city            VARCHAR(100)   NOT NULL,
    geolocation_state           CHAR(2)        NOT NULL
);



