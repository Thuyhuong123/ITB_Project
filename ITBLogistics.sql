--I. Create Dataset & Import Data:--
CREATE TABLE ITBlogistics (
    Type VARCHAR(50),
    Days_for_shipping_real INT,
    Days_for_shipment_scheduled INT,
    Benefit_per_order DECIMAL(10, 2),
    Sales_per_customer DECIMAL(10, 2),
    Delivery_Status VARCHAR(50),
    Late_delivery_risk INT,
    Category_Id INT,
    Category_Name VARCHAR(100),
    Customer_City VARCHAR(100),
    Customer_Country VARCHAR(100),
    Customer_Email VARCHAR(100),
    Customer_Fname VARCHAR(50),
    Customer_Id INT,
    Customer_Lname VARCHAR(50),
    Customer_Password VARCHAR(100),
    Customer_Segment VARCHAR(50),
    Customer_State VARCHAR(100),
    Customer_Street VARCHAR(100),
    Customer_Zipcode VARCHAR(20),
    Department_Id INT,
    Department_Name VARCHAR(100),
    Latitude DECIMAL(10, 7),
    Longitude DECIMAL(10, 7),
    Market VARCHAR(50),
    Order_City VARCHAR(100),
    Order_Country VARCHAR(100),
    Order_Customer_Id INT,
    Order_Date DATE,
    Order_Id INT,
    Order_Item_Cardprod_Id INT,
    Order_Item_Discount DECIMAL(10, 2),
    Order_Item_Discount_Rate DECIMAL(10, 2),
    Order_Item_Id INT,
    Order_Item_Product_Price DECIMAL(10, 2),
    Order_Item_Profit_Ratio DECIMAL(10, 2),
    Order_Item_Quantity INT,
    Sales DECIMAL(10, 2),
    Order_Item_Total DECIMAL(10, 2),
    Order_Profit_Per_Order DECIMAL(10, 2),
    Order_Region VARCHAR(100),
    Order_State VARCHAR(100),
    Order_Status VARCHAR(50),
    Order_Zipcode VARCHAR(20),
    Product_Card_Id INT,
    Product_Category_Id INT,
    Product_Description TEXT,
    Product_Image TEXT,
    Product_Name VARCHAR(100),
    Product_Price DECIMAL(10, 2),
    Product_Status VARCHAR(50),
    Shipping_Date DATE,
    Shipping_Mode VARCHAR(50)
);
--II. Make EDA process on the dataset:--
--Understand the Structure of the Dataset:--
--1.1. Inspect the Schema:--
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'itblogistics'
AND table_schema = 'public';
--1.2. View Data Sample: --
--View 10 first records of the dataset--
SELECT * FROM
public.itblogistics
LIMIT 10
--2. Summary Statistics:--
--2.1.Count the number of rows: --
SELECT COUNT(*) AS total_records FROM public.itblogistics;
--2.2. Count the unique values:--
--Unique values: order_id, customer_id, category_id--
SELECT 
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT category_id) AS unique_product_categories
FROM public.itblogistics;
--2.3. Summary Statistics for Numeric Columns:--
SELECT 
    'days_for_shipping_real' AS column_name,
    ROUND(AVG(days_for_shipping_real),2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_for_shipping_real) AS median_value,
    ROUND(STDDEV(days_for_shipping_real),2) AS std_dev_value,
    MIN(days_for_shipping_real) AS min_value,
    MAX(days_for_shipping_real) AS max_value,
    COUNT(days_for_shipping_real) AS count_value
FROM 
public.itblogistics
UNION ALL
SELECT 
    'days_for_shipment_scheduled' AS column_name,
    ROUND(AVG(days_for_shipment_scheduled),2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_for_shipment_scheduled) AS median_value,
    ROUND(STDDEV(days_for_shipment_scheduled),2) AS std_dev_value,
    MIN(days_for_shipment_scheduled) AS min_value,
    MAX(days_for_shipment_scheduled) AS max_value,
    COUNT(days_for_shipment_scheduled) AS count_value
FROM 
public.itblogistics

UNION ALL
SELECT 
    'product_price' AS column_name,
    ROUND(AVG(product_price),2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY product_price) AS median_value,
   ROUND(STDDEV(product_price),2) AS std_dev_value,
    MIN(product_price) AS min_value,
    MAX(product_price) AS max_value,
    COUNT(product_price) AS count_value
