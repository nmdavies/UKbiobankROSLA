//Neil Davies 19/07/16
//This runs the interaction analysis.
//We use the pre-ROSLA data to generate a prediction of propensity to stay in school.
//We expect that individuals who were very likely to remain in school would be relatively unaffected by the reform.


use "working data/cleaned_biobank_outcomes_ENGLISH",clear

//Add in ethnicity, rural dummy, and assessment centre

joinby n_eid using "working data/eth_rural_assessment_centre",unmatched(master)

ds cov_male cov_matsmoking  cov_birthweight cov_comp_height8 cov_comp_bodysize8 cov_breastfed cov_num_brothers cov_num_sisters cov_Z_GW_EA2_score cov_rural cov_assess cov_ethnic_minority
foreach i in `r(varlist)'{
	gen miss_`i'=(`i'==.)
	sum `i'
	replace `i'=r(mean) if `i'==.
	}

//Generate interaction with genomic score:
logit more_edu_15 i.yob i.mob cov_male cov_matsmoking cov_birthweight cov_comp_height8 cov_comp_bodysize8 cov_breastfed cov_num_brothers cov_num_sisters cov_Z_GW_EA2_score miss_* cov_ethnic_minority i.cov_ass if bw12==. & rosla<-12 [pweight=weight]

predict predicted_edu

//Generate interaction
gen int_bw12=bw12*predicted_edu
tab mob, gen(I_mob_)
ds I_mob_* cov_male
foreach i in `r(varlist)'{
	gen I_predict_`i'=predicted_edu*`i'
	}

reg out_phys_v_act bw12 predicted_edu int_bw12 i.mob cov_male I_pred* if more_edu_15!=.  [pweight=weight], cluster(cov_assessment_centre)
regsave bw12 predicted_edu int_bw12 using "results/INTERACT_outcome", replace detail(all) pval ci 	

test bw12
	
ds out_*
foreach i in `r(varlist)'{
	reg `i' bw12 predicted_edu int_bw12 i.mob cov_male I_pred* if more_edu_15!=.  [pweight=weight], cluster(cov_assessment_centre)
	regsave bw12 predicted_edu int_bw12 using "results/INTERACT_outcome", append detail(all) pval ci 
	}


use "results/INTERACT_outcome", clear

drop if var=="predicted_edu"
order depvar var N coef ci_lower ci_upper pval 
drop if _n>_N-2

joinby depvar using "working data/order",unmatched(master)


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

sort n var

//Next creating a plot of the interacted effects

mkmat coef ci_lower ci_upper if var=="int_bw12" & binary==1, mat(coef1) rownames(depvar)
mkmat coef ci_lower ci_upper if var=="bw12" & binary==1, mat(coef2) rownames(depvar)

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

