//Neil Davies 24/01/17
//This creates an indicator for birth month in the UK Biobank data
//This runs the regressions on a range of negative control samples

use "working data/cleaned_biobank_outcomes_ENGLISH" ,clear

gen weight=1.8857 if more_edu_15==0
replace weight=1 if weight==.


//Create negative control populations

forvalues i=0(1)5{
	gen bw12_`i'=0 if (dob>=(-40+`i'*24)) & (dob<=(-29+`i'*24))
	replace bw12_`i'=1 if (dob>=(-28+`i'*24)) & (dob<=(-17+`i'*24))
	}

forvalues i=1(1)5{
	gen bw12_N`i'=0 if (dob>=(-40-`i'*24)) & (dob<=(-29-`i'*24))
	replace bw12_N`i'=1 if (dob>=(-28-`i'*24)) & (dob<=(-17-`i'*24))
	}
save  "working data/cleaned_biobank_outcomes_ENGLISH" ,replace
	
	
	
reg out_phys_v_act bw12 i.mob cov_male if more_edu_15!=.  [pweight=weight], cluster(mobi)
regsave  bw12 using "results/by_year/outcome", replace detail(all) pval ci	
	
foreach i in  bw12_N5 bw12_N4 bw12_N3 bw12_N2 bw12_N1 bw12_0  bw12_1  bw12_2  bw12_3  bw12_4 bw12_5 {
	ds out_*
	foreach j in `r(varlist)'{
		reg `j' `i' i.mob cov_male if more_edu_15!=. [pweight=weight], cluster(mobi)
		regsave  `i' using "results/by_year/outcome", append detail(all) pval ci	
		}
	}

use "results/by_year/outcome", clear

gen n=_n
gsort - n

replace var ="10 years after reform" if var=="bw12_5"
replace var ="8 years after reform" if var=="bw12_4"
replace var ="6 years after reform" if var=="bw12_3"
replace var ="4 years after reform" if var=="bw12_2"
replace var ="2 years after reform" if var=="bw12_1"
replace var ="ROSLA cohort" if var=="bw12_0"
replace var ="2 years before reform" if var=="bw12_N1"
replace var ="4 years before reform" if var=="bw12_N2"
replace var ="6 years before reform" if var=="bw12_N3"
replace var ="8 years before reform" if var=="bw12_N4"
replace var ="10 years before reform" if var=="bw12_N5"

gen reform=(var=="ROSLA cohort")
replace reform =2 if word(cmdline,3)=="bw12_5"|word(cmdline,3)=="bw12_4"|word(cmdline,3)=="bw12_3"|word(cmdline,3)=="bw12_2"|word(cmdline,3)=="bw12_1"
label define reform 1 " " 0 "Before ROSLA cohorts" 2 "Post ROSLA cohorts"
label values reform reform

//Test for difference between ROSLA and other cohort and calculate the diff-in-diff estimates 
//Pool negative controls using metan

gen pooled_es=.
gen pooled_se=.

#delimit ;
foreach i in out_highbloodpressure
out_diabetes
out_stroke
out_heartattack
out_depression
out_cancer
out_dead
out_exsmoker
out_smoker
out_income_under_18k
out_income_over_31k
out_income_over_52k
out_income_over_100k
out_arterial_stiffness
out_bmi
out_sys_bp
out_dia_bp
out_gripstrength
out_happiness
out_height
out_intell
out_phys_m_act
out_phys_v_act
out_sedentary
out_alcohol{;
	metan coef ci_lower ci_upper if word(cmdline ,2)=="`i'" & coef<10 & var!="ROSLA cohort", nohet nograph;
	replace pooled_es=r(ES) if depvar=="`i'";
	replace pooled_se=r(seES) if depvar=="`i'";
	};
#delimit cr

//Generate difference estimate
gen diff=coef-pooled_es if var=="ROSLA cohort"
gen diff_se=(pooled_se^2+stderr^2)^0.5 if var=="ROSLA cohort"
gen diff_lci=diff-1.96*diff_se
gen diff_uci=diff+1.96*diff_se
gen double diff_p=2*(1-normal(abs((diff/diff_se ))))

replace diff_p=7.828726e-29 if diff_p==0

foreach i in diff diff_se diff_lci diff_uci diff_p{
	bys depvar:egen X`i'=max(`i')
	drop `i'
	rename X`i' `i'
	}
	
label variable var "Sample"
gsort - n

tostring diff_p, gen( diff_p2) format(%12.1e) force

