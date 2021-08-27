
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

SELECT DISTINCT 
	country
FROM covid19_basic_differences cbd 
WHERE country LIKE 'US%'
;


SELECT 
	cbd.country,
	cbd.date,
	cbd.confirmed,
	cttpm.tests_performed
FROM covid19_basic_differences AS cbd 
LEFT JOIN covid19_tests_tests_performed_modified AS cttpm 
	ON cbd.country = cttpm.country 
	AND cbd.`date` = cttpm.`date` 
ORDER BY cbd.`date`,cbd.country 
;

SELECT 
	cac.country,
	cac.date,
	cac.confirmed,
	cac.tests_performed,
	lt.population
FROM cbd_and_cttpm AS cac
LEFT JOIN lookup_table AS lt
	ON cac.country = lt.country 
		AND lt.province IS NULL 
;

SELECT 
	*
FROM cbd_and_cttpm cac
;

-- Vytvoreni VIEW pro nasledny EXCEPT pro nasledny UNION s cbd_and_cttpm

SELECT 
	cttpm.country,
	cttpm.date,
	cac.confirmed,
	cttpm.tests_performed
FROM covid19_tests_tests_performed_modified AS cttpm 
LEFT JOIN cbd_and_cttpm AS cac 
	ON cttpm.country = cac.country 
	AND cttpm.`date` = cac.`date` 
ORDER BY cttpm.`date`, cttpm.country 
;

DROP VIEW pokus 
;

SELECT 
	country
FROM countries c 
EXCEPT 
SELECT country
FROM cbd_and_cttpm cac 
;

SELECT 
	country
FROM cbd_and_cttpm cac 
EXCEPT
SELECT
	country 
FROM countries c 

SELECT DISTINCT 
	country
FROM pokus
;
SELECT 
	*
FROM countries c
;

SELECT 
	*
FROM cbd_and_cttpm cac 
;

SELECT DISTINCT 
	country 
FROM countries c 
EXCEPT
SELECT DISTINCT 
	country 
FROM cbd_and_cttpm cac 
;

-- Dalsi pokusy
SELECT 
	*
FROM cbd_and_cttpm_EXCEPT
EXCEPT 
SELECT
	*
FROM cbd_and_cttpm
;

SELECT 
	*
FROM cbd_and_cttpm cac 
WHERE country = 'Mexico'
;

SELECT 
	*
FROM cbd_and_cttpm cac 
UNION
SELECT 
	*
FROM cbd_and_cttpm_for_union cacfu 
;

SELECT DISTINCT 
	cac2.country,
	lt.population
FROM cbd_and_cttpm_2 AS cac2 
LEFT JOIN lookup_table AS lt 
	ON cac2.country = lt.country
	AND lt.province IS NULL
;

SELECT DISTINCT 
	country,
	population 
FROM lookup_table lt 
WHERE province IS NULL
;

SELECT DISTINCT 
	country
FROM cbd_and_cttpm_2 cac 
;

SELECT DISTINCT 	
	country
FROM covid19_tests
EXCEPT
SELECT DISTINCT 
	country
FROM covid19_basic_differences cbd
;

SELECT 
	*
FROM lookup_table lt 
WHERE country = 'Korea, South'
;

SELECT 
	cac2.*,
	lt.population
FROM cbd_and_cttpm_2 AS cac2 
LEFT JOIN lookup_table AS lt 
	ON cac2.country = lt.country 
	AND lt.province IS NULL 
;

SELECT
	*,
	CASE WHEN weekday(`date`) BETWEEN 0 AND 4
		THEN 'Pracovni den'
		ELSE 'Vikend'
	END AS PracovniDen_Vikend
FROM cbd_and_cttpm_3 cac 
;

SELECT 
	WEEKDAY(`date`)
FROM cbd_and_cttpm_3 cac2 
;

SELECT 
	*,
	CASE WHEN MONTH(`date`) BETWEEN 3 AND 5
			THEN 0
		 WHEN MONTH(`date`) BETWEEN 6 AND 8
			THEN 1
		 WHEN MONTH(`date`) BETWEEN 9 AND 11
			THEN 2
		 ELSE 3
	END AS Rocni_obdobi
FROM cbd_and_cttpm_4 cac 
;

SELECT 
	MONTH(`date`) 
FROM cbd_and_cttpm_4 cac 
;

SELECT 	
	*
FROM countries c
;

SELECT 
	country 
FROM covid19_tests ct 
UNION
SELECT 
	country 
FROM covid19_basic_differences cbd 
;

SELECT 
	*
FROM lookup_table lt 
WHERE country = 'Taiwan*'
;

CREATE VIEW countries_modified AS 
SELECT 
	CASE WHEN country = 'Czech Republic'
			THEN 'Czechia'
		 WHEN country = 'United States'
		 	THEN 'US' 
		 WHEN country = 'Taiwan' 
		 	THEN 'Taiwan*'
		 WHEN country = 'South Korea'
		 	THEN 'Korea, South'
		 ELSE country
	END AS country,
	population_density
FROM countries
;

SELECT 
	*
FROM countries_modified
;

SELECT 
	cac5.*,
	cm.population_density
FROM cbd_and_cttpm_5 AS cac5
LEFT JOIN countries_modified AS cm 
	ON cac5.country = cm.country 
;

SELECT  
	CASE WHEN country = 'Czech Republic'
			THEN 'Czechia'
		 WHEN country = 'United States'
		 	THEN 'US' 
		 WHEN country = 'Taiwan' 
		 	THEN 'Taiwan*'
		 WHEN country = 'South Korea'
		 	THEN 'Korea, South'
		 ELSE country
	END AS country,
	`year`,
	ROUND(GDP/population, 3) AS HDP_na_obyvatele
FROM economies e 
WHERE `year` = 2019
	OR `year` = 2020
;

SELECT 
	*
FROM economies e 
WHERE country = 'Germany'
	
