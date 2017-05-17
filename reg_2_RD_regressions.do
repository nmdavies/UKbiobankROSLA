//Neil Davies 09/07/15
//This conducts the UK Biobank RD regressions:
cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA/"

//Create program for estimating RD regressions
cap prog drop rd_rosla
prog def rd_rosla
preserve
if "`1'"=="male"{
	keep if male==1
	}
if "`1'"=="female"{
	keep if male==0
	}
rd out_phys_v_act `2' , bw(12) mbw(100 200 300 400 500 600) kernel(rectangle)  cluster(mobi)
regsave using "results/RD_`1'_`2'.dta", replace detail(all) pval ci
ds out_phys_m_act-out_highbloodpressure
foreach i in `r(varlist)'{
	rd `i' `2' , bw(12) mbw(100 200 300 400 500 600) kernel(rectangle)  cluster(mobi)
	regsave using "results/RD_`1'_`2'", append detail(all) pval ci
	}
restore
end

use "working data/cleaned_biobank_outcomes_ENGLISH",clear

foreach j in all male female{
	foreach k in rosla rosla_neg1 rosla_neg2{
		rd_rosla `j' `k'
		}
	}

use "results/RD_all_rosla",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_male_rosla",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_female_rosla",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_all_rosla_neg1",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_male_rosla_neg1",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_female_rosla_neg1",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_all_rosla_neg2",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_male_rosla_neg2",clear
order depvar N coef ci_lower ci_upper pval 

use "results/RD_female_rosla_neg2",clear
order depvar N coef ci_lower ci_upper pval 
