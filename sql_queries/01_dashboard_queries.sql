-- Total Revenue
SELECT SUM(payment_value) AS total_revenue
FROM fact_sales;

-- Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM fact_sales;

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM fact_sales;
