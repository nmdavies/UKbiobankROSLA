//Neil Davies 27/10/16
//This runs the bandwidth selection analysis on the UK Biobank data with the negative control exposures


use "working data/cleaned_biobank_outcomes_ENGLISH",clear
	
	
/* 

The column labeled “RF” presents reduced-form estimates including a linear function of month-year of birth, a linear interaction 
of month-year of birth and the relevant reform dummy, a third-order polynomial in age (mea- sured in months) and dummy variables
 for sex, survey, year of survey, month of survey, and month of birth. For the 1972 reform, the month-of-birth dummies are allowed to differ on either side of the reform threshold.

1. Linear function of month-year of birth
2. Linear interaction of month-year of birth and reform dummy
3. Third-order polynomial in age
4. Sex
5. Survey
6. Year of survey
7. Month of survey
8. Month of birth
9. Interaction of month of birth and reform dummy 
 
*/

//Gen interaction of rosla and reform
replace rosla_i=rosla*post_reform

//Gen third order poly nomial in age
gen cov_age3=(2008-yob)^3
	
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
rd out_phys_v_act `2' , mbw(100 200 300 400 500 600) kernel(rectangle)  cluster(mobi) cov(mob cov_male rosla rosla_i cov_age3 male imob_*)
//regsave using "results/RD_cov_`1'_`2'.dta", replace detail(all) pval ci
//ds out_phys_m_act-out_highbloodpressure

ds cov_mother_alive cov_father_alive cov_num_brothers cov_breastfed cov_comp_bodysize8 cov_comp_height8 cov_matsmoking cov_birthweight
foreach i in `r(varlist)'{
	rd `i' `2' , bw(12) mbw(100 200 300 400 500 600) kernel(rectangle)  cluster(mobi) cov(mob cov_male)
	//regsave using "results/RD_cov_`1'_`2'", append detail(all) pval ci
	}
restore

end

rd_rosla 

