# Databricks notebook source
customers_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_files/olist_customers_dataset.csv",
    header=True,
    inferSchema=True
)

orders_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_files/olist_orders_dataset.csv",
    header=True,
    inferSchema=True
)

order_items_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_files/olist_order_items_dataset.csv",
    header=True,
    inferSchema=True
)

payments_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_files/olist_order_payments_dataset.csv",
    header=True,
    inferSchema=True
)

products_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_files/olist_products_dataset.csv",
    header=True,
    inferSchema=True
)

sellers_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_files/olist_sellers_dataset.csv",
    header=True,
    inferSchema=True
)

# COMMAND ----------

print("Customers:", customers_df.count())
print("Orders:", orders_df.count())
print("Order Items:", order_items_df.count())
print("Payments:", payments_df.count())
print("Products:", products_df.count())
print("Sellers:", sellers_df.count())

# COMMAND ----------

customers_df.printSchema()
orders_df.printSchema()

# COMMAND ----------

customers_df.createOrReplaceTempView("customers")
orders_df.createOrReplaceTempView("orders")
order_items_df.createOrReplaceTempView("order_items")
payments_df.createOrReplaceTempView("payments")
products_df.createOrReplaceTempView("products")
sellers_df.createOrReplaceTempView("sellers")

# COMMAND ----------

spark.sql("""
SELECT COUNT(*) AS total_orders
FROM orders
""").show()

# COMMAND ----------

dim_customer = customers_df.select(
    "customer_id",
    "customer_unique_id",
    "customer_city",
    "customer_state"
)

dim_customer.show(5)

# COMMAND ----------

dim_product = products_df.select(
    "product_id",
    "product_category_name",
    "product_weight_g",
    "product_length_cm",
    "product_height_cm",
    "product_width_cm"
)

dim_product.show(5)

# COMMAND ----------

dim_seller = sellers_df.select(
    "seller_id",
    "seller_city",
    "seller_state"
)

dim_seller.show(5)

# COMMAND ----------

from pyspark.sql.functions import *

dim_date = orders_df.select(
    col("order_purchase_timestamp")
).distinct()

dim_date = dim_date.withColumn(
    "purchase_date",
    to_date("order_purchase_timestamp")
)

dim_date = dim_date.withColumn(
    "year",
    year("purchase_date")
)

dim_date = dim_date.withColumn(
    "month",
    month("purchase_date")
)

dim_date = dim_date.withColumn(
    "day",
    dayofmonth("purchase_date")
)

dim_date.show(5)

# COMMAND ----------

fact_sales = (
    order_items_df
    .join(
        orders_df,
        "order_id",
        "inner"
    )
    .join(
        payments_df,
        "order_id",
        "left"
    )
)

fact_sales.show(5)

# COMMAND ----------

print("Fact Sales Rows:", fact_sales.count())

# COMMAND ----------

dim_customer.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("workspace.ecommerce.dim_customer")

# COMMAND ----------

dim_product.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("workspace.ecommerce.dim_product")

# COMMAND ----------

dim_seller.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("workspace.ecommerce.dim_seller")

# COMMAND ----------

dim_date.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("workspace.ecommerce.dim_date")

# COMMAND ----------

fact_sales.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("workspace.ecommerce.fact_sales")

# COMMAND ----------

spark.sql("""
SHOW TABLES IN workspace.ecommerce
""").show(truncate=False)

# COMMAND ----------

spark.sql("""
SELECT ROUND(SUM(payment_value),2) AS total_revenue
FROM workspace.ecommerce.fact_sales
""").show()

# COMMAND ----------

spark.sql("""
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM workspace.ecommerce.fact_sales
""").show()

# COMMAND ----------

spark.sql("""
SELECT
    c.customer_state,
    ROUND(SUM(f.payment_value),2) AS revenue
FROM workspace.ecommerce.fact_sales f
JOIN workspace.ecommerce.dim_customer c
ON f.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10
""").show()

# COMMAND ----------

spark.sql("""
SELECT
    p.product_category_name,
    COUNT(*) AS total_sales
FROM workspace.ecommerce.fact_sales f
JOIN workspace.ecommerce.dim_product p
ON f.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC
LIMIT 10
""").show()

# COMMAND ----------

spark.sql("""
SHOW TABLES IN workspace.ecommerce
""").show(truncate=False)

# COMMAND ----------

spark.sql("""
SELECT
ROUND(SUM(payment_value),2) AS total_revenue
FROM workspace.ecommerce.fact_sales
""").show()

# COMMAND ----------

spark.sql("""
SELECT
ROUND(
SUM(payment_value) /
COUNT(DISTINCT order_id)
,2) AS average_order_value
FROM workspace.ecommerce.fact_sales
""").show()

# COMMAND ----------

spark.sql("""
SELECT
payment_type,
COUNT(*) AS transactions
FROM workspace.ecommerce.fact_sales
GROUP BY payment_type
ORDER BY transactions DESC
""").show()

# COMMAND ----------

spark.sql("""
SELECT
YEAR(order_purchase_timestamp) AS year,
MONTH(order_purchase_timestamp) AS month,
ROUND(SUM(payment_value),2) AS revenue
FROM workspace.ecommerce.fact_sales
GROUP BY
YEAR(order_purchase_timestamp),
MONTH(order_purchase_timestamp)
ORDER BY year,month
""").show(100)

# COMMAND ----------

spark.sql("""
SELECT
seller_id,
ROUND(SUM(payment_value),2) AS revenue
FROM workspace.ecommerce.fact_sales
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10
""").show()

# COMMAND ----------

spark.sql("""
CREATE OR REPLACE VIEW workspace.ecommerce.v_revenue_by_state AS

SELECT
c.customer_state,
ROUND(SUM(f.payment_value),2) AS revenue

FROM workspace.ecommerce.fact_sales f

JOIN workspace.ecommerce.dim_customer c
ON f.customer_id = c.customer_id

GROUP BY c.customer_state
""")