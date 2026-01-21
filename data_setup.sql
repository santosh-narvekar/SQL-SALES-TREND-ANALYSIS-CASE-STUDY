-- Create a new database for the retail sales dataset
CREATE DATABASE retail;

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
	sales_month DATE,
	naics_code VARCHAR(50),
	kind_of_business TEXT,
	reason_for_null VARCHAR(100),
	sales NUMERIC
);

-- This copies all the data from the csv file to the retail_sales table
COPY retail_sales
FROM '/Users/yourusername/Downloads/us_retail_sales.csv' -- Change this location to the location where you saved the csv file
DELIMITER ','
CSV HEADER;