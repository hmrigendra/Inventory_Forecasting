/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'bronze' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading bronze Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

USE Inventory_Forecasting;
GO

-- Basic Sanity Check: Raw preview
-- Expectation: Manual inspection, if needed

SELECT *
FROM bronze.combined;

-- Check: NULLs in Date Field  
-- Expectation: No NULLs in date

SELECT *
FROM bronze.combined
WHERE date IS NULL;

-- Check: Distict Values
-- Expectation: Distinct values for manual inspection

SELECT DISTINCT store_ID
FROM bronze.combined;

SELECT DISTINCT product_ID
FROM bronze.combined;

SELECT DISTINCT category
FROM bronze.combined;

SELECT DISTINCT region
FROM bronze.combined;

SELECT DISTINCT weather_cond
FROM bronze.combined;

SELECT DISTINCT seasonality
FROM bronze.combined;

-- Check: NULLs or Negative Values in Numeric Fields  
-- Expectation: No NULLs or negative values
SELECT *
FROM bronze.combined
WHERE inventory_level IS NULL OR inventory_level < 0
	  OR units_sold IS NULL OR units_sold < 0
	  OR units_ord IS NULL OR units_ord < 0
	  OR demand_for IS NULL OR  demand_for < 0
	  OR price IS NULL OR price < 0
	  OR discount IS NULL OR discount < 0
	  OR promo IS NULL OR promo NOT IN (0,1)
	  OR comp_pricing IS NULL OR comp_pricing < 0;

-- Check for unwanted spaces
-- Expectation: No mismatch between original and trimmed values
SELECT *
FROM bronze.combined
WHERE store_ID != TRIM(store_ID)
	OR product_ID != TRIM(product_ID)
	OR category != TRIM(category)
	OR region != TRIM(region)
	OR weather_cond != TRIM(weather_cond)
	OR seasonality != TRIM(seasonality);

-- Check: Date Range Validity  
-- Expectation: All dates fall within 2022-01-01 to 2023-12-31
SELECT *
FROM bronze.combined
WHERE date NOT BETWEEN '2022-01-01' AND '2023-12-31';

-- Check: Duplicate Primary Key Candidates  
-- Expectation: No duplicates for (date, store_ID, region, product_ID)
SELECT date, store_ID, region, product_ID, COUNT(*) AS cnt
FROM bronze.combined
GROUP BY date, store_ID, region, product_ID
HAVING COUNT(*) > 1

-- Check: Logical Consistency - Sold Units > Inventory  
-- Expectation: No cases where units_sold > inventory_level
-- Inconsistency Found (but ignoring for now)
SELECT *
FROM bronze.combined
WHERE units_sold > inventory_level;

-- Check: Chronological Order Within Store + Region + Product  
-- Expectation: No records where current date > next date
WITH cte AS (
	SELECT *,
		LEAD(date) OVER (PARTITION BY store_ID, region, product_ID order by DATE) AS next_date
	FROM bronze.combined
)
SELECT *
FROM cte
WHERE date > next_date;