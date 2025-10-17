{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fswiss\fcharset0 Helvetica-Bold;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww18280\viewh10620\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 1first_icu_stay: Uses row_number and partition to identify if it\'92s the subject\'92s first icu stay. If it\'92s their first icu stay then rn = 1.\
\
2adults_first_cohort: creates a base table which puts age_years as (time of admission - patient date of birth). It also joins patients and admission so this base table is the 
\f1\b most important part to our final cohort
\f0\b0 . Creates column of length of stay in hospital (days) and only outputs data where the age of the patient is between 16 and 90. (think about changing to 95 based on supplementary table 1).\
\
3diag_description: NEED TO CHANGE. it joins icd codes to description of icd codes but does it in such a way that the data is output as \'91\{icd1, icd2, icd3\}\'92 in 4. We want to onehot encode the diagnoses so that we have a 1 if the patient has the disease and a 0 if they don\'92t. Probably need to look at elixhauser comorbidity indices to correctly label. Varun said there\'92s something on the github for MIT to change the disease names to something more easily understandable and applicable to our scope.\
\
4agg_disease: NEED TO CHANGE. same issue as 3. \
\
5final_cohort: joins the adults_first to agg_disease. Honestly, just adults_first gives us the correct final cohort. However, we need to change agg_disease to be onehotencoding as said before for the purpose of multimorbidities and everything else.}