FROM 
    public.itblogistics
UNION ALL

SELECT 
    'sales' AS column_name,
    ROUND(AVG(sales),2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sales) AS median_value,
    ROUND(STDDEV(sales),2) AS std_dev_value,
    MIN(sales) AS min_value,
    MAX(sales) AS max_value,
    COUNT(sales) AS count_value
FROM 
    public.itblogistics
UNION ALL

SELECT 
    'sales_per_customer' AS column_name,
    ROUND(AVG(sales_per_customer),2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sales_per_customer) AS median_value,
    ROUND(STDDEV(sales_per_customer),2) AS std_dev_value,
    MIN(sales_per_customer) AS min_value,
    MAX(sales_per_customer) AS max_value,
    COUNT(sales_per_customer) AS count_value
FROM 
    public.itblogistics
UNION ALL

SELECT 
    'benefit_per_customer' AS column_name,
    ROUND(AVG(benefit_per_customer),2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY benefit_per_customer) AS median_value,
    ROUND(STDDEV(benefit_per_customer),2) AS std_dev_value,
    MIN(benefit_per_customer) AS min_value,
    MAX(benefit_per_customer) AS max_value,
    COUNT(benefit_per_customer) AS count_value
FROM 
    public.itblogistics
--3. Data distribution:--
--3.1. Frequency Distribution of Categorical Columns and their correlations with Late delivery risk:--
SELECT 
	late_delivery_risk,
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY late_delivery_risk;
--- Distribution of shipping mode by late delivery risk---
SELECT 
	shipping_mode,
	late_delivery_risk, 
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY shipping_mode,
	late_delivery_risk;
--- Distribution of department by late delivery risk---
SELECT 
	department_name,
	late_delivery_risk, 
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY department_name,
	late_delivery_risk
--- Distribution of order region by late delivery risk---
SELECT 
	order_region,
	late_delivery_risk, 
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY order_region,
	late_delivery_risk
--3.2 Histogram of Numeric Columns--
--Distribution of Days for shipments (real)--
SELECT 
    "days_for_shipping_real", 
    COUNT(*) AS frequency
FROM 
    public.itblogistics
GROUP BY 
    "days_for_shipping_real"
ORDER BY 
    "days_for_shipping_real";
--Distribution of Days for shipments (scheduled)--
SELECT 
    "days_for_shipment_scheduled", 
    COUNT(*) AS frequency
FROM 
    public.itblogistics
GROUP BY 
    "days_for_shipment_scheduled"
ORDER BY 
    "days_for_shipment_scheduled";
--Distribution of Product price--
SELECT 
    "product_price", 
    COUNT(*) AS frequency
FROM 
    public.itblogistics
GROUP BY 
    "product_price"
ORDER BY 
    "product_price";
----Distribution of Sales--
SELECT 
    "sales", 
    COUNT(*) AS frequency
FROM 
    public.itblogistics
GROUP BY 
    "sales"
ORDER BY 
    "sales";
----Distribution of Sales per customer--
SELECT 
    "sales_per_customer", 
    COUNT(*) AS frequency
FROM 
    public.itblogistics
GROUP BY 
    "sales_per_customer"
ORDER BY 
    sales_per_customer
----Distribution of Benefit per order--
 SELECT 
    "benefit_per_order", 
    COUNT(*) AS frequency
FROM 
    public.itblogistics
GROUP BY 
    "benefit_per_order"
ORDER BY 
    benefit_per_order
--4. Identify Missing Values--
--Count Null in Key Columns: category_id, customer_id, order_id
SELECT 
    SUM(CASE WHEN category_id IS NULL THEN 1 ELSE 0 END) AS missing_category_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customerid,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id
FROM public.itblogistics;
--5. Outlier Detection and Handle in Sales Columns--
WITH abc AS (
    SELECT
        q1 - 1.5 * iqr AS min,
        q3 + 1.5 * iqr AS max
    FROM (
        SELECT
            percentile_cont(0.25) WITHIN GROUP (ORDER BY "sales") AS q1,
            percentile_cont(0.75) WITHIN GROUP (ORDER BY "sales") AS q3,
            percentile_cont(0.75) WITHIN GROUP (ORDER BY "sales") - percentile_cont(0.25) 
	WITHIN GROUP (ORDER BY "sales") AS iqr
        FROM public.itblogistics
    ) AS a
)
, twt_outliers AS (
SELECT * FROM public.itblogistics
WHERE "sales" < (SELECT min FROM abc)
   OR "sales" > (SELECT max FROM abc)
	)
