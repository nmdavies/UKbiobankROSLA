//Neil Davies 08/06/16
//This creates an indicator for birth month in the UK Biobank data
//This runs the sensitivity analyses using an identical specification to Clark and Royer Table 4.
//They also include an interaction between between the reform and month of birth.
//The local linear models run by Clark and Royer were reg outcome post_reform post_rosla rosla month2-month12 post_month2-post_month12 

global ols_covariates = "mob_I_1-mob_I_12"
global iv_covariates = "mob_I_1-mob_I_12 int_mob_I_2-int_mob_I_12"

global exposure = ""
global bandwidth = 47

cap prog drop reduced_form
prog def reduced_form
args gender gender_desc
	
	use "working data/cleaned_biobank_outcomes_ENGLISH" if male!=`gender',clear
	
	gen int_mob=post_reform*mob
	gen int_rosla=post_reform*rosla

	tab int_mob, gen(int_mob_I_)
	
	//Run baseline regressions just using actual schooling (more than 15 years):
	reg out_phys_v_act more_edu_15 ${ols_covariates} if (rosla)^2>(${bandwidth})^2, cluster(mobi)
	regsave more_edu_15 using "results/EA_Z_IV_outcome_act_exposure_`gender_desc'", replace detail(all) pval ci
	
	//Reduced form
	reg out_phys_v_act post_reform ${iv_covariates} if (rosla)^2>(${bandwidth})^2, cluster(mobi)
	regsave post_reform using "results/EA_Z_IV_outcome_reduced_form_`gender_desc'", replace detail(all) pval ci

	//Instrumental variable regressions			
	ivreg2 out_phys_v_act (more_edu_15= EA_Z_score) ${iv_covariates} if (rosla)^2>(${bandwidth})^2, endog(more_edu_15) cluster(mobi) partial(${iv_covariates})
	regsave more_edu_15 using "results/EA_Z_IV_outcome_IV_`gender_desc'", replace detail(all) pval ci
	
	//Repeat these regression for all the other outcomes:
	ds out_*
	foreach i in `r(varlist)'{
		reg `i' more_edu_15 ${ols_covariates} if (rosla)^2>(${bandwidth})^2, cluster(mobi)
		regsave more_edu_15 using "results/EA_Z_IV_outcome_act_exposure_`gender_desc'", append detail(all) pval ci		
		
		reg `i' post_reform ${iv_covariates} if (rosla)^2>(${bandwidth})^2, cluster(mobi)
		regsave  post_reform using "results/EA_Z_IV_outcome_reduced_form_`gender_desc'", append detail(all) pval ci
		
		ivreg2 `i' (more_edu_15= EA_Z_score) ${iv_covariates} if (rosla)^2>(${bandwidth})^2, endog(more_edu_15) cluster(mobi) partial(${iv_covariates}) nocollin 
		regsave more_edu_15 using "results/EA_Z_IV_outcome_IV_`gender_desc'", append detail(all) pval ci
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
duplicates drop
foreach j in N coef ci_lower ci_upper pval{
	rename `j' `j'_`1'
	}
save "working data/temp`1'.dta",replace
end

foreach j in male female all{
	clean 1 "results/CR_outcome_act_exposure_`j'"
	clean 2 "results/CR_outcome_reduced_form_`j'"
	use "working data/temp1.dta",clear
	rm "working data/temp1.dta"
	forvalues i=2(1)2{
		sleep 100
		joinby n using "working data/temp`i'.dta", unmatched(both)
		tab _m
		drop _m
		//rm "working data/temp`i'.dta"
		}
	drop n

	save "results/CR_table3_`j'_reduced_form",replace
	}

use "results/CR_table3_all_reduced_form",clear
gen type=1
append using "results/CR_table3_male_reduced_form"
replace type=2 if type==.
append using "results/CR_table3_female_reduced_form"
replace type=3 if type==.
joinby depvar using "working data/var_output_order.dta",unmatched(both)

sort type order
duplicates drop
save "results/CR_table3",replace

rm "results/CR_table3_all_reduced_form.dta"
rm "results/CR_table3_male_reduced_form.dta"
rm "results/CR_table3_female_reduced_form.dta"

//Clean IV results for Table 4
cap prog drop clean_iv
prog def clean_iv
use "`2'",clear
keep depvar N coef ci_lower ci_upper pval estatp cdf
gen n=_n
order depvar N coef ci_lower ci_upper pval
drop if _n==_N
save "working data/temp`1'.dta",replace
end


clean_iv 1 "results/CR_outcome_IV_all"
clean_iv 2 "results/CR_outcome_IV_male"
clean_iv 3 "results/CR_outcome_IV_female"

use "working data/temp1.dta",clear
gen type=1
append using  "working data/temp2"
replace type=2 if type==.
append using  "working data/temp3"
replace type=3 if type==.
joinby depvar using "working data/var_output_order.dta",unmatched(both)

order depvar N coef ci_lower ci_upper pval estatp cdf

sort type order
duplicates drop
save "results/CR_table4",replace

rm "working data/temp1.dta"
rm "working data/temp2.dta"
rm "working data/temp3.dta"

