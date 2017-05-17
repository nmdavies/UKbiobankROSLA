//Neil Davies 10/03/2016
//This merges the height and BMI data and the socioeconomic outcomes with the height and BMI allele scores


use "raw_data/Biobank_phenotypes_NMD_150417.dta", clear

//Program to combine the fields 0 and 1 for each variable
cap prog drop merge_var
prog def merge_var
local x=`2'+10000
if `x'==10000{
	replace `1'_0_0=`1'_1_0 if (`1'_0_0==.|`1'_0_0<0 )& (`1'_1_0>0 & `1'_1_0!=.)
	}
else{
	replace `1'_0_`2'=`1'_1_`2' if (`1'_0_`2'==.|`1'_0_`2'<0 )& (`1'_1_`2'>0 & `1'_1_`2'!=.)
	}
end

//Gen indicator for months and year of birth
gen year_month_birth=100*n_34_0_0+n_52_0_0
tab year_month_birth

//CLEANING HEIGHT AND BMI:

//Anthropometry
merge_var n_21001
merge_var n_50
merge_var n_20015

//Gen height and BMI variables
gen out_bmi=n_21001_0_0
gen out_height=n_50_0_0

/*
//don't need to exclude individual with height sitting height (no GWAS data) 
gen height_sitting_ratio=n_20015_0_0/out_height
*/

//Covariates
//age, sex, assessment centre location, five (within UK) ancestry principal components, 
//and microarray used to measure genotypes.

//Gender
gen cov_male=n_31_0_0

//Age
merge_var n_21003 
gen cov_age=n_21003_0_0

//Assessment centre location
tab n_54_0_0, gen(cov_assessment_centre_)

//Five genetic principal components
joinby n_eid using "raw_data/biobank_genotype_supp_NMD_150417",unmatched(master)

forvalues i=1(1)5{
	rename n_22009_0_`i' cov_gen_pca_`i'
	}

//Microarray
gen cov_axiom=(n_22000_0_0>0)

//Generate the outcomes:
//Has degree or not
forvalues i=0(1)5{
	merge_var n_6138 `i'
	}

gen out_degree=(n_6138_0_0==1) if n_6138_0_0!=.

//Gen years of education

merge_var n_845
gen out_educ_wrong=n_845_0_0 if n_845_0_0>0
gen out_educ_right=n_845_0_0 if n_845_0_0>0
replace  out_educ_right=21 if out_degree==1

//Gen income
merge_var n_738
gen out_income=18 if n_738_0_0==1
replace out_income=(18+31)*0.5 if n_738_0_0==2
replace out_income=(31+52)*0.5 if n_738_0_0==3
replace out_income=(52+100)*0.5 if n_738_0_0==4
replace out_income=(100) if n_738_0_0==5

//Negative control outcomes
//Gen breastfed
merge_var n_1677
gen out_breastfed=(n_1677_0_0==1) if n_1677_0_0>=0 & n_1677_0_0!=.

//Gen exposed to smoke in utero
merge_var n_1787
gen out_smoke_preg=(n_1787_0_0==1) if n_1787_0_0>=0 & n_1787_0_0!=.

//************************************
//SAMPLE SELECTION
//************************************

//Initial sample =152,249
//Exclude 182 individuals with inconsistent gender and sex
drop if  n_22001_0_0 !=cov_male

//Remaining sample =152,067
//Exclude 31,781 non-European individuals
drop if   n_22006_0_0 !=1

//Remaining sample =120,286
//Drop 325 individuals missing BMI or height
drop if out_bmi ==.|out_height ==.

joinby n_eid using "working data/height_score"
joinby n_eid using "working data/bmi_score"

//Normalisation

cap prog drop normalise
prog def normalise
args var
reg `var' cov_age cov_male cov_ass* cov_axiom cov_gen_pca_*
predict `var'_hat,res
egen z_`var'=std(`var'_hat)

egen rank = rank(`var'_hat)
su `var'_hat, meanonly 
gen inv_rank_`var' = invnormal((rank - 0.5) / r(N)) 
drop rank
drop z_`var' `var'_hat
end

ds  out_*
foreach i in `r(varlist)'{
	normalise `i'
	}

keep n_eid out_* cov_* inv_* *_score

compress

save "working data/tyrell_replication",replace