UPDATE public.itblogistics
SET sales = (SELECT AVG(sales)
FROM public.itblogistics)
WHERE sales IN (SELECT sales FROM twt_outliers)
--6. Check Duplicates--
WITH ranked_data AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY order_id, customer_id ORDER BY order_date) AS rnk
    FROM
        public.itblogistics
)
SELECT *
FROM ranked_data 
    WHERE rnk > 1
;
--7. Monthly Sales Trends--
SELECT
    EXTRACT (YEAR FROM shipping_date) AS year,
    EXTRACT( MONTH FROM shipping_date) AS month,
    SUM(sales) AS total_sales
FROM public.itblogistics
GROUP BY year, month
ORDER BY year, month;

	
----Calculate the cumulative percentage of total sales contributed by each product category-----

WITH twt_total_sales AS (
    SELECT 
        category_name,
        SUM(sales) AS total_sales
    FROM itblogistics
    GROUP BY category_name
),
grand_sales AS (
    SELECT SUM(total_sales) AS grand_sales
    FROM twt_total_sales
),
cumulative_sales AS (
    SELECT 
        category_name, 
        total_sales, 
        SUM(total_sales) OVER (ORDER BY total_sales) AS cumulative_sales
    FROM twt_total_sales
)
SELECT 
    category_name,
    total_sales,
    ROUND((100.0 * cumulative_sales / (SELECT grand_sales FROM grand_sales)), 2) || '%' AS cumulative_percent
FROM cumulative_sales;
----Classify the Order Regions based on the occurrence of late shipments----
WITH late_shipments AS
	(SELECT
	order_region,
	shipping_mode,
	CASE WHEN days_for_shipping_real > days_for_shipment_scheduled THEN 1 
	ELSE 0 END AS late_shipments
FROM public.itblogistics)
SELECT 
	order_region,
	COUNT(*) AS total_shipments,
	SUM(late_shipments) as late_shipments,
	ROUND((1.00*SUM(late_shipments)/COUNT(*)),2) AS late_shipment_rate
FROM late_shipments
GROUP BY order_region
ORDER BY late_shipment_rate 
---- Select the best Shipping Mode that consistently delivers shipments-----
WITH late_shipments AS
	(SELECT
	order_region,
	shipping_mode,
	CASE WHEN days_for_shipping_real > days_for_shipment_scheduled THEN 1 
	ELSE 0 END AS late_shipments
FROM public.itblogistics)
SELECT 
	order_region,
	shipping_mode,
	COUNT(*) AS total_shipments,
	ROUND(((SUM(late_shipments))*1.0/COUNT(*)),2) AS late_shipments_rate
FROM late_shipments
GROUP BY shipping_mode, order_region
ORDER BY order_region, late_shipments_rate
----- Common factors associated with orders that have a higher likelihood of experiencing delays in delivery----
WITH late_shipments AS (
	SELECT *, 
	CASE WHEN late_delivery_risk=1 THEN 1 
	ELSE 0 END AS late_shipments
	FROM public.itblogistics
)
--Late delivery rate by Order Region--
SELECT 
	order_region,
	ROUND(AVG(late_shipments),2) AS late_shipments_rate
FROM late_shipments
GROUP BY order_region
ORDER BY late_shipments_rate DESC
--Late delivery rate by Shipping Mode--
SELECT 
	shipping_mode,
	ROUND(AVG(late_shipments),2) AS late_shipments_rate
FROM late_shipments
GROUP BY shipping_mode
ORDER BY late_shipments_rate DESC
--Late delivery rate by Product Category --
SELECT 
	category_name,
	ROUND(AVG(late_shipments),2) AS late_shipments_rate
FROM late_shipments
GROUP BY category_name
ORDER BY late_shipments_rate DESC
-- Late delivery rate by Customer Segment --
SELECT 
	customer_segment,
	ROUND(AVG(late_shipments),2) AS late_shipments_rate
FROM late_shipments
GROUP BY customer_segment
ORDER BY late_shipments_rate DESC
-- Late delivery rate by Deparment  --
SELECT 
	department_name,
	ROUND(AVG(late_shipments),2) AS late_shipments_rate
FROM late_shipments
GROUP BY department_name
ORDER BY late_shipments_rate DESC


