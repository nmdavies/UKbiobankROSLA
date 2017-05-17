//Neil Davies 19/07/16
//This runs the interaction analysis.
//We use the pre-ROSLA data to generate a prediction of propensity to stay in school.
//We expect that individuals who were very likely to remain in school would be relatively unaffected by the reform.


use "working data/cleaned_biobank_outcomes_ENGLISH",clear

//Add in genotyping batch

joinby n_eid using "/Volumes/Height_BMI_and_schooling/UK biobank/raw_data/genotype_PCA_data.dta",unmatched(master)

drop if n_22010_0_0==1|n_22052_0_0==0
drop _m


//Add in ethnicity, rural dummy, and assessment centre

joinby n_eid using "working data/eth_rural_assessment_centre",unmatched(master)

ds cov_male cov_matsmoking  cov_birthweight cov_comp_height8 cov_comp_bodysize8 cov_breastfed cov_num_brothers cov_num_sisters cov_Z_GW_EA2_score cov_rural cov_assess cov_ethnic_minority
foreach i in `r(varlist)'{
	gen miss_`i'=(`i'==.)
	sum `i'
	replace `i'=r(mean) if `i'==.
	}

//Generate interaction
gen int_bw12=bw12*(cov_Z_GW_EA2_score<0)
tab mob, gen(I_mob_)
ds I_mob_* cov_male  cov_batch
foreach i in `r(varlist)'{
	gen I_predict_`i'=(cov_Z_GW_EA2_score<0)*`i'
	}

gen ea_lower=(cov_Z_GW_EA2_score<0)	
	
reg out_phys_v_act  bw12 ea_lower int_bw12 i.mob cov_male I_pred*  cov_batch if more_edu_15!=. & EA_Z_score!=., cluster(cov_assessment_centre)
regsave bw12 ea_lower int_bw12 using "results/INTERACT_ea_grs_outcome", replace detail(all) pval ci 	

test bw12
	
ds out_*
foreach i in `r(varlist)'{
	reg `i' bw12 ea_lower int_bw12 i.mob cov_male I_pred*   cov_batch if more_edu_15!=. & EA_Z_score!=., cluster(cov_assessment_centre)
	regsave bw12 ea_lower int_bw12 using "results/INTERACT_ea_grs_outcome", append detail(all) pval ci 
	}


use "results/INTERACT_ea_grs_outcome", clear


