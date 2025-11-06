DROP MATERIALIZED VIEW IF EXISTS mv_cohort_with_diseases CASCADE;
CREATE MATERIALIZED VIEW mv_cohort_with_diseases AS
SELECT
  *
FROM mv_adult_first_icu
JOIN elixhauser_quan
USING (hadm_id);