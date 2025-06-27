/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

USE Inventory_Forecasting;
GO

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		-- Loading silver.store_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.store_info';
		TRUNCATE TABLE silver.store_info;
		PRINT '>> Inserting Data Into: silver.store_info';


		INSERT INTO silver.store_info (
			store_id,
			store_key,
			region
		)
		SELECT
			ROW_NUMBER() OVER (ORDER BY store_ID, region) AS unique_store_id,
			store_ID,
			region
		FROM (
			SELECT DISTINCT
				store_ID,
				region
			FROM bronze.combined
		) AS distinct_pairs
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.prd_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.prd_info';
		TRUNCATE TABLE silver.prd_info;
		PRINT '>> Inserting Data Into: silver.prd_info';
		INSERT INTO silver.prd_info (
			prd_id,
			prd_key,
			cat
		)
		SELECT
			ROW_NUMBER() OVER (ORDER BY product_ID) AS prd_id,
			product_ID,
			category
		FROM (
			SELECT DISTINCT
				bc.product_ID,
				bc.category
			FROM bronze.combined bc
		) AS distinct_pairs
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.inv_lvl_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.inv_lvl_info';
		TRUNCATE TABLE silver.inv_lvl_info;
		PRINT '>> Inserting Data Into: silver.inv_lvl_info';
		INSERT INTO silver.inv_lvl_info (
			prd_id,
			store_id,
			prd_st_dt,
			prd_end_dt,
			inv_lvl,
			units_sold,
			units_ord,
			dmd_for
		)
		SELECT
			spi.prd_id,
			ssi.store_id,
			bc.date as prd_st_dt,
			DATEADD(DAY, -1, LEAD(date) OVER (PARTITION BY spi.prd_id, ssi.store_id ORDER BY date)) AS prd_end_dt,
			bc.inventory_level,
			bc.units_sold,
			bc.units_ord,
			bc.demand_for
		FROM
		bronze.combined bc
		LEFT JOIN silver.prd_info spi
		ON spi.prd_key = bc.product_ID
		LEFT JOIN silver.store_info ssi
		ON ssi.store_key = bc.store_ID AND ssi.region = bc.region
		ORDER BY prd_id, store_id, date;
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.pricing_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.pricing_info';
		TRUNCATE TABLE silver.pricing_info;
		PRINT '>> Inserting Data Into: silver.pricing_info';
		INSERT INTO silver.pricing_info (
			prd_id,
			store_id,
			prd_st_dt,
			prd_end_dt,
			price,
			disc,
			comp_pri,
			promo
		)
		SELECT
			spi.prd_id,
			ssi.store_id,
			bc.date AS prd_st_dt,
			DATEADD(DAY, -1, LEAD(date) OVER (PARTITION BY spi.prd_id, ssi.store_id ORDER BY bc.date)) AS prd_end_dt,
			bc.price,
			bc.discount,
			bc.comp_pricing,
			bc.promo
		FROM bronze.combined bc
		LEFT JOIN silver.prd_info spi
		ON spi.prd_key = bc.product_ID
		LEFT JOIN silver.store_info ssi
		ON ssi.store_key = bc.store_ID AND ssi.region = bc.region
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.date_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.date_info';
		TRUNCATE TABLE silver.date_info;
		PRINT '>> Inserting Data Into: silver.date_info';
		INSERT INTO silver.date_info (
			date,
			store_id,
			prd_id,
			weath_cond,
			seas
		)
		SELECT
			bc.date,
			ssi.store_id,
			spi.prd_id,
			bc.weather_cond,
			bc.seasonality
		FROM bronze.combined bc
		LEFT JOIN silver.store_info ssi
		ON ssi.store_key = bc.store_ID AND ssi.region = bc.region
		LEFT JOIN silver.prd_info spi
		ON spi.prd_key = bc.product_ID
		ORDER BY bc.date, ssi.store_id, spi.prd_id;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
		PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END