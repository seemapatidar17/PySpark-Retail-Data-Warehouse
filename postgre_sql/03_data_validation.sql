ELECT * FROM raw_data.customers
LIMIT 10;

SELECT COUNT(*) FROM raw_data.orders;

SELECT COUNT(*) FROM raw_data.customers

SELECT COUNT(*) FROM raw_data.order_items

SELECT COUNT(*) FROM raw_data.products

SELECT COUNT(*) FROM raw_data.sellers

SELECT *
FROM raw_data.orders
LIMIT 5;

SELECT COUNT(*)
FROM raw_data.orders;



/* Top States */

SELECT customer_state,
       COUNT(*)
FROM raw_data.customers
GROUP BY customer_state
ORDER BY COUNT(*) DESC;

/* Orders + Customers */

SELECT o.order_id,
       c.customer_city,
       o.order_status
FROM raw_data.orders o
JOIN raw_data.customers c
ON o.customer_id = c.customer_id
LIMIT 10;


/* Revenue-Per-Order */

SELECT o.order_id,
       p.payment_value
FROM raw_data.orders o
JOIN raw_data.payments p
ON o.order_id = p.order_id;


SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'raw_data';

SELECT *
FROM raw_data.orders
LIMIT 10;

SELECT *
FROM raw_data.products
LIMIT 10;

SELECT *
FROM raw_data.order_items
LIMIT 10;


SELECT *
FROM raw_data.orders
where order_status = 'delivered'


SELECT count(*)
FROM raw_data.orders
where order_status = 'delivered'

SELECT *
FROM raw_data.order_items
WHERE price>500

SELECT *
FROM raw_data.payments
ORDER BY payment_value DESC;

SELECT *
FROM raw_data.payments
ORDER BY payment_value ASC;

SELECT SUM(payment_value)
FROM raw_data.payments;

SELECT AVG(payment_value)
FROM raw_data.payments;

SELECT MAX(payment_value)
FROM raw_data.payments;

SELECT MIN(payment_value)
FROM raw_data.payments;


/*#Customers Per State */

SELECT customer_state,
       COUNT(*) AS total_customers
FROM raw_data.customers
GROUP BY customer_state
ORDER BY total_customers DESC;


/*Revenue By Payment Type */

SELECT payment_type,
       SUM(payment_value) AS revenue
FROM raw_data.payments
GROUP BY payment_type;

SELECT o.order_id,
       c.customer_city,
       o.order_status
FROM raw_data.orders o
JOIN raw_data.customers c
ON o.customer_id = c.customer_id
LIMIT 20;



SELECT p.product_category_name,
       SUM(oi.price) AS revenue
FROM raw_data.order_items oi
JOIN raw_data.products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;

/* Revenue By State */

SELECT c.customer_state,
       SUM(py.payment_value) AS revenue
FROM raw_data.orders o
JOIN raw_data.customers c
ON o.customer_id = c.customer_id
JOIN raw_data.payments py
ON o.order_id = py.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;



/*Top Customers */

SELECT o.customer_id,
       SUM(py.payment_value) AS total_spent
FROM raw_data.orders o
JOIN raw_data.payments py
ON o.order_id = py.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;

/* MONTHLY SALES TREND */

SELECT DATE_TRUNC('month',
       order_purchase_timestamp) AS month,
       COUNT(*) AS total_orders
FROM raw_data.orders
GROUP BY month
ORDER BY month;


SELECT order_id,
       payment_value,
       CASE
           WHEN payment_value > 500 THEN 'High Value'
           WHEN payment_value > 100 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS order_category
FROM raw_data.payments;

/* REVENUE */
WITH revenue_table AS (
    SELECT payment_type,
           SUM(payment_value) AS total_revenue
    FROM raw_data.payments
    GROUP BY payment_type
)
SELECT *
FROM revenue_table;

/* RANK */

SELECT customer_id,
       total_spent,
       RANK() OVER (
           ORDER BY total_spent DESC
       ) AS customer_rank
FROM (
    SELECT o.customer_id,
           SUM(py.payment_value) AS total_spent
    FROM raw_data.orders o
    JOIN raw_data.payments py
    ON o.order_id = py.order_id
    GROUP BY o.customer_id
) t;

CREATE VIEW raw_data.revenue_by_state AS

SELECT c.customer_state,
       SUM(py.payment_value) AS revenue
FROM raw_data.orders o
JOIN raw_data.customers c
ON o.customer_id = c.customer_id
JOIN raw_data.payments py
ON o.order_id = py.order_id
GROUP BY c.customer_state;


SELECT *
FROM raw_data.revenue_by_state;


SELECT SUM(payment_value)
FROM raw_data.payments;

SELECT COUNT(*)
FROM raw_data.orders;

SELECT COUNT(DISTINCT customer_id)
FROM raw_data.customers;

SELECT AVG(payment_value)
FROM raw_data.payments;


CREATE SCHEMA IF NOT EXISTS warehouse;

