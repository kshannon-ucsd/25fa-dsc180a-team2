DROP MATERIALIZED VIEW IF EXISTS mv_first_icu CASCADE;
CREATE MATERIALIZED VIEW mv_first_icu AS
SELECT
    i.subject_id,
    i.hadm_id,
    i.icustay_id,
    i.intime,
    i.outtime,
    i.los AS icu_los_days,
    ROW_NUMBER() OVER (PARTITION BY i.subject_id ORDER BY i.intime) AS rn
FROM icustays i;