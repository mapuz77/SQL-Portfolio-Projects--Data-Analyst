/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

SELECT
	order_date,
	sales_amount
FROM gold.fact_sales
WHERE  order_date IS NOT NULL
ORDER BY order_date


-- Calculate the total sales per month 
SELECT
DATETRUNC (month, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE  order_date IS NOT NULL
GROUP BY DATETRUNC (month, order_date)
ORDER BY DATETRUNC (month, order_date)



 --  Calculate the running total of sales over time for each year  
 --for each MONTH
 SELECT 
 order_date,
 total_sales,
 --window function
 SUM (total_sales) OVER(ORDER BY order_date) AS runing_total
 FROM
 ( 
SELECT
DATETRUNC (month, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE  order_date IS NOT NULL
GROUP BY DATETRUNC (month, order_date)
)t

--  Calculate the running total of sales over time for each year  
 --for each YEAR
 SELECT 
 order_date,
 total_sales,
 --window function
 SUM (total_sales) OVER(ORDER BY order_date) AS runing_total
 FROM
 ( 
SELECT
DATETRUNC (year, order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE  order_date IS NOT NULL
GROUP BY DATETRUNC (year, order_date)
)t

--To calculate moving average
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t