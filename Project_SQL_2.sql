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
;

-- Vytvoreni tabulky cbd_and_cttpm_7 > napojeni HDP na obyvatele, na kazdy zaznam se napojuje ukazatel z predchoziho roku 
CREATE TABLE cbd_and_cttpm_7 AS 
SELECT 
	cac6.*,
	ehno.HDP_na_obyvatele
FROM cbd_and_cttpm_6 AS cac6
LEFT JOIN (
			SELECT 
				HDP_na_obyvatele,
				country,
				`year`
			FROM economies_hdp_na_obyvatele
			) AS ehno
	ON cac6.country = ehno.country
	AND YEAR(cac6.`date`) = ehno.`year` + 1 
;

SELECT 
	*
FROM cbd_and_cttpm_7 cac 
;

-- Napadl me elegatnejsi kod, proto DROPnu VIEW economies_hdp_na_obyvatele a TABLE cbd_and_cttpm_7
DROP VIEW economies_hdp_na_obyvatele 
;

DROP TABLE cbd_and_cttpm_7 
;

-- Vytvoreni tabulky cbd_and_cttpm_7 > napojeni HDP na obyvatele, na kazdy zaznam se napojuje ukazatel z predchoziho roku 
CREATE TABLE cbd_and_cttpm_7 AS 
SELECT 
	cac6.*,
	e.GDP/e.population AS HDP_na_obyvatele
FROM cbd_and_cttpm_6 AS cac6
LEFT JOIN (
			SELECT 
				population,
				GDP,
				`year`,
				CASE WHEN country = 'Czech Republic'
						THEN 'Czechia'
					 WHEN country = 'United States'
					 	THEN 'US' 
					 WHEN country = 'Taiwan' 
					 	THEN 'Taiwan*'
					 WHEN country = 'South Korea'
					 	THEN 'Korea, South'
					 ELSE country
				END AS country
			FROM economies
			WHERE `year` = 2019 OR 2020
			) AS e
	ON cac6.country = e.country
	AND YEAR(cac6.`date`) = e.`year` + 1
;

SELECT 	
	*
FROM cbd_and_cttpm_7 cac
;

-- Vytvoreni tabulky cbd_and_cttpm_8 > napojeni gini ukazatele kazde zeme na kazdy zaznam
CREATE TABLE cbd_and_cttpm_8 AS 
SELECT 
	cac7.*,
	e.gini_avg
FROM cbd_and_cttpm_7 AS cac7
LEFT JOIN (
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
				ROUND(AVG(gini), 3) AS gini_avg
			FROM economies
			GROUP BY country 
			) AS e
	ON cac7.country = e.country 
;

SELECT 
	*
FROM cbd_and_cttpm_8 AS cac8
;

-- Vytvoreni tabulky cbd_and_cttpm_9 > napojeni sloupce detska umrtnost
CREATE TABLE cbd_and_cttpm_9 AS
SELECT 
	cac8.*,
	e.mortaliy_under5
FROM cbd_and_cttpm_8 AS cac8
LEFT JOIN (
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
				mortaliy_under5
			FROM economies 
			WHERE `year` = 2019
			) AS e 
		ON cac8.country = e.country
;

SELECT 
	*
FROM cbd_and_cttpm_9

-- Vytvoreni tabulky cbd_and_cttpm_10 > napojeni sloupce median_age_2018
CREATE TABLE cbd_and_cttpm_10 AS 
SELECT 
	cac9.*,
	c.median_age_2018
FROM cbd_and_cttpm_9 AS cac9
LEFT JOIN (
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
				median_age_2018
			FROM countries
			) AS c 
	ON cac9.country = c.country 
;

SELECT 
	*
FROM cbd_and_cttpm_10 
;

-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Christianity
CREATE TABLE podil_Christianity AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Christianity'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_christianity

-- Vytvoreni tabulky cbd_and_cttpm_11 > napojeni sloupce podil_Christianity
CREATE TABLE cbd_and_cttpm_11 AS 
SELECT 
	cac10.*,
	pc.`r.population / cac10.population * 100` AS podil_Christianity
