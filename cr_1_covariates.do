//Neil Davies 08/07/15
//This produces Table 1: descriptive statistics for the biobank paper

cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA/"
use "raw_data/biobank_phenotypes_nmd_150417.dta", clear

//Program to combine the fields 0 and 1 for each variable
cap prog drop merge_var
prog def merge_var
replace `1'_0_0=`1'_1_0 if (`1'_0_0==.|`1'_0_0<0 )& (`1'_1_0>0 & `1'_1_0!=.)
end

//Mother and father alive 

merge_var n_1835
merge_var n_1797
gen cov_mother_alive=(n_1835_0_0==1) if  n_1835_0_0>=0& n_1835_0_0!=.
gen cov_father_alive=(n_1797_0_0==1) if n_1797_0_0>=0& n_1797_0_0!=.

//Number of brothers and sisters
merge_var n_1883
merge_var n_1873

gen cov_num_sisters=n_1883_0_0 if n_1883_0_0>=0 & n_1883_0_0!=.
gen cov_num_brothers=n_1873_0_0 if n_1873_0_0>=0 & n_1873_0_0!=.

//Breastfed as a baby
merge_var n_1677
gen cov_breastfed=(n_1677_0_0) if n_1677_0_0>=0 & n_1677_0_0!=.

//Comparative body size and height aged 10
merge_var n_1687
merge_var n_1697
gen cov_comp_bodysize10=1 if n_1687_0_0==1
replace cov_comp_bodysize10=2 if n_1687_0_0==3
replace cov_comp_bodysize10=3 if n_1687_0_0==2

gen cov_comp_height10=1 if  n_1697_0_0==1
replace cov_comp_height10=2 if n_1697_0_0==3
replace cov_comp_height10=3 if n_1697_0_0==2

//Maternal smoking at birth
merge_var n_1787
gen cov_matsmoking=( n_1787_0_0==1) if  n_1787_0_0>=0&  n_1787_0_0!=.

//birth weight
merge_var n_20022
gen cov_birthweight=n_20022_0_0

//Sex
gen cov_male=n_31_0_0
keep n_eid cov_*
compress
save "working data/covariates",replace
