SELECT 
	*
FROM collegedegrees.college_majors;

-- Using to check for possible duplicate rows of data

SELECT
	COUNT(Major)
FROM collegedegrees.college_majors
GROUP BY Major
HAVING COUNT(Major) > 1;

-- Now trying to find any null values in the data set

SELECT 
    *
FROM collegedegrees.college_majors
WHERE Total IS NULL;

-- Only one row contains NULL values so we will remove it in order to ensure the later calculations are accurate

DELETE FROM collegedegrees.college_majors
WHERE Major_code = 1104 AND Major = 'FOOD SCIENCE';

-- Finding the 5 most popular majors between men and women

SELECT 
	Major,
    Men,
    Major_category
FROM collegedegrees.college_majors
ORDER BY Men DESC
LIMIT 5;

SELECT 
	Major,
    Women,
    Major_category
FROM collegedegrees.college_majors
ORDER BY Women DESC
LIMIT 5;

-- Finding the most popular major categories based on number of graduates

SELECT
	Major_category,
    SUM(Total) AS TotalNumber
FROM collegedegrees.college_majors
GROUP BY Major_category
ORDER BY TotalNumber DESC;

-- Now that we know what the most popular major categories, lets see which ones pay the most (based on full-time workers)

SELECT 
	Major_category,
    AVG(Median) AS median_salary
FROM collegedegrees.college_majors
GROUP BY Major_category
ORDER BY median_salary DESC;

-- Finding the top specific majors for median income (full-time workers)

SELECT
	major,
    median
FROM collegedegrees.college_majors
GROUP BY Major
ORDER BY median DESC
LIMIT 10;


-- 	Finding the percent difference between each major and the average median salary of its own major category

WITH cte AS (SELECT
	major,
	median,
    major_category,
    AVG(median) OVER(PARTITION BY major_category) AS AVGMedianPerMC
FROM collegedegrees.college_majors
ORDER BY major_category, median DESC)
SELECT 
	major_category,
	major,
    (median - AVGMedianPerMC) / median * 100 AS PercentDiffBetweenMCAVGMedian
FROM cte
ORDER BY major_category, PercentDiffBetweenMCAVGMedian DESC;

-- % of men and women in each major

SELECT
	Major,
    major_category,
    men / total * 100 AS PercentMen,
   women / total * 100 AS PercentWomen
FROM collegedegrees.college_majors
ORDER BY major_category, PercentMen DESC, PercentWomen DESC;

-- Adding classifications to the majorities of majors

SELECT
	*,
    CASE
		WHEN PercentMen BETWEEN 50.0001 AND 59.9999 THEN 'SlightMenMajority'
        WHEN PercentMen BETWEEN 60.0000 AND 69.9999 THEN 'MenMajority'
        WHEN PercentMen > 70 THEN 'MajorMenMajority'
        WHEN PercentWomen BETWEEN 50.0001 AND 59.9999 THEN 'SlightWomenMajority'
        WHEN PercentWomen BETWEEN 60.0000 AND 69.9999 THEN 'WomenMajority'
        WHEN PercentWomen > 70 THEN 'MajorWomenMajority'
        END AS 'Majority'
FROM (SELECT
	Major,
    major_category,
    men / total * 100 AS PercentMen,
   women / total * 100 AS PercentWomen
FROM collegedegrees.college_majors
ORDER BY major_category, PercentMen DESC, PercentWomen DESC) subqry;

-- Using the above query as a CTE to take the 'Majority' column and use it to further analyze salary and whether men or women are in better paying fields

WITH cte AS (SELECT
	*,
    CASE
		WHEN PercentMen BETWEEN 50.0001 AND 59.9999 THEN 'SlightMenMajority'
        WHEN PercentMen BETWEEN 60.0000 AND 69.9999 THEN 'MenMajority'
        WHEN PercentMen > 70 THEN 'MajorMenMajority'
        WHEN PercentWomen BETWEEN 50.0001 AND 59.9999 THEN 'SlightWomenMajority'
        WHEN PercentWomen BETWEEN 60.0000 AND 69.9999 THEN 'WomenMajority'
        WHEN PercentWomen > 70 THEN 'MajorWomenMajority'
        END AS 'Majority'
FROM (SELECT
	Major,
    major_category,
    men / total * 100 AS PercentMen,
   women / total * 100 AS PercentWomen
FROM collegedegrees.college_majors
ORDER BY major_category, PercentMen DESC, PercentWomen DESC) subqry)
SELECT 
    c.major_category,
    c.major,
    m.median,
    c.majority
FROM collegedegrees.college_majors m
JOIN cte c ON m.major = c.major
ORDER BY m.median DESC;

-- Another means to get the previous query but without specification for majority type

SELECT 
	major_category,
    major,
    median,
    CASE
		WHEN men > women THEN 'MajorityMen'
        WHEN women > men THEN 'MajorityWomen'
        END Majority
FROM collegedegrees.college_majors
GROUP BY Major
ORDER BY Median DESC;

-- median income of women dominated fields vs men dominated fields

SELECT
	AVG(CASE WHEN Majority = 'majoritymen' THEN Median END) AVG_Men_Median,
    AVG(CASE WHEN Majority = 'majoritywomen' THEN Median END) AVG_Women_Median
FROM (SELECT 
	major_category,
    major,
    median,
    CASE
		WHEN men > women THEN 'MajorityMen'
        WHEN women > men THEN 'MajorityWomen'
        END Majority
FROM collegedegrees.college_majors
GROUP BY Major
ORDER BY Median DESC) x;

-- Finding the top ten majors based on employment rate

SELECT 
	Major,
    major_category,
    unemployment_rate
FROM collegedegrees.college_majors
ORDER BY unemployment_rate
LIMIT 10;

-- Find possible correlation between low unemployment and higher median salary

SELECT
	major,
    major_category,
    unemployment_rate,
    median
FROM collegedegrees.college_majors
ORDER BY median DESC, unemployment_rate;

-- Top 5 women populated majors

SELECT
	major,
    major_category,
    women
FROM collegedegrees.college_majors
ORDER BY women DESC
LIMIT 5;

-- Top 5 men poplulated majors

SELECT
	major,
    major_category,
    men
FROM collegedegrees.college_majors
ORDER BY men DESC
LIMIT 5;