FROM cbd_and_cttpm_10 AS cac10
LEFT JOIN podil_christianity AS pc 
	ON cac10.country = pc.country 
;

SELECT 
	*
FROM cbd_and_cttpm_11

-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Islam
CREATE TABLE podil_Islam AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Islam'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_Islam

-- Vytvoreni tabulky cbd_and_cttpm_12 > napojeni sloupce podil_Islam
CREATE TABLE cbd_and_cttpm_12 AS 
SELECT 
	cac10.*,
	p.`r.population / cac10.population * 100` AS podil_Islam
FROM cbd_and_cttpm_11 AS cac10
LEFT JOIN podil_Islam AS p
	ON cac10.country = p.country 
;

SELECT 
	*
FROM cbd_and_cttpm_12
;


-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Buddhism
CREATE TABLE podil_Buddhism AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Buddhism'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_Buddhism

-- Vytvoreni tabulky cbd_and_cttpm_13 > napojeni sloupce podil_Buddhism
CREATE TABLE cbd_and_cttpm_13 AS 
SELECT 
	cac10.*,
	p.`r.population / cac10.population * 100` AS podil_Buddhism
FROM cbd_and_cttpm_12 AS cac10
LEFT JOIN podil_Buddhism AS p
	ON cac10.country = p.country 
;

SELECT 	
	*
FROM cbd_and_cttpm_13
;

-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Hinduism
CREATE TABLE podil_Hinduism AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Hinduism'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_Hinduism
;

-- Vytvoreni tabulky cbd_and_cttpm_14 > napojeni sloupce podil_Hinduism
CREATE TABLE cbd_and_cttpm_14 AS 
SELECT 
	cac10.*,
	p.`r.population / cac10.population * 100` AS podil_Hinduism
FROM cbd_and_cttpm_13 AS cac10
LEFT JOIN podil_Hinduism AS p
	ON cac10.country = p.country 
;

SELECT 	
	*
FROM cbd_and_cttpm_14
;

-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Folk Religions
CREATE TABLE podil_Folk_Religions AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Folk Religions'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_Folk_Religions
;

-- Vytvoreni tabulky cbd_and_cttpm_15 > napojeni sloupce podil_Folk_Religions
CREATE TABLE cbd_and_cttpm_15 AS 
SELECT 
	cac10.*,
	p.`r.population / cac10.population * 100` AS podil_Folk_Religions
FROM cbd_and_cttpm_14 AS cac10
LEFT JOIN podil_Folk_Religions AS p
	ON cac10.country = p.country 
;

SELECT 	
	*
FROM cbd_and_cttpm_15
;

-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Unaffiliated Religions
CREATE TABLE podil_Unaffiliated_Religions AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Unaffiliated Religions'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_Unaffiliated_Religions
;

-- Vytvoreni tabulky cbd_and_cttpm_16 > napojeni sloupce podil_Unaffiliated_Religions
CREATE TABLE cbd_and_cttpm_16 AS 
SELECT 
	cac10.*,
	p.`r.population / cac10.population * 100` AS podil_Unaffiliated_Religions
FROM cbd_and_cttpm_15 AS cac10
LEFT JOIN podil_Unaffiliated_Religions AS p
	ON cac10.country = p.country 
;

SELECT 	
	*
FROM cbd_and_cttpm_16
;

-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Judaism
CREATE TABLE podil_Judaism AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Judaism'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_Judaism
;

-- Vytvoreni tabulky cbd_and_cttpm_17 > napojeni sloupce podil_Judaism
CREATE TABLE cbd_and_cttpm_17 AS 
SELECT 
	cac10.*,
	p.`r.population / cac10.population * 100` AS podil_Judaism
FROM cbd_and_cttpm_16 AS cac10
LEFT JOIN podil_Judaism AS p
	ON cac10.country = p.country 
;

SELECT 	
	*
FROM cbd_and_cttpm_17
;

