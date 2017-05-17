//Neil Davies 04/11/15
//This creates a figure that compares the OLS to IV results:
cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA/"

use "working data/cleaned_biobank_outcomes_ENGLISH",clear

cap prog drop outcome_figure
prog def outcome_figure
	ds out_*
	foreach i in `r(varlist)'{	
		//Run baseline regressions just using actual schooling (more than 15 years and eduyears):
		reg `i' more_edu_15 i.mob cov_male if bw12!=., cluster(mobi)
		est sto reg_`i'	
		//Instrumental variable regressions			
		ivreg2 `i' (more_edu_15 =post_reform) imob_*  cov_male if bw12!=., endog(more_edu_15) cluster(mobi) partial(imob_* cov_male)
		est sto iv_`i'
		}
end

outcome_figure

//Plot the regression results for the binary outcomes:

coefplot (reg_out_highbloodpressure,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.05) rename(more_edu_15 = "High blood pressure")) (iv_out_highbloodpressure,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.05)  rename(more_edu_15 = "High blood pressure")) ///
		 (reg_out_diabetes,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Diabetes")) (iv_out_diabetes,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Diabetes")) ///
		 (reg_out_stroke,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Stroke")) (iv_out_stroke,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Stroke")) ///
		 (reg_out_heartattack,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Heart attack")) (iv_out_heartattack,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Heart attack")) ///
		 (reg_out_cancer,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Cancer")) (iv_out_cancer,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Cancer")) ///
		 (reg_out_dead,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Died")) (iv_out_dead,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Died")) ///
		 (reg_out_depression,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Depression")) (iv_out_depression,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Depression")) ///
		 (reg_out_exsmoker,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Ex smoker")) (iv_out_exsmoker,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Ex smoker")) ///
		 (reg_out_smoker,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Smoker")) (iv_out_smoker,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Smoker")) /// 
		 (reg_out_income_over_100k,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Income over £100k")) (iv_out_income_over_100k,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Income over £100k")) /// 
		 (reg_out_income_over_52k,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Income over £52k")) (iv_out_income_over_52k,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Income over £52k")) /// 
		 (reg_out_income_over_31k,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Income over £31k")) (iv_out_income_over_31k,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Income over £31k")) /// 
		 (reg_out_income_over_18k,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5)) offset(0.1)   rename(more_edu_15 = "Income over £18k")) (iv_out_income_over_18k,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Income over £18k")) /// 		 
		 , xline(0) byopts(yrescale) legend(off) xtitle("Difference in absolute risk of outcome") graphregion(color(white))

//Plot the regression results for the continuous outcomes:

coefplot (reg_out_gripstrength,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Grip strength")) (iv_out_gripstrength,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10))  offset(-0.1)  rename(more_edu_15 = "Grip strength")) ///
		 (reg_out_arterial_stiffness,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Arterial stiffness")) (iv_out_arterial_stiffness,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Arterial stiffness")) ///
		 (reg_out_height,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Height")) (iv_out_height,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Height")) ///
		 (reg_out_bmi,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "BMI")) (iv_out_bmi,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "BMI")) ///
		 (reg_out_dia_bp,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Diastolic blood pressure")) (iv_out_dia_bp,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Diastolic blood pressure")) ///
		 (reg_out_sys_bp,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Systolic blood pressure")) (iv_out_sys_bp,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Systolic blood pressure")) ///
		 (reg_out_intell,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Intelligence")) (iv_out_intell,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Intelligence")) ///
		 (reg_out_happiness,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Happiness")) (iv_out_happiness,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Happiness")) ///
		 (reg_out_alcohol,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Alcohol consumption")) (iv_out_alcohol,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Alcohol consumption")) ///
		 (reg_out_sedentary,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Hours watching TV")) (iv_out_sedentary,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Hours watching TV")) ///
		 (reg_out_phys_m_act,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Moderate exercise")) (iv_out_phys_m_act,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Moderate exercise")) ///
		 (reg_out_phys_v_act,keep(more_edu_15) ms(S) mc(gs5) ciopts(lc(gs5))  offset(0.1)   rename(more_edu_15 = "Vigorous exercise")) (iv_out_phys_v_act,keep(more_edu_15) ms(T) mc(gs10) ciopts(lc(gs10)) offset(-0.1)  rename(more_edu_15 = "Vigorous exercise")) ///
		 ,  xline(0) byopts(yrescale) legend(off) xtitle("Mean difference in outcomes") graphregion(color(white))
	 
		 
		 /*
		 (reg_out_phys_m_act,keep(more_edu_15) ms(S) mc(gs5)  offset(0.1)   rename(more_edu_15 = "Moderate physical exercise")) (iv_out_phys_m_act,keep(more_edu_15) ms(T) mc(gs10) offset(-0.1)  rename(more_edu_15 = "Moderate physical exercise")) ///
		 (reg_out_phys_v_act,keep(more_edu_15) ms(S) mc(gs5)  offset(0.1)   rename(more_edu_15 = "Vigorous physical exercise")) (iv_out_phys_v_act,keep(more_edu_15) ms(T) mc(gs10) offset(-0.1)  rename(more_edu_15 = "Vigorous physical exercise")) ///
		 (reg_out_alcohol,keep(more_edu_15) ms(S) mc(gs5)  offset(0.1)   rename(more_edu_15 = "Alcohol consumption")) (iv_out_alcohol,keep(more_edu_15) ms(T) mc(gs10) offset(-0.1)  rename(more_edu_15 = "Alcohol consumption")) ///
		  (reg_out_phys_v_act,keep(more_edu_15) ms(S) mc(gs5)  offset(0.1)   rename(more_edu_15 = "Vigorous physical exercise")) (iv_out_phys_v_act,keep(more_edu_15) ms(T) mc(gs10) offset(-0.1)  rename(more_edu_15 = "Vigorous physical exercise")) ///
		 (reg_out_phys_v_act,keep(more_edu_15) ms(S) mc(gs5)  offset(0.1)   rename(more_edu_15 = "Vigorous physical exercise")) (iv_out_phys_v_act,keep(more_edu_15) ms(T) mc(gs10) offset(-0.1)  rename(more_edu_15 = "Vigorous physical exercise")) ///
		 (reg_out_phys_v_act,keep(more_edu_15) ms(S) mc(gs5)  offset(0.1)   rename(more_edu_15 = "Vigorous physical exercise")) (iv_out_phys_v_act,keep(more_edu_15) ms(T) mc(gs10) offset(-0.1)  rename(more_edu_15 = "Vigorous physical exercise")) ///
		 (reg_out_phys_v_act,keep(more_edu_15) ms(S) mc(gs5)  offset(0.1)   rename(more_edu_15 = "Vigorous physical exercise")) (iv_out_phys_v_act,keep(more_edu_15) ms(T) mc(gs10) offset(-0.1)  rename(more_edu_15 = "Vigorous physical exercise")) ///
		  */,  xline(0) byopts(yrescale) legend(off) xtitle("Mean difference in outcomes") graphregion(color(white))
		  
		 out_phys_v_act out_phys_m_act out_sedentary out_alcohol out_happiness out_intell out_sys_bp out_dia_bp out_bmi out_height out_arterial_stiffness out_gripstrength 
		 
		 
		 
		 
		 
