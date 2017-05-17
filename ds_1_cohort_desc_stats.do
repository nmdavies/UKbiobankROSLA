//Neil Davies 08/07/15
//This creates the descriptive statistics for Table 1 and supp tables 2 & 3

cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA"

use "working data/cleaned_biobank_outcomes_ENGLISH",clear

order cov_male cov_birthweight  cov_comp_height8 cov_comp_bodysize8  cov_num_brothers cov_num_sisters 

//Binary covariates
tabstat cov_male cov_matsmoking cov_breastfed cov_father_alive cov_mother_alive if bw12!=. & more_edu_15!=.,stats(n sum mean sd min max) c(s) save

//Continuous covariates
tabstat cov_birthweight cov_num_brothers cov_num_sisters cov_Z_GW_EA2_score if bw12!=. & more_edu_15!=.,stats(n sum mean sd min max) c(s) save

//Binary co-morbidities
tabstat out_highbloodpressure out_diabetes out_stroke out_heartattack out_cancer out_dead out_exsmoker out_smoker out_income_over_100k ///
 	out_income_over_52k out_income_over_31k out_income_under_18k ///
 	if bw12!=. & more_edu_15!=.,stats(n sum mean sd min max) c(s) save

//Continuous covariates
tabstat  out_gripstrength out_arterial_stiffness out_height out_bmi out_dia_bp out_sys_bp out_intell out_happiness out_alcohol ///
	 out_sedentary out_phys_m_act out_phys_v_act ///
	if bw12!=. & more_edu_15!=.,stats(n sum mean sd min max) c(s) save



