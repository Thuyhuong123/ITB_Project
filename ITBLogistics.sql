---- Find and handle outliers----
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
-------EDA process------
--- View sample data---
SELECT * FROM
public.itblogistics
LIMIT 10
---Count the number of rows---
SELECT COUNT(*) FROM public.itblogistics ---180519 records---
SELECT 
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT category_id) AS unique_product_categories
FROM public.itblogistics;
--- Summary Statistics for Numeric Columns---
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
    'benefit_per_order' AS column_name,
    ROUND(AVG(benefit_per_order),2) AS mean_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY benefit_per_order) AS median_value,
    ROUND(STDDEV(benefit_per_order),2) AS std_dev_value,
    MIN(benefit_per_order) AS min_value,
    MAX(benefit_per_order) AS max_value,
    COUNT(benefit_per_order) AS count_value
FROM 
public.itblogistics
	
---Distru=ibution of categorical variables---
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
	late_delivery_risk
--- Distribution of product category by late delivery risk---
SELECT 
	category_name,
	late_delivery_risk, 
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY category_name,
	late_delivery_risk
--- Distribution of department by late delivery risk---
SELECT 
	department_name,
	late_delivery_risk, 
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY department_name,
	late_delivery_risk
--- Distribution of department by late delivery risk---
SELECT 
	order_region,
	late_delivery_risk, 
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY order_region,
	late_delivery_risk
--- Distribution of department by late delivery risk---
SELECT 
	order_region,
	late_delivery_risk, 
	COUNT(*) AS count,
	ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM public.itblogistics),2) AS percentage
FROM public.itblogistics
GROUP BY order_region,
	late_delivery_risk
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
	COUNT(*)-SUM(late_shipments) AS on_time_shipments,
	ROUND(((COUNT(*)-SUM(late_shipments))*1.0/COUNT(*)),2) AS on_time_shipments_rate
FROM late_shipments
GROUP BY shipping_mode, order_region
ORDER BY order_region, on_time_shipments_rate DESC
----- Common factors associated with orders that have a higher likelihood of experiencing delays in delivery----
WITH late_shipments AS (
	SELECT *, 
	CASE WHEN days_for_shipping_real > days_for_shipment_scheduled THEN 1 
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


