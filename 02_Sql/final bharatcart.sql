
USE bharatcart;

-- CUSTOMERS
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    gender VARCHAR(10),
    age INT,
    segment VARCHAR(20),
    join_date DATE
);

-- PRODUCTS
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    brand VARCHAR(50),
    cost_price FLOAT
);

-- SELLERS
CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100),
    seller_city VARCHAR(50),
    rating FLOAT,
    commission_pct FLOAT
);

-- ORDERS
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(20),
    payment_mode VARCHAR(20),
    delivery_days INT,
    order_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ORDER ITEMS
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    selling_price FLOAT,
    discount_pct FLOAT,
    seller_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- RETURNS
CREATE TABLE returns (
    order_id INT,
    return_reason VARCHAR(100),
    return_date DATE,
    refund_amount FLOAT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

show tables;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM returns;

SELECT 
ROUND(SUM(quantity * selling_price),2) AS total_revenue
FROM order_items;

SELECT 
ROUND(SUM((oi.selling_price - p.cost_price) * oi.quantity),2) AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

SELECT 
ROUND(
SUM((oi.selling_price - p.cost_price) * oi.quantity)
/
SUM(oi.selling_price * oi.quantity) * 100
,2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

SELECT 
ROUND(
COUNT(DISTINCT r.order_id) 
/ 
COUNT(DISTINCT o.order_id) * 100
,2) AS return_rate_pct
FROM orders o
LEFT JOIN returns r 
ON o.order_id = r.order_id;

SELECT 
o.city,
ROUND(SUM(oi.quantity * oi.selling_price),2) AS revenue
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.city
ORDER BY revenue DESC
LIMIT 5;

SELECT 
p.category,
ROUND(SUM((oi.selling_price - p.cost_price) * oi.quantity),2) AS category_profit
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_profit DESC;

SELECT 
o.payment_mode,
ROUND(SUM((oi.selling_price - p.cost_price) * oi.quantity),2) AS profit
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY o.payment_mode
ORDER BY profit DESC;

SELECT 
s.seller_name,
ROUND(SUM((oi.selling_price - p.cost_price) * oi.quantity),2) AS seller_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_name
ORDER BY seller_profit DESC
LIMIT 10;

SELECT 
MIN(selling_price - p.cost_price) AS min_margin,
MAX(selling_price - p.cost_price) AS max_margin
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;

SELECT 
p.category,
ROUND(SUM((oi.selling_price - p.cost_price) * oi.quantity),2) AS category_profit
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_profit DESC;

SELECT 
p.product_name,
ROUND(SUM((oi.selling_price - p.cost_price) * oi.quantity),2) AS product_profit
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY product_profit ASC
LIMIT 10;
SELECT 
CASE 
    WHEN discount_pct < 10 THEN 'Low Discount'
    WHEN discount_pct BETWEEN 10 AND 30 THEN 'Medium Discount'
    ELSE 'High Discount'
END AS discount_bucket,
ROUND(SUM((oi.selling_price - p.cost_price) * oi.quantity),2) AS profit
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id
GROUP BY discount_bucket;