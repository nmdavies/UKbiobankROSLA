//Neil Davies 03/07/15
//This creates an indicator for birth month in the UK Biobank data

cap prog drop reduced_form
prog def reduced_form

	use "working data/cleaned_biobank_outcomes_ENGLISH" if male!=`1',clear
	
	//Run baseline regressions just using actual schooling (more than 15 years and eduyears):
	reg out_phys_v_act more_edu_15 i.mob cov_male if bw12!=. [pweight=weight], cluster(mobi)
	regsave more_edu_15 using "results/outcome_act_exposure_`2'", replace detail(all) pval ci
	
	reg out_phys_v_act eduyears i.mob cov_male if bw12!=. [pweight=weight], cluster(mobi)
	regsave eduyears using "results/outcome_act_exposure2_`2'", replace detail(all) pval ci
	
	//On the policy change and the two negative control populations
	foreach j in bw12 N1_bw12 N2_bw12{
		reg out_phys_v_act `j' i.mob cov_male if more_edu_15!=. [pweight=weight], cluster(mobi)
		regsave  `j' using "results/outcome_`j'_`2'", replace detail(all) pval ci
		}
	
	//Instrumental variable regressions			
	ivreg2 out_phys_v_act (more_edu_15 =post_reform) imob_*  cov_male if bw12!=. [pweight=weight], endog(more_edu_15) cluster(mobi) partial(imob_* cov_male)
	regsave more_edu_15 using "results/outcome_IV_`2'", replace detail(all) pval ci
	
	ivreg2 out_phys_v_act (eduyears =post_reform) imob_*  cov_male if bw12!=. [pweight=weight], endog(eduyears) cluster(mobi) partial(imob_* cov_male)
	regsave eduyears using "results/outcome_IV2_`2'", replace detail(all) pval ci
	
	//Repeat these regression for all the other outcomes:
	ds out_*
	foreach i in `r(varlist)'{
		reg `i' more_edu_15 i.mob cov_male if bw12!=. [pweight=weight], cluster(mobi)
		regsave more_edu_15 using "results/outcome_act_exposure_`2'", append detail(all) pval ci		
		
		reg `i' eduyears i.mob cov_male if bw12!=. [pweight=weight], cluster(mobi)
		regsave eduyears using "results/outcome_act_exposure2_`2'", append detail(all) pval ci		
		
		foreach j in bw12 N1_bw12 N2_bw12{
			reg `i'  `j'  i.mob  cov_male if more_edu_15!=. & yob>1947 [pweight=weight], cluster(mobi)
			regsave `j'  using "results/outcome_`j'_`2'", append detail(all) pval ci
			}		
		ivreg2 `i' (more_edu_15 =post_reform)  imob_*  cov_male if bw12!=. [pweight=weight] , endog(more_edu_15) cluster(mobi) partial(imob_* cov_male)
		regsave more_edu_15 using "results/outcome_IV_`2'", append detail(all) pval ci 
		ivreg2 `i' (eduyears =post_reform)  imob_*  cov_male if bw12!=. [pweight=weight], endog(eduyears) cluster(mobi) partial(imob_* cov_male)
		regsave eduyears using "results/outcome_IV2_`2'", append detail(all) pval ci 
		
		}
end

reduced_form 2 all
reduced_form 1 female
reduced_form 0 male

//Clean results:	

cap prog drop clean
prog def clean
use "`2'",clear
keep depvar N coef ci_lower ci_upper pval
gen n=_n
order depvar N coef ci_lower ci_upper pval
drop if _n==_N
foreach j in N coef ci_lower ci_upper pval{
	rename `j' `j'_`1'
	}
save "working data/temp`1'.dta",replace
rm "`2'.dta"
end

foreach j in male female all{
	clean 1 "results/outcome_act_exposure_`j'"
	clean 2 "results/outcome_bw12_`j'"
	clean 3 "results/outcome_N1_bw12_`j'"
	clean 4 "results/outcome_N2_bw12_`j'"
	clean 5 "results/outcome_act_exposure2_`j'"
	
	use "working data/temp1.dta",clear
	rm "working data/temp1.dta"
	forvalues i=2(1)5{
		joinby n using "working data/temp`i'.dta", unmatched(both)
		tab _m
		drop _m
		rm "working data/temp`i'.dta"
		}
	drop n

	
	sort n
	drop n
	save "results/table3_`j'_reduced_form",replace
	}

use "results/table3_all_reduced_form"
append using "results/table3_male_reduced_form"
append using "results/table3_female_reduced_form"
save "results/table3",replace
use "results/table3",clear
gen analysis="all" if _n<26
replace analysis="males" if analysis=="" & _n<51
replace analysis="females" if analysis==""
joinby depvar using "working data/order",unmatched(master)
sort analysis n

rm "results/table3_all_reduced_form.dta"
rm "results/table3_male_reduced_form.dta"
rm "results/table3_female_reduced_form.dta"

//Clean IV results for Table 4
cap prog drop clean_iv
prog def clean_iv
use "`2'",clear
keep depvar N coef ci_lower ci_upper pval estatp cdf
gen n=_n
order depvar N coef ci_lower ci_upper pval
drop if _n==_N
save "working data/temp`1'.dta",replace
rm "`2'.dta"
end


clean_iv 1 "results/outcome_IV_all"
clean_iv 2 "results/outcome_IV_male"
clean_iv 3 "results/outcome_IV_female"

use "working data/temp1.dta",clear
append using  "working data/temp2"
append using  "working data/temp3"
order depvar N coef ci_lower ci_upper pval estatp cdf
save "results/table4",replace

