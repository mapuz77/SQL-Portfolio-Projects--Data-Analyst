/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) AS  order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 

FROM gold.fact_sales  f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL 
GROUP BY YEAR(f.order_date), p.product_name
) 
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS  diff_in_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below avg'
	 ELSE 'Avg'
END avg__change,
--Year-Over-Year-Analaysis
LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) AS  previous_year_sales,
current_sales - LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) AS diff_of_previous_year,
CASE WHEN current_sales - LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'INCREASE'
	 WHEN current_sales - LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'DECREASE'
	 ELSE 'NO_Change'
END previous_year__change
FROM yearly_product_sales;

/*===========================================================================================*/
/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

--Yearly Performance of Products
SELECT
YEAR(f.order_date) AS  order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 

FROM gold.fact_sales  f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL 
GROUP BY YEAR(f.order_date), p.product_name; 


--the Average Sales Performance
WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) AS  order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 

FROM gold.fact_sales  f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL 
GROUP BY YEAR(f.order_date), p.product_name
) 
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS  diff_in_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below avg'
			ELSE 'Avg'
END avg__change
FROM yearly_product_sales;


-- the Previous Year's Sales 
WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) AS  order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 

FROM gold.fact_sales  f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL 
GROUP BY YEAR(f.order_date), p.product_name
) 
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS  diff_in_avg,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above avg'
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below avg'
	 ELSE 'Avg'
END avg__change,
--Year-Over-Year-Analaysis
LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) AS  previous_year_sales,
current_sales - LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) AS diff_of_previous_year,
CASE WHEN current_sales - LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'INCREASE'
	 WHEN current_sales - LAG (current_sales)	OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'DECREASE'
	 ELSE 'NO_Change'
END previous_year__change
FROM yearly_product_sales