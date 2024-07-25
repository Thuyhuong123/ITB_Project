--Identify products that have experienced changes in price--
WITH daily_avg_price AS (
    SELECT
        product_name,
        shipping_date,
        AVG(product_price) AS avg_daily_price
    FROM public.itblogistics
    GROUP BY product_name, shipping_date
),
price_changes AS (
    SELECT
        p1.product_name,
        p1.shipping_date AS date1,
        p1.avg_daily_price AS price1,
        p2.shipping_date AS date2,
        p2.avg_daily_price AS price2,
        (p2.avg_daily_price - p1.avg_daily_price) AS price_change
    FROM daily_avg_price p1
    JOIN daily_avg_price p2 ON p1.product_name = p2.product_name AND p2.shipping_date = p1.shipping_date + INTERVAL '1 day'
)
SELECT
    product_name,
    date1 AS previous_date,
    date2 AS current_date,
    price1 AS previous_price,
    price2 AS current_price,
    price_change
FROM price_changes
WHERE price_change <> 0
ORDER BY product_name, date1
--- Compare the change in product quantity--
WITH first_six_months AS (
    SELECT 
        "product_card_id",product_name,
        SUM("order_item_quantity") AS total_quantity_first
    FROM public.itblogistics
    WHERE EXTRACT(YEAR FROM "shipping_date") = 2017
      AND EXTRACT(MONTH FROM "shipping_date") BETWEEN 1 AND 6
    GROUP BY "product_card_id", product_name
),
last_six_months AS (
    SELECT 
        "product_card_id",product_name,
        SUM("order_item_quantity") AS total_quantity_last
    FROM public.itblogistics
    WHERE EXTRACT(YEAR FROM "shipping_date") = 2017
      AND EXTRACT(MONTH FROM "shipping_date") BETWEEN 7 AND 12
    GROUP BY "product_card_id",product_name
)
SELECT 
    f.product_name, f.product_card_id,
    f.total_quantity_first,
    l.total_quantity_last,
    ROUND(((l.total_quantity_last - f.total_quantity_first) * 100.0 / f.total_quantity_first),2) AS percent_change_quantity
FROM 
    first_six_months f
    JOIN last_six_months l ON f.product_name = l.product_name
ORDER BY product_card_id;


