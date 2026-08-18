/*=============================================================
                 FOODTECH ANALYTICS DATABASE PROJECT
===============================================================
Description:
This project demonstrates an end-to-end SQL implementation including database creation, normalization, relationships,
views, stored procedures, triggers and business reporting.

TABLE OF CONTENTS

Phase 1 : Database Creation & Validation
Phase 2 : Database Normalization
Phase 3 : Relationship Design
Phase 4 : SQL Views
Phase 5 : Stored Procedures
Phase 6 : Database Triggers
Phase 7 : Business Queries
Phase 8 : Advanced SQL (Optional)

=============================================================*/

/*=============================================================
Phase 1 : Database Creation & Validation

Objective:
Create the FoodTech Analytics database, validate the imported
dataset, optimize data types, and perform initial data quality
checks before database development.

=============================================================*/
-- Create Project Database

CREATE DATABASE IF NOT EXISTS FoodTech_Analytics;
USE FoodTech_Analytics;

-- Verify Active Database

SELECT DATABASE();

-- Verify Tables Imported from Python

SHOW TABLES;
describe foodtech_analysis;

-- Inspect Imported Table Structure

DESCRIBE foodtech_analysis;

-- Convert Order_Date from TEXT to DATE

ALTER TABLE foodtech_analysis
MODIFY COLUMN Order_Date DATE;

-- Convert Identifier Columns from TEXT to VARCHAR

ALTER TABLE foodtech_analysis
MODIFY COLUMN Order_ID VARCHAR(20),
MODIFY COLUMN Customer_ID VARCHAR(20),
MODIFY COLUMN Restaurant_ID VARCHAR(20),
MODIFY COLUMN Delivery_Partner_ID VARCHAR(20);

-- Verify Updated Data Types

DESCRIBE foodtech_analysis;

-- Data Validation
-- Verify Total Records

SELECT COUNT(*) AS Total_Records
FROM foodtech_analysis;

-- Display Sample Records

SELECT *
FROM foodtech_analysis
LIMIT 5;

-- Verify Order Date Range

SELECT
    MIN(Order_Date) AS Start_Date,
    MAX(Order_Date) AS End_Date
FROM foodtech_analysis;

-- Verify Distinct Regions

SELECT DISTINCT Region
FROM foodtech_analysis;

/*=============================================================
Phase 1 Completed:
Created FoodTech_Analytics database
Connected Python with MySQL
Imported FoodTech Analysis Dataset
Verified successful table creation
Optimized data types
Validated imported records
Verified date range
Verified available regions
=============================================================*/

/*=============================================================
Phase 2 : Database Normalization

Objective:
Transform the denormalized master dataset (foodtech_analysis)
into a normalized relational database by separating customer,
restaurant, delivery partner, and order information into
independent business entities
=============================================================*/ 
-- Create Customers table
CREATE TABLE customers AS
SELECT DISTINCT
    Customer_ID,
    Gender,
    Age_Group,
    Customer_City,
    Customer_Type,
    Preferred_Cuisine
FROM foodtech_analysis;

-- Verify Customers table
SELECT * FROM customers LIMIT 5;
SELECT COUNT(*) AS Total_Customers FROM customers;

-- Create Restaurants Table
CREATE TABLE restaurants AS
SELECT DISTINCT
    Restaurant_ID,
    Restaurant_Name,
    Restaurant_City,
    Cuisine_Type,
    Avg_Preparation_Time_Minutes,
    Order_Capacity_Per_Day
FROM foodtech_analysis;

-- Verify Restaurants table
SELECT * FROM restaurants LIMIT 5;
SELECT COUNT(*) AS Total_Restaurants FROM restaurants;

-- Create Delivery Partners Table
CREATE TABLE delivery_partners AS
SELECT DISTINCT
    Delivery_Partner_ID,
    Partner_Name,
    Vehicle_Type,
    Delivery_Region,
    Avg_Delivery_Speed_KMPH,
    Successful_Deliveries,
    Delayed_Deliveries,
    Avg_Customer_Rating,
    Delivery_Efficiency_Score
FROM foodtech_analysis;

-- Verify Delivery Partners table
SELECT * FROM delivery_partners LIMIT 5;
SELECT COUNT(*) AS Total_Delivery_Partners FROM delivery_partners;

-- Create Orders table
SHOW TABLES;
CREATE TABLE orders AS
SELECT
    Order_ID,
    Order_Date,
    Customer_ID,
    Restaurant_ID,
    Delivery_Partner_ID,
    Region,
    Order_Value,
    Delivery_Fee,
    Discount_Applied,
    Final_Amount,
    Payment_Mode,
    Order_Status,
    Delivery_Time_Minutes,
    Order_Rating,
    Festival_Flag,
    Delivery_Time_Category,
    Order_Value_Category