#delimit ;
foreach i in 
out_highbloodpressure
out_diabetes
out_stroke
out_heartattack
out_depression
out_cancer
out_dead
out_exsmoker
out_smoker
out_income_under_18k
out_income_over_31k
out_income_over_52k
out_income_over_100k
{;
	preserve;
	replace coef=coef*100 if word(cmdline ,2)=="`i'";
	replace ci_lower=ci_lower*100 if word(cmdline ,2)=="`i'";
	replace ci_upper=ci_upper*100 if word(cmdline ,2)=="`i'";
	
	
	keep  if word(cmdline ,2)=="`i'" ;
	local dd_effect=diff[1]*100 ;
	local dd_lci=diff_lci[1]*100;
	local dd_uci=diff_uci[1]*100;
	
	local dd_pvalue=diff_p2[1];
	di "`dd_pvalue'";
	metan coef ci_lower ci_upper if word(cmdline ,2)=="`i'" & coef<10, lcols(var) by(reform) title(`i') effect("Risk difference*100") textsize(150)
		nosecsub nowt plotregion(lc(white)) nohet second(`dd_effect' `dd_lci' `dd_uci' "Diff-in-diff ROSLA vs. avg y-o-y diff (p-value=`dd_pvalue')");
	graph export "/Users/ecnmd/Desktop/uk_Biobank/metan_bin_`i'.eps", replace ;
	restore;
	};
	
#delimit cr

drop if var=="bw12"

#delimit ;
foreach i in 	
out_arterial_stiffness
out_bmi
out_sys_bp
out_dia_bp
out_gripstrength
out_happiness
out_height
out_intell
out_phys_m_act
out_phys_v_act
out_sedentary
out_alcohol
{;

	preserve;
	keep  if word(cmdline ,2)=="`i'" ;
	local dd_effect=diff[1];
	local dd_lci=diff_lci[1];
	local dd_uci=diff_uci[1];
	local dd_pvalue=diff_p2[1];
	metan coef ci_lower ci_upper if word(cmdline ,2)=="`i'" & coef<10, lcols(var) by(reform) title(`i') effect("Mean difference")
		nosecsub  plotregion(lc(white)) nohet second(`dd_effect' `dd_lci' `dd_uci' "Diff-in-diff ROSLA vs. avg y-o-y diff (p-value=`dd_pvalue')");
	graph export "/Users/ecnmd/Desktop/uk_Biobank/metan_con_`i'.eps",replace;
	restore;
	};	
rename diff_p p_value	

gen order=.
replace order = 25 in 1
replace order = 24 in 2
replace order = 23 in 3
replace order = 22 in 10
replace order = 21 in 12
replace order = 20 in 13
replace order = 19 in 14
replace order = 18 in 15
replace order = 17 in 16
replace order = 16 in 17
replace order = 15 in 18
replace order = 14 in 19
replace order = 13 in 7
replace order = 12 in 6
replace order = 11 in 5
replace order = 10 in 4
replace order = 9 in 8
replace order = 8 in 9
replace order = 7 in 20
replace order = 6 in 21
replace order = 5 in 11
replace order = 4 in 22
replace order = 3 in 23
replace order = 2 in 24
replace order = 1 in 25


gen depvar_desc=""
replace depvar_desc = "Vigorous exercise (days/week)" in 1
replace depvar_desc = "Moderate exercise (days/week)" in 2
replace depvar_desc = "Hours watching television per day" in 3
replace depvar_desc = "Ever smoked" in 9
replace depvar_desc = "Alcohol consumption (1 low, 5 high)" in 10

replace depvar_desc = "Depression" in 11
replace depvar_desc = "Happiness (0 to 5 Likert)" in 12
replace depvar_desc = "Intelligence (0 to 13)" in 13
replace depvar_desc = "Systolic blood pressure (mmHg)" in 14
replace depvar_desc = "Diastolic blood pressure (mmHg)" in 15
replace depvar_desc = "BMI (kg/m2)" in 16
replace depvar_desc = "Height (cm)" in 17
replace depvar_desc = "Arterial Stiffness" in 18
replace depvar_desc = "Grip strength (kg)" in 19
replace depvar_desc = "Died" in 20
replace depvar_desc = "Cancer" in 21
replace depvar_desc = "Heart attack" in 22
replace depvar_desc = "Stroke" in 23
replace depvar_desc = "Diabetes" in 24
replace depvar_desc = "High blood pressure" in 25
sort order
save "/Users/ecnmd/Desktop/uk_biobank/results.dta"
use "/Users/ecnmd/Desktop/uk_biobank/results.dta",clear
label var diff_p2 "P value"
label var depvar_desc "Outcome"
//Finally create figure of DD results which allow for age effects
preserve 
keep if reform==1
#delimit ;
keep if depvar=="out_arterial_stiffness"
| depvar=="out_bmi"
| depvar=="out_sys_bp"
| depvar=="out_dia_bp"
| depvar=="out_gripstrength"
| depvar=="out_happiness"
| depvar=="out_height"
| depvar=="out_intell"
| depvar=="out_phys_m_act"
| depvar=="out_phys_v_act"
| depvar=="out_sedentary"
| depvar=="out_alcohol";

metan diff diff_se , lcols(depvar_desc) rcols(diff_p2) title("Cont outcomes") effect("Mean difference")
	nosecsub  plotregion(lc(white)) nohet nooverall nobox textsize(150)  
	favours(Remaining in school reduces # Remaining in school increases); 
#delimit cr	
graph export "/Users/ecnmd/Desktop/uk_Biobank/DD_cont_outcomes.png",replace

//Repeat for binary outcomes
replace diff_p2="7.8e-29" if diff_p2=="0.0e+00"

preserve 
keep if reform==1
replace diff=diff*100
replace diff_se=diff_se*100

#delimit ;
keep if depvar=="out_highbloodpressure"
| depvar=="out_diabetes"
| depvar=="out_stroke"
| depvar=="out_heartattack"
| depvar=="out_depression"
| depvar=="out_cancer"
| depvar=="out_dead"
| depvar=="out_exsmoker"
| depvar=="out_smoker"
| depvar=="out_income_under_18k"
| depvar=="out_income_over_31k"
| depvar=="out_income_over_52k"
| depvar=="out_income_over_100k";

metan diff diff_se , lcols(depvar_desc) rcols(diff_p2) title("Binary outcomes") effect("Risk difference*100")
	nosecsub  plotregion(lc(white)) nohet nooverall nobox textsize(125)
	favours(Remaining in school reduces # Remaining in school increases); 
#delimit cr	
graph export "/Users/ecnmd/Desktop/uk_Biobank/DD_bin_outcomes.png",replace
