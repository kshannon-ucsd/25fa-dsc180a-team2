with vital_ids as
(
select *
from d_items di
where lower(di.category) like '%vital%'
or lower(di.label) like any (array[
	'%heart%', '%respiratory rate%', '%resp rate%', '%o2 sat%', '%spo2%',
	'%temperature%', '%nbp%', '%arterial blood pressure%', '%mean arterial%']
)
), chart_vitals as 
(
  select *
  from chartevents ce
  join vital_ids v
  	on ce.itemid = v.itemid
)
select cv.label, cv.category, cv.unitname, cv.param_type, count(*)
from chart_vitals cv
group by cv.label, cv.category, cv.unitname, cv.param_type;

