--Identify products that have experienced changes in price--
WITH daily_avg_price AS (
    SELECT
        p.product_name,
        o.shipping_date,
        AVG(p.product_price) AS avg_daily_price
    FROM 
        orderdetails od
    JOIN 
        products p ON od.order_item_id = p.order_item_id
    JOIN
        orders o ON od.order_item_id = o.order_item_id
    GROUP BY 
        p.product_name, o.shipping_date
),
price_changes AS (
    SELECT
        p1.product_name,
        p1.shipping_date AS date1,
        p1.avg_daily_price AS price1,
        p2.shipping_date AS date2,
        p2.avg_daily_price AS price2,
        (p2.avg_daily_price - p1.avg_daily_price) AS price_change
    FROM 
        daily_avg_price p1
    JOIN 
        daily_avg_price p2 ON p1.product_name = p2.product_name 
        AND p2.shipping_date = p1.shipping_date + INTERVAL '1 day'
)
SELECT
    product_name,
    date1 AS previous_date,
    date2 AS current_date,
    price1 AS previous_price,
    price2 AS current_price,
    price_change
FROM 
    price_changes
WHERE 
    price_change <> 0
ORDER BY 
    product_name, date1;

--- Compare the change in product quantity--
WITH first_six_months AS (
    SELECT 
        p.product_card_id,
        p.product_name,
        SUM(od.order_item_quantity) AS total_quantity_first
    FROM 
        orderdetails od
    JOIN 
        orders o ON od.order_item_id = o.order_item_id
    JOIN 
        products p ON od.order_item_id = p.order_item_id
    WHERE 
        EXTRACT(YEAR FROM o.shipping_date) = 2017
        AND EXTRACT(MONTH FROM o.shipping_date) BETWEEN 1 AND 6
    GROUP BY 
        p.product_card_id, p.product_name
),
last_six_months AS (
    SELECT 
        p.product_card_id,
        p.product_name,
        SUM(od.order_item_quantity) AS total_quantity_last
    FROM 
        orderdetails od
    JOIN 
        orders o ON od.order_item_id = o.order_item_id
    JOIN 
        products p ON od.order_item_id = p.order_item_id
    WHERE 
        EXTRACT(YEAR FROM o.shipping_date) = 2017
        AND EXTRACT(MONTH FROM o.shipping_date) BETWEEN 7 AND 12
    GROUP BY 
        p.product_card_id, p.product_name
)
SELECT 
    f.product_name, 
    f.product_card_id,
    f.total_quantity_first,
    l.total_quantity_last,
    ROUND(((l.total_quantity_last - f.total_quantity_first) * 100.0 / f.total_quantity_first), 2) AS percent_change_quantity
FROM 
    first_six_months f
JOIN 
    last_six_months l ON f.product_card_id = l.product_card_id
ORDER BY 
    f.product_card_id;
