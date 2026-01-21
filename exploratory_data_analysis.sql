/*** Exploratory data analysis (EDA) ***/0

SELECT * FROM RETAIL_SALES;


-- Count the total number of rows in the table
SELECT COUNT(*) FROM RETAIL_SALES;

-- Check for missing sales value
SELECT * FROM RETAIL_SALES
Where sales is null
;

-- we want to exclude this null values

-- check reason for null
-- instead of scrolling
-- write sql to look for different reason of that null sales

-- Check the various reason_for_null sales value and take the count for identify patterns

Select reason_for_null,COUNT(*)
from retail_sales
where sales is null
Group by reason_for_null

-- check for missing dates
Select * from retail_sales
where sales_month is null;

-- no missing dates - good - no inconsistent data

-- check missing naics code
Select * from retail_sales
where naics_code is null;

-- 2436 nulls
-- no nulls for kind for business => good
-- Validate sales format

Select * from retail_Sales
where sales  <= 0;

-- no negative values

-- Basic statiscs for sales => min, max, average
-- for eda

Select min(sales),max(sales),round(avg(sales),2)
from retail_sales;

-- Identify Outliers: Detect unusually high or low sales

-- Unusally high
Select * from retail_sales
Where sales is not null
Order by sales desc
LIMIT 10;

-- NO OUTLIER , NO ISSUE IN UPPER END SIDE

-- Unusally low
Select * from retail_sales
Where sales is not null
Order by sales 
LIMIT 10;

-- LITTLE MORE DIFFERENCE BUT NOT TOTALLY OUT OF RANGE (positive values, not like 0 or going in negative), SO NO OUTLIERS
-- NO OUTLIERS 

-- Categorical Analysis: Most Frequent Business Types
SELECT kind_of_business, COUNT(*) AS record_count FROM retail_sales
Group by kind_of_business
ORDER BY record_count DESC

-- all business have 348 records
-- uniform distribution of records in kinds of business