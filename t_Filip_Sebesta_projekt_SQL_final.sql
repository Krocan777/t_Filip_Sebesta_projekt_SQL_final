-- Vytvoreni tabulky base_1 : Napojeni tests_performed a population na covid19_basic_differences 
CREATE TABLE base_1 AS 
WITH covid19_basic_differences AS (
	SELECT 
		cbd.`date`,
		cbd.country,
		cbd.confirmed,
		ct.tests_performed
	FROM (
			SELECT 
				CASE WHEN country = 'Czechia'
						THEN 'Czech Republic'
					WHEN country = 'Congo (Kinshasa)'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Korea, South'
						THEN 'South Korea'
					WHEN country = 'Taiwan*'
						THEN 'Taiwan'
					WHEN country = 'US'
						THEN 'United States'
					ELSE country
				END AS country,
				date,
				confirmed
			FROM covid19_basic_differences
			) AS cbd
	LEFT JOIN covid19_tests AS ct 
		ON cbd.country = ct.country 
		AND cbd.`date` = ct.`date` 
	ORDER BY cbd.`date`, cbd.country 
),
religions AS (
	SELECT 
		CASE WHEN country = 'The Democratic Republic of Congo'
				THEN 'Democratic Republic of Congo'
			WHEN country = 'Russian Federation'
				THEN 'Russia'
			ELSE country
		END AS country,
		SUM(population)	AS population 
	FROM religions
	WHERE `year` = 2020
	GROUP BY country
)
SELECT 
	cbd.*,
	r.population 
FROM covid19_basic_differences AS cbd
LEFT JOIN religions AS r
	ON cbd.country = r.country 
;

SELECT 
	*
FROM base_1
;

-- Vytvoreni tabulky base_2: Napojeni casovych promennych 
CREATE TABLE base_2 AS 
SELECT
	*,
	CASE WHEN WEEKDAY(`date`) BETWEEN 0 AND 4
		THEN 'Pracovni den'
		ELSE 'Vikend'
	END AS pracovni_den_vikend,
	CASE WHEN MONTH(`date`) BETWEEN 3 AND 5
			THEN 0
		 WHEN MONTH(`date`) BETWEEN 6 AND 8
			THEN 1
		 WHEN MONTH(`date`) BETWEEN 9 AND 11
			THEN 2
		 ELSE 3
	END AS rocni_obdobi
FROM base_1
;

SELECT 
	*
FROM base_2
;

-- Vytvoreni tabulky base_3: Napojeni sloupce hustota_zalidneni
CREATE TABLE base_3 AS
SELECT 
	b.*,
	ROUND(b.population / c.surface_area, 2) AS hustota_zalidneni
FROM base_2 AS b
LEFT JOIN (
			SELECT 
				surface_area,
				CASE WHEN country = 'Fiji Islands'
						THEN 'Fiji'
					WHEN country = 'Libyan Arab Jamahiriya'
						THEN 'Libya'
					WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country
			FROM countries c2 
			) AS c
	ON b.country = c.country 
;

SELECT 
	*
FROM base_3

-- Vytvoreni tabulky base_4: Napojeni sloupce HDP_na_obyvatele
CREATE TABLE base_4 AS 
SELECT 
	b.*,
	ROUND(e.GDP/ b.population, 2) AS HDP_na_obyvatele
FROM base_3 AS b
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'Russian Federation'
						THEN 'Russia'
					WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					ELSE country 
				END AS country,
				GDP,
				`year`
			FROM economies
			WHERE `year` = 2019
				OR `year` = 2020
			) AS e
	ON b.country = e.country
	AND YEAR(b.`date`) = e.`year` + 1 
;

SELECT  
	*
FROM base_4
;

-- Vytvoreni tabulky base_5: Napojeni gini koeficientu
CREATE TABLE base_5 AS 
SELECT 
	b.*,
	e.gini_koeficient
