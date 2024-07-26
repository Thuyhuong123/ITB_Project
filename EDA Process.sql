--1.Creating Tables & Importing Data
CREATE TABLE Customers (
    order_item_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    customer_fname VARCHAR,
    customer_lname VARCHAR,
    customer_email VARCHAR,
    customer_password VARCHAR,
    customer_segment VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR,
    customer_country VARCHAR,
    customer_street VARCHAR,
    customer_zipcode VARCHAR
);

CREATE TABLE Categories (
    order_item_id INTEGER PRIMARY KEY,
    category_id INTEGER,
    category_name VARCHAR
);

CREATE TABLE Departments (
    order_item_id INTEGER PRIMARY KEY,
    department_id INTEGER,
    department_name VARCHAR
);

CREATE TABLE MarketRegions (
    order_item_id INTEGER PRIMARY KEY,
    market VARCHAR,
    latitude NUMERIC,
    longitude NUMERIC
);

CREATE TABLE Products (
    order_item_id INTEGER PRIMARY KEY,
    product_card_id INTEGER,
    product_category_id INTEGER,
    product_name VARCHAR,
    product_description TEXT,
    product_image TEXT,
    product_price NUMERIC,
    product_status VARCHAR
);

CREATE TABLE Orders (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    order_date DATE,
    shipping_date DATE,
    delivery_status VARCHAR,
    late_delivery_risk INTEGER,
    order_city VARCHAR,
    order_state VARCHAR,
    order_country VARCHAR,
    order_zipcode VARCHAR,
    customer_id INTEGER,
    market VARCHAR,
    order_status VARCHAR,
    shipping_mode VARCHAR,
    order_region VARCHAR
);

CREATE TABLE OrderDetails (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_card_id INTEGER,
    order_item_cardprod_id INTEGER,
    order_item_discount NUMERIC,
    order_item_discount_rate NUMERIC,
    order_item_product_price NUMERIC,
    order_item_profit_ratio NUMERIC,
    order_item_quantity INTEGER,
    sales NUMERIC,
    order_item_total NUMERIC,
    order_profit_per_order NUMERIC,
    benefit_per_order NUMERIC,
    sales_per_customer NUMERIC
);


--2. Cleaning & Structuring Data
-- 2.1.Check Null Values--
SELECT * 
FROM Customers
WHERE customer_id IS NULL;

SELECT * 
FROM Categories
WHERE category_id IS NULL;

SELECT * 
FROM Departments
WHERE department_id IS NULL;

SELECT * 
FROM Products
WHERE  product_card_id IS NULL OR product_category_id IS NULL;

SELECT * 
FROM Orders
WHERE  order_id IS NULL OR customer_id IS NULL;

SELECT * 
FROM OrderDetails
WHERE  order_id IS NULL OR product_card_id IS NULL OR sales IS NULL;

SELECT * 
FROM public.shipments
WHERE days_for_shipping_real IS NULL
OR days_for_shipment_scheduled IS NULL
or  order_id IS NULL
--3. EDA Process
--The total number of orders 
SELECT COUNT(*) AS total_orders FROM Orders;
--The total number of unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM Customers;
--Sales performance
SELECT 
	ROUND(SUM(sales),2) AS total_sales, 
	ROUND(AVG(sales),2) AS average_order_value 
FROM OrderDetails;
--Profit performance:
SELECT 
	 SUM(order_profit_per_order) AS total_profit ,
	 ROUND(AVG(order_profit_per_order),2) AS average_profit_per_order 
FROM OrderDetails;

--3.1. Shipments Performance:
--3.1.1.Number of Shipments:
--a. By Order region
SELECT 
    order_region,
    COUNT(*) AS total_orders
FROM Orders
GROUP BY order_region
ORDER BY total_orders DESC;
SELECT 
    order_region, order_country,
    COUNT(*) AS total_orders
FROM Orders
GROUP BY order_region, order_country
ORDER BY total_orders DESC;
--Late delivery Risk 
WITH TopRegions AS (
    SELECT 
        order_region, 
        COUNT(*) AS total_orders
    FROM Orders
    GROUP BY order_region
    ORDER BY total_orders DESC
    LIMIT 10
)
SELECT 
    tr.order_region,
    tr.total_orders,
    ROUND((SUM(CASE WHEN o.delivery_status = 'Late delivery' THEN 1 ELSE 0 END)*1.0 / COUNT(*)) * 100,2) || '%' AS late_delivery_rate
