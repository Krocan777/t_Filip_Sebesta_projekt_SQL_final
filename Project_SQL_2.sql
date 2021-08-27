-- Zalozeni VIEW, upraveni nazvu stejnych zemi mezi cbd a ct --
CREATE VIEW covid19_tests_tests_performed_modified AS
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
	date,
	tests_performed
FROM covid19_tests ct 
;

SELECT 
	*
FROM covid19_tests_tests_performed_modified cttpm
;

-- Vytvoreni TABLE pomoci VIEW cttpm, kde se budou nachazet data country, date, confirmed, tests_performed (budou chybet zeme, ktere se nachazi 
-- v covid19_tests ale nenachazi se v covid19_basic_differences) --
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
FROM cbd_and_cttpm AS cac
;

-- Vytvoreni pomocne TABLE pro následné vytvoøení TABLE s EXCEPT s tabulkou cbd_and_cttpm pro následné vytvoøení TABLE s UNION s tabulkou cbd_and_cttpm,
-- z duvodu doplneni zemi, ktere se nachazi v tabulce covid19_tests a nejsou v nove vytvorene tabulce cbd_and_cttpm

-- Vytvoreni TABLE pro EXCEPT 
CREATE TABLE cbd_and_cttpm_for_except AS 
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
FROM cbd_and_cttpm_for_except AS cacfe  
;

-- Vytvoreni TABLE pro UNION (Tato tabulka obsahuje zaznamy zemi z covid19_test, ktere nejsou v tabulce cbd a tudiz take ne v nove vytvorene tabulce cac)
CREATE TABLE cbd_and_cttpm_for_union AS 
SELECT 
	*
FROM cbd_and_cttpm_for_except cacfe 
EXCEPT 
SELECT
	*
FROM cbd_and_cttpm
;

SELECT 
	*
FROM cbd_and_cttpm_for_union AS cacfu 
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
FROM cbd_and_cttpm_2 AS cac2
;

-- Vytvoreni tabulky cbd_and_cttpm_3 > napojeni sloupce population z lookup_table na cbd_and_cttpm_2
CREATE TABLE cbd_and_cttpm_3 AS 
SELECT 
	cac2.*,
	lt.population
FROM cbd_and_cttpm_2 AS cac2 
LEFT JOIN lookup_table AS lt 
	ON cac2.country = lt.country 
	AND lt.province IS NULL 
;

SELECT	
	*
FROM cbd_and_cttpm_3 AS cac3 
;

-- Vytvoreni tabulky cbd_and_cttpm_4 > napojeni 1. cas. promenne, prac. den/vikend
CREATE TABLE cbd_and_cttpm_4 AS 
SELECT
	*,
	CASE WHEN WEEKDAY(`date`) BETWEEN 0 AND 4
		THEN 'Pracovni den'
		ELSE 'Vikend'
	END AS PracovniDen_Vikend
FROM cbd_and_cttpm_3 AS cac3
;

SELECT 
	*
FROM cbd_and_cttpm_4 AS cac4 

-- Vytvoreni tabulky cbd_and_cttpm_5 > napojeni 2. cas. promenne, rocni obdobi
CREATE TABLE cbd_and_cttpm_5 AS 
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
FROM cbd_and_cttpm_4 AS cac4
;

SELECT 
	*
FROM cbd_and_cttpm_5
;

-- Vytvoreni VIEW countries_modified, protoze potrebujeme napojit hustotu zalidneni z tabulky countries na cbd_and_cttpm_5 a nejake zeme maji jine nazvy
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
FROM countries_modified cm 

-- Vytvoreni tabulky cbd_and_cttpm_6 > napojeni hustoty obyvatel 
CREATE TABLE cbd_and_cttpm_6 AS 
SELECT 
	cac5.*,
	cm.population_density
FROM cbd_and_cttpm_5 AS cac5
LEFT JOIN countries_modified AS cm 
	ON cac5.country = cm.country
;

SELECT 
	*
FROM cbd_and_cttpm_6
ORDER BY date 
;

-- Vytvoreni VIEW, kde bude zobrazeno HDP na obyvatele za rok 2019 a 2020
CREATE VIEW economies_hdp_na_obyvatele AS 
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
FROM economies_hdp_na_obyvatele ehno 






