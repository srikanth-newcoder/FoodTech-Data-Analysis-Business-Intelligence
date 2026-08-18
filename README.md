# FoodTech Data Analysis & Business Intelligence
## Analyze Food Delivery Demand Across Regions to Inform Market Expansion & Logistics

### Project Overview
This project analyzes food delivery business data to understand customer behavior, regional demand, revenue performance, restaurant performance, delivery partner efficiency, and operational factors affecting delivery quality.

The project follows an end-to-end data analytics workflow using SQL, Excel, Power BI, Python, Statistics, and Machine Learning.

The analysis focuses on four major business areas:
- Market expansion and regional demand
- Customer purchasing behavior and retention
- Restaurant performance
- Delivery and logistics efficiency

---

## Business Objectives

1. Identify high-demand regions and revenue opportunities to support market expansion.
2. Analyze customer purchasing behavior, spending patterns, ratings, and loyalty.
3. Evaluate restaurant performance based on revenue, orders, ratings, and operational metrics.
4. Evaluate delivery partner performance, delivery efficiency, delivery speed, vehicle performance, and customer satisfaction.

---

## Dataset

The project uses four core datasets:
- Customers
- Orders
- Restaurants
- Delivery Partners

These datasets contain information related to customers, orders, restaurants, cuisines, delivery partners, regions, delivery performance, ratings, and revenue.

The data was cleaned and transformed before being used for analysis.

---

## Database Design

A relational database was designed using four core entities:
- Customers
- Orders
- Restaurants
- Delivery Partners

Primary keys and foreign keys were implemented to establish relationships between the tables.

The database also includes:
- SQL Views
- Stored Procedures
- Audit Triggers
- Referential Integrity Checks
- Joins and Aggregations
- Subqueries
- Window Functions

A surrogate key was introduced for the Orders table because the original Order_ID contained repeated values representing different business transactions.

---

## Data Cleaning & Preprocessing

The raw datasets were prepared for analysis through:
- Data type validation
- Duplicate and consistency checks
- Missing-value checks
- Relationship validation
- Derived column creation
- Data transformation
- Preparation of analysis-ready datasets

---

## Excel Analysis

An Excel dashboard was developed to analyze:
- Revenue by region
- Revenue by cuisine
- Customer segments
- Customer purchasing behavior
- Delivery-time categories
- Vehicle performance
- Key business KPIs

The dashboard was used to identify business trends and generate initial recommendations.

---

## Power BI Dashboard

A five-page Power BI dashboard was developed:
### 1. Executive Overview
Provides an overall view of revenue, orders, customers, ratings, and business performance.

### 2. Customer Insights
Analyzes customer distribution, customer types, spending behavior, ratings, and loyalty patterns.

### 3. Restaurant Performance
Evaluates restaurant revenue, order volume, ratings, cuisines, and restaurant-level performance.

### 4. Delivery Partner Performance
Analyzes delivery time, delivery efficiency, vehicle performance, delivery partner ratings, and delivery outcomes.

### 5. Business Trends & Performance
Analyzes revenue trends, order trends, average order value, customer ratings, and overall business performance.

Interactive slicers were used to analyze the data by dimensions such as year, month, region, customer type, cuisine, and vehicle type.

---

## Statistical Analysis

Statistical techniques were applied to answer business questions and validate relationships within the data.

### Joint Probability
Only 0.53% of orders experienced both slow delivery and a customer rating below 4.

### Conditional Probability
78.56% of Fast deliveries received a customer rating of 4 or above, indicating a positive relationship between faster delivery and customer satisfaction.

### Sampling Distribution
Larger random samples produced sample means closer to the population mean, demonstrating the importance of adequate sample sizes for reliable business estimates.

### Two-Sample Z-Test
The average delivery time between Urban and Metropolitan regions showed no statistically significant difference.

- Z Statistic: 0.2156
- P-value: 0.8293

### Chi-Square Test
There was no statistically significant association between Customer Type and Delivery Time Category.

- Chi-Square Statistic: 4.2525
- P-value: 0.3729
- Degrees of Freedom: 4

---

## Machine Learning
Three machine learning approaches were implemented.

### Simple Linear Regression
Used Average Delivery Speed to predict Delivery Efficiency Score.

- R² Score: 0.4358
- MAE: 0.13
- RMSE: 0.16

The model showed that delivery speed alone explains approximately 44% of the variation in delivery efficiency.

### Multiple Linear Regression
Used multiple operational factors:

- Average Delivery Speed
- Average Preparation Time
- Order Capacity per Day
- Festival Flag

Model performance:

- R² Score: 0.7926
- MAE: 0.0684
- RMSE: 0.0946

The model provided a significant improvement over Simple Linear Regression.

### Logistic Regression
Used operational factors to classify deliveries into High and Low Delivery Efficiency.

Model performance:

- Accuracy: 93.96%
- Precision for High Efficiency: 97%
- Recall for High Efficiency: 93%

Average Preparation Time had the strongest negative influence on delivery efficiency, while delivery speed had a positive influence.

---

## Key Business Findings

- Regional demand and revenue patterns can support targeted market expansion.
- New customers contribute a large share of order volume, creating an opportunity to improve customer retention.
- Restaurant preparation time is an important factor affecting delivery efficiency.
- Faster delivery is associated with higher customer ratings.
- Delivery performance is broadly consistent across customer segments.
- Delivery efficiency can be better explained when multiple operational factors are considered together.

---

## Business Recommendations

### Reduce Restaurant Preparation Time
Improve kitchen workflows, staffing plans, order management, and preparation-time monitoring.

### Optimize Delivery Routes
Use delivery KPIs, workload balancing, GPS-based route analysis, and performance-based partner allocation.

### Expand High-Demand Regions
Increase restaurant partnerships, delivery coverage, and region-specific marketing in areas with strong demand and revenue potential.

### Improve Customer Retention
Use loyalty rewards, personalized offers, customer feedback, and faster complaint resolution to convert new customers into returning and loyal customers.

### Monitor Operational KPIs
Use Excel and Power BI dashboards to continuously monitor revenue, orders, delivery efficiency, customer ratings, and other operational KPIs.

### Use Machine Learning for Proactive Planning
Use predictive models to identify potential efficiency risks and support proactive logistics and operational planning.

---

## Tools & Technologies

- SQL / MySQL
- Microsoft Excel
- Power BI
- Python
- Pandas
- NumPy
- Matplotlib
- Scikit-learn
- SciPy
- Statistics
- Machine Learning

---

## Project Workflow
Raw Data,
    
Data Cleaning & Preprocessing,
    
Relational Database Design,
    
SQL Analysis & Automation,
    
Excel Analysis,
    
Power BI Dashboards,
    
Statistical Analysis,
    
Machine Learning,
    
Business Insights,
    
Recommendations.
