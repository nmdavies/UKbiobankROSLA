//Neil Davies 01/02/17
//This runs the ROSLA results for the optimal bandwidths
//Includes a time trend that varies either side of the reform.

use "working data/cleaned_biobank_outcomes_ENGLISH" ,clear

//Create post reform month of birth dummies
forvalues i=1(1)12{
	gen post_mob_`i'=mob_I_`i'*post_reform
	}

foreach i in all male female{
	reg out_phys_v_act more_edu_15 rosla rosla_post cov_male mob_I_1-mob_I_10 post_mob_* if rosla^2<12^2 [pweight=weight], cluster(mobi)
	regsave more_edu_15 using "results/optimal_bw_outcome_act_exposure_`i'", replace detail(all) pval ci
		
	reg out_phys_v_act post_reform rosla rosla_post cov_male mob_I_1-mob_I_10 post_mob_* if rosla^2<12^2 [pweight=weight], cluster(mobi)
	regsave  `j' using "results/optimal_bw_outcome_`i'", replace detail(all) pval ci
	}


gen n=_n

//Optimal bandwidths calculated using the CCT method
joinby n using "working data/cct_weights",unmatched(master)

cap prog drop optimal_bw
prog def optimal_bw
	args male num_male
	forvalues i=1(1)25{
		local covars="rosla rosla_post cov_male mob_I_1-mob_I_10 post_mob_* "
		
		local outcome=varname[`i']
		local bandwidth=cct_weights[`i']
		
		di "Outcome: `outcome'"
		di "Male?: `male'"
		di "Bandwidth: `bandwidth'"
		preserve
		keep if male!=`num_male'
		
		reg `outcome' more_edu_15 `covars' if rosla^2<`bandwidth'^2 [pweight=weight], cluster(mobi)
		regsave more_edu_15 using "results/optimal_bw_outcome_act_exposure_`male'", append detail(all) pval ci		
		
		reg `outcome' post_reform  `covars' if more_edu_15!=. & rosla^2<`bandwidth'^2 [pweight=weight], cluster(mobi)
		regsave `j'  using "results/optimal_bw_outcome_`male'", append detail(all) pval ci
		restore
		}
end

optimal_bw all 2
optimal_bw male 0
optimal_bw female 1

use "results/optimal_bw_outcome_all",clear
gen sample="all"
append using "results/optimal_bw_outcome_male"
replace sample="male" if sample==""
append using "results/optimal_bw_outcome_female"
replace sample="female" if sample==""

keep if var=="post_reform"
order sample depvar N coef ci_lower ci_upper pval 

joinby depvar using  "working data/order",unmatched(master)
sort sample n

use "results/optimal_bw_outcome_act_exposure_all",clear
gen sample="all"
drop if _n== _N
append using "results/optimal_bw_outcome_act_exposure_male"
replace sample="male" if sample==""
drop if _n== _N
append using "results/optimal_bw_outcome_act_exposure_female"
replace sample="female" if sample==""
drop if _n== _N
order sample depvar N coef ci_lower ci_upper pval 

joinby depvar using  "working data/order",unmatched(master)
sort sample n
 
//Clean Bandwidth
use "working data/cct_weights",clear
rename varname depvar 
drop n
joinby depvar using  "working data/order",unmatched(master)
sort n

