WITH total_sales_per_category AS (
    SELECT 
        ct.category_name,
        SUM(od.sales) AS total_sales
    FROM 
        public.orderdetails od
    JOIN 
        public.products pr ON od.order_item_id = pr.order_item_id
    JOIN 
        categories ct ON pr.order_item_id = ct.order_item_id
    GROUP BY 
        ct.category_name
),
grand_total_sales AS (
    SELECT 
        SUM(total_sales) AS grand_sales
    FROM 
        total_sales_per_category
),
cumulative_sales AS (
    SELECT 
        category_name,
        total_sales,
        SUM(total_sales) OVER (ORDER BY total_sales DESC) AS cumulative_sales
    FROM 
        total_sales_per_category
)
SELECT 
    cs.category_name,
    cs.total_sales,
    ROUND((100.0 * cs.cumulative_sales / gts.grand_sales), 2) || '%' AS cumulative_percent
FROM 
    cumulative_sales cs, 
    grand_total_sales gts
ORDER BY 
    cs.total_sales DESC;
