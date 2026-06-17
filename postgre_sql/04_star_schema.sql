CREATE TABLE warehouse.dim_customer (

    customer_key SERIAL PRIMARY KEY,

    customer_id VARCHAR(50),

    customer_city VARCHAR(100),

    customer_state VARCHAR(10)

);

INSERT INTO warehouse.dim_customer (
    customer_id,
    customer_city,
    customer_state
)

SELECT DISTINCT
    customer_id,
    customer_city,
    customer_state

FROM raw_data.customers;

SELECT  count(*)
FROM warehouse.dim_customer
LIMIT 10;


----------------------------------------------------

CREATE TABLE warehouse.dim_product (

    product_key SERIAL PRIMARY KEY,

    product_id VARCHAR(50),

    product_category_name VARCHAR(100)

);

INSERT INTO warehouse.dim_product (
product_id ,
product_category_name 

)

SELECT DISTINCT 
    product_id,
	product_category_name

FROM  raw_data.products	


----------------------------------------------------------


CREATE TABLE warehouse.dim_seller(
seller_key SERIAL PRIMARY KEY,
seller_id VARCHAR(50),
seller_city VARCHAR(50),
seller_state VARCHAR(50)
);

INSERT INTO warehouse.dim_seller(
seller_id,
seller_city,
seller_state
)

SELECT DISTINCT
seller_id,
seller_city,
seller_state

FROM raw_data.sellers


----------------------------------------------------------------------------

CREATE TABLE warehouse.dim_date(
date_key SERIAL PRIMARY KEY,
full_date TIMESTAMP,
year INT,
month INT,
day INT,
quarter INT
);

INSERT INTO warehouse.dim_date(
full_date,
year,
month,
day,
quarter
)

SELECT DISTINCT
order_purchase_timestamp,
EXTRACT(YEAR FROM order_purchase_timestamp),
EXTRACT(MONTH FROM order_purchase_timestamp),
EXTRACT(DAY FROM order_purchase_timestamp),
EXTRACT(QUARTER FROM order_purchase_timestamp)

FROM raw_data.orders
WHERE order_purchase_timestamp IS NOT NULL;


---------------------------------------------------------------------------------------------------------------------------

CREATE TABLE warehouse.fact_orders(
fact_order_key SERIAL PRIMARY KEY,
order_id VARCHAR(50),
customer_key INT,
product_key INT,
seller_key INT,
date_key INT,
payment_value NUMERIC,
price NUMERIC,
freight_value NUMERIC
);

INSERT INTO warehouse.fact_orders(
order_id,
customer_key,
product_key,
seller_key,
date_key,
payment_value,
price,
freight_value
)

SELECT 
o.order_id,
dc.customer_key,
dp.product_key,
ds.seller_key,
dd.date_key,
py.payment_value,
oi.price,
oi.freight_value

FROM raw_data.orders o
JOIN raw_data.order_items oi
ON o.order_id = oi.order_id

JOIN raw_data.payments py
ON o.order_id = py.order_id

JOIN warehouse.dim_customer dc
ON o.customer_id = dc.customer_id

JOIN warehouse.dim_product dp
ON oi.product_id = dp.product_id

JOIN warehouse.dim_seller ds
ON oi.seller_id = ds.seller_id

JOIN warehouse.dim_date dd
ON o.order_purchase_timestamp = dd.full_date;
--------------------------------------------------------------------------------------------------

ALTER TABLE warehouse.fact_orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_key)
REFERENCES warehouse.dim_customer(customer_key);

ALTER TABLE warehouse.fact_orders
ADD CONSTRAINT fk_product
FOREIGN KEY (product_key)
REFERENCES warehouse.dim_product(product_key);

ALTER TABLE warehouse.fact_orders
ADD CONSTRAINT fk_seller
FOREIGN KEY (seller_key)
REFERENCES warehouse.dim_seller(seller_key);

ALTER TABLE warehouse.fact_orders
ADD CONSTRAINT fk_date
FOREIGN KEY (date_key)
REFERENCES warehouse.dim_date(date_key);
