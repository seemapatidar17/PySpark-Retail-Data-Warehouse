-- Average Order Value
SELECT
SUM(payment_value) / COUNT(DISTINCT order_id) AS avg_order_value
FROM fact_sales;

-- Revenue Per Customer
SELECT
SUM(payment_value) / COUNT(DISTINCT customer_id) AS revenue_per_customer
FROM fact_sales;

-- Monthly Revenue
SELECT
date_format(order_purchase_timestamp,'yyyy-MM') AS month,
SUM(payment_value) AS revenue
FROM fact_sales
GROUP BY month
ORDER BY month;
