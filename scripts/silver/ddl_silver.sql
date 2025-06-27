/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('silver.store_info', 'U') IS NOT NULL
	DROP TABLE silver.store_info;
GO

CREATE TABLE silver.store_info (
	store_id INT,
	store_key NVARCHAR(50),
	region NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.prd_info', 'U') IS NOT NULL
	DROP TABLE silver.prd_info;
GO

CREATE TABLE silver.prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	cat NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.inv_lvl_info', 'U') IS NOT NULL
	DROP TABLE silver.inv_lvl_info;
GO

CREATE TABLE silver.inv_lvl_info (
	prd_id INT,
	store_id INT,
	prd_st_dt DATE,
	prd_end_dt DATE,
	inv_lvl INT,
	units_sold INT,
	units_ord INT,
	dmd_for DECIMAL(10,2),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.pricing_info', 'U') IS NOT NULL
	DROP TABLE silver.pricing_info;
GO

CREATE TABLE silver.pricing_info (
	prd_id INT,
	store_id INT,
	prd_st_dt DATE,
	prd_end_dt DATE,
	price DECIMAL (10,2),
	disc DECIMAL (5,2),
	comp_pri DECIMAL (10,2),
	promo BIT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.date_info', 'U') IS NOT NULL
	DROP TABLE silver.date_info;
GO

CREATE TABLE silver.date_info (
	date DATE,
	store_id INT,
	prd_id INT,
	weath_cond NVARCHAR(50),
	seas NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO