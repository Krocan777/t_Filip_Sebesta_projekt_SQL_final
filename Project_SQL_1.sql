
SELECT 
	*
FROM covid19_basic_differences cbd 
WHERE confirmed IS NOT NULL 
	AND confirmed != 0
	AND country = 'Austria'
;

SELECT 
	country
FROM covid19_basic_differences cbd 

;

SELECT 
	country,
	population 
FROM countries c 
;

SELECT 
	country,
	population 
FROM lookup_table lt
WHERE province IS NULL 
;

SELECT 
	ct.country,
	cbd.date,
	cbd.confirmed,
	ct.tests_performed,
	c.population 
FROM covid19_basic_differences AS cbd 
LEFT JOIN covid19_tests AS ct 
	ON cbd.`date` = ct.date
LEFT JOIN countries AS c 
	ON c.country = cbd.country 
	AND ct.country = 'Austria'
;

SELECT 
	*
FROM economies e 
;

SELECT 
	date 
FROM covid19_tests ct 
WHERE country = 'Austria'
;

SELECT DISTINCT 
	country,
	population
FROM lookup_table lt 
WHERE province IS NULL 
;

SELECT  
	*
FROM covid19_basic_differences cbd
;

SELECT DISTINCT 
	country 
FROM covid19_tests ct 
;

SELECT
	COUNT(country)
FROM covid19_basic_differences cbd 
WHERE country = 'Austria'
;

SELECT 
	COUNT(country)
FROM covid19_tests ct
WHERE country = 'Austria'
;

SELECT 
	country 
FROM covid19_tests ct2 
;

SELECT 
	cbd.country,
	ct.country
FROM covid19_basic_differences cbd 
LEFT JOIN covid19_tests ct 
	ON cbd.country = ct.country 
	AND cbd.country = 'Austria'
;

SELECT 
	cbd.country,
	cbd.date,
	cbd.confirmed,
	ct.tests_performed 
FROM (
	SELECT
		country,
		date,
		confirmed
	FROM covid19_basic_differences
) AS cbd
LEFT JOIN covid19_tests ct 
	ON cbd.date = ct.`date` 
	AND cbd.country = ct.country
	ORDER BY cbd.date, cbd.country 
;

SELECT 
	cbd.country,
	cbd.date,
	cbd.confirmed,
	ct.tests_performed
FROM covid19_tests AS ct 
RIGHT JOIN covid19_basic_differences AS cbd 
	ON cbd.country = ct.country 
	AND cbd.`date` = ct.`date` 
ORDER BY cbd.`date`, cbd.country 
;

SELECT 
	cbd.country,
	cbd.date,
	cbd.confirmed,
	ct.tests_performed
FROM covid19_basic_differences AS cbd 
LEFT JOIN covid19_tests AS ct 
	ON cbd.country = ct.country 
	AND cbd.`date` = ct.`date` 
ORDER BY cbd.`date`,cbd.country 
;
	
SELECT 
	*
FROM covid19_basic_differences cbd
;

SELECT 
	*
FROM covid19_tests ct
;

SELECT 
	cbd.country,
	cbd.date,
	ct.country,
	ct.date
FROM covid19_basic_differences AS cbd, covid19_tests AS ct 
WHERE cbd.country = ct.country 
;

SELECT 
	ct.country,
	ct.date
FROM covid19_tests AS ct
EXCEPT
SELECT 
	cbd.country,
	cbd.date
FROM covid19_basic_differences cbd 
;

SELECT 
	*
FROM covid19_tests ct 
WHERE tests_performed IS NULL 
;


