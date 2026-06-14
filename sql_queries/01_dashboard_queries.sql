--Total Revenue
SELECT
ROUND(SUM(payment_value),2) AS total_revenue
FROM workspace.ecommerce.fact_sales

--Total Orders
SELECT
COUNT(DISTINCT order_id) AS total_orders
FROM workspace.ecommerce.fact_sales

-- Total Customers
SELECT
COUNT(DISTINCT customer_id) AS total_customers
FROM workspace.ecommerce.dim_customer


-- Revenue by Month
SELECT
YEAR(order_purchase_timestamp) AS year,
MONTH(order_purchase_timestamp) AS month,
ROUND(SUM(payment_value),2) AS revenue
FROM workspace.ecommerce.fact_sales
GROUP BY
YEAR(order_purchase_timestamp),
MONTH(order_purchase_timestamp)
ORDER BY year, month

--Revenue by State
SELECT
dc.customer_state,
ROUND(SUM(fs.payment_value),2) AS revenue
FROM workspace.ecommerce.fact_sales fs
JOIN workspace.ecommerce.dim_customer dc
ON fs.customer_id = dc.customer_id
GROUP BY dc.customer_state
ORDER BY revenue DESC
