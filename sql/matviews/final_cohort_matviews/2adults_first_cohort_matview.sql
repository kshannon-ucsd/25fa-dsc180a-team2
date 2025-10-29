DROP MATERIALIZED VIEW IF EXISTS mv_adult_first_icu CASCADE;
CREATE MATERIALIZED VIEW mv_adult_first_icu AS
WITH base AS (
  SELECT
    f.subject_id,
    f.hadm_id,
    f.icustay_id,
    f.intime,
    f.outtime,
    f.icu_los_days,
    a.admittime,
    a.dischtime,
    a.admission_type,
    a.hospital_expire_flag,
    p.gender,
	EXTRACT(YEAR FROM a.admittime) - EXTRACT(YEAR FROM p.dob) AS age_years
  FROM mv_first_icu f
  JOIN admissions a ON f.hadm_id = a.hadm_id
  JOIN patients p ON f.subject_id = p.subject_id
  WHERE f.rn = 1
)
SELECT
  *,
  (EXTRACT(EPOCH FROM (dischtime - admittime)) / 86400.0) AS hosp_los_days,
  CASE
    WHEN UPPER(admission_type) = 'ELECTIVE' THEN 'elective'
    ELSE 'non-elective'
  END AS admission_type_grp
FROM base
WHERE age_years >= 16 AND age_years <= 90;

