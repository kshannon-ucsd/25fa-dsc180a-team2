DROP MATERIALIZED VIEW IF EXISTS mv_dx_by_hadm CASCADE;

CREATE MATERIALIZED VIEW mv_dx_by_hadm AS
WITH distinct_dx AS (
  SELECT DISTINCT
    d.hadm_id,
    d.icd9_code,
    d.icd9_long_title
  FROM mv_dx_detailed d
),
ordered_dx AS (
  SELECT
    hadm_id,
    icd9_code,
    icd9_long_title
  FROM distinct_dx
  ORDER BY hadm_id, icd9_code
)
SELECT
  hadm_id,
  COUNT(*) AS n_distinct_icd9,
  ARRAY_AGG(icd9_code) AS icd9_codes,
  ARRAY_AGG(icd9_code || ' — ' || icd9_long_title) AS icd9_code_titles,
  JSONB_AGG(JSONB_BUILD_OBJECT(
      'code',  icd9_code,
      'title', icd9_long_title
  )) AS icd9_json
FROM ordered_dx
GROUP BY hadm_id;
