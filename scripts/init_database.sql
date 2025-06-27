/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'Inventory_Forecasting' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'Inventory_Forecasting' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'Inventory_Forecasting' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Inventory_Forecasting')
BEGIN
    ALTER DATABASE Inventory_Forecasting SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Inventory_Forecasting;
END;
GO

-- Create the 'Inventory_Forecasting' database
CREATE DATABASE Inventory_Forecasting;
GO

USE Inventory_Forecasting;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