-- Vytvoreni TABLE, kde se budou nachazet procentuelni podily vyznavacu Other Religions
CREATE TABLE podil_Other_Religions AS 
SELECT DISTINCT 
	r.*,
	r.population / cac10.population * 100
FROM (
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
				population
		FROM religions
		WHERE religion = 'Other Religions'
			AND `year` = 2020
	) AS r 
LEFT JOIN cbd_and_cttpm_10 AS cac10
	ON r.country = cac10.country 
;

SELECT 
	*
FROM podil_Other_Religions
;

-- Vytvoreni tabulky cbd_and_cttpm_18 > napojeni sloupce podil_Other_Religions
CREATE TABLE cbd_and_cttpm_18 AS 
SELECT 
	cac10.*,
	p.`r.population / cac10.population * 100` AS podil_Other_Religions
FROM cbd_and_cttpm_17 AS cac10
LEFT JOIN podil_Other_Religions AS p
	ON cac10.country = p.country 
;

SELECT 	
	*
FROM cbd_and_cttpm_18
;

-- Vytvoreni tabulky cbd_and_cttpm_19 > napojeni diff_life_expectancy
CREATE TABLE cbd_and_cttpm_19 AS 
SELECT 
	cac18.*,
	lf2.diff AS diff_life_expectancy
FROM cbd_and_cttpm_18 AS cac18
LEFT JOIN (
			SELECT 
				life_expectancy - nasledujici_hodnota AS diff,
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
				life_expectancy
			FROM (
					SELECT
						country,
						`year`,
						life_expectancy,
						LAG(life_expectancy) OVER(ORDER BY country DESC) AS nasledujici_hodnota
					FROM life_expectancy
					WHERE `year` = 1965
						OR `year` = 2015
					) AS lf
			WHERE `year` = 2015
			ORDER BY country) AS lf2
	ON cac18.country = lf2.country 
ORDER BY country, date 
;

SELECT 
	*
FROM cbd_and_cttpm_19
WHERE country = 'Czechia'
; 

-- Vytvorime pomocnou tabulku countries_modified_2
CREATE TABLE countries_modified_2 AS
SELECT 
	CASE WHEN c.country = 'Czech Republic'
						THEN 'Czechia'
					 WHEN c.country = 'United States'
						THEN 'US' 
					 WHEN c.country = 'Taiwan' 					
						THEN 'Taiwan*'
					WHEN c.country = 'South Korea'	
						THEN 'Korea, South'
					WHEN c.country = 'Russian Federation'
						THEN 'Russia'
					ELSE c.country
				END AS country,
	CASE WHEN c.capital_city = 'Athenai'
						THEN 'Athens'
					 WHEN c.capital_city = 'Bruxelles [Brussel]'
					 	THEN 'Brussels'
					 WHEN c.capital_city = 'Bucuresti'
					 	THEN 'Bucharest'
					 WHEN c.capital_city = 'Helsinki [Helsingfors]'
					 	THEN 'Helsinki'
					  WHEN c.capital_city = 'Kyiv'
					 	THEN 'Kiev'
					  WHEN c.capital_city = 'Lisboa'
					 	THEN 'Lisbon'
					  WHEN c.capital_city = 'Luxembourg [Luxemburg/L'
					 	THEN 'Luxembourg'
					 WHEN c.capital_city = 'Praha'
					 	THEN 'Prague'
					 WHEN c.capital_city = 'Roma'
					 	THEN 'Rome'
					 WHEN c.capital_city = 'Wien'
					 	THEN 'Vienna'
					 WHEN c.capital_city = 'Warszawa'
					 	THEN 'Warsaw'
					 ELSE c.capital_city 
				END AS city
FROM countries AS c 
;

SELECT 
	*
FROM countries_modified_2 cm 
;

-- Vytvoreni tabulky weather_2
CREATE TABLE weather_2 AS 
SELECT 
	w.time,
	REPLACE(temp, '°c', '') AS temp,
	w.rain,
	w.wind,
	CAST(`date` AS DATE) AS `date`,
	w.city,
	cm.country 