FROM foodtech_analysis;
-- Verify Orders table
DESCRIBE orders;
SELECT *  FROM orders LIMIT 5;
SELECT COUNT(*) AS Total_Orders FROM orders;

-- Verify all tables
SHOW tables;

-- Verify Table Structures
DESCRIBE customers;
DESCRIBE restaurants;
DESCRIBE delivery_partners;
DESCRIBE orders;

/*=============================================================
Phase 2 Completed
Tasks Accomplished:

 Created Customers, Restaurants, Delivery Partners and Orders table
 Verified table structures
 Verified record counts
=============================================================*/

/*=============================================================
Phase 3 : Relational Database Modeling

Objective:
Transform the normalized tables into a fully relational database by
defining primary keys, introducing a surrogate key for Orders,
creating the Payments entity, and establishing foreign key
relationships between all business entities.
=============================================================*/
-- Add Primary Keys (Customers Table)
ALTER TABLE customers ADD PRIMARY KEY (Customer_ID);
-- Verify
SHOW KEYS FROM customers WHERE Key_name='PRIMARY';
 
-- Restaurants Table
ALTER TABLE restaurants ADD PRIMARY KEY (Restaurant_ID);
-- Verify
SHOW KEYS FROM restaurants WHERE Key_name='PRIMARY';

-- Delivery Partners Table
ALTER TABLE delivery_partners ADD PRIMARY KEY (Delivery_Partner_ID);
-- Verify
SHOW KEYS FROM delivery_partners WHERE Key_name='PRIMARY';

-- Attempt to Create Primary Key - Orders
ALTER TABLE orders ADD PRIMARY KEY (Order_ID);         -- Error Code: 1062. Duplicate entry 'O693842' for key 'orders.PRIMARY'
/*
Observation:

MySQL rejected Order_ID as the primary key because duplicate
Order_ID values exist in the dataset.

A primary key must uniquely identify every record; therefore,
Order_ID cannot be used as the primary key.
*/

-- Investigate the Problem
SELECT Order_ID, COUNT(*) AS Duplicate_Count
FROM orders
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;           -- Check the duplicate Order_IDs

SELECT 
    COUNT(*) AS Total_Orders,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    COUNT(*) - COUNT(DISTINCT Order_ID) AS Duplicate_Rows
FROM orders;                                                -- Finding out how many duplicate rows exist                   
-- Total_Orders : 1,00,000 , Unique_Orders : 94,550 , Duplicate_Rows : 5450

SELECT *
FROM orders
WHERE Order_ID = 'O693842';         -- Check whether the duplicate rows are identical

/*
Observation:

The repeated Order_ID values represent different business transactions rather than duplicate records.
Removing these rows would result in the loss of valid order data.
Therefore, a surrogate key is required to uniquely identify each order while preserving the original business Order_ID.
*/

/*
Introduce Surrogate Key for Orders :

Since Order_ID is not unique, it cannot serve as the primary key.
To uniquely identify every order record while preserving the original business Order_ID, a surrogate key named Order_Key is introduced.
Order_Key is an auto-incrementing integer generated by MySQL and will serve as the primary key for the Orders table.
*/

-- Add a Surrogate key to Orders table and making it as a Primary Key
ALTER TABLE orders ADD COLUMN Order_Key INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

-- Verify
DESCRIBE orders;

-- Verify Sample Data
SELECT Order_Key, Order_ID FROM orders LIMIT 10;

/*
Why Order_Key?

Deleting duplicate Order_ID values would remove valid business transactions because the repeated Order_IDs represent different 
orders rather than duplicate records.

Introducing a surrogate key allows every order to be uniquely identified while preserving the original Order_ID for business 
reporting and operational reference.
*/

-- Add the Foreign Keys
ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (Customer_ID)
REFERENCES customers(Customer_ID);

ALTER TABLE orders
ADD CONSTRAINT fk_restaurant
FOREIGN KEY (Restaurant_ID)
REFERENCES restaurants(Restaurant_ID);

ALTER TABLE orders
ADD CONSTRAINT fk_delivery_partner
FOREIGN KEY (Delivery_Partner_ID)
REFERENCES delivery_partners(Delivery_Partner_ID);

