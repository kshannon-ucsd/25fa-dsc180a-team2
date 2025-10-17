with heart_ids as (
  select di.itemid, di.label
  from d_items di
  where lower(di.label) = 'heart rate' or lower(di.label) = 'heart rhythm'
), hr_first24 as 
(
  select
    ce.subject_id,
    ce.hadm_id,
    ce.icustay_id,
    ce.charttime,
	hi.label,
    ce.valuenum as hr
  from chartevents ce
  join heart_ids hi
  	on ce.itemid = hi.itemid
  join icustays icu 
    on ce.icustay_id = icu.icustay_id
  where ce.valuenum is not null
    and ce.charttime between icu.intime and icu.intime + interval '24 hours'
), hr_agg as 
(
  select
    hr.subject_id,
    hr.hadm_id,
    hr.icustay_id,
	hr.label,
    avg(hr) as hr_mean_24h
  from hr_first24 hr
  group by hr.subject_id, hr.hadm_id, hr.icustay_id, hr.label
)
select
  hr.subject_id,
  hr.hadm_id,
  hr.icustay_id,
  hr.label,
  case
    when extract(year from age(a.admittime, p.dob)) >= 300 then 90
    else extract(year from age(a.admittime, p.dob))
  end::int as age_years,
  hr.hr_mean_24h
from hr_agg as hr
join admissions as a
  on a.hadm_id = hr.hadm_id
join patients  as p
  on p.subject_id = hr.subject_id
where 
  (case
  	when extract(year from age(a.admittime, p.dob)) >= 300 THEN 90
    else extract(year from age(a.admittime, p.dob))
   end) > 0
order by age_years;
