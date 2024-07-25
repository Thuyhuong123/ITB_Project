--1.Creating Tables & Importing Data
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_fname VARCHAR(255),
    customer_lname VARCHAR(255),
    customer_email VARCHAR(255),
    customer_password VARCHAR(255),
    customer_segment VARCHAR(50),
    customer_city VARCHAR(255),
    customer_state VARCHAR(255),
    customer_country VARCHAR(255),
    customer_street VARCHAR(255),
    customer_zipcode VARCHAR(20)
);
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255)
);
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(255)
);
CREATE TABLE Products (
    product_card_id INT PRIMARY KEY,
    product_category_id INT,
    product_name VARCHAR(255),
    product_description TEXT,
    product_image TEXT,
    product_price NUMERIC,
    product_status VARCHAR(50),
    FOREIGN KEY (product_category_id) REFERENCES Categories(category_id)
);
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    shipping_date DATE,
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    order_city VARCHAR(255),
    order_state VARCHAR(255),
    order_country VARCHAR(255),
    order_zipcode VARCHAR(20),
    customer_id INT,
    market VARCHAR(50),
    order_status VARCHAR(50),
    shipping_mode VARCHAR(50),
    order_region VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
CREATE TABLE OrderDetails (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_card_id INT,
    order_item_cardprod_id INT,
    order_item_discount NUMERIC,
    order_item_discount_rate NUMERIC,
    order_item_product_price NUMERIC,
    order_item_profit_ratio NUMERIC,
    order_item_quantity INT,
    sales NUMERIC,
    order_item_total NUMERIC,
    order_profit_per_order NUMERIC,
    benefit_per_order NUMERIC,
    sales_per_customer NUMERIC,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_card_id) REFERENCES Products(product_card_id)
);
CREATE TABLE Shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT,
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

--2. Cleaning & Structuring Data
-- 2.1.Check Null Values--
SELECT * 
FROM public.customers
WHERE customer_email IS NULL

SELECT * 
FROM public.categories
WHERE category_name IS NULL

SELECT * 
FROM public.departments
WHERE department_name IS NULL

SELECT * 
FROM public.orderdetails
WHERE order_id IS NULL
or product_card_id IS NULL
or order_item_product_price IS NULL
or order_item_quantity IS NULL
or sales IS NULL

SELECT * 
FROM public.orders
WHERE order_date IS NULL
or shipping_date IS NULL
or shipping_mode IS NULL
or order_region IS NULL
or late_delivery_risk IS NULL

SELECT * 
FROM public.products
WHERE product_category_id IS NULL

SELECT * 
FROM public.shipments
WHERE days_for_shipping_real IS NULL
OR days_for_shipment_scheduled IS NULL
  
--2.2. Cleaning Dup Values:--
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY  order_date, shipping_date, delivery_status, late_delivery_risk, order_city, customer_id, order_status, shipping_mode ORDER BY order_id) AS row_num
    FROM Orders
)
SELECT  order_date, shipping_date, delivery_status, late_delivery_risk, order_city, customer_id, order_status, shipping_mode
FROM CTE
WHERE row_num > 1;
