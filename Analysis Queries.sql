-- VOLUME ANALYSIS / SERVICE UTILISATION (2017 - 2019) 

-- Total encounters by year from 2017 - 2019
SELECT year(START) AS encounter_year, COUNT(*) AS encounter_count
FROM encounters
WHERE START>='2017-01-01' AND START<'2020-01-01'
GROUP BY year(START)
ORDER BY encounter_year; -- There was a decrease in total encounters from 2017 (3153) to 2019 (2919)

-- Distinct Patients by Year
SELECT year(START) AS encounter_year, COUNT(DISTINCT PATIENT) AS distinct_patients
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01'
GROUP BY year(START)
ORDER BY encounter_year; -- Similar number of patients across the 3 years

-- Encounters per Patient (Utilisation Intensity)
SELECT 
year(START) AS encounter_year, 
COUNT(*) AS total_encounters, 
COUNT(DISTINCT PATIENT) AS distinct_patients, 
ROUND(COUNT(*) / COUNT(DISTINCT Patient), 2) AS encounters_per_patient
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01'
GROUP BY year(START)
ORDER BY encounter_year; -- Encounters per patient declined each year, showing that patients are using services less frequently even though the size of the patient population remained stable.

-- Service Mix
SELECT year(START) AS encounter_year, EncounterClass, COUNT(*) AS encounters
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01'
GROUP BY year(START), EncounterClass
ORDER BY encounter_year, encounters DESC; -- to get a more compressed veiw of the changes happening, I've grouped the encounterclasses in the next query

-- Grouped Version of Encounterclasses 
SELECT year(START) AS encounter_year,
SUM(CASE WHEN EncounterClass IN ('inpatient', 'emergency') THEN 1 ELSE 0 END) AS 'Acute Care',
SUM(CASE WHEN EncounterClass IN ('wellness', 'urgentcare') THEN 1 ELSE 0 END) AS 'Preventative / Community',
SUM(CASE WHEN EncounterClass IN ('ambulatory', 'outpatient') THEN 1 ELSE 0 END) AS 'Scheduled Care',
COUNT(*) AS 'Total'
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01'
GROUP BY year(START)
ORDER BY encounter_year; /* The service mix shows stable preventative/community care and declining scheduled care, 
while acute care remains the smallest but most resource‑intensive category.*/

-- Service Mix Percentage
SELECT 
    YEAR(START) AS encounter_year,
    ROUND(100 * SUM(CASE WHEN EncounterClass IN ('inpatient','emergency') THEN 1 ELSE 0 END) / COUNT(*), 2) AS acute_pct,
    ROUND(100 * SUM(CASE WHEN EncounterClass IN ('wellness','urgentcare') THEN 1 ELSE 0 END) / COUNT(*), 2) AS preventative_pct,
    ROUND(100 * SUM(CASE WHEN EncounterClass IN ('ambulatory','outpatient') THEN 1 ELSE 0 END) / COUNT(*), 2) AS scheduled_pct
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01'
GROUP BY YEAR(START)
ORDER BY encounter_year; /* Acute care remained a small, stable share of total encounters,
 while preventative/community care grew and scheduled care declined, indicating a gradual shift away from planned
outpatient activity toward more community‑based services.*/

-- Year-over-Year Change %
SELECT encounter_year, total_encounters, 
ROUND(100 * (total_encounters - LAG(total_encounters) OVER (ORDER BY encounter_year))
/ LAG(total_encounters) OVER (ORDER BY encounter_year),2) AS yoy_change_pct
FROM (SELECT year(START) AS encounter_year, COUNT(*) AS total_encounters
FROM encounters
WHERE START>='2017-01-01' AND START<'2020-01-01'
GROUP BY year(START) ) AS t; /* Year-over-year encounter volume declined in both 2018 and 2019, with the drop accelerating over time.*/



-- FINANCIAL ANALYSIS (2017 - 2019)

-- Total Claim Cost by Year
SELECT year(START) as encounter_year, ROUND(SUM(TOTAL_CLAIM_COST),2) AS total_claim_cost
FROM encounters
WHERE START>='2017-01-01' AND START<'2020-01-01'
GROUP BY year(START)
ORDER BY encounter_year; -- Total claim costs decreased each year from 2017 to 2019, suggesting cost decline is proportional to activity decline.
 
-- Average Cost per Encounter
SELECT year(START) AS encounter_year, ROUND(AVG(Total_Claim_Cost), 2) AS avg_cost_per_encounter
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01'
GROUP BY year(START)
ORDER BY encounter_year; -- Remained almost unchanged across the timeline 

-- Total Cost by Care Group (2017–2019 Combined)
SELECT
CASE
WHEN EncounterClass IN ('inpatient','emergency') THEN 'Acute Care'
WHEN EncounterClass IN ('ambulatory','outpatient') THEN 'Scheduled Care'
WHEN EncounterClass IN ('wellness','urgentcare') THEN 'Preventative / Community'
END AS care_group,
COUNT(*) AS encounters, ROUND(SUM(Total_Claim_Cost), 2) AS total_cost, ROUND(AVG(Total_Claim_Cost), 2) AS avg_cost_per_encounter
FROM encounters
WHERE START >= '2017-01-01' AND START <  '2020-01-01'
GROUP BY care_group
ORDER BY total_cost DESC; -- Scheduled care and preventative/community care account for the majority of total costs due to their high encounter volumes

-- Cost per Care Group by Year
SELECT
    YEAR(start) AS encounter_year,
    CASE 
        WHEN EncounterClass IN ('inpatient','emergency') THEN 'Acute Care'
        WHEN EncounterClass IN ('wellness','urgentcare') THEN 'Preventative / Community'
        WHEN EncounterClass IN ('ambulatory','outpatient') THEN 'Scheduled Care'
    END AS care_group,
    COUNT(*) AS encounters,
    ROUND(SUM(TOTAL_CLAIM_COST), 2) AS total_cost,
    ROUND(AVG(TOTAL_CLAIM_COST), 2) AS avg_cost_per_encounter
FROM encounters
WHERE start >= '2017-01-01' AND start < '2020-01-01'
GROUP BY encounter_year, care_group
ORDER BY encounter_year, care_group; /* Average cost per encounter stayed stable across all care groups from 2017–2019,
showing that spending shifts were driven by changes in encounter volume rather than rising costs within any specific service type.*/


-- EMERGENCY ANALYSIS (2017 - 2019)

-- Emergency volume trend (2017–2019)
SELECT year(START) AS encounter_year, 
ROUND( 100 * SUM(CASE WHEN EncounterClass = 'emergency' THEN 1 ELSE 0 END) / COUNT(*),2) AS emergency_pct_of_total
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01'
GROUP BY year(START)
ORDER BY encounter_year; /* Emergency encounters remained a small and stable share of total activity,
with only minor year‑to‑year fluctuations, indicating no significant shift in acute emergency demand.*/

-- Emergency utilisation intensity (ED encounters per ED patient)
SELECT year(START) AS encounter_year,
COUNT(*) AS emergency_encounters,
COUNT(DISTINCT Patient) AS distinct_ed_patients,
ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT Patient), 0), 2) AS ed_encounters_per_patient
FROM encounters
WHERE START >= '2017-01-01' AND START < '2020-01-01' AND EncounterClass = 'emergency'
GROUP BY year(START)
ORDER BY encounter_year; /* ED utilisation intensity stayed low and stable from 2017–2019,
showing that most patients used the emergency department only once per year,
with very few repeat visit patients driving demand.*/

-- Emergency cost trend (total + average)
SELECT year(START) AS encounter_year,
ROUND(SUM(Total_Claim_Cost), 2) AS total_emergency_cost,
ROUND(AVG(Total_Claim_Cost), 2) AS avg_emergency_cost
FROM encounters
WHERE START >= '2017-01-01' AND `Start` < '2020-01-01' AND EncounterClass = 'emergency'
GROUP BY year(START)
ORDER BY encounter_year; /* Total emergency spending dropped sharply after 2017 while the average cost per ED encounter stayed flat,
showing that reduced emergency activity drove the change in overall ED expenditure*/


-- Hypertension Management Analysis

-- Total Patients with Any BP Recorded
SELECT COUNT(DISTINCT PATIENT) AS patients_with_bp_recorded
FROM observations
WHERE DATE >= '2017-01-01' AND DATE <  '2020-01-01'
  AND DESCRIPTION IN ('Systolic Blood Pressure', 'Diastolic Blood Pressure');
/* Blood pressure was recorded for 346 patients between 2017–2019, 
providing a solid clinical base for assessing hypertension control across the population.*/

-- Count Patients with Any Uncontrolled BP (2017–2019)
SELECT COUNT(DISTINCT PATIENT) AS patients_with_uncontrolled_bp
FROM observations
WHERE DATE >= '2017-01-01' AND DATE <  '2020-01-01'
  AND ((DESCRIPTION = 'Systolic Blood Pressure' AND Value >= 140)
     OR (DESCRIPTION = 'Diastolic Blood Pressure' AND Value >= 90)
      ); /* Only a small subset of patients (20 in total) had any episode of uncontrolled blood pressure across the three-year period,
indicating that uncontrolled hypertension was relatively uncommon in this population.*/






