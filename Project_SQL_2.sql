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

-- Vytvoreni tabulky pomoci VIEW cttpm, kde se nachazi data country, date, confirmed, tests_performed --
SELECT 
	*
FROM covid19_tests_tests_performed_modified cttpm
WHERE country = 'Czechia'
;
-- Zalozeni
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