use "results/table4",clear
drop n
gen analysis="all" if _n<26
replace analysis="males" if analysis=="" & _n<51
replace analysis="females" if analysis==""
joinby depvar using "working data/varname",unmatched(master)
drop _m
joinby depvar using "working data/order",unmatched(master)
sort analysis n


//Create indicator for binary or continious measure:

#delimit ;
gen binary=(depvar=="out_highbloodpressure"
|depvar=="out_diabetes"
|depvar=="out_stroke"
|depvar=="out_heartattack"
|depvar=="out_depression"
|depvar=="out_cancer"
|depvar=="out_dead"
|depvar=="out_exsmoker"
|depvar=="out_smoker"
|depvar=="out_income_under_18k"
|depvar=="out_income_over_31k"
|depvar=="out_income_over_52k"
|depvar=="out_income_over_100k");

#delimit cr
//Create Figure 5

mkmat coef ci_lower ci_upper if analysis=="all" & binary==1, mat(coef1_bin) rownames(depvar)
mkmat coef ci_lower ci_upper if analysis=="all" & binary==0, mat(coef1_con) rownames(depvar)

use "results/table3",clear
gen analysis="all" if _n<26
replace analysis="males" if analysis=="" & _n<51
replace analysis="females" if analysis==""
joinby depvar using "working data/order",unmatched(master)
drop _m
joinby depvar using "working data/varname",unmatched(master)
sort analysis n

//Create indicator for binary or continious measure:

#delimit ;
gen binary=(depvar=="out_highbloodpressure"
|depvar=="out_diabetes"
|depvar=="out_stroke"
|depvar=="out_heartattack"
|depvar=="out_depression"
|depvar=="out_cancer"
|depvar=="out_dead"
|depvar=="out_exsmoker"
|depvar=="out_smoker"
|depvar=="out_income_under_18k"
|depvar=="out_income_over_31k"
|depvar=="out_income_over_52k"
|depvar=="out_income_over_100k");

#delimit cr


mkmat coef_1 ci_lower_1 ci_upper_1 if analysis=="all" & binary==1, mat(coef2_bin) rownames(depvar)
mkmat coef_1 ci_lower_1 ci_upper_1 if analysis=="all" & binary==0, mat(coef2_con) rownames(depvar)





//Binary outcomes
#delimit ;
coefplot (matrix(coef1[,1]), ms(T) mc(edkblue) lc() ciopts(lc(edkblue)) lc(edkblue) ci((coef1[,2] coef1[,3])) offset(.05)) ///
	     (matrix(coef2[,1]), ms(S) mc(red) ciopts(lc(red)) lstyle(p1) lc(red) ci((coef2[,2] coef2[,3]))   offset(-.05)) , ///
	  xline(0) leg(off) ylabel(,format(%9.1f))  plotregion(lc(white)) xtitle(Risk difference) grid(none)
	  coeflabels(out_highbloodpressure = "Hypertension"
		out_diabetes = "Diabetes"
		out_stroke = "Stroke"
		out_heartattack = "Heart attack"
		out_depression = "Depression"
		out_cancer = "Cancer"
		out_dead = "Died"
		out_exsmoker = "Ever smoked"
		out_smoker = "Current smoker"
		out_income_under_18k = "Income over £18k"
		out_income_over_31k = "Income over £31k"
		out_income_over_52k = "Income over £52k"
		out_income_over_100k = "Income over £100k");
#delimit cr

graph export "results/figure_5.png", replace as(png)


//Continious outcomes
#delimit ;
coefplot (matrix(coef1_con[,1]), ms(T) mc(edkblue) lc() ciopts(lc(edkblue)) lc(edkblue) ci((coef1_con[,2] coef1_con[,3])) offset(.05)) ///
	     (matrix(coef2_con[,1]), ms(S) mc(red) ciopts(lc(red)) lstyle(p1) lc(red) ci((coef2_con[,2] coef2_con[,3]))   offset(-.05)) , ///
	  xline(0) leg(off) ylabel(,format(%9.1f))  plotregion(lc(white)) xtitle(Risk difference) grid(none)
	  coeflabels(out_gripstrength = "Grip strength (kg)"
		out_arterial_stiffness = "Arterial Stiffness"
		out_height = "Height (cm)"
		out_bmi = "BMI (kg/m2)"
		out_dia_bp = "Diastolic blood pressure (mmHg)"
		out_sys_bp = "Systolic blood pressure (mmHg)"
		out_intell = "Intelligence (0 to 13)"
		out_happiness = "Happiness (0 to 5 Likert)"
		out_alcohol = "Alcohol consumption (1 low, 5 high)"
		out_sedentary = "Hours watching television"
		out_phys_m_act = "Moderate exercise (days/week)"
		out_phys_v_act = "Vigorous exercise (days/week)");
#delimit cr
graph export "results/figure_6.png", replace as(png)


/*













*/





rm "working data/temp1.dta"
rm "working data/temp2.dta"
rm "working data/temp3.dta"


//Clean the results for Table 4a - the IV results with edu years

clean_iv 1 "results/outcome_IV2_all"
clean_iv 2 "results/outcome_IV2_male"
clean_iv 3 "results/outcome_IV2_female"

use "working data/temp1.dta",clear
append using  "working data/temp2"
append using  "working data/temp3"
order depvar N coef ci_lower ci_upper pval estatp cdf
save "results/table4a",replace

rm "working data/temp1.dta"
rm "working data/temp2.dta"
rm "working data/temp3.dta"

//Clean the observational association of eduyears and the outcome

use "results/outcome_act_exposure2_0",
append using "results/outcome_act_exposure2_1",
append using "results/outcome_act_exposure2_2",
