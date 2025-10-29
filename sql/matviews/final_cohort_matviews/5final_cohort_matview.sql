DROP MATERIALIZED VIEW IF EXISTS mv_cohort_with_diseases CASCADE;
CREATE MATERIALIZED VIEW mv_cohort_with_diseases AS
SELECT
  c.subject_id,
  c.hadm_id,
  c.icustay_id,
  c.gender,
  c.age_years,
  c.admission_type,
  c.admission_type_grp,
  c.intime,
  c.outtime,
  c.icu_los_days,
  c.hosp_los_days,
  c.hospital_expire_flag AS hosp_mortality,
  -- disease info change this shit
  dx.n_distinct_icd9,
  dx.icd9_codes,
  dx.icd9_code_titles,
  dx.icd9_json
FROM mv_adult_first_icu c
LEFT JOIN mv_dx_by_hadm dx
  ON dx.hadm_id = c.hadm_id;
