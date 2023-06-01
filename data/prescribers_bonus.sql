--bonus 
--Q1
SELECT COUNT(prescriber.npi) - COUNT(prescription.npi)
FROM prescriber FULL JOIN prescription USING (npi)
--25050 - 20592 = 4458

SELECT DISTINCT(npi)
FROM prescription
--20592

--Q2 
--a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT prescriber.specialty_description, d.generic_name, p.total_claim_count
FROM drug as d
FULL JOIN prescription as p USING (drug_name)
FULL JOIN prescriber USING (npi)
WHERE prescriber.specialty_description = 'Family Practice' AND generic_name IS NOT NULL
GROUP BY prescriber.specialty_description, d.generic_name, p.total_claim_count
ORDER BY p.total_claim_count DESC
LIMIT 5;

SELECT generic_name
FROM drug

SELECT *
FROM prescriber

--Q2b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

SELECT prescriber.specialty_description, d.generic_name, p.total_claim_count
FROM drug as d
FULL JOIN prescription as p USING (drug_name)
FULL JOIN prescriber USING (npi)
WHERE prescriber.specialty_description = 'Cardiology' AND generic_name IS NOT NULL
GROUP BY prescriber.specialty_description, d.generic_name, p.total_claim_count
ORDER BY p.total_claim_count DESC
LIMIT 5;

--Q2c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? 
--Combine what you did for parts a and b into a single query to answer this question.
(SELECT prescriber.specialty_description, d.generic_name, p.total_claim_count
FROM drug as d
FULL JOIN prescription as p USING (drug_name)
FULL JOIN prescriber USING (npi)
WHERE prescriber.specialty_description = 'Family Practice' AND generic_name IS NOT NULL
GROUP BY prescriber.specialty_description, d.generic_name, p.total_claim_count
ORDER BY p.total_claim_count DESC
LIMIT 5) 
UNION
(SELECT prescriber.specialty_description, d.generic_name, p.total_claim_count
FROM drug as d
FULL JOIN prescription as p USING (drug_name)
FULL JOIN prescriber USING (npi)
WHERE prescriber.specialty_description = 'Cardiology' AND generic_name IS NOT NULL
GROUP BY prescriber.specialty_description, d.generic_name, p.total_claim_count
ORDER BY p.total_claim_count DESC
LIMIT 5);

--ALT ???
SELECT prescriber.specialty_description, d.generic_name, p.total_claim_count
FROM drug as d
FULL JOIN prescription as p USING (drug_name)
FULL JOIN prescriber USING (npi)
WHERE prescriber.specialty_description = 'Cardiology'
	AND prescriber.specialty_description = 'Family Practice'
	AND generic_name IS NOT NULL
GROUP BY prescriber.specialty_description, d.generic_name, p.total_claim_count
ORDER BY p.total_claim_count DESC
LIMIT 10;

--Q3a. Your goal in this question is to generate a list of the top prescribers in each of 
--the major metropolitan areas of Tennessee.
    --a. First, write a query that finds the top 5 prescribers in Nashville in terms of the 
	--total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, 
	--and include a column showing the city.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, prescriber.npi, nppes_provider_city, SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'NASHVILLE'
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, prescriber.npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

--Qb MEMPHIS
SELECT nppes_provider_first_name, nppes_provider_last_org_name, prescriber.npi, nppes_provider_city, SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'MEMPHIS'
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, prescriber.npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

SELECT nppes_provider_first_name, nppes_provider_last_org_name, nppes_provider_city, SUM(total_claim_count)
FROM prescriber
INNER JOIN prescription USING (npi)
WHERE nppes_provider_city = 'HENDERSONVILLE'
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC;

SELECT *
FROM population
INNER JOIN fips_county AS fc USING (fipscounty)
ORDER BY population DESC
--"47157"	937847	"SHELBY"	"TN"	"47"
"47037"	678322	"DAVIDSON"	"TN"	"47"
"47093"	452286	"KNOX"	"TN"	"47"

--Q4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.
SELECT AVG(overdose_deaths)
FROM overdose_deaths
--12.6

SELECT overdose_deaths, od.fipscounty, year
FROM overdose_deaths AS od
LEFT JOIN fips_county USING cast(fipscounty AS INTEGER) AS [zip_code]
GROUP BY overdose_deaths, od.fipscounty, year

SELECT *
FROM fips_county

SELECT *
FROM overdose_deaths

SELECT *
FROM population