-- Verify the Foreign keys
-- This query is used to view all the foreign key relationships in our FoodTech_Analytics database.
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE  
-- information_schema is a system database provided by MySQL.
-- It stores information about your databases, tables, columns, keys, constraints, etc.
-- KEY_COLUMN_USAGE. It is a table which contains details about primary keys, foreign keys and unique keys
WHERE TABLE_SCHEMA = 'FoodTech_Analytics'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Validate Referential Integrity :
-- Since I normalized the master dataset into multiple related tables, I performed a Referential Integrity check to 
-- ensure that every Customer_ID, Restaurant_ID, and Delivery_Partner_ID in the Orders table existed in their 
-- respective master tables.

-- This helped me identify any orphan records before creating Foreign Key constraints.

-- Since all IDs matched successfully, I was able to establish the relationships and maintain database consistency.

-- Customer Integrity
SELECT COUNT(*) AS Invalid_Customers
FROM orders o
LEFT JOIN customers c ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- Restaurant Integrity
SELECT COUNT(*) AS Invalid_Restaurants
FROM orders o
LEFT JOIN restaurants r ON o.Restaurant_ID = r.Restaurant_ID
WHERE r.Restaurant_ID IS NULL;

-- Delivery Partner Integrity
SELECT COUNT(*) AS Invalid_Delivery_Partners
FROM orders o
LEFT JOIN delivery_partners d ON o.Delivery_Partner_ID = d.Delivery_Partner_ID
WHERE d.Delivery_Partner_ID IS NULL;

/*=============================================================
Phase 3 Completed
Tasks Accomplished:

Added Primary Keys
Implemented Surrogate Key for Orders
Established Foreign Key Relationships
Verified Referential Integrity
=============================================================*/

/*=============================================================
Phase 4 : SQL Views

Objective:
Create reusable business reporting views that simplify complex
queries and provide ready-to-use datasets for analytics and
dashboard reporting.
=============================================================*/
-- View 1 : Region Performance
-- Business Objective: Identify high-demand regions and evaluate profitability, customer satisfaction, and operational efficiency.
CREATE VIEW vw_region_performance AS
SELECT
    Region,
    COUNT(Order_Key) AS Total_Orders,
    SUM(Final_Amount) AS Total_Revenue,
    ROUND(AVG(Order_Value),2) AS Avg_Order_Value,
    ROUND(AVG(Order_Rating),2) AS Avg_Rating,
    ROUND(AVG(Delivery_Time_Minutes),2) AS Avg_Delivery_Time
FROM orders
GROUP BY Region;

-- Verify
SELECT * FROM vw_region_performance;  

-- View 2 : Delivery Partner Performance
-- Business Objective : To evaluate delivery partner efficiency and logistics routes to improve service quality.
drop view vw_delivery_partner_performance;
CREATE VIEW vw_delivery_partner_performance AS
SELECT
    d.Delivery_Partner_ID,
    d.Partner_Name,
    d.Vehicle_Type,
    d.Delivery_Region,
    COUNT(o.Order_Key) AS Total_Deliveries,
    ROUND(AVG(o.Delivery_Time_Minutes),2) AS Avg_Delivery_Time,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Rating,
    ROUND(AVG(d.Delivery_Efficiency_Score),2) AS Avg_Efficiency,
    ROUND(SUM(
        CASE
            WHEN o.Delivery_Time_Minutes <= 30 THEN 1
            ELSE 0
        END
    ) * 100.0 / COUNT(o.Order_Key),2) AS On_Time_Delivery_Rate
FROM delivery_partners d
JOIN orders o ON d.Delivery_Partner_ID = o.Delivery_Partner_ID
GROUP BY d.Delivery_Partner_ID, d.Partner_Name, d.Vehicle_Type, d.Delivery_Region;

-- Verify
SELECT * FROM vw_delivery_partner_performance;

-- View 3 : Customer Insights
-- Business Objective : To understand customer behavior and loyalty patterns to strengthen retention
CREATE VIEW vw_customer_insights AS
SELECT
    c.Customer_ID,
    c.Customer_Type,
    c.Gender,
    c.Age_Group,
    c.Customer_City,
    c.Preferred_Cuisine,
    COUNT(o.Order_Key) AS Total_Orders,
    ROUND(AVG(o.Final_Amount),2) AS Avg_Spend,
    ROUND(SUM(o.Final_Amount),2) AS Total_Spent,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Rating
FROM customers c
JOIN orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Type, c.Gender, c.Age_Group, c.Customer_City, c.Preferred_Cuisine;

-- Verify
SELECT * FROM vw_customer_insights LIMIT 10;

-- View 4 : Restaurant Performance
-- Business Objective : To assess profitability and efficiency across restaurants
CREATE VIEW vw_restaurant_performance AS
SELECT
    r.Restaurant_ID,
    r.Restaurant_Name,
    r.Restaurant_City,
    r.Cuisine_Type,
    COUNT(o.Order_Key) AS Total_Orders,
    SUM(o.Final_Amount) AS Total_Revenue,
    ROUND(AVG(o.Final_Amount),2) AS Avg_Order_Value,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Customer_Rating,
    ROUND(AVG(o.Delivery_Time_Minutes),2) AS Avg_Delivery_Time