FROM weather AS w 
LEFT JOIN countries_modified_2 AS cm
	ON w.city = cm.city 
;

SELECT 
	*
FROM weather_2 w 
;
-- Vytvoreni pomocne tabulky pro prumernou denni teplotu
CREATE TABLE prum_denni_tep AS 
SELECT 
	AVG(temp),
	country,
	date
FROM weather_2 
WHERE `time` IN ('06:00', '09:00', '12:00', '15:00', '18:00')
	AND country IS NOT NULL 
GROUP BY country, date
;

SELECT 
	*
FROM prum_denni_tep

-- Vytvoreni tabulky cbd_and_cttpm_20 > napojeni sloupce prum_den_tep
CREATE TABLE cbd_and_cttpm_20 AS 
SELECT 
	cac19.*,
	pdt.`AVG(temp)` AS prum_den_tep
FROM cbd_and_cttpm_19 AS cac19
LEFT JOIN prum_denni_tep AS pdt
	ON cac19.country = pdt.country
	AND cac19.`date` = pdt.date
;

SELECT 
	*
FROM cbd_and_cttpm_20 cac 
ORDER BY country, `date` 
;

-- pouziti with a vnoreny select do jednoho dotazu, ocisteni dat a priprava poctu hodin deste behem dne
-- CREATE TABLE pokus3 AS 
WITH weather AS (
	SELECT
		CAST(`date` AS date) AS `date`,
		cb.`time`,
		cb.city,
		CAST(`temp_°c` AS INT) AS temp_°c,
		ROUND(CAST(`rain_in_mm` AS FLOAT),2) AS `rain_in_mm`,
		CAST(`max_gust_km_h` AS INT) AS `max_gust_km_h`,
		cm2.country,
		CASE WHEN rain_in_mm != 0.0
			THEN 3
			WHEN rain_in_mm = 0.0
			THEN 0
		END AS pocet_hodin_deste
	FROM (
			SELECT 
				`date`,
				`time`,
				city,
				REPLACE(temp, ' °c', '') AS temp_°c,
				REPLACE(rain, ' mm', '') AS rain_in_mm,
				REPLACE (gust, ' km/h', '') AS max_gust_km_h
			FROM weather w4 ) AS cb
	LEFT JOIN countries_modified_2 AS cm2
		ON cb.city = cm2.city
	)
SELECT 
	*
FROM weather cb
;

-- Napojeni sloupce sum_h_dest na moji tabulku 
CREATE TABLE cbd_and_cttpm_21 AS 
WITH cbd_and_cttpm_20 AS (
	SELECT
		cac20.*,
		p3.sum_h_dest
	FROM cbd_and_cttpm_20 AS cac20
	LEFT JOIN (
		SELECT 
			`date`,
			country,
			CASE WHEN SUM(pocet_hodin_deste) > 24 
				THEN SUM(pocet_hodin_deste) / 2
				ELSE SUM(pocet_hodin_deste)
			END AS sum_h_dest
		FROM pokus3
		GROUP BY date, city 
		) AS p3
	ON cac20.country = p3.country
		AND cac20.date = p3.date
		)
SELECT 
	*
FROM cbd_and_cttpm_20
;	

SELECT 
	*
FROM cbd_and_cttpm_21
;

-- Napojeni sloupce max_gust_km_h 
CREATE TABLE t_Filip_Sebesta_projekt_SQL_final AS 
WITH cbd_and_cttpm_21 AS (
	SELECT 
		cac.*,
		p3.MAX_gust_km_h
	FROM cbd_and_cttpm_21 cac 
	LEFT JOIN (
		SELECT
		`date`,
		country,
		MAX(max_gust_km_h) AS MAX_gust_km_h
	FROM pokus3 		
	WHERE country IS NOT NULL
	GROUP BY date, city 
	) AS p3
	ON cac.date = p3.date
		AND cac.country  = p3.country
)
SELECT 
	*
FROM cbd_and_cttpm_21
;

SELECT 
	*
FROM t_Filip_Sebesta_projekt_SQL_final
