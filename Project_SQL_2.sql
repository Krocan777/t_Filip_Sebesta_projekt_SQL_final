-- Zalozeni VIEW, upraveni nazvu stejnych zemi mezi cbd a ct --
CREATE VIEW covid19_tests_tests_performed_modified AS
SELECT 
	CASE WHEN country = 'Czech Republic'
			THEN 'Czechia'
		 WHEN country = 'United States'
		 	THEN 'US' 
		 WHEN country = 'Taiwan' 
		 	THEN 'Taiwan*'
		 ELSE country
	END AS country,
	date,
	tests_performed
FROM covid19_tests ct 
;

SELECT 
	*
FROM covid19_tests_tests_performed_modified cttpm
WHERE country = 'Czechia'
;

-- Vytvoreni tabulky pomoci VIEW cttpm, kde se nachazi data country, date, confirmed, tests_performed --
CREATE TABLE cbd_and_cttpm AS 
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
	*
FROM cbd_and_cttpm cac
;

-- Vytvoøení TABLE pro následné vytvoøení VIEW EXCEPT s tabulkou cbd_and_cttpm pro následné vytvoøení TABLE Union
-- Vytvoreni TABLE pro EXCEPT 
CREATE TABLE cbd_and_cttpm_EXCEPT AS 
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

SELECT 
	*
FROM cbd_and_cttpm_except cace  
;

-- Vytvoreni VIEW pro UNION
CREATE VIEW cbd_and_cttpm_for_union AS 
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
FROM cbd_and_cttpm_for_union cacfu 
;

-- Vytvoreni TABLE cbd_and_cttpm_2, z duvodu chybejicich statu, ktere se puvodne vyskytovaly v tabulce covid19_tests ale nevyskytovaly se v tabulce cbd 
CREATE TABLE cbd_and_cttpm_2 AS 
SELECT 
	*
FROM cbd_and_cttpm cac 
UNION
SELECT 
	*
FROM cbd_and_cttpm_for_union cacfu 
;

SELECT 
	*
FROM cbd_and_cttpm_2 cac
WHERE country = 'Australia'
ORDER BY country 
;





