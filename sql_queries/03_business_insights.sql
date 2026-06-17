-- Top 10 States by Revenue
SELECT
customer_state,
SUM(payment_value) AS revenue
FROM fact_sales f
JOIN dim_customer c
ON f.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY revenue DESC
LIMIT 10;

-- Top Selling Products
SELECT
product_category_name,
COUNT(*) AS sales_count
FROM fact_sales
GROUP BY product_category_name
ORDER BY sales_count DESC
LIMIT 10;
