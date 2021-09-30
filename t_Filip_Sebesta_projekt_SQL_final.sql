-- Vytvoreni tabulky base_table : Napojeni tests_performed a population na covid19_basic_differences 
CREATE TABLE base_table AS 
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
FROM base_table
;

-- Vytvoreni tabulky base_cas_prom: Napojeni casovych promennych 
CREATE TABLE base_cas_prom AS 
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
FROM base_table
;

SELECT 
	*
FROM base_cas_prom
;

-- Vytvoreni tabulky base_hustota_zalidneni: Napojeni sloupce hustota_zalidneni
CREATE TABLE base_hustota_zalidneni AS
SELECT 
	b.*,
	ROUND(b.population / c.surface_area, 2) AS hustota_zalidneni
FROM base_cas_prom AS b
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
FROM base_hustota_zalidneni

-- Vytvoreni tabulky base_HDP_na_obyvatele: Napojeni sloupce HDP_na_obyvatele
CREATE TABLE base_hdp_na_obyvatele AS 
SELECT 
	b.*,
	ROUND(e.GDP/ b.population, 2) AS HDP_na_obyvatele
FROM base_hustota_zalidneni AS b
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
FROM base_hdp_na_obyvatele
;

-- Vytvoreni tabulky base_gini_koef: Napojeni gini koeficientu
CREATE TABLE base_gini_koef AS 
SELECT 
	b.*,
	e.gini_koeficient
FROM base_hdp_na_obyvatele AS b 
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
FROM base_gini_koef
;

-- Vytvoreni tabulky base_detska_umrtnost_and_median_veku: Napojeni sloupce detska_umrtnost a median_veku_2018
CREATE TABLE base_detska_umrtnost_and_median_veku AS
WITH base_gini_koef AS (
SELECT 
	b.*,
	e.detska_umrtnost
FROM base_gini_koef AS b 
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
FROM base_gini_koef AS b 
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
FROM base_detska_umrtnost_and_median_veku
WHERE country = 'Czech Republic'
;

-- Vytvoreni tabulky base_podil_Christianity: Napojeni sloupce podil_Christianity
CREATE TABLE base_podil_christianity AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Christianity
FROM base_detska_umrtnost_and_median_veku AS b 
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

-- Vytvoreni tabulky base_podil_Islam: Napojeni sloupce podil_Islam
CREATE TABLE base_podil_islam AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Islam
FROM base_podil_christianity AS b 
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
FROM base_podil_islam 
;

-- Vytvoreni tabulky base_podil_Unaffiliated_Religions: Napojeni sloupce podil_Unaffiliated_Religions
CREATE TABLE base_podil_unaffiliated_religions AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Unaffiliated_Religions
FROM base_podil_islam AS b 
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
FROM base_podil_unaffiliated_religions

-- Vytvoreni tabulky base_podil_hinduism: Napojeni sloupce podil_Hinduism
CREATE TABLE base_podil_hinduism AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Hinduism
FROM base_podil_unaffiliated_religions AS b 
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
FROM base_podil_hinduism

-- Vytvoreni tabulky base_podil_Buddhism: Napojeni sloupce podil_Buddhism
CREATE TABLE base_podil_buddhism AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Buddhism
FROM base_podil_hinduism AS b 
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
FROM base_podil_buddhism
;

-- Vytvoreni tabulky base_podil_Folk_Religions: Napojeni sloupce podil_Folk Religions
CREATE TABLE base_podil_folk_religions AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Folk_Religions
FROM base_podil_buddhism AS b 
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
FROM base_podil_folk_religions
;

-- Vytvoreni tabulky base_podil_Other_religions: Napojeni sloupce podil_Other Religions
CREATE TABLE base_podil_other_religions AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Other_Religions
FROM base_podil_folk_religions AS b 
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
FROM base_podil_other_religions

-- Vytvoreni tabulky base_podil_Judaism: Napojeni sloupce podil_Judaism
CREATE TABLE base_podil_judaism AS 
SELECT 
	b.*,
	ROUND(r.podil / b.population, 4) AS podil_Judaism
FROM base_podil_other_religions AS b 
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
FROM base_podil_judaism
;

-- Vytvoreni tabulky base_diff_life_expectancy: Napojeni sloupce diff_life_expectancy
CREATE TABLE base_diff_life_expectancy AS 
SELECT 
	b.*,
	lf2.diff AS diff_life_expectancy
FROM base_podil_judaism AS b
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
FROM base_diff_life_expectancy
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

-- Vytvoreni tabulky base_prum_den_tep: Napojeni sloupce prum_den_tep
CREATE TABLE base_prum_den_tep AS 
SELECT 
	b.*,
	w.prum_den_tep
FROM base_diff_life_expectancy AS b
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
FROM base_prum_den_tep

-- Vytvoreni tabulky base_pocet_h_deste: Napojeni sloupce pocet_h_deste
CREATE TABLE base_pocet_h_deste AS 
SELECT 
	b.*,
	w.pocet_h_deste
FROM base_prum_den_tep AS b 
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
FROM base_pocet_h_deste

-- Vytvoreni tabulky t_Filip_Sebesta_projekt_SQL_final: Napojeni sloupce max_gust
CREATE TABLE t_Filip_Sebesta_projekt_SQL_final
SELECT 
	b.*, 
	w.max_gust
FROM base_pocet_h_deste AS b
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
;




