DROP MATERIALIZED VIEW IF EXISTS mv_dx_detailed CASCADE;
CREATE MATERIALIZED VIEW mv_dx_detailed AS
SELECT
  d.hadm_id,
  d.icd9_code,
  COALESCE(dd.long_title, 'Unknown ICD9 code') AS icd9_long_title
FROM diagnoses_icd d
LEFT JOIN d_icd_diagnoses dd
  ON dd.icd9_code = d.icd9_code;
