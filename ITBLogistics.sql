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



