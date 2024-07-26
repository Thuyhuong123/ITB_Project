-- Step 1: Create the Temporary Table
CREATE TEMP TABLE temp_order_details AS
SELECT 
    o.order_id,
    od.order_item_id,
    o.shipping_mode,
    o.order_region,
    c.customer_segment,
    d.department_name,
    od.order_item_quantity,
    p.product_price,
    o.late_delivery_risk
FROM 
    orderdetails od
JOIN 
    orders o ON od.order_id = o.order_id
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    products p ON od.product_card_id = p.product_card_id
JOIN 
    departments d ON p.department_id = d.department_id;

-- Step 2: Query for Shipping Mode
SELECT 
    shipping_mode,
    COUNT(order_item_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_delivery_risk_orders,
    COUNT(order_item_id) - SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS on_time_delivery_orders
FROM 
    temp_order_details
GROUP BY 
    shipping_mode
ORDER BY 
    late_delivery_risk_orders DESC;

-- Step 3: Query for Order Region
SELECT 
    order_region,
    COUNT(order_item_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_delivery_risk_orders,
    COUNT(order_item_id) - SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS on_time_delivery_orders
FROM 
    temp_order_details
GROUP BY 
    order_region
ORDER BY 
    late_delivery_risk_orders DESC;

-- Step 4: Query for Customer Segment
SELECT 
    customer_segment,
    COUNT(order_item_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_delivery_risk_orders,
    COUNT(order_item_id) - SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS on_time_delivery_orders
FROM 
    temp_order_details
GROUP BY 
    customer_segment
ORDER BY 
    late_delivery_risk_orders DESC;

-- Step 5: Query for Department
SELECT 
    department_name,
    COUNT(order_item_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_delivery_risk_orders,
    COUNT(order_item_id) - SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS on_time_delivery_orders
FROM 
    temp_order_details
GROUP BY 
    department_name
ORDER BY 
    late_delivery_risk_orders DESC;

-- Step 6: Query for Order Item Quantity
SELECT 
    order_item_quantity,
    COUNT(order_item_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_delivery_risk_orders,
    COUNT(order_item_id) - SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS on_time_delivery_orders
FROM 
    temp_order_details
GROUP BY 
    order_item_quantity
ORDER BY 
    late_delivery_risk_orders DESC;

-- Step 7: Query for Product Price Range
SELECT 
    CASE 
        WHEN product_price BETWEEN 0 AND 50 THEN '0 - 50'
        WHEN product_price BETWEEN 51 AND 100 THEN '51 - 100'
        WHEN product_price BETWEEN 101 AND 200 THEN '101 - 200'
        WHEN product_price BETWEEN 201 AND 300 THEN '201 - 300'
        WHEN product_price BETWEEN 301 AND 400 THEN '301 - 400'
        WHEN product_price BETWEEN 401 AND 600 THEN '401 - 600'
        WHEN product_price BETWEEN 601 AND 1000 THEN '601 - 1000'
        ELSE 'Over 1000'
    END AS price_range,
    COUNT(order_item_id) AS total_orders,
    SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS late_delivery_risk_orders,
    COUNT(order_item_id) - SUM(CASE WHEN late_delivery_risk = 1 THEN 1 ELSE 0 END) AS on_time_delivery_orders
FROM 
    temp_order_details
GROUP BY 
    CASE 
        WHEN product_price BETWEEN 0 AND 50 THEN '0 - 50'
        WHEN product_price BETWEEN 51 AND 100 THEN '51 - 100'
        WHEN product_price BETWEEN 101 AND 200 THEN '101 - 200'
        WHEN product_price BETWEEN 201 AND 300 THEN '201 - 300'
        WHEN product_price BETWEEN 301 AND 400 THEN '301 - 400'
        WHEN product_price BETWEEN 401 AND 600 THEN '401 - 600'
        WHEN product_price BETWEEN 601 AND 1000 THEN '601 - 1000'
        ELSE 'Over 1000'
    END
ORDER BY 
    price_range;