FROM base_4 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'Russian Federation'
						THEN 'Russia'
					WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					ELSE country
				END AS country,
				AVG(gini) AS gini_koeficient 
			FROM economies AS e
			GROUP BY e.country 
			) AS e 
	ON b.country = e.country
;

SELECT 
	*
FROM base_5
;

-- Vytvoreni tabulky base_6: Napojeni sloupce detska_umrtnost a median_veku_2018
CREATE TABLE base_6 AS
WITH base_5 AS (
SELECT 
	b.*,
	e.detska_umrtnost
FROM base_5 AS b 
LEFT JOIN (
			SELECT
				CASE WHEN country = 'Russian Federation'
						THEN 'Russia'
					WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					ELSE country
				END AS country,
				mortaliy_under5 AS detska_umrtnost
			FROM economies
			WHERE `year` = 2019
			) AS e 
	ON b.country = e.country
), 
counntries AS (
 	SELECT 
		median_age_2018	
	FROM countries
		)
SELECT 
	b.*,
	c.median_age_2018
FROM base_5 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'Fiji Islands'
						THEN 'Fiji'
					WHEN country = 'Libyan Arab Jamahiriya'
						THEN 'Libya'
					WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				median_age_2018
			FROM countries) AS c
	ON b.country = c.country 
;

SELECT 
	*
FROM base_6
WHERE country = 'Czech Republic'
;

-- Vytvoreni tabulky base_7: Napojeni sloupce podil_Christianity
CREATE TABLE base_7 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Christianity
FROM base_6 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Christianity'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country
;

-- Vytvoreni tabulky base_8: Napojeni sloupce podil_Islam
CREATE TABLE base_8 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Islam
FROM base_7 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Islam'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country
;

SELECT 
	*
FROM base_8
;

-- Vytvoreni tabulky base_9: Napojeni sloupce podil_Unaffiliated_Religions
CREATE TABLE base_9 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Unaffiliated_Religions
FROM base_8 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Unaffiliated Religions'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country

SELECT 
	*
FROM base_9

-- Vytvoreni tabulky base_10: Napojeni sloupce podil_Hinduism
CREATE TABLE base_10 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Hinduism
FROM base_9 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Hinduism'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country
	
SELECT 
	*
FROM base_10

-- Vytvoreni tabulky base_11: Napojeni sloupce podil_Buddhism
CREATE TABLE base_11 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Buddhism
FROM base_10 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Buddhism'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country
;
	
SELECT 
	*
FROM base_11
;

-- Vytvoreni tabulky base_12: Napojeni sloupce podil_Folk Religions
CREATE TABLE base_12 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Folk_Religions
FROM base_11 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Folk Religions'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country
;
	
SELECT 
	*
FROM base_12
;

-- Vytvoreni tabulky base_13: Napojeni sloupce podil_Other Religions
CREATE TABLE base_13 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Other_Religions
FROM base_12 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Other Religions'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country
;
	
SELECT 
	*
FROM base_13

-- Vytvoreni tabulky base_14: Napojeni sloupce podil_Judaism
CREATE TABLE base_14 AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Judaism
FROM base_13 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					WHEN country = 'Russian Federation'
						THEN 'Russia'
					ELSE country
				END AS country,
				religion,
				SUM(population) AS podil
			FROM religions r 
			WHERE `year` = 2020
				AND religion = 'Judaism'
			GROUP BY country, religion 
			) AS r
	ON b.country = r.country
;

SELECT 
	*
FROM base_14
;

-- Vytvoreni tabulky base_15: Napojeni sloupce diff_life_expectancy
CREATE TABLE base_15 AS 
SELECT 
	b.*,
	lf2.diff AS diff_life_expectancy
