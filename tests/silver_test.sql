/*
===============================================================================
Silver Layer Quality Checks
===============================================================================
Purpose:
- Ensure integrity and completeness of transformed data from the bronze layer.
- Validate keys, relationships, date ranges, duplicates, and potential data loss.

Usage:
- Run this after populating all silver tables.
- Investigate and resolve any queries that return results.
===============================================================================
*/

USE Inventory_Forecasting;
GO

-- ====================================================================
-- Checking for 'silver.store_info'
-- ====================================================================

-- Bronze store_IDs not mapped to Silver store_info
-- Expectation: No results
SELECT DISTINCT bc.store_ID
FROM bronze.combined bc
LEFT JOIN silver.store_info ssi
    ON ssi.store_key = bc.store_ID
WHERE ssi.store_key IS NULL;

-- Bronze regions not mapped to Silver store_info
-- Expectation: No results
SELECT DISTINCT bc.region
FROM bronze.combined bc
LEFT JOIN silver.store_info ssi
    ON ssi.region = bc.region
WHERE ssi.region IS NULL;

-- Store keys in silver that do not appear in bronze
-- Expectation: No results
SELECT store_id
FROM silver.store_info
WHERE store_key NOT IN (
    SELECT DISTINCT store_ID FROM bronze.combined
);

-- Duplicate store_id in silver.store_info
-- Expectation: No results
SELECT store_id, COUNT(*) AS cnt
FROM silver.store_info
GROUP BY store_id
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking for 'silver.prd_info'
-- ====================================================================

-- Bronze product_IDs not mapped to Silver prd_info
-- Expectation: No results
SELECT DISTINCT bc.product_ID
FROM bronze.combined bc
LEFT JOIN silver.prd_info spi
    ON spi.prd_key = bc.product_ID
WHERE spi.prd_key IS NULL;

-- Bronze categories not mapped to Silver prd_info
-- Expectation: No results
SELECT DISTINCT bc.category
FROM bronze.combined bc
LEFT JOIN silver.prd_info spi
    ON spi.cat = bc.category
WHERE spi.cat IS NULL;

-- Product keys in silver that do not appear in bronze
-- Expectation: No results
SELECT prd_key
FROM silver.prd_info
WHERE prd_key NOT IN (
    SELECT DISTINCT product_ID FROM bronze.combined
);

-- Duplicate prd_id in silver.prd_info
-- Expectation: No results
SELECT prd_id, COUNT(*) AS cnt
FROM silver.prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking for 'silver.inv_lvl_info'
-- ====================================================================

-- prd_id in prd_info not mapped in inv_lvl_info
-- Expectation: No results
SELECT DISTINCT spi.prd_id
FROM silver.prd_info spi
LEFT JOIN silver.inv_lvl_info sii
    ON sii.prd_id = spi.prd_id
WHERE sii.prd_id IS NULL;

-- store_id in store_info not mapped in inv_lvl_info
-- Expectation: No results
SELECT DISTINCT spi.store_id
FROM silver.store_info spi
LEFT JOIN silver.inv_lvl_info sii
    ON sii.store_id = spi.store_id
WHERE sii.store_id IS NULL;

-- Invalid date ranges in inv_lvl_info (start > end)
-- Expectation: No results
SELECT *
FROM silver.inv_lvl_info
WHERE prd_st_dt > prd_end_dt;

-- Overlapping date ranges in inv_lvl_info for same prd_id and store_id
-- Expectation: No results
WITH inv_dates AS (
    SELECT *,
        LEAD(prd_st_dt) OVER (PARTITION BY store_id, prd_id ORDER BY prd_st_dt) AS next_start_date
    FROM silver.inv_lvl_info
)
SELECT *
FROM inv_dates
WHERE next_start_date IS NOT NULL AND prd_end_dt >= next_start_date;

-- ====================================================================
-- Checking for 'silver.pricing_info'
-- ====================================================================

-- prd_id in prd_info not mapped in pricing_info
-- Expectation: No results
SELECT DISTINCT spi.prd_id
FROM silver.prd_info spi
LEFT JOIN silver.pricing_info spci
    ON spci.prd_id = spi.prd_id
WHERE spci.prd_id IS NULL;

-- store_id in store_info not mapped in pricing_info
-- Expectation: No results
SELECT DISTINCT spi.store_id
FROM silver.store_info spi
LEFT JOIN silver.pricing_info spci
    ON spci.store_id = spi.store_id
WHERE spci.store_id IS NULL;

-- Invalid date ranges in pricing_info (start > end)
-- Expectation: No results
SELECT *
FROM silver.pricing_info
WHERE prd_st_dt > prd_end_dt;

-- Overlapping date ranges in pricing_info for same prd_id and store_id
-- Expectation: No results
WITH prices AS (
    SELECT *,
        LEAD(prd_st_dt) OVER (PARTITION BY store_id, prd_id ORDER BY prd_st_dt) AS next_start_date
    FROM silver.pricing_info
)
SELECT *
FROM prices
WHERE next_start_date IS NOT NULL AND prd_end_dt >= next_start_date;

-- ====================================================================
-- Checking for 'silver.date_info'
-- ====================================================================

-- prd_id in prd_info not mapped in date_info
-- Expectation: No results
SELECT DISTINCT spi.prd_id
FROM silver.prd_info spi
LEFT JOIN silver.date_info sdi
    ON sdi.prd_id = spi.prd_id
WHERE sdi.prd_id IS NULL;

-- store_id in store_info not mapped in date_info
-- Expectation: No results
SELECT DISTINCT spi.store_id
FROM silver.store_info spi
LEFT JOIN silver.date_info sdi
    ON sdi.store_id = spi.store_id
WHERE sdi.store_id IS NULL;

-- ====================================================================
-- Sanity check: Count validation
-- Expectation: Silver layer row counts should align with bronze records
-- ====================================================================

-- Total records in bronze.combined
SELECT COUNT(*) AS bronze_records
FROM bronze.combined;

-- Total records in silver.inv_lvl_info
SELECT COUNT(*) AS inv_level_records
FROM silver.inv_lvl_info;

-- Total records in silver.pricing_info
SELECT COUNT(*) AS pricing_records
FROM silver.pricing_info;

-- Total records in silver.date_info
SELECT COUNT(*) AS date_info_records
FROM silver.date_info;
