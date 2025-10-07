 /*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categorie contributes the most to the overall sales?

WITH category_sales AS (
SELECT 
category,
SUM(sales_amount) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY category
)
SELECT
category,
total_sales,
SUM(total_sales) OVER() AS overall_sales, 
--the Percentage 
CONCAT(ROUND((CAST(total_sales  as FLOAT)/ SUM(total_sales) OVER())*100,2), '%') as percentage_of_total
FROM category_sales
ORDER BY  total_sales DESC