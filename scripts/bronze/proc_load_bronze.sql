/*
================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
================================================
Script Purpose:
    This stored procedure loads data int I the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the BULK INSERT command to load data from csv Files to bronze tables.
Parameters:
    None.
  This stored procedure does not accept any parameters or return any values.
Usage Example:
    EXEC bronze.load_bronze;
*/

USE Inventory_Forecasting;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME
	BEGIN TRY
		SET @start_time = GETDATE();
		PRINT '=========================';
		PRINT 'Loading Bronze Layer';
		PRINT '=========================';

		PRINT '-------------------------';
		PRINT 'Loading Tables';
		PRINT '-------------------------';

		-- Clear data before loading
		PRINT '>> Truncating Table: bronze.combined';
		IF OBJECT_ID('bronze.combined') IS NOT NULL
			TRUNCATE TABLE bronze.combined;

		-- Load CSV file into the table
		PRINT '>> Inserting Data Into Table: bronze.combined';
		BULK INSERT bronze.combined
		FROM 'C:\Users\mrige\Downloads\CAC Project\inventory_forecasting.csv'
		WITH (
			FIRSTROW = 2,                            -- Skip header row
			FIELDTERMINATOR = ',',                   -- Fields separated by commas
			ROWTERMINATOR = '0x0a',                  -- Line break (\n) - in hexadecimal
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '-------------------------';

	END TRY

	BEGIN CATCH
		PRINT '=========================';
		PRINT 'Error occurred during loading Bronze Layer';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================';
	END CATCH
END


--SELECT * FROM bronze.combined