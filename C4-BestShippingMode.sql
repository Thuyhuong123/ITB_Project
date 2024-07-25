-- classify the Order Regions based on the occurrence of late shipments-- 
WITH late_shipments AS (
    SELECT
        order_region,
        shipping_mode,
        CASE 
            WHEN days_for_shipping_real > days_for_shipment_scheduled THEN 1 
            ELSE 0 
        END AS late_shipments
    FROM public.itblogistics
)
    SELECT 
        order_region,
        COUNT(*) AS total_shipments,
        SUM(late_shipments) AS late_shipments,
        ROUND((1.00 * SUM(late_shipments) / COUNT(*)), 2) AS late_shipment_rate
    FROM late_shipments
    GROUP BY order_region
    ORDER BY late_shipment_rate; 
--select the best Shipping Mode--
    SELECT 
        order_region,
        shipping_mode,
        COUNT(*) AS total_shipments,
        ROUND(((SUM(late_shipments)) * 1.0 / COUNT(*)), 2) AS late_shipments_rate
    FROM late_shipments
    GROUP BY shipping_mode, order_region
    ORDER BY order_region, late_shipments_rate



