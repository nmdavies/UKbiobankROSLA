//Neil Davies 03/07/15
//This creates an indicator for birth month in the UK Biobank data

cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA"

use "raw_data/biobank_phenotypes_nmd_150417.dta", clear

//Gen indicator for months and year of birth
gen year_month_birth=100*n_34_0_0+n_52_0_0
tab year_month_birth
replace year_month_birth=100*n_34_0_0+n_52_0_0

//generate quarter of birth indicators

gen year_q=n_34_0_0*10+1 if n_52_0_0==12|n_52_0_0==1|n_52_0_0==2
replace year_q =n_34_0_0*10+2 if n_52_0_0==3|n_52_0_0==4|n_52_0_0==5
replace year_q =n_34_0_0*10+3 if n_52_0_0==6|n_52_0_0==7|n_52_0_0==8
replace year_q =n_34_0_0*10+4 if n_52_0_0==9|n_52_0_0==10|n_52_0_0==11

//Program to combine the fields 0 and 1 for each variable
cap prog drop merge_var
prog def merge_var
replace `1'_0_0=`1'_1_0 if (`1'_0_0==.|`1'_0_0<0 )& (`1'_1_0>0 & `1'_1_0!=.)
end

cap prog drop merge_var2
prog def merge_var2
replace `1'_0_0=`1'_1_`2' if (`1'_0_`2'==.|`1'_0_`2'<0 )& (`1'_1_`2'>0 & `1'_1_`2'!=.)
end

cap prog drop merge_svar
prog def merge_svar
replace `1'_0_0=`1'_1_0 if (`1'_0_0=="")& (`1'_1_0!="")
end

//Clean years of full time education
//Use Rietveld method for defining years of education

merge_var n_845
gen eduyears =n_845_0_0 if n_845_0_0>0
gen less_edu_14=(n_845_0_0<=14) if n_845_0_0>0 & eduyears!=.
gen less_edu_15=(n_845_0_0<=15) if n_845_0_0>0 & eduyears!=.
gen less_edu_16=(n_845_0_0<=16) if n_845_0_0>0 & eduyears!=.
gen less_edu_21=(n_845_0_0<=20) if n_845_0_0>0 & eduyears!=.

gen more_edu_15=1-less_edu_15

//Participants who said they had a university or college degree were not asked what age they left school.
//We impute these participants at 21, and set them to left school after age 15:

ds n_6138_*
foreach i in `r(varlist)'{
	replace more_edu_15=1 if `i'==1 & more_edu_15==.
	replace eduyears=21 if `i'==1 & eduyears==.
	}


//Identify individuals who were not born in England:
merge_var n_1647
gen born_english=(n_1647_0_0==1 & n_20115_0_0==.)

//Again using quarter of birth
tabstat eduyears if born_english==1, by(year_q) stats(mean n)
tabstat less_edu_* if born_english==1, by(year_q) stats(mean) 

tabstat eduyears if born_english==0, by(year_q) stats(mean n)
tabstat less_edu_* if born_english==0, by(year_q) stats(mean) 

//Generate a indicator for 'after reform' which is after 1957Q4
gen post_reform=(year_month_birth>195708)

//Generate rosla variable
gen yob=n_34_0_0
gen mob=n_52_0_0
gen dob=ym(yob,mob)
gen bw12=0 if dob>=-40 & dob<=-29
replace bw12=1 if dob>=-28 & dob<=-17

//Generate negative control exposures for the year before and after the reform:
gen N1_bw12=0 if dob>=-52 & dob<=-31
replace N1_bw12=1 if dob>=-40 & dob<=-29
gen N2_bw12=0 if dob>=-28 & dob<=-17
replace N2_bw12=1 if dob>=-16 & dob<=-5

gen rosla=dob+28

//Clean the outcome data
//Physical Exercise
/*
Maximum	7
Decile 9	7
Decile 8	6
Decile 7	5
Decile 6	4
Median	3
Decile 4	3
Decile 3	2
Decile 2	1
Decile 1	0
Minimum	0
2304 items have value -3 (Prefer not to answer)
24680 items have value -1 (Do not know)
*/

merge_var n_904
merge_var n_884
gen out_phys_v_act=n_904_0_0 if n_904_0_0 >=0 &n_904_0_0!=.
gen out_phys_m_act=n_884_0_0 if n_884_0_0 >=0 & n_884_0_0!=.

//Sedentary activity
/*
Maximum	24
Decile 9	5
Decile 8	4
Decile 7	4
Decile 6	3
Median	3
Decile 4	2
Decile 3	2
Decile 2	2
Decile 1	1
Minimum	0

24259 items have value -10 (Less than an hour a day)
767 items have value -3 (Prefer not to answer)
3838 items have value -1 (Do not know)
*/

merge_var n_1070
gen out_sedentary=n_1070_0_0 if n_1070_0_0>0 & n_1070_0_0
replace out_sedentary=0 if n_1070_0_0==-10 & n_1070_0_0

//Income
//See http://biobank.ctsu.ox.ac.uk/crystal/field.cgi?id=738

merge_var n_738
gen out_income_under_18k=(n_738_0_0>1) if n_738_0_0>0 &n_738_0_0!=.
gen out_income_over_31k=(n_738_0_0>2) if n_738_0_0>0 &n_738_0_0!=.
gen out_income_over_52k=(n_738_0_0>3) if n_738_0_0>0 &n_738_0_0!=.
gen out_income_over_100k=(n_738_0_0>4) if n_738_0_0>0 &n_738_0_0!=.