FROM Orders o
JOIN TopRegions tr ON o.order_region = tr.order_region
GROUP BY 
    tr.order_region, 
    tr.total_orders
ORDER BY tr.total_orders DESC;
--b.By Time:
SELECT 
  TO_CHAR(order_date, 'YYYY-MM') AS year_month,
    COUNT(*) AS total_orders
FROM Orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY TO_CHAR(order_date, 'YYYY-MM')

--3.1.1. Average Delivery Time
SELECT 
    ROUND(AVG(days_for_shipping_real),2) AS average_delivery_time
FROM Shipments;
--3.1.2.Delivery Time Variance:
SELECT 
    ROUND(AVG(days_for_shipping_real - days_for_shipment_scheduled),3) AS delivery_time_variance
FROM Shipments;
--3.1.3. On-time delivery rate:
SELECT 
    ROUND(SUM(CASE WHEN days_for_shipping_real <= days_for_shipment_scheduled THEN 1 
                   ELSE 0 
               END) * 100.0 / COUNT(*), 2) || '%' AS on_time_delivery_rate,
    ROUND(SUM(CASE WHEN days_for_shipping_real > days_for_shipment_scheduled + 2 THEN 1 
                   ELSE 0 
               END) * 100.0 / COUNT(*), 2) || '%' AS severely_late_delivery_rate
FROM Shipments;
--3.1.4. Detailed Shipping Analysis:
SELECT 
    o.shipping_mode,
   ROUND(AVG(s.days_for_shipping_real), 2) AS average_shipping_time
FROM 
    public.orders o
JOIN 
    public.shipments s ON o.order_id = s.order_id
GROUP BY 
    o.shipping_mode
	ORDER BY average_shipping_time

SELECT 
    o.shipping_mode,
    ROUND(SUM(CASE WHEN o.late_delivery_risk = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS on_time_delivery_rate
FROM 
    public.orders o
JOIN 
    public.shipments s ON o.order_id = s.order_id
GROUP BY 
    o.shipping_mode
ORDER BY on_time_delivery_rate;


SELECT 
    shipping_mode,
    COUNT(*) AS number_of_shipments
FROM 
    public.orders
GROUP BY 
    shipping_mode
ORDER BY 
    number_of_shipments DESC;

--3.2.Delivery Time Forecast
WITH cte1 AS (
SELECT a.order_item_id, a.days_for_shipping_real, 
a.days_for_shipment_scheduled, b.late_delivery_risk
FROM public.shipments AS a
JOIN public.orders AS b ON a.order_item_id=b.order_item_id
WHERE 
a.days_for_shipping_real>a.days_for_shipment_scheduled 
AND b.late_delivery_risk=0),
cte2 AS
(SELECT a.order_item_id, a.days_for_shipping_real, 
a.days_for_shipment_scheduled, b.late_delivery_risk
FROM public.shipments AS a
JOIN public.orders AS b ON a.order_item_id=b.order_item_id
WHERE a.days_for_shipping_real-a.days_for_shipment_scheduled>2
AND b.late_delivery_risk=0)
SELECT 
	COUNT(d.order_item_id) AS total_delivery,
	ROUND(COUNT(c.*)*100.0/COUNT(d.order_item_id),2)||'%' AS incorrect_late_risk_rate, 
	ROUND(COUNT(e.*)*100.0/COUNT(d.order_item_id),2)||'%' AS severely_incorrect_late_risk_rate
FROM 
cte1 AS c
LEFT JOIN cte2 AS e ON c.order_item_id=e.order_item_id
RIGHT JOIN public.orders AS d ON c.order_item_id=d.order_item_id
--3.3. Inventory Performance:
--3.3.1. Total Products Sold:

SELECT 
    SUM(od.order_item_quantity) AS total_items_ordered,
    SUM(CASE WHEN o.delivery_status != 'Shipping canceled' THEN od.order_item_quantity ELSE 0 END) AS total_items_sold,
    ROUND(100-SUM(CASE WHEN o.delivery_status != 'Shipping canceled' THEN od.order_item_quantity ELSE 0 END) * 100.0 / SUM(od.order_item_quantity), 2) || '%' AS canceled_rate
FROM 
    public.orderdetails od
JOIN 
    public.orders o ON od.order_id = o.order_id;
--3.3.2.Out of Stock Rate:

SELECT 
    (SUM(CASE WHEN product_status = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS out_of_stock_rate
FROM 
    public.products;
--3.3.3. Processing Time:

SELECT 
  AVG(shipping_date - order_date) AS avg_processing_day
FROM 
    public.orders

 