FROM restaurants r
JOIN orders o ON r.Restaurant_ID = o.Restaurant_ID
GROUP BY r.Restaurant_ID, r.Restaurant_Name, r.Restaurant_City, r.Cuisine_Type;

-- Verify
SELECT * FROM vw_restaurant_performance LIMIT 10;

-- View 5 : Monthly Business Performance
-- Business Objective : Provides a monthly business performance summary for trend analysis, management reporting, and decision making
CREATE VIEW vw_monthly_business_performance AS
SELECT
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Order_Month,
    MONTHNAME(Order_Date) AS Month_Name,
    COUNT(Order_Key) AS Total_Orders,
    SUM(Final_Amount) AS Total_Revenue,
    ROUND(AVG(Order_Value),2) AS Avg_Order_Value,
    ROUND(AVG(Order_Rating),2) AS Avg_Customer_Rating,
    ROUND(AVG(Delivery_Time_Minutes),2) AS Avg_Delivery_Time
FROM orders
GROUP BY YEAR(Order_Date), MONTH(Order_Date), MONTHNAME(Order_Date)
ORDER BY Order_Year, Order_Month;

-- Verify
SELECT * FROM vw_monthly_business_performance;

-- Verify All Views
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

/*=============================================================
Phase 4 Completed

Views Created:
 vw_region_performance
 vw_restaurant_performance
 vw_delivery_partner_performance
 vw_customer_insights
 vw_monthly_business_performance
=============================================================*/

/*=============================================================
Phase 5 : Stored Procedures

Objective:
Develop reusable stored procedures that automate frequently
used business reports and minimize repetitive SQL queries.
=============================================================*/
-- Stored Procedure 1 : Customer Profile Summary
-- Purpose: Retrieve purchase behaviour and loyalty information for a specific customer.
DELIMITER $$
CREATE PROCEDURE sp_customer_profile(IN p_customer_id VARCHAR(20))
BEGIN
    SELECT
        Customer_ID,
        Customer_Type,
        Gender,
        Age_Group,
        Customer_City,
        Preferred_Cuisine,
        Total_Orders,
        Avg_Spend,
        Total_Spent,
        Avg_Rating
    FROM vw_customer_insights WHERE Customer_ID = p_customer_id;
END $$
DELIMITER ;
-- Execute
CALL sp_customer_profile('C00001');

-- Stored Procedure 2 : Restaurant Performance Summary
-- Purpose: Retrieve profitability and operational performance for a specific restaurant.
DELIMITER $$
CREATE PROCEDURE sp_restaurant_summary (IN p_restaurant_id VARCHAR(20))
BEGIN
    SELECT
        Restaurant_ID,
        Restaurant_Name,
        Restaurant_City,
        Cuisine_Type,
        Total_Orders,
        Total_Revenue,
        Avg_Order_Value,
        Avg_Customer_Rating,
        Avg_Delivery_Time
    FROM vw_restaurant_performance WHERE Restaurant_ID = p_restaurant_id;
END $$
DELIMITER ;
-- Execute
CALL sp_restaurant_summary('R001');

-- Stored Procedure 3 : Delivery Partner Performance
-- Purpose : Retrieve the performance of a delivery partner
DELIMITER $$
CREATE PROCEDURE sp_delivery_partner_summary(IN p_partner_id VARCHAR(20))
BEGIN
    SELECT
        Delivery_Partner_ID,
        Partner_Name,
        Vehicle_Type,
        Delivery_Region,
        Total_Deliveries,
        Avg_Delivery_Time,
        Avg_Rating,
        Avg_Efficiency
    FROM vw_delivery_partner_performance WHERE Delivery_Partner_ID = p_partner_id;
END $$
DELIMITER ;
-- Execute
CALL sp_delivery_partner_summary('D0001');

-- Stored Procedure 4 : Top Performing Restaurants
-- Purpose : Retrieve the Top N restaurants based on revenue and customer rating
DELIMITER $$
CREATE PROCEDURE sp_top_restaurants (IN p_top_n INT)
BEGIN
    SELECT
        Restaurant_Name,
        Cuisine_Type,
        Total_Orders,
        Total_Revenue,
        Avg_Customer_Rating,
        Avg_Delivery_Time
    FROM vw_restaurant_performance
    ORDER BY Total_Revenue DESC, Avg_Customer_Rating DESC
    LIMIT p_top_n;
