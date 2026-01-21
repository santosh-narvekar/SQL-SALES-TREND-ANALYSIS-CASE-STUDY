-- time-series analysis
-- monthly and yearly sales trend
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	KIND_OF_BUSINESS = 'Retail and food services sales, total';

-- monthly sales report from 1992-2020 for a particular business
SELECT
	TO_CHAR(SALES_MONTH, 'FMMonth, YYYY') AS SALES_MONTH,
	SALES
FROM
	RETAIL_SALES
WHERE
	KIND_OF_BUSINESS = 'Retail and food services sales, total'
ORDER BY
	SALES_MONTH DESC;

-- => January, 2020
-- yearly sales report from 1992-2020 
SELECT
	DATE_PART('year', SALES_MONTH) AS SALES_YEAR,
	SUM(SALES) AS YEARLY_SALES
FROM
	RETAIL_SALES
GROUP BY
	SALES_YEAR
ORDER BY
	SALES_YEAR DESC;

-- scenario: want data from 1990 to 2024 want to improve records
-- also want to fill sales values where sales are null year wise for our report
-- 1990,1991, 2021, 2022, 2023, 2024
-- not hardcoding years as it is not a feasible solution
-- so, how to generate a report where data is not there for certain years
-- but we want it in our report, then how to include it
-- think of any sql concept 

SELECT
	GENERATE_SERIES(
		'1990-01-01'::DATE,
		'2024-12-31'::DATE,
		'1 day'::INTERVAL
	) AS DATE;

WITH
	DATE_DIMENSION AS (
		-- not specific to any industry
		-- it will only have dates like a calendar
		-- frequently used in time-series analysis
		-- all important information is provided by this table
		-- this is a very expensive operation in whole query
		-- first create dates, then extract year part of it
		-- also note, its a static information
		-- it will be always 1990 for a year
		-- and day of week for 1 jan 1990 will always be monday
		-- so better solution will be to create a table
		-- pregenerate or precalculate it for further use cases
		SELECT
			DATE,
			DATE_PART('year', DATE) AS YEAR
		FROM
			GENERATE_SERIES(
				'1990-01-01'::DATE,
				'2024-12-31'::DATE,
				'1 day'::INTERVAL
			) AS DATE
	)
SELECT
	D.YEAR,
	SUM(R.SALES) AS TOTAL_SALES
FROM
	DATE_DIMENSION D
	-- the table to join is known as a fact table 
	-- contains factual information like a revenue  
	LEFT JOIN RETAIL_SALES R ON D.DATE = R.SALES_MONTH
GROUP BY
	D.YEAR
ORDER BY
	D.YEAR;

-- generic/reusable date dimension table
-------------------------------------
SELECT
	DATE::DATE,
	DATE_PART('day', DATE)::INT AS DAY_OF_MONTH,
	DATE_PART('doy', DATE)::INT AS DAY_OF_YEAR,
	DATE_PART('dow', DATE)::INT AS DAY_OF_WEEK
FROM
	GENERATE_SERIES(
		'1990-01-01'::DATE,
		'2050-12-31'::DATE,
		'1 day'::INTERVAL
	) AS DATE
---------------------------------------
-- table for time series analysis upto 2050 from 1990

CREATE TABLE DATE_DIM AS
SELECT
	DATE::DATE,
	TO_CHAR(DATE, 'yyyymmdd')::INT AS DATE_KEY,
	DATE_PART('day', DATE)::INT AS DAY_OF_MONTH,
	DATE_PART('doy', DATE)::INT AS DAY_OF_YEAR,
	DATE_PART('dow', DATE)::INT AS DAY_OF_WEEK,
	TRIM(TO_CHAR(DATE, 'Day')) AS DAY_NAME,
	TRIM(TO_CHAR(DATE, 'Dy')) AS DAY_SHORT_NAME,
	DATE_PART('week', DATE)::INT AS WEEK_NUMBER,
	TO_CHAR(DATE, 'W')::INT AS WEEK_OF_MONTH,
	DATE_TRUNC('week', DATE)::DATE AS WEEK,
	DATE_PART('month', DATE)::INT AS MONTH_NUMBER,
	TRIM(TO_CHAR(DATE, 'Month')) AS MONTH_NAME,
	TRIM(TO_CHAR(DATE, 'Mon')) AS MONTH_SHORT_NAME,
	DATE_TRUNC('month', DATE)::DATE AS FIRST_DAY_OF_MONTH,
	(
		DATE_TRUNC('month', DATE) + INTERVAL '1 month' - INTERVAL '1 day'
	)::DATE AS LAST_DAY_OF_MONTH,
	DATE_PART('quarter', DATE)::INT AS QUARTER_NUMBER,
	TRIM('Q' || DATE_PART('quarter', DATE)::INT) AS QUARTER_NAME,
	DATE_TRUNC('quarter', DATE)::DATE AS FIRST_DAY_OF_QUARTER,
	(
		DATE_TRUNC('quarter', DATE) + INTERVAL '3 months' - INTERVAL '1 day'
	)::DATE AS LAST_DAY_OF_QUARTER,
	DATE_PART('year', DATE)::INT AS YEAR,
	DATE_PART('decade', DATE)::INT * 10 AS DECADE,
	DATE_PART('century', DATE)::INT AS CENTURYS
