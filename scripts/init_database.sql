/*
======================================
CREATES DATABASE AND SCHEMAS
======================================
Script Purpose:
	This script creates a database names 'Inventory_Forecasting' after checking if it already exists.
	If the database already exists, it drops it and is created again.

Warning:
	The script will the database 'Inventory_Forecasting'.
	Tread with caution.
*/

USE master;
GO

-- Drops and creates database 'Inventory_Forecasting'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Inventory_Forecasting')
BEGIN
	ALTER DATABASE Inventory_Forecasting SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Inventory_Forecasting;
END;
GO

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