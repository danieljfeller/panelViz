SELECT condition_occurrence.person_id, 'psychosis' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (436073,4133495,4335169,436952,37117049,442582,435783,432597,433450,
                               436067,440373,435782,432598,436944)
UNION
SELECT condition_occurrence.person_id, 'diabetes' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01') AND
      condition_concept_id in (201820, 201826,40482801,201254,195771)
UNION
SELECT condition_occurrence.person_id, 'hcv' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (197494,198964,192242)
UNION
SELECT condition_occurrence.person_id, 'obesity' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (4215968)
UNION
SELECT condition_occurrence.person_id, 'hypertension' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (42538697, 4028741, 4167358, 320128, 4179379)
UNION
SELECT condition_occurrence.person_id, 'drug abuse' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (436954,4175635,439312,4145220,436097,440694,439313,434917,434627,4103426,43530681)
UNION
SELECT condition_occurrence.person_id, 'alcoholism' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (433753,4152165,435534,441276,440685,4218106,436953,433735,439005,435532,437257,441261,432609)
UNION
SELECT condition_occurrence.person_id, 'depression' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (500002701,4098302,4282316,35624743,4149321,42872722,439254,4282096,441534,4327337,374326,37111697,438406,4250023)
UNION
SELECT condition_occurrence.person_id, 'anxiety' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (441542,442077,434613,4113821,381537,433178)
UNION
SELECT condition_occurrence.person_id, 'drug abuse' dx
FROM condition_occurrence
JOIN (SELECT person_id
      FROM condition_occurrence
      WHERE condition_concept_id in (4241530,432554,439727)
      GROUP BY person_id
      HAVING count(*) >2) tbl
ON tbl.person_id = condition_occurrence.person_id
WHERE condition_start_date >= Convert(datetime, '2018-01-01' ) AND
      condition_concept_id in (436954, 4001994, 4275756, 4145220,
                              436954,4175635,439312,4145220,436097,
                               440694,439313,434917,434627,4103426,43530681)


-- new HIV diagnosis
SELECT person_id
FROM condition_occurrence
WHERE condition_concept_id in (4241530,432554,439727)
GROUP BY person_id
HAVING count(*) >2 AND person_id NOT IN (
SELECT person_id
FROM condition_occurrence
WHERE condition_concept_id in (4241530,432554,439727) AND
condition_start_date < Convert(datetime, '2018-06-01'))



-- CONDITIONS
-- Active chronic hepatitis C - CONDITION
(197494,198964,192242)
-- obesity
(4215968)
-- Hypertension
(4289933,317898)
-- Drug abuse
(436954,4175635,439312,4145220,436097,440694,439313,434917,434627,4103426,43530681)
-- Alcohol abuse
(433753,4152165,435534,441276,440685,4218106,436953,433735,439005,435532,437257,441261,432609)
-- Depression
(500002701,4098302,4282316,35624743,4149321,42872722,439254,4282096,441534,4327337,374326,37111697,438406,4250023)
-- Anxiety
(441542,442077,434613,4113821,381537,433178)
-- Psychotic disorder
(436073,4133495,4335169,436952,37117049,442582,435783,432597,433450,436067,440373,435782,432598,436944)