FROM
	GENERATE_SERIES('1990-01-01'::DATE, '2050-12-31'::DATE, '1 day') AS DATE;

SELECT
	*
FROM
	DATE_DIM;

-- much faster than previous date dimension query with cte
SELECT
	D.YEAR,
	SUM(R.SALES) AS TOTAL_SALES
FROM
	DATE_DIM D
	-- the table to join is known as a fact table 
	-- contains factual information like a revenue  
	LEFT JOIN RETAIL_SALES R ON D.DATE = R.SALES_MONTH
WHERE
	D.YEAR BETWEEN 1990 AND 2024
GROUP BY
	D.YEAR
ORDER BY
	D.YEAR DESC;

-- Example using the date_dim table
-- our tables can hove some gaps
-- for the dates we are not making any sales
-- to generate a report for each day with dates we havent made any revenue
-- solution use date_dim table as it has all the dates
-- and use left join
SELECT
	D.YEAR,
	SUM(R.SALES) AS TOTAL_SALES
FROM
	DATE_DIM D
	LEFT JOIN RETAIL_SALES R ON D.DATE = R.SALES_MONTH
WHERE
	D.YEAR BETWEEN 1990 AND 2024
GROUP BY
	D.YEAR
ORDER BY
	D.YEAR;

-- top business categories by sales
-- Q: Identify the top 5 kind_of_business categories based on there sales contribution
-- for the year 2020
-- I LEARNED WHY NOT TO USE NULL WHILE ORDERING DATA
-- subquery in select
-- cte to make it more readable
WITH
	TOTAL_SALES_2020 AS (
		SELECT
			SUM(SALES) AS TOTAL_SALES
		FROM
			RETAIL_SALES
		WHERE
			DATE_PART('year', SALES_MONTH) = 2020
			AND SALES IS NOT NULL
	)
SELECT
	KIND_OF_BUSINESS,
	SUM(SALES) AS TOTAL_SALES_2020,
	ROUND(
		(
			-- current_sales / cur_year_sales(2020 in this case) * 100
			SUM(SALES) / (
				SELECT
					TOTAL_SALES
				FROM
					TOTAL_SALES_2020
			) * 100
		),
		2
	) AS SALES_CONTRIBUTION_PERCENTAGE
FROM
	RETAIL_SALES
WHERE
	DATE_PART('year', SALES_MONTH) = 2020
	AND SALES IS NOT NULL
GROUP BY
	KIND_OF_BUSINESS
ORDER BY
	TOTAL_SALES_2020 DESC
LIMIT
	5;

-- YoY Sales Analysis
-- very common in time-series-analysis
-- Q: Calculate year-over-year (YoY) growth in total_value
-- subtask 1
-- calculate yearly sales report for a specific kind  of business
SELECT
	DATE_PART('year', D.DATE) AS SALES_YEAR,
	SUM(SALES) AS TOTAL_SALES
FROM
	DATE_DIM D
	LEFT JOIN RETAIL_SALES RS ON D.DATE = RS.SALES_MONTH
GROUP BY
	SALES_YEAR
ORDER BY
	SALES_YEAR;

WITH
	YEARLY_SALES_REPORT AS (
		SELECT
			DATE_PART('year', SALES_MONTH) AS SALES_YEAR,
			SUM(SALES) AS YEARLY_SALES
		FROM
			RETAIL_SALES
		WHERE
			KIND_OF_BUSINESS = 'Retail and food services sales, total'
		GROUP BY
			SALES_YEAR
	)
	-- use of lag -> RETURNS PREVIOUS VALUES
	-- can use subquery instead of cte for temporary table
SELECT
	SALES_YEAR,
	YEARLY_SALES,
	LAG(YEARLY_SALES) OVER (
		ORDER BY
			SALES_YEAR
	) AS PREVIOUS_YEAR_SALES,
	ROUND(
		(
			(
				YEARLY_SALES - LAG(YEARLY_SALES) OVER (
					ORDER BY
						SALES_YEAR
				)
			) / LAG(YEARLY_SALES) OVER (
				ORDER BY
					SALES_YEAR
			)
		) * 100,
		2
	) AS YOY_GROWTH_PERCENTAGE
FROM
	YEARLY_SALES_REPORT;

-- learned the practical use case of lag

SELECT sales_month,
sales,
LAG(sales) OVER( order by sales)
from retail_sales;