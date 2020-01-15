-- E&M visits
(2414395,2414396,2414397,2414398,2414399)

-- Emergency Department Visit
9203, 8870, 32583

-- Inpatient Admission
8717, 9201

SELECT er.person_id, coalesce(er_encounters, 0) er_visits, coalesce(inpatient_admissions, 0) inpatient_admissions
FROM
(SELECT tbl.person_id, count(*) er_encounters
FROM visit_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON visit_occurrence.person_id = tbl.person_id
WHERE visit_concept_id IN (9203, 8870) AND
visit_start_date >= Convert(datetime, '2018-06-01' )
GROUP BY tbl.person_id) er
FULL OUTER JOIN (
SELECT tbl.person_id, count(*) inpatient_admissions
FROM visit_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON visit_occurrence.person_id = tbl.person_id
WHERE visit_concept_id IN (32583, 8717, 9201) AND
visit_start_date >= Convert(datetime, '2018-06-01')
GROUP BY tbl.person_id) inpatient
ON inpatient.person_id = er.person_id






SELECT person_id, 'ER_visit'
FROM visit_occurrence
WHERE visit_concept_id IN (32583, 8717, 9201)