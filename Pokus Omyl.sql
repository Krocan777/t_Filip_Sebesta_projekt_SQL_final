
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
;

SELECT DISTINCT 
	cac6.*,
	ehno.HDP_na_obyvatele
FROM cbd_and_cttpm_6 AS cac6
LEFT JOIN economies_hdp_na_obyvatele AS ehno 
	ON cac6.country = ehno.country 
	AND YEAR(cac6.`date`) = ehno.`year` -1
ORDER BY date 
;

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
FROM economies_hdp_na_obyvatele ehno 
;

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

SELECT DISTINCT 
	country,
	gini 
FROM economies e 
;

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
	country,
	AVG(gini)
FROM economies e 
GROUP BY country
;

SELECT 
	*
FROM covid19_basic_differences cbd
WHERE country = 'czechia'
;

SELECT 
	*
FROM covid19_tests ct 
WHERE country = 'Czech Republic'
;

SELECT 
	*
FROM life_expectancy le
;

SELECT 
	country,
	mortaliy_under5 
FROM economies e 
WHERE `year` = 2019
;

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
	country,
	median_age_2018
FROM countries c
WHERE country = 'United States'
;

SELECT 
	*
FROM religions r 
;

SELECT 
	cac10.country,
	cac10.population,
	cac10.date,
	r.Christianity
FROM cbd_and_cttpm_10 AS cac10
LEFT JOIN (
			SELECT 
				cac10.country,
				CASE WHEN r.religion = 'Christianity'
					THEN r.population / cac10.population * 100 
				END AS Christianity
			FROM cbd_and_cttpm_10 AS cac10
			LEFT JOIN religions AS r 
				ON cac10.country = r.country 
				AND r.region = 'Christianity' 
			) AS r
	ON cac10.country = r.country	
;
 
SELECT 
	cac10.country,
	cac10.population,
	cac10.date,
	r.podil
FROM cbd_and_cttpm_10 AS cac10
LEFT JOIN (
			SELECT 
				religion / population * 10 AS podil,
				country
			FROM religions
			WHERE religion = 'Christianity'
			) AS r
	ON cac10.country = r.country 
;

SELECT 
	*
FROM religions r
WHERE `year` = 2020
ORDER BY `year` DESC 
;

SELECT 
	*
FROM religions r 
WHERE `year` = 2020
;

SELECT 
	cac10.country,
	cac10.population,
	cac10.date,
	r.religion / cac10.population * 100 AS podil
FROM cbd_and_cttpm_10 AS cac10, religions AS r 
WHERE r.religion = 'Islam'
	AND r.`year` = 2020
	AND cac10.country = r.country 
;

SELECT DISTINCT 
	COUNT(country),
	religion 
FROM religions r 
WHERE `year` = 2020
GROUP BY religion 
;

SELECT 
	*
FROM religions r 

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
FROM religions r
WHERE country = 'Czech Republic'
	AND `year` = 2020
;

SELECT 
	*
FROM cbd_and_cttpm_10 cac 
WHERE country = 'Czechia'
;

SELECT 
	cac10.*,
	pc.`r.population / cac10.population * 100` AS podil_Christianity
FROM cbd_and_cttpm_10 AS cac10
LEFT JOIN podil_christianity AS pc 
	ON cac10.country = pc.country
;

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
	country,
	`year`,
	life_expectancy,
	LAG(life_expectancy) OVER(ORDER BY country DESC) AS nasledujici_hodnota
FROM life_expectancy le 
WHERE `year` = 1965
	OR `year` = 2015
ORDER BY country 
;

SELECT 
	*
FROM countries c2 
;

SELECT DISTINCT 
	city 
FROM weather w 
WHERE city IS NOT NULL
;
SELECT DISTINCT 
	`year` 
FROM religions r2 
;

SELECT 	
	SUM(population),
	country 
FROM religions r 
WHERE `year` = 2020
GROUP BY country
;

SELECT 
	*
FROM religions r 
;

SELECT 
	country,
	population / SUM(population)
FROM religions r 
WHERE `year` = 2020
	AND religion = 'Islam'
GROUP BY country 
;

SELECT DISTINCT 
	country,
	population,
	population_density,
	podil_Islam,
	podil_Buddhism,
	podil_Hinduism,
	podil_Folk_Religions,
	podil_Unaffiliated_Religions,
	podil_Judaism,
	podil_Other_Religions
FROM cbd_and_cttpm_20
;

SELECT 
	*
FROM weather w 
;

-- cisteni dat, pozor na mezery
CREATE TABLE weather_3 AS 
SELECT 
	CAST(`date` AS date) AS `date`,
	REPLACE(temp, ' °c', '') AS temp_°c,
	REPLACE(rain, ' mm', '') AS rain_in_mm,
	REPLACE (gust, ' km/h', '') AS max_gust_km_h
FROM weather w 
;
SELECT 
	*
FROM weather_3 w 
;
DROP TABLE weather_3 
;
SELECT 
	avg(temp),
	city,
	date
-- 	CAST(temp AS INT) AS temp
FROM weather w 
GROUP BY date, city 
;

-- CREATE TABLE pokus AS 
SELECT 
	CAST(`temp_°c` AS INT) AS temp_°c,
	ROUND(CAST(`rain_in_mm` AS FLOAT),2) AS `rain_in_mm`,
	CAST(`max_gust_km_h` AS INT) AS `max_gust_km_h`,
	date 
FROM weather_3
ORDER BY date
;

-- pouziti with a vnoreny select do jednoho dotazu
CREATE TABLE pokus3 AS 
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

DROP TABLE pokus3
;
SELECT 
	*
FROM pokus3
;

SELECT 
	*
FROM cbd_and_cttpm_20 cac 

;
SELECT 
	*
FROM weather w 
;

DROP TABLE pokus3
;
SELECT 
	avg(temp_°c) 
FROM pokus3
; 

SELECT 
	sum(pokus) 
FROM pokus
;



--  srazky 2
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

SELECT 
	*
FROM hodiny_sum hs 
-- max sila vetru behem dne

SELECT 
	*,
	MAX(max_gust_km_h)
FROM weather_3 w
GROUP BY date, city 
;


	