END $$
DELIMITER ;
-- Execute
CALL sp_top_restaurants(10);

-- Stored Procedure 5 : Monthly Business Summary
-- Purpose : Returns monthly business performance for the specified year and month
DELIMITER $$
CREATE PROCEDURE sp_monthly_summary (IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        Order_Year,
        Order_Month,
        Month_Name,
        Total_Orders,
        Total_Revenue,
        Avg_Order_Value,
        Avg_Customer_Rating,
        Avg_Delivery_Time
    FROM vw_monthly_business_performance WHERE Order_Year = p_year AND Order_Month = p_month;
END $$
DELIMITER ;
-- Execute
CALL sp_monthly_summary(2024,6);

-- Verify all the procedures
SHOW PROCEDURE STATUS WHERE Db='FoodTech_Analytics';

/*=============================================================
Phase 5 Completed

Stored Procedures Created:
 sp_customer_profile
 sp_delivery_partner_summary
 sp_restaurant_summary
 sp_top_restaurants
 sp_monthly_summary
=============================================================*/

/*=============================================================
Phase 6 : Database Triggers

Objective:
Implement automated auditing to track INSERT,UPDATE and DELETE operations performed on the Orders table.
=============================================================*/
-- Trigger 1 : After Insert Audit
/*
Purpose:
This trigger automatically records every new order inserted into the Orders table.
It creates an audit trail containing the Order Key, Order ID, action performed,
and timestamp. This helps track when new orders are added without requiring
manual logging.
*/

-- Create Audit Table
CREATE TABLE order_audit
(
    Audit_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_Key INT,
    Order_ID VARCHAR(20),
    Action_Type VARCHAR(20),
    Action_Time DATETIME
);
-- Create Trigger
DELIMITER $$
CREATE TRIGGER trg_order_insert_audit
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit
    (
        Order_Key,
        Order_ID,
        Action_Type,
        Action_Time
    )
    VALUES
    (
        NEW.Order_Key,
        NEW.Order_ID,
        'INSERT',
        NOW()
    );
END $$
DELIMITER ;

-- Test the trigger
SELECT * FROM order_audit; -- Check audit table before insert
INSERT INTO orders
(
    Order_ID,
    Order_Date,
    Customer_ID,
    Restaurant_ID,
    Delivery_Partner_ID,
    Region,
    Order_Value,
    Delivery_Fee,
    Discount_Applied,
    Final_Amount,
    Payment_Mode,
    Order_Status,
    Delivery_Time_Minutes,
    Order_Rating,
    Festival_Flag,
    Delivery_Time_Category,
    Order_Value_Category
)

VALUES
(
    'OTEST001',
    '2025-12-31',
    'C01162',
    'R282',
    'D0496',
    'Metropolitian',
    500,
    30,
    20,
    510,
    'UPI',
    'Placed',
    35,
    5,
    0,
    'Moderate',
    'Medium Value'
);
-- Verify
SELECT * FROM orders WHERE Order_ID='OTEST001';
SELECT * FROM order_audit;

-- Trigger 2 : AFTER UPDATE Audit
/*
Purpose:
This table stores the history of every Order Status modification.
It records both the previous status and the updated status,
allowing complete tracking of order status changes.
*/
-- Create Status Audit Table
CREATE TABLE order_status_audit
(
    Audit_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_Key INT,
    Order_ID VARCHAR(20),
    Old_Status VARCHAR(30),
    New_Status VARCHAR(30),
    Action_Time DATETIME
);
/*
Purpose:
This trigger automatically records every change made to Order_Status.
Whenever the status is updated, the previous status, new status,
Order Key, Order ID, and timestamp are stored in the audit table.
This maintains a complete history of status changes.
*/
-- Create Trigger
DELIMITER $$
CREATE TRIGGER trg_order_status_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.Order_Status <> NEW.Order_Status THEN
        INSERT INTO order_status_audit
        (
            Order_Key,
            Order_ID,
            Old_Status,
            New_Status,
            Action_Time
        )
        VALUES
        (
            NEW.Order_Key,
            NEW.Order_ID,
            OLD.Order_Status,
            NEW.Order_Status,
            NOW()
        );
    END IF;
END $$
DELIMITER ;
-- Test the Trigger
-- Before Update
SELECT Order_Key, Order_ID, Order_Status
FROM orders WHERE Order_ID='OTEST001';
-- Update status
UPDATE orders SET Order_Status='Delivered' WHERE Order_ID='OTEST001';
-- Verify
SELECT Order_Key, Order_ID, Order_Status
FROM orders WHERE Order_ID='OTEST001';

SELECT * FROM order_status_audit;

-- Trigger 3 : AFTER DELETE Audit
-- Create Delete Audit Table
CREATE TABLE order_delete_audit
(
    Audit_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_Key INT,
    Order_ID VARCHAR(20),
    Action_Type VARCHAR(20),
    Action_Time DATETIME
);
-- Create Trigger
DELIMITER $$
CREATE TRIGGER trg_order_delete_audit
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_delete_audit
    (
        Order_Key,
        Order_ID,
        Action_Type,
        Action_Time
    )
    VALUES
    (
        OLD.Order_Key,
        OLD.Order_ID,
        'DELETE',
        NOW()
    );
END $$
DELIMITER ;
-- Test the trigger
SELECT * FROM orders WHERE Order_ID='OTEST001';   -- Verify Record Exists
SELECT * FROM order_delete_audit;                 -- Check Audit Table Before Delete
DELETE FROM orders WHERE Order_ID='OTEST001';     -- Delete Record
-- Verfy
SELECT * FROM orders WHERE Order_ID='OTEST001';
SELECT * FROM order_delete_audit;

-- Verify All Triggers
SHOW TRIGGERS;

/*=============================================================
Phase 6 Completed Successfully

Triggers Created :
 trg_order_insert_audit
 trg_order_status_update
 trg_order_delete_audit

Audit Tables Created :
 order_audit
 order_status_audit
 order_delete_audit

Business Benefits :
 Tracks every newly inserted order.
 Maintains a complete history of order status changes.
 Preserves details of deleted orders for audit and recovery.
 Ensures accountability and supports operational monitoring.
=============================================================*/

/*=============================================================
Phase 7 : Business Analytics & Reporting
=============================================================*/
-- Business Objective 1 : Identify high-demand regions and growth potential to prioritize expansion strategies.
-- Business Question 1 : Which region generates the highest revenue while maintaining strong customer satisfaction?
SELECT Region, Total_Orders, Total_Revenue, Avg_Rating
FROM vw_region_performance
ORDER BY Total_Revenue DESC, Avg_Rating DESC;

/* Interpretation:
 Urban generated the highest total revenue (18.75 million), making it the strongest-performing region in terms of revenue generation.

 Semi-Urban recorded the highest average customer rating (4.03), indicating that customers rated their orders slightly higher than 
 in the other regions despite generating marginally lower revenue.

 Overall, Urban demonstrates the strongest commercial performance, while Semi-Urban presents an opportunity to increase revenue by 
 leveraging its comparatively higher customer ratings.
*/

-- Business Question 2 : Rank all regions based on overall business performance using Total Revenue, Average Order Value, Customer Rating, and Operational Efficiency.
SELECT
    Region,
    Total_Orders,
    Total_Revenue,
    Avg_Order_Value,
    Avg_Rating,
    Avg_Delivery_Time,
    DENSE_RANK() OVER
    (ORDER BY Total_Revenue DESC, Avg_Order_Value DESC, Avg_Rating DESC, Avg_Delivery_Time ASC) AS Business_Performance_Rank
FROM vw_region_performance;

/*
Interpretation :
- Urban secured the first rank by generating the highest total revenue (18.75 million) and the highest average order value (546.60), 
making it the strongest-performing market from a financial perspective. 

- Semi-Urban ranked second despite having the highest customer rating (4.03), indicating strong customer satisfaction but 
slightly lower commercial performance. 

- Metropolitan ranked third, with revenue and average order value marginally below the other regions. 

- Overall, the analysis suggests that Urban is the most suitable candidate for business expansion, while Semi-Urban offers an opportunity to increase
revenue by leveraging its excellent customer satisfaction.
*/

-- Business Objective 2 : To evaluate delivery partner efficiency and logistics routes to improve service quality
-- Business Question 3 : Which vehicle type delivers the best balance of delivery speed, customer satisfaction, and delivery efficiency?
SELECT
    dp.Vehicle_Type,
    COUNT(o.Order_Key) AS Total_Deliveries,
    ROUND(AVG(o.Delivery_Time_Minutes),2) AS Avg_Delivery_Time,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Customer_Rating,
    ROUND(AVG(dp.Delivery_Efficiency_Score),2) AS Avg_Efficiency_Score
FROM orders o
JOIN delivery_partners dp ON o.Delivery_Partner_ID = dp.Delivery_Partner_ID
GROUP BY dp.Vehicle_Type
ORDER BY Avg_Efficiency_Score DESC, Avg_Customer_Rating DESC, Avg_Delivery_Time ASC;

/*
Interpretation :
- Scooters achieved the highest average delivery efficiency score (0.71), making them the most operationally efficient vehicle type for food deliveries.

- Bikes handled the highest number of deliveries (46,794) while maintaining the joint highest average customer rating (4.03), 
demonstrating their ability to support large delivery volumes without compromising service quality.

- Bicycles recorded the fastest average delivery time (35.41 minutes) and shared the highest customer rating (4.03) with Bikes. 
However, they completed significantly fewer deliveries (4,210), indicating that they are better suited for limited or short-distance deliveries 
rather than high-volume operations.

- Cars recorded the lowest delivery efficiency score (0.61) and the lowest average customer rating (4.01), 
suggesting comparatively lower operational performance.

- Overall, Bikes and Scooters are the most suitable vehicle types for large-scale delivery operations. 
Scooters provide the highest operational efficiency, while Bikes offer the best balance between delivery volume, customer satisfaction, 
and operational performance.
*/

-- Business Question 4 : Which delivery partners have the highest percentage of delayed deliveries, and what impact does it have on customer satisfaction?
SELECT
    dp.Delivery_Partner_ID,
    dp.Partner_Name,
    dp.Vehicle_Type,
    dp.Successful_Deliveries,
    dp.Delayed_Deliveries,
    ROUND((dp.Delayed_Deliveries * 100.0) /(dp.Successful_Deliveries + dp.Delayed_Deliveries),2) AS Delay_Percentage,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Customer_Rating
FROM delivery_partners dp
JOIN orders o ON dp.Delivery_Partner_ID = o.Delivery_Partner_ID
GROUP BY dp.Delivery_Partner_ID, dp.Partner_Name, dp.Vehicle_Type, dp.Successful_Deliveries, dp.Delayed_Deliveries
HAVING (dp.Successful_Deliveries + dp.Delayed_Deliveries) >= 50
ORDER BY Delay_Percentage DESC, Avg_Customer_Rating ASC
LIMIT 10;

/*
Interpretation :
- Priya Patel (D0481) recorded the highest delay percentage (23.08%), indicating that nearly one out of every four deliveries was delayed. 
Despite this, the partner maintained a strong average customer rating of 4.07, suggesting that customers were still generally satisfied 
with the overall service.

- Suresh Reddy (D0391) and Vikram Singh (D0295) also recorded relatively high delay percentages (15.69% and 13.46%, respectively), 
along with lower customer ratings of 3.91 and 3.85. This indicates that frequent delivery delays may negatively influence customer satisfaction.

- Kiran Iyer (D0983) achieved a comparatively high customer rating (4.10) despite a delay percentage of 12.00%, 
suggesting that factors such as service quality or customer interaction can help maintain customer satisfaction even when occasional delays occur.

- Overall, the analysis indicates that higher delay percentages are generally associated with lower customer ratings. 
Delivery partners with consistently high delays should be monitored, and improvements in route planning, workload distribution, 
or delivery operations can help enhance service quality and customer experience.
*/

-- Business Objective 3 : To understand customer behavior and loyalty patterns to strengthen retention
-- Business Question 5 : Which customer segment (New, Returning, Loyal) contributes the highest revenue and spending?
SELECT
    c.Customer_Type,
    COUNT(o.Order_Key) AS Total_Orders,
    SUM(o.Final_Amount) AS Total_Revenue,
    ROUND(AVG(o.Order_Value),2) AS Avg_Order_Value,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Customer_Rating
FROM customers c
JOIN orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_Type
ORDER BY Total_Revenue DESC, Avg_Order_Value DESC;
/*
Note:
 New Customer      : Recently acquired customer who has started using the platform.
 Returning Customer: Customer who has come back after the initial purchase but whose purchasing behaviour is still occasional or moderate.
 Loyal Customer    : Customer who repeatedly chooses the platform over a long period, demonstrating strong engagement and a higher likelihood of retention.
*/

/*
Interpretation :
- New customers generated the highest total revenue (30.26 million) and placed the highest number of orders (54,067), 
making them the largest contributor to the business. 
This indicates that the company is successfully attracting new customers and generating strong sales from customer acquisition.

- Returning customers ranked second by contributing 19.55 million in revenue from 34,873 orders. 
They also recorded the highest average order value (546.21), suggesting that returning customers tend to spend 
slightly more per order than other customer segments.

- Loyal customers contributed the lowest total revenue (6.19 million) because they represent the smallest customer segment (11,060 orders). 
However, they achieved the highest average customer rating (4.03), indicating greater satisfaction and 
a stronger long-term relationship with the business.

- Overall, the business should continue attracting new customers to sustain revenue growth while implementing targeted loyalty and 
retention programs to convert New and Returning customers into Loyal customers, thereby improving long-term customer value.
*/

-- Business Question 6 : Which age group contributes the highest revenue, order volume, and customer satisfaction?
SELECT
    c.Age_Group,
    COUNT(o.Order_Key) AS Total_Orders,
    SUM(o.Final_Amount) AS Total_Revenue,
    ROUND(AVG(o.Order_Value),2) AS Avg_Order_Value,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Customer_Rating
FROM customers c
JOIN orders o ON c.Customer_ID = o.Customer_ID
GROUP BY c.Age_Group
ORDER BY Total_Revenue DESC, Total_Orders DESC;

/*
Interpretation :
- Customers aged 36–50 contributed the highest total revenue (20.75 million) and placed the highest number of orders (37,043), 
making them the most valuable customer segment in terms of overall business contribution.

- The 26–35 age group ranked second in revenue generation (16.22 million) and recorded the highest average order value (546.69), 
indicating that customers in this segment tend to spend slightly more per order than other age groups.

- Customers aged 18–25 achieved the highest average customer rating (4.03), suggesting greater satisfaction with the platform despite
generating comparatively lower revenue than the older age groups.

- Customers aged 50 and above contributed the lowest revenue (6.91 million) and the fewest orders (12,365), 
indicating comparatively lower engagement with the platform.

- Overall, the analysis suggests that the 36–50 age group should remain the primary target for revenue-focused marketing campaigns, 
while the 26–35 age group presents opportunities for premium offerings due to their higher spending per order. 
The 18–25 age group can be targeted with retention and loyalty programs to convert their high satisfaction into increased purchasing frequency.
*/

-- Business Objective 4 : To assess profitability and efficiency across regions, restaurants, and delivery partners.
-- Business Question 7 : Which cuisines generate the highest revenue and customer satisfaction?
SELECT
    r.Cuisine_Type,
    COUNT(o.Order_Key) AS Total_Orders,
    SUM(o.Final_Amount) AS Total_Revenue,
    ROUND(AVG(o.Order_Value),2) AS Avg_Order_Value,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Customer_Rating
FROM restaurants r
JOIN orders o ON r.Restaurant_ID = o.Restaurant_ID
GROUP BY r.Cuisine_Type
ORDER BY Total_Revenue DESC, Avg_Customer_Rating DESC;

/*
Interpretation :
- Italian cuisine generated the highest total revenue (16.34 million) and recorded the highest number of orders (29,228), 
making it the most profitable and popular cuisine in the platform.

- Chinese cuisine ranked second by generating 15.08 million in revenue from 26,908 orders while maintaining an average customer rating of 4.03, 
matching Italian cuisine in customer satisfaction.

- Indian cuisine generated 12.73 million in revenue with an average order value of 546.05, 
indicating that customers tend to spend slightly more per order compared to Italian cuisine despite a lower overall order volume.

- Fast Food contributed the lowest revenue (11.84 million) and processed the fewest orders (21,123). 
However, its average order value (546.23) remained the highest among all cuisines, 
suggesting that customers purchasing Fast Food tend to place slightly higher-value orders.

- Overall, Italian and Chinese cuisines should remain priority categories for menu expansion and promotional campaigns 
due to their strong revenue generation and consistently high customer satisfaction. 
Indian and Fast Food cuisines present opportunities to increase order volume while maintaining their healthy average order values.
*/

-- Business Question 8 : Which cuisines handle the highest average number of orders per restaurant, indicating stronger operational demand?
SELECT
    r.Cuisine_Type,
    COUNT(DISTINCT r.Restaurant_ID) AS Total_Restaurants,
    COUNT(o.Order_Key) AS Total_Orders,
    ROUND(COUNT(o.Order_Key) / COUNT(DISTINCT r.Restaurant_ID),2) AS Avg_Orders_Per_Restaurant,
    SUM(o.Final_Amount) AS Total_Revenue,
    ROUND(AVG(o.Order_Rating),2) AS Avg_Customer_Rating
FROM restaurants r
JOIN orders o
ON r.Restaurant_ID = o.Restaurant_ID
GROUP BY r.Cuisine_Type
ORDER BY Avg_Orders_Per_Restaurant DESC;

/*Interpretation :
- Chinese cuisine handled the highest average number of orders per restaurant (190.84), indicating the strongest operational demand among all 
cuisine types. 

- Indian cuisine ranked second (186.40), demonstrating consistently high restaurant activity. 

- Although Italian cuisine generated the highest overall revenue (₹16.34M), its average orders per restaurant (180.42) were slightly lower, 
suggesting higher revenue despite handling fewer orders per outlet. 

- Fast Food recorded the lowest average orders per restaurant (168.98), indicating comparatively lower operational demand and 
presenting an opportunity to increase customer traffic through targeted promotions.
*/