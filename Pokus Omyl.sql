
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
dfas
