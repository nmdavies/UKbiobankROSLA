//Neil Davies 08/07/15
//This assesses the balance of covariates across the RD:

cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA"

cap prog drop balance_test
prog def balance_test
use "working data/cleaned_biobank_outcomes_ENGLISH" if male!=`4',clear
keep if male!=`4'
reg cov_male `1' imob_* if `2' , cluster(mob)
regsave `1' using "results/`3'_`5'.dta", replace detail(all) pval ci
ds cov_*
foreach i in `r(varlist)'{
	reg `i' `1' imob_* cov_male if `2' , cluster(mob)
	regsave `1' using "results/`3'_`5'", append detail(all) pval ci
	}
end

local x=2
foreach k in all female male{
	balance_test more_edu_15 "bw12!=." "cov" `x' `k'
	balance_test bw12 "more_edu_15!=." "cov_bw12" `x' `k'
	balance_test N1_bw12 "more_edu_15!=." "cov_N1_bw12" `x' `k'
	balance_test N2_bw12 "more_edu_15!=." "cov_N2_bw12" `x' `k'
	local x=`x'-1
	}
	
//The following code cleans the results

cap prog drop clean_balance_tests
prog def clean_balance_tests
local x=1
foreach i in cov cov_bw12 cov_N1_bw12 cov_N2_bw12{
	use "results/`i'_`1'", clear
	keep depvar N coef ci_lower ci_upper pval
	order depvar N coef ci_lower ci_upper pval
	foreach j in N coef ci_lower ci_upper pval{
		rename `j' `j'_`x'
		}
	drop if _n==1
	gen n=_n
	replace n=0 if n==12
	sort n
	rm "results/`i'_`1'.dta"
	save "results/temp_`1'_`i'",replace
	local x=`x'+1
	}
use "results/temp_`1'_cov"
foreach i in cov_bw12 cov_N1_bw12 cov_N2_bw12{
	joinby n using "results/temp_`1'_`i'"
	rm "results/temp_`1'_`i'.dta"
	}
save "results/table2_`1'",replace
rm "results/temp_`1'_cov.dta"
end

clean_balance_tests all
clean_balance_tests female
clean_balance_tests male

use "results/table2_all",clear
append using "results/table2_male"
append using "results/table2_female"
drop n
drop if inlist(_n, 3,13,15,25,27)


gen n=_n
order n
replace n=32 if n==22
sort n
replace n=22 if n==12
sort n
replace n=12 if n==2
sort n

ds coef_* ci_*
foreach i in `r(varlist)'{
		replace `i'=`i'*100 if inlist(n,32,22,12)
		}
	
	
	