//Smoking

merge_var n_20116
gen out_smoker=(n_20116_0_0==2) if n_20116_0_0>=0 & n_20116_0_0!=.
gen out_exsmoker=(n_20116_0_0==2|n_20116_0_0==1) if n_20116_0_0>=0 & n_20116_0_0!=.

//Alcohol consumption

merge_var n_1558
gen out_alcohol=6-n_1558_0_0 if n_1558_0_0>0 & n_1558_0_0!=.

//Depression
merge_var n_4620
gen out_depression=(n_4620_0_0>0 & n_4620_0_0!=.) if n_4620_0_0>0

//Happiness
merge_var n_4526
gen out_happiness=(6-n_4526_0_0) if n_4526_0_0>0 & n_4526_0_0!=.

//Cognition
merge_var n_20016
gen out_intell=n_20016_0_0

//Blood pressure
merge_var n_4080
merge_var n_4079
egen out_sys_bp=rowmean(n_4080_0_1 n_4080_0_0)
egen out_dia_bp=rowmean(n_4079_0_1 n_4079_0_0)

//Anthropometry
merge_var n_21001
merge_var n_50
gen out_bmi=n_21001_0_0
gen out_height=n_50_0_0

//Arterial Stiffness
merge_var n_21021
merge_svar s_4206

xi:reg n_21021_0_0 i.s_4206_0_0 
predict out_arterial_stiffness,res

//Grip strength
merge_var n_46
merge_var n_47
merge_svar s_38
egen X=rowmean(n_46_0_0 n_47_0_0)
xi:reg X i.s_38_0_0
predict out_gripstrength if X!=.,res
drop X

//Mortality
gen out_dead=(n_40018_0_0!=.)

//Diagnosed with cancer
gen out_cancer=(n_40008_0_0>=30 & n_40008_0_0!=.) if n_40008_0_0>=30 | n_40008_0_0==.

//Had heart attack or stroke
merge_var n_6150

merge_var2 n_6150 1
merge_var2 n_6150 2
merge_var2 n_6150 3

gen out_heartattack=(n_6150_0_0==1|n_6150_0_1==1|n_6150_0_2==1|n_6150_0_3==1) if n_6150_0_0!=-3 & n_6150_0_0!=.
gen out_stroke=(n_6150_0_0==3|n_6150_0_1==3|n_6150_0_2==3|n_6150_0_3==3) if n_6150_0_0!=-3 & n_6150_0_0!=.

//Diagnosed with diabetes
merge_var n_2443
merge_var n_2976
gen out_diabetes=(n_2443_0_0==1) if n_2443_0_0>=0 
replace out_diabete=. if n_2976_0_0<=21 & n_2976_0_0!=.

//Diagnosed with hypertension
merge_var n_2966
gen out_highbloodpressure=(n_2966_0_0>0 &  n_2966_0_0!=.) if n_2966_0_0>0

//Gender
gen male=(n_31_0_0==1)

keep n_845_0_0 n_6138_* out_* male year_month_birth year_q eduyears less_edu_14 less_edu_15 less_edu_16 less_edu_21 more_edu_15 born_english post_reform yob mob dob rosla n_eid bw12 N1_bw12 N2_bw12
compress

//Limit the sample just to English born individuals
drop if born_english!=1

save "working data/temp",replace
use  "working data/temp",clear

joinby n_eid using "working data/covariates",unmatched(master) _merge(XXX)
drop if XXX!=3
drop XXX

*doby here is the year of birth in four digit format i.e. 1956... 
*dobm here is the month of birth

gen bw24 = 0 if dob >= -52 & dob <= -29
replace bw24 = 1 if dob >= -28 & dob <= -5

gen bw36 = 0 if dob >= -64 & dob <= -29
replace bw36 = 1 if dob >= -28 & dob <= 7

gen bw48 = 0 if dob >= -76 & dob <= -29
replace bw48 = 1 if dob >= -28 & dob <= 19

gen bw60 = 0 if dob >= -88  & dob <= -29
replace bw60 = 1 if dob >= -28 & dob <= 31

gen bw72 = 0 if dob >= -100 & dob <= -29
replace bw72 = 1 if dob >= -28 & dob <= 43	

gen bw120 = 0 if dob >= -148 & dob <= -29
replace bw120 = 1 if dob >= -28 & dob <= 91	

tab mob, gen(imob_)
drop imob_12
gen rosla_i=rosla*bw12

//Merge in the educational attainment allele score
joinby n_eid using "working data/EA_score", unmatched(master)
drop _m
joinby n_eid using "working data/genome_wide_EA2_score", unmatched(master)

drop _m

//Create month of birth variable and negative control ROSLAs

gen mobi=100*yob+mob
gen rosla_neg1=rosla+12
gen rosla_neg2=rosla-12

compress

//Generate interaction with birth month and year and reform
gen mob_post=mob*post_reform
gen rosla_post=rosla*post_reform

tab mob_post, gen(mob_post_I_)
tab mob, gen(mob_I_)


gen weight=1.8857 if more_edu_15==0
replace weight=1 if weight==.

save "working data/cleaned_biobank_outcomes_ENGLISH",replace

