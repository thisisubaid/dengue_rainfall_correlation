/* 
Correlation between Monsoon Rainfall and Dengue Outbreak
Author: Md Ubaidullah Ansari
Date: 2025-09-13

This script contains all SQL queries for the public health analysis project.
All tables are in the `top-geography-426410-i8.public_health` dataset.
*/

-- ***************************************************
-- QUESTION 1: Data Summary
-- What is the total number of cases and rainfall?
-- ***************************************************

--Summary for Dengue
SELECT 
    SUM(cases) AS total_cases,
    AVG(cases) AS avg_monthly_cases
FROM `top-geography-426410-i8.public_health.dengue_cases`;

-- Summary for Rainfall
SELECT 
    SUM(PRCP) AS total_rainfall,
    AVG(PRCP) AS avg_monthly_rainfall
FROM `top-geography-426410-i8.public_health.rainfall`;

-- ***************************************************
-- QUESTION 2: Seasonal Patterns
-- Which months have the highest average cases and rainfall?
-- ***************************************************

---- Highest/Lowest Average Cases by Month
SELECT 
    month,
    AVG(cases) AS avg_cases
FROM `top-geography-426410-i8.public_health.dengue_cases`
GROUP BY month
ORDER BY avg_cases DESC;

-- Highest/Lowest Average Rainfall by Month
SELECT 
    EXTRACT(MONTH FROM DATE) AS month,
    AVG(PRCP) AS avg_rainfall
FROM top-geography-426410-i8.public_health.rainfall
GROUP BY month
ORDER BY avg_rainfall DESC;

-- ***************************************************
-- QUESTION 3: Correlation Analysis
-- What is the average number of cases after the top 5 wettest months?
-- ***************************************************

-- Average cases after the top 5 wettest months
SELECT 
    AVG(d.cases) AS avg_cases_after_heavy_rain
FROM top-geography-426410-i8.public_health.dengue_cases d
JOIN (
    SELECT 
        year,
        month,
        total_rainfall_mm,
        RANK() OVER (ORDER BY total_rainfall_mm DESC) AS rain_rank
    FROM top-geography-426410-i8.public_health.rainfall_monthly
) r
  ON d.year = CASE WHEN r.month = 12 THEN r.year + 1 ELSE r.year END
 AND d.month = CASE WHEN r.month = 12 THEN 1 ELSE r.month + 1 END
WHERE r.rain_rank <= 5;

-- ***************************************************
-- QUESTION 4: Lag Validation
-- How does the relationship change with a 1-month vs 2-month lag?
-- ***************************************************

-- Compare average cases for one-month lag vs. two-month lag after high rain
SELECT 
    '1_month_lag' AS lag_period,
    AVG(d.cases) AS avg_cases
FROM `top-geography-426410-i8.public_health.dengue_cases` d
JOIN (
    SELECT 
        year, 
        month
    FROM `top-geography-426410-i8.public_health.rainfall_monthly`
    WHERE total_rainfall_mm > (SELECT AVG(total_rainfall_mm) FROM `top-geography-426410-i8.public_health.rainfall_monthly`)
) r
  ON d.year = CASE WHEN r.month + 1 > 12 THEN r.year + 1 ELSE r.year END
 AND d.month = CASE WHEN r.month + 1 > 12 THEN r.month + 1 - 12 ELSE r.month + 1 END

UNION ALL

SELECT 
    '2_month_lag' AS lag_period,
    AVG(d.cases) AS avg_cases
FROM `top-geography-426410-i8.public_health.dengue_cases` d
JOIN (
    SELECT 
        year, 
        month
    FROM `top-geography-426410-i8.public_health.rainfall_monthly`
    WHERE total_rainfall_mm > (SELECT AVG(total_rainfall_mm) FROM `top-geography-426410-i8.public_health.rainfall_monthly`)
) r
  ON d.year = CASE WHEN r.month + 2 > 12 THEN r.year + 1 ELSE r.year END
 AND d.month = CASE WHEN r.month + 2 > 12 THEN r.month + 2 - 12 ELSE r.month + 2 END;
