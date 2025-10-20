-- Drop the table if it exists, so we can re-run this script
DROP TABLE IF EXISTS elixhauser_ahrq_no_drg_filter;

-- Create the new table with the results of the query
CREATE TABLE elixhauser_ahrq_no_drg_filter AS
WITH eliflg AS (
    -- This CTE uses the specific AHRQ ICD-9 code mappings
    SELECT
        hadm_id, seq_num, icd9_code,
        CASE WHEN icd9_code = '39891' OR icd9_code BETWEEN '4280' AND '4289' THEN 1 END AS chf,
        CASE WHEN icd9_code IN ('42610', '42611', '42613', '4270', '4272', '42731', '42760', '4279', '7850') OR icd9_code BETWEEN '4262' AND '42653' OR icd9_code BETWEEN '4266' AND '42689' OR icd9_code BETWEEN 'V450' AND 'V4509' OR icd9_code BETWEEN 'V533' AND 'V5339' THEN 1 END AS arythm,
        CASE WHEN icd9_code IN ('3979', 'V422', 'V433') OR icd9_code BETWEEN '09320' AND '09324' OR icd9_code BETWEEN '3940' AND '3971' OR icd9_code BETWEEN '4240' AND '42499' OR icd9_code BETWEEN '7463' AND '7466' THEN 1 END AS valve,
        CASE WHEN icd9_code = '4179' OR icd9_code BETWEEN '41511' AND '41519' OR icd9_code BETWEEN '4160' AND '4169' THEN 1 END AS pulmcirc,
        CASE WHEN icd9_code IN ('4471', '449', '5571', '5579', 'V434') OR icd9_code BETWEEN '4400' AND '4409' OR icd9_code BETWEEN '44100' AND '4419' OR icd9_code BETWEEN '4420' AND '4429' OR icd9_code BETWEEN '4431' AND '4439' OR icd9_code BETWEEN '44421' AND '44422' THEN 1 END AS perivasc,
        CASE WHEN icd9_code IN ('4011', '4019') OR icd9_code BETWEEN '64200' AND '64204' THEN 1 END AS htn,
        CASE WHEN icd9_code IN ('4010', '4372') THEN 1 END AS htncx,
        CASE WHEN icd9_code BETWEEN '64220' AND '64224' THEN 1 END AS htnpreg,
        CASE WHEN icd9_code IN ('40200', '40210', '40290', '40509', '40519', '40599') THEN 1 END AS htnwochf,
        CASE WHEN icd9_code IN ('40201', '40211', '40291') THEN 1 END AS htnwchf,
        CASE WHEN icd9_code IN ('40300', '40310', '40390', '40501', '40511', '40591') OR icd9_code BETWEEN '64210' AND '64214' THEN 1 END AS hrenworf,
        CASE WHEN icd9_code IN ('40301', '40311', '40391') THEN 1 END AS hrenwrf,
        CASE WHEN icd9_code IN ('40400', '40410', '40490') THEN 1 END AS hhrwohrf,
        CASE WHEN icd9_code IN ('40401', '40411', '40491') THEN 1 END AS hhrwchf,
        CASE WHEN icd9_code IN ('40402', '40412', '40492') THEN 1 END AS hhrwrf,
        CASE WHEN icd9_code IN ('40403', '40413', '40493') THEN 1 END AS hhrwhrf,
        CASE WHEN icd9_code BETWEEN '64270' AND '64274' OR icd9_code BETWEEN '64290' AND '64294' THEN 1 END AS ohtnpreg,
        CASE WHEN icd9_code = '78072' OR icd9_code BETWEEN '3420' AND '3449' OR icd9_code BETWEEN '43820' AND '43853' THEN 1 END AS para,
        CASE WHEN icd9_code IN ('3320','3334','3335','3337','33371','33372','33379','33385','33394','3380','340','3483','7687','7803','78031','78032','78033','78039','78097','7843') OR icd9_code BETWEEN '3300' AND '3319' OR icd9_code BETWEEN '3340' AND '3359' OR icd9_code BETWEEN '3411' AND '3419' OR icd9_code BETWEEN '34500' AND '34511' OR icd9_code BETWEEN '3452' AND '3453' OR icd9_code BETWEEN '34540' AND '34591' OR icd9_code BETWEEN '34700' AND '34701' OR icd9_code BETWEEN '34710' AND '34711' OR icd9_code BETWEEN '64940' AND '64944' OR icd9_code BETWEEN '76870' AND '76873' THEN 1 END AS neuro,
        CASE WHEN icd9_code = '5064' OR icd9_code BETWEEN '490' AND '4928' OR icd9_code BETWEEN '49300' AND '49392' OR icd9_code BETWEEN '494' AND '4941' OR icd9_code BETWEEN '4950' AND '505' THEN 1 END AS chrnlung,
        CASE WHEN icd9_code BETWEEN '25000' AND '25033' OR icd9_code BETWEEN '64800' AND '64804' OR icd9_code BETWEEN '24900' AND '24931' THEN 1 END AS dm,
        CASE WHEN icd9_code = '7751' OR icd9_code BETWEEN '25040' AND '25093' OR icd9_code BETWEEN '24940' AND '24991' THEN 1 END AS dmcx,
        CASE WHEN icd9_code IN ('2448', '2449') OR icd9_code BETWEEN '243' AND '2442' THEN 1 END AS hypothy,
        CASE WHEN icd9_code IN ('585', '5853', '5854', '5855', '5856', '5859', '586', 'V420', 'V451', 'V568') OR icd9_code BETWEEN 'V560' AND 'V5632' OR icd9_code BETWEEN 'V4511' AND 'V4512' THEN 1 END AS renlfail,
        CASE WHEN icd9_code IN ('07022','07023','07032','07033','07044','07054','4560','4561','45620','45621','5710','5712','5713','5715','5716','5718','5719','5723','5728','5735','V427') OR icd9_code BETWEEN '57140' AND '57149' THEN 1 END AS liver,
        CASE WHEN icd9_code IN ('53141','53151','53161','53170','53171','53191','53241','53251','53261','53270','53271','53291','53341','53351','53361','53370','53371','53391','53441','53451','53461','53470','53471','53491') THEN 1 END AS ulcer,
        CASE WHEN icd9_code BETWEEN '042' AND '0449' THEN 1 END AS aids,
        CASE WHEN icd9_code IN ('2386', '2733') OR icd9_code BETWEEN '20000' AND '20238' OR icd9_code BETWEEN '20250' AND '20301' OR icd9_code BETWEEN '20302' AND '20382' THEN 1 END AS lymph,
        CASE WHEN icd9_code IN ('20979', '78951') OR icd9_code BETWEEN '1960' AND '1991' OR icd9_code BETWEEN '20970' AND '20975' THEN 1 END AS mets,
        CASE WHEN icd9_code BETWEEN '1400' AND '1729' OR icd9_code BETWEEN '1740' AND '1759' OR icd9_code BETWEEN '179' AND '1958' OR icd9_code BETWEEN '20900' AND '20924' OR icd9_code BETWEEN '20925' AND '2093' OR icd9_code BETWEEN '20930' AND '20936' OR icd9_code BETWEEN '25801' AND '25803' THEN 1 END AS tumor,
        CASE WHEN icd9_code = '7010' OR icd9_code = '725' OR icd9_code BETWEEN '7100' AND '7109' OR icd9_code BETWEEN '7140' AND '7149' OR icd9_code BETWEEN '7200' AND '7209' THEN 1 END AS arth,
        CASE WHEN icd9_code IN ('2871', '28984') OR icd9_code BETWEEN '2860' AND '2869' OR icd9_code BETWEEN '2873' AND '2875' OR icd9_code BETWEEN '64930' AND '64934' THEN 1 END AS coag,
        CASE WHEN icd9_code IN ('2780', '27800', '27801', '27803', 'V854', 'V8554', '79391') OR icd9_code BETWEEN '64910' AND '64914' OR icd9_code BETWEEN 'V8530' AND 'V8539' OR icd9_code BETWEEN 'V8541' AND 'V8545' THEN 1 END AS obese,
        CASE WHEN icd9_code BETWEEN '260' AND '2639' OR icd9_code BETWEEN '78321' AND '78322' THEN 1 END AS wghtloss,
        CASE WHEN icd9_code BETWEEN '2760' AND '2769' THEN 1 END AS lytes,
        CASE WHEN icd9_code = '2800' OR icd9_code BETWEEN '64820' AND '64824' THEN 1 END AS bldloss,
        CASE WHEN icd9_code = '2859' OR icd9_code BETWEEN '2801' AND '2819' OR icd9_code BETWEEN '28521' AND '28529' THEN 1 END AS anemdef,
        CASE WHEN icd9_code IN ('2915', '2918', '29181', '29182', '29189', '2919') OR icd9_code BETWEEN '2910' AND '2913' OR icd9_code BETWEEN '30300' AND '30393' OR icd9_code BETWEEN '30500' AND '30503' THEN 1 END AS alcohol,
        CASE WHEN icd9_code IN ('2920', '2929') OR icd9_code BETWEEN '29282' AND '29289' OR icd9_code BETWEEN '30400' AND '30493' OR icd9_code BETWEEN '30520' AND '30593' OR icd9_code BETWEEN '64830' AND '64834' THEN 1 END AS drug,
        CASE WHEN icd9_code IN ('29910', '29911') OR icd9_code BETWEEN '29500' AND '2989' THEN 1 END AS psych,
        CASE WHEN icd9_code IN ('3004', '30112', '3090', '3091', '311') THEN 1 END AS depress
    FROM diagnoses_icd
    WHERE seq_num > 1 -- We only look at secondary diagnoses for comorbidities
),
eligrp AS (
    -- This CTE collapses the flags for each admission
    SELECT
        hadm_id,
        MAX(chf) AS chf, MAX(arythm) AS arythm, MAX(valve) AS valve, MAX(pulmcirc) AS pulmcirc, MAX(perivasc) AS perivasc,
        MAX(htn) AS htn, MAX(htncx) AS htncx, MAX(htnpreg) AS htnpreg, MAX(htnwochf) AS htnwochf, MAX(htnwchf) AS htnwchf,
        MAX(hrenworf) AS hrenworf, MAX(hrenwrf) AS hrenwrf, MAX(hhrwohrf) AS hhrwohrf, MAX(hhrwchf) AS hhrwchf,
        MAX(hhrwrf) AS hhrwrf, MAX(hhrwhrf) AS hhrwhrf, MAX(ohtnpreg) AS ohtnpreg, MAX(para) AS para,
        MAX(neuro) AS neuro, MAX(chrnlung) AS chrnlung, MAX(dm) AS dm, MAX(dmcx) AS dmcx, MAX(hypothy) AS hypothy,
        MAX(renlfail) AS renlfail, MAX(liver) AS liver, MAX(ulcer) AS ulcer, MAX(aids) AS aids, MAX(lymph) AS lymph,
        MAX(mets) AS mets, MAX(tumor) AS tumor, MAX(arth) AS arth, MAX(coag) AS coag, MAX(obese) AS obese,
        MAX(wghtloss) AS wghtloss, MAX(lytes) AS lytes, MAX(bldloss) AS bldloss, MAX(anemdef) AS anemdef,
        MAX(alcohol) AS alcohol, MAX(drug) AS drug, MAX(psych) AS psych, MAX(depress) AS depress
    FROM eliflg
    GROUP BY hadm_id
)
SELECT
    -- Select demographic and stay info from the main cohort table
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
    dx.n_distinct_icd9,
    dx.icd9_codes,
    dx.icd9_code_titles,
    dx.icd9_json,
    
    -- Calculate the final comorbidity flags, but WITHOUT DRG filtering
    CASE WHEN eli.chf = 1 OR eli.htnwchf = 1 OR eli.hhrwchf = 1 OR eli.hhrwhrf = 1 THEN 1 ELSE 0 END AS congestive_heart_failure,
    COALESCE(eli.arythm, 0) AS cardiac_arrhythmias,
    COALESCE(eli.valve, 0) AS valvular_disease,
    COALESCE(eli.pulmcirc, 0) AS pulmonary_circulation,
    COALESCE(eli.perivasc, 0) AS peripheral_vascular,
    CASE WHEN eli.htn = 1 OR eli.htncx = 1 OR eli.htnpreg = 1 OR eli.htnwochf = 1 OR eli.htnwchf = 1 OR eli.hrenworf = 1 OR eli.hrenwrf = 1 OR eli.hhrwohrf = 1 OR eli.hhrwchf = 1 OR eli.hhrwrf = 1 OR eli.hhrwhrf = 1 OR eli.ohtnpreg = 1 THEN 1 ELSE 0 END AS hypertension,
    COALESCE(eli.para, 0) AS paralysis,
    COALESCE(eli.neuro, 0) AS other_neurological,
    COALESCE(eli.chrnlung, 0) AS chronic_pulmonary,
    CASE WHEN eli.dmcx = 1 THEN 0 ELSE COALESCE(eli.dm, 0) END AS diabetes_uncomplicated,
    COALESCE(eli.dmcx, 0) AS diabetes_complicated,
    COALESCE(eli.hypothy, 0) AS hypothyroidism,
    CASE WHEN eli.renlfail = 1 OR eli.hrenwrf = 1 OR eli.hhrwrf = 1 OR eli.hhrwhrf = 1 THEN 1 ELSE 0 END AS renal_failure,
    COALESCE(eli.liver, 0) AS liver_disease,
    COALESCE(eli.ulcer, 0) AS peptic_ulcer,
    COALESCE(eli.aids, 0) AS aids,
    COALESCE(eli.lymph, 0) AS lymphoma,
    COALESCE(eli.mets, 0) AS metastatic_cancer,
    CASE WHEN eli.mets = 1 THEN 0 ELSE COALESCE(eli.tumor, 0) END AS solid_tumor,
    COALESCE(eli.arth, 0) AS rheumatoid_arthritis,
    COALESCE(eli.coag, 0) AS coagulopathy,
    COALESCE(eli.obese, 0) AS obesity,
    COALESCE(eli.wghtloss, 0) AS weight_loss,
    COALESCE(eli.lytes, 0) AS fluid_electrolyte,
    COALESCE(eli.bldloss, 0) AS blood_loss_anemia,
    COALESCE(eli.anemdef, 0) AS deficiency_anemias,
    COALESCE(eli.alcohol, 0) AS alcohol_abuse,
    COALESCE(eli.drug, 0) AS drug_abuse,
    COALESCE(eli.psych, 0) AS psychoses,
    COALESCE(eli.depress, 0) AS depression

FROM mv_adult_first_icu c
-- Join diagnosis info (for columns like icd9_codes, icd9_json, etc.)
LEFT JOIN mv_dx_by_hadm dx ON c.hadm_id = dx.hadm_id
-- Join the calculated Elixhauser flags
LEFT JOIN eligrp eli ON c.hadm_id = eli.hadm_id;