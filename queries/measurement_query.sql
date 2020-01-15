SELECT measurement.person_id, measurement_date, measurement_source_value, value_source_value
      FROM measurement
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = measurement.person_id
WHERE measurement_date >= Convert(datetime, '2018-06-01' ) AND
      measurement_concept_id in (3010747,3039421)

-- Viral load suppression MEASUREMENT
(3010747,3039421,3031527,3031839,3026532,3000685,3014347,3010074)
-- CD4+ cell count - MEASUREMENT
(37039820)

SELECT concept_name, count(*)
FROM measurement
JOIN concept
ON measurement.measurement_concept_id = concept.concept_id
GROUP BY concept_name
HAVING count(*) > 10000



SELECT measurement.person_id, measurement_date, value_as_number
FROM measurement
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON measurement.person_id = tbl.person_id
WHERE measurement.measurement_concept_id IN
(SELECT concept_id
FROM concept
WHERE concept_name LIKE 'CD4' AND
domain_id = 'Measurement')

SELECT concept_id, concept_name
FROM concept
WHERE concept_name LIKE 'CD4' AND
domain_id = 'Measurement'