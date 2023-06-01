--Q1 a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and 
--the total number of claims.
    
--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  
--specialty_description, and the total number of claims.

SELECT prescriber.npi, prescription.total_claim_count
FROM prescriber
	LEFT JOIN prescription 
	USING (NPI)
GROUP BY prescriber.npi, prescription.total_claim_count 
ORDER BY prescription.total_claim_count DESC NULLS LAST;
--1912011792	4538

SELECT prescriber.nppes_provider_first_name, 
	prescriber.nppes_provider_last_org_name, 
	prescriber.npi, 
	prescriber.specialty_description,
SUM(prescription.total_claim_count) AS claim_count
FROM prescriber INNER JOIN prescription USING (NPI)
GROUP BY prescriber.nppes_provider_first_name, 
	prescriber.nppes_provider_last_org_name, 
	prescriber.npi, 
	prescriber.specialty_description
ORDER BY claim_count DESC NULLS LAST;
--Bruce Pendley

SELECT prescriber.npi, 
	nppes_provider_first_name, 
	nppes_provider_last_org_name,
	specialty_description,
	SUM(total_claim_count) AS claim_count
FROM prescriber INNER JOIN prescription USING (npi)
GROUP BY prescriber.npi, 
	nppes_provider_first_name, 
	nppes_provider_last_org_name,
	specialty_description
ORDER BY claim_count DESC
LIMIT 10;

SELECT npi, prescription.total_claim_count 
FROM prescriber
	LEFT JOIN prescription USING (NPI)
WHERE prescriber.npi = 1003000282
GROUP BY prescriber.npi, prescription.total_claim_count
ORDER BY prescription.total_claim_count DESC NULLS LAST;

prescriber.nppes_provider_last_org_name
SELECT *
FROM prescription

--Q2
 --a. Which specialty had the most total number of claims (totaled over all drugs)?

   -- b. Which specialty had the most total number of claims for opioids?

   -- c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated 
	--prescriptions in the prescription table?

   -- d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the 
	--percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of 
	--opioids?
--2a
SELECT DISTINCT(prescriber.specialty_description), SUM(prescription.total_claim_count) AS claim_count
FROM prescriber
	LEFT JOIN prescription USING (NPI)
GROUP BY prescriber.specialty_description
ORDER BY claim_count DESC NULLS LAST;
--family practice


--2b 
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims
FROM prescription
	FULL JOIN prescriber USING (NPI)
	FULL JOIN drug USING (drug_name)
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC NULLS LAST;
--nurse practitioner

--SELECT drug_name, total_claim_count
FROM prescription
ORDER BY total_claim_count DESC NULLS LAST;

--SELECT drug_name, total_claim_count
FROM prescription
	FULL JOIN prescriber USING (npi)
ORDER BY total_claim_count DESC NULLS LAST;

--2c ?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
	FULL JOIN prescription USING (NPI)
	FULL JOIN drug USING (drug_name)
GROUP BY prescriber.specialty_description, prescription.total_claim_count 
ORDER BY total_claims DESC;
--NO

--Q3a. Which drug (generic_name) had the highest total drug cost?

    --b. Which drug (generic_name) has the hightest total cost per day? 
	--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, SUM(total_drug_cost)::money AS total_drug_cost 
FROM prescription
	FULL JOIN drug USING (drug_name)
GROUP BY drug.generic_name
ORDER BY total_drug_cost DESC NULLS LAST;
--INSULIN

--alt logic
SELECT prescription.drug_name, drug.generic_name, SUM(prescription.total_drug_cost)::money AS total_cost 
FROM prescription
	FULL JOIN drug USING (drug_name)
GROUP BY prescription.drug_name, drug.generic_name
ORDER BY total_cost DESC NULLS LAST;
--Lyrica

SELECT DISTINCT prescription.drug_name, drug.generic_name, SUM(prescription.total_drug_cost) 
FROM prescription
	FULL JOIN drug USING (drug_name)
GROUP BY prescription.drug_name, drug.generic_name
ORDER BY SUM(prescription.total_drug_cost) DESC NULLS LAST;


--b. Which drug (generic_name) has the hightest total cost per day? 
	**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
	
SELECT generic_name, SUM(total_drug_cost/prescription.total_day_supply)::money AS cost_per_day
FROM prescription
	FULL JOIN drug USING (drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC NULLS LAST;
--"LEDIPASVIR/SOFOSBUVIR"

--??
SELECT drug.generic_name, (SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply))::money AS cost_per_day
FROM prescription
	FULL JOIN drug USING (drug_name)
GROUP BY drug.generic_name
ORDER BY cost_per_day DESC NULLS LAST;

--Q4
SELECT generic_name
FROM drug

 --a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 
 --'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have 
 --antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT prescription.drug_name, drug.generic_name, drug.opioid_drug_flag AS opioids, drug.antibiotic_drug_flag AS antibiotics
FROM prescription
	FULL JOIN drug USING (drug_name)
GROUP BY prescription.drug_name, drug.generic_name, opioids, antibiotics
ORDER BY prescription.drug_name, drug.generic_name DESC NULLS LAST;

SELECT DISTINCT prescription.drug_name, drug.generic_name, prescription.total_drug_cost AS MONEY,
	CASE WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic' ELSE 'neither' END AS drug_type
FROM prescription
	FULL JOIN drug USING (drug_name)
ORDER BY MONEY DESC NULLS LAST;

--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on 
	--opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT DISTINCT SUM(prescription.total_drug_cost)::money AS MONEY,
	CASE WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic' 
	WHEN drug.opioid_drug_flag <>'Y' AND drug.antibiotic_drug_flag <> 'Y' THEN 'neither' END AS drug_type
FROM prescription
	INNER JOIN drug USING (drug_name)
GROUP BY drug_type, drug.antibiotic_drug_flag, drug.opioid_drug_flag
ORDER BY MONEY DESC NULLS LAST;


--5a How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
   
SELECT *
FROM cbsa

SELECT COUNT(DISTINCT cbsa)
FROM cbsa AS c
INNER JOIN fips_county AS f USING (fipscounty)
WHERE f.state = 'TN';
--10

SELECT COUNT(cbsaname)
FROM cbsa
WHERE cbsaname ILIKE '%TN%';
--58

--5 b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT c.cbsaname, SUM(p.population) AS total_pop
FROM cbsa AS c
JOIN population AS p USING (fipscounty)
GROUP BY c.cbsaname
ORDER BY total_pop DESC NULLS LAST;
--"Nashville-Davidson--Murfreesboro--Franklin, TN"

--chase, darina
SELECT SUM(p.population), c.cbsaname
FROM cbsa AS c
INNER JOIN population AS p
USING( fipscounty)
GROUP BY  c.cbsaname 
ORDER BY SUM(p.population) DESC;

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county 
--name and population.

SELECT *
FROM fips_county as fc LEFT JOIN population as p USING (fipscounty)
LEFT JOIN cbsa USING (fipscounty)
WHERE state = 'TN' AND cbsa IS NULL
ORDER BY p.population DESC;
--SEVIER
--PICKETT

--SELECT f.county, p.population
FROM fips_county AS f
JOIN population AS p USING (fipscounty)
GROUP BY f.county, p.population
ORDER BY p.population DESC;
--"SHELBY"	937847

--patrick 
SELECT * 
FROM fips_county as fc
LEFT JOIN population AS p ON fc.fipscounty = p.fipscounty
LEFT JOIN cbsa as c ON fc.fipscounty = c.fipscounty
WHERE state = 'TN' AND cbsa IS NULL
ORDER BY population DESC
NULLS LAST;



--6. 
   -- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

    --b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

    --c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

--6a
SELECT DISTINCT(npi)
FROM prescription

SELECT drug_name, SUM(total_claim_count) as total_claims
FROM prescription
WHERE total_claim_count > 3000
GROUP BY drug_name, total_claim_count
ORDER BY total_claims DESC;
--"OXYCODONE HCL"	4538

--6b & c
SELECT nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count, 
	(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid' 
	WHEN opioid_drug_flag = 'N' THEN 'not opioid' END) AS drug_type
FROM drug
LEFT JOIN prescription USING (drug_name)
FULL JOIN prescriber USING (npi)
WHERE prescription.total_claim_count >= 3000
ORDER BY prescription.total_claim_count DESC;
--

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of 
--claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--a. First, create a list of all npi/drug_name combinations for pain management specialists 
	--(specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug 
	--is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use 
	--the prescriber and drug tables since you don't need the claims numbers yet.

   -- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the 
	--prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    
--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. 
	--Hint - Google the COALESCE function.

SELECT *
FROM prescriber

--7a
SELECT npi, drug_name, specialty_description 
FROM prescriber CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	  AND nppes_provider_city = 'NASHVILLE'
	  AND opioid_drug_flag = 'Y'
GROUP BY npi, drug_name, specialty_description
ORDER BY npi;



--7b  -- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the 
	--prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT npi, drug.drug_name, SUM(total_claim_count) AS claim_count
FROM prescriber CROSS JOIN drug
FULL JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management'
	  AND nppes_provider_city = 'NASHVILLE'
	  AND opioid_drug_flag = 'Y'
GROUP BY npi, drug.drug_name
ORDER BY claim_count DESC NULLS LAST;


SELECT npi, drug.drug_name, SUM(total_claim_count)
FROM prescriber CROSS JOIN drug
FULL JOIN prescription USING (npi)
WHERE specialty_description = 'Pain Management'
	  AND nppes_provider_city = 'NASHVILLE'
	  AND opioid_drug_flag = 'Y'
GROUP BY npi, drug.drug_name, total_claim_count
ORDER BY npi;

--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. 
	--Hint - Google the COALESCE function.
	
SELECT npi, drug.drug_name, COALESCE(SUM(total_claim_count),0) AS claim_count
FROM prescriber CROSS JOIN drug
FULL JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management'
	  AND nppes_provider_city = 'NASHVILLE'
	  AND opioid_drug_flag = 'Y'
GROUP BY npi, drug.drug_name
ORDER BY claim_count DESC;