FROM base_14 AS b
LEFT JOIN (
			SELECT 
				life_expectancy - nasledujici_hodnota AS diff,
				CASE WHEN country = 'The Democratic Republic of Congo'
						THEN 'Democratic Republic of Congo'
					 WHEN country = 'Russian Federation'
					 	THEN 'Russia' 
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
	ON b.country = lf2.country 
ORDER BY country, date 
;

SELECT 
	*
FROM base_15
;

-- Vytvoreni pomocne tabulky weather_2
CREATE TABLE weather2 AS 
WITH weather AS (
	SELECT
		CAST(`date` AS date) AS `date`,
		cb.`time`,
		cb.city,
		CAST(`temp_°c` AS INT) AS temp_°c,
		ROUND(CAST(`rain_in_mm` AS FLOAT),2) AS `rain_in_mm`,
		CAST(`max_gust_km_h` AS INT) AS `max_gust_km_h`,
		c.country,
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
	LEFT JOIN (
				SELECT 
					CASE WHEN country = 'Fiji Islands'
							THEN 'Fiji'
						WHEN country = 'Libyan Arab Jamahiriya'
							THEN 'Libya'
						WHEN country = 'The Democratic Republic of Congo'
							THEN 'Democratic Republic of Congo'
						WHEN country = 'Russian Federation'
							THEN 'Russia'
						ELSE country
					END AS country,
					CASE WHEN capital_city = 'Athenai'
							THEN 'Athens'
						WHEN capital_city = 'Bruxelles [Brussel]'
							THEN 'Brussels'
						WHEN capital_city = 'Bucuresti'
						 	THEN 'Bucharest'
						WHEN capital_city = 'Helsinki [Helsingfors]'
						 	THEN 'Helsinki'
					  	WHEN capital_city = 'Kyiv'
							THEN 'Kiev'
						WHEN capital_city = 'Lisboa'
							THEN 'Lisbon'
						WHEN capital_city = 'Luxembourg [Luxemburg/L'
							THEN 'Luxembourg'
						WHEN capital_city = 'Praha'
							THEN 'Prague'
						WHEN capital_city = 'Roma'
							THEN 'Rome'
						 WHEN capital_city = 'Wien'
						 	THEN 'Vienna'
						 WHEN capital_city = 'Warszawa'
							THEN 'Warsaw'
					ELSE capital_city 
					END AS city
				FROM countries
				) AS c 
		ON cb.city = c.city 
		)
SELECT 
	*
FROM weather cb
;

SELECT 
	*
FROM weather2 w 

-- Vytvoreni tabulky base_16: Napojeni sloupce prum_den_tep
CREATE TABLE base_16 AS 
SELECT 
	b.*,
	w.prum_den_tep
FROM base_15 AS b
LEFT JOIN (
			SELECT 
				AVG(`temp_°c`) AS prum_den_tep,
				country,
				`date` 
			FROM weather2
			WHERE `time` IN ('06:00', '09:00', '12:00', '15:00', '18:00')
			GROUP BY country, `date` 
			) AS w 
	ON b.country = w.country
	AND b.`date` = w.date 
;

SELECT 
	*
FROM base_16

-- Vytvoreni tabulky base_17: Napojeni sloupce pocet_h_deste
CREATE TABLE base_17 AS 
SELECT 
	b.*,
	w.pocet_h_deste
FROM base_16 AS b 
LEFT JOIN (
			SELECT 
				CASE WHEN SUM(pocet_hodin_deste) > 24 
						THEN SUM(pocet_hodin_deste) / 2
					ELSE SUM(pocet_hodin_deste)
				END AS pocet_h_deste,
				country,
				`date` 
			FROM weather2
			GROUP BY country, `date` 
			) AS w 
	ON b.country = w.country
	AND b.`date` = w.date 
;

SELECT 
	*
FROM base_17

-- Vytvoreni tabulky base_18: Napojeni sloupce max_gust
CREATE TABLE t_Filip_Sebesta_projekt_SQL_final
SELECT 
	b.*, 
	w.max_gust
FROM base_17 AS b
LEFT JOIN (
			SELECT 
				MAX(max_gust_km_h) AS max_gust,
				country,
				`date` 
			FROM weather2
			GROUP BY country, date 
			) AS w 
	ON b.country = w.country
	AND b.`date` = w.date 
;

SELECT 
	*
FROM t_filip_sebesta_projekt_sql_final


