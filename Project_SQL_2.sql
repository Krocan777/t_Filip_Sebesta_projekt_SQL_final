-- Vytvoreni tabulky cbd_and_ct > jedna tabulka, kde je pocet nakazenych a pocet provedenych testu --
CREATE TABLE cbd_and_ct AS (
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
)
;

SELECT 
	*
FROM cbd_and_ct cac 
;