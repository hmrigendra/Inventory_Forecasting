/*
====================================
DDL Script: Cretae Bronze Tables
====================================
Script Purpose:
	This script creates tables in the 'bronze' schma, dropping existing tables that alrady exist.
	Run this script to redefine the DDL structure of 'bronze' Tables.
====================================
*/

USE Inventory_Forecasting

IF OBJECT_ID ('bronze.combined', 'U') IS NOT NULL
	DROP TABLE bronze.combined;

CREATE TABLE bronze.combined (
	date DATE,
	store_ID NVARCHAR(50),
	product_ID NVARCHAR(50),
	category NVARCHAR(50),
	region NVARCHAR(50),
	inventory_level INT,
	units_sold INT,
	units_ord INT,
	demand_for DECIMAL(10,2),
	price DECIMAL(10,2),
	discount DECIMAL(5,0),
	weather_cond NVARCHAR(50),
	promo BIT,
	comp_pricing DECIMAL (10,2),
	seasonality NVARCHAR(50)
);
GO