DROP TABLE IF EXISTS public.date_dim;

CREATE TABLE public.date_dim AS
SELECT
	date::date,
	TO_CHAR(date, 'yyyymmdd')::INT AS date_key,
	DATE_PART('day', date)::INT AS day_of_month,
	DATE_PART('doy', date)::INT AS day_of_year,
	DATE_PART('dow', date)::INT AS day_of_week,
	TRIM(TO_CHAR(date, 'Day')) AS day_name,
	TRIM(TO_CHAR(date, 'Dy')) AS day_short_name,
	DATE_PART('week', date)::INT AS week_number,
	TO_CHAR(date, 'W')::INT AS week_of_month,
	DATE_TRUNC('week', date)::date AS week,
	DATE_PART('month', date)::INT AS month_number,
	TRIM(TO_CHAR(date, 'Month')) AS month_name,
	TRIM(TO_CHAR(date, 'Mon')) AS month_short_name,
	DATE_TRUNC('month', date)::date AS first_day_of_month,
	(DATE_TRUNC('month', date) + INTERVAL '1 month' - INTERVAL '1 day')::date AS last_day_of_month,
	DATE_PART('quarter', date)::INT AS quarter_number,
	TRIM('Q' || DATE_PART('quarter', date)::INT) AS quarter_name,
	DATE_TRUNC('quarter', date)::date AS first_day_of_quarter,
	(DATE_TRUNC('quarter', date) + INTERVAL '3 months' - INTERVAL '1 day')::date AS last_day_of_quarter,
	DATE_PART('year', date)::INT AS YEAR,
	DATE_PART('decade', date)::INT * 10 AS decade,
	DATE_PART('century', date)::INT AS centurys
FROM
	GENERATE_SERIES('1990-01-01'::date, '2050-12-31'::date, '1 day') AS date;

-- Example using the date_dim table
SELECT d.year, SUM(r.sales) AS total_sales
FROM date_dim d
LEFT JOIN retail_sales r ON d.date = r.sales_month
WHERE d.year BETWEEN 1990 AND 2024
GROUP BY d.year
ORDER BY d.year;