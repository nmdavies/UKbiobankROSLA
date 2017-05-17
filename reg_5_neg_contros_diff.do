//Neil Davies 09/05/16
//This tests whether the differences found in the negative control populations are bigger than the ROSLA differences

cap prog drop rolsa_neg_diff
prog def rolsa_neg_diff
	
	use "working data/cleaned_biobank_outcomes_ENGLISH" if male!=`1',clear
	
	//Create indicators for each cohort:

	gen cohort1=(N1_bw12==0)
	gen cohort2=(N1_bw12==1)
	gen cohort3=(N2_bw12==0)
	gen cohort4=(N2_bw12==1)

	//Run baseline regressions to create results file
	reg out_phys_v_act  cohort*  i.mob cov_male if (bw12!=.|N1_bw12!=.|N2_bw12!=.), cluster(mobi) nocons

	//Test for difference between the coefficients:
	test cohort2-cohort1=cohort3-cohort2
	local neg_1_het_test=r(p)
	
	test cohort4-cohort3=cohort3-cohort2
	local neg_2_het_test=r(p)
	
	regsave  cohort*  using "results/outcome_rolsa_neg_diff_`2'", replace detail(all) pval ci ///
		addvar(neg_1_het_test,`neg_1_het_test',0,neg_2_het_test,`neg_2_het_test',0)
	
	
	//Repeat these regression for all the other outcomes:
	ds out_*
	foreach i in `r(varlist)'{
		logit `i'  cohort*  i.mob cov_male if (bw12!=.|N1_bw12!=.|N2_bw12!=.), cluster(mobi) nocons
		
		//Test for difference between the coefficients:
		test cohort2-cohort1=cohort3-cohort2
		local neg_1_het_test=r(p)
	
		test cohort4-cohort3=cohort3-cohort2
		local neg_2_het_test=r(p)
		
		test cohort2-cohort1=cohort3-cohort2=cohort4-cohort3
		local neg_combined_het_test=r(p)
		
		regsave cohort*  using "results/outcome_rolsa_neg_diff_`2'", append detail(all) pval ci	///
		addvar(neg_1_het_test,`neg_1_het_test',0,neg_2_het_test,`neg_2_het_test',0,neg_combined_het_test,`neg_combined_het_test',0)		
		
		}
	
	local 2 all
	use "results/outcome_rolsa_neg_diff_`2'.dta",clear 
	order depvar
	drop if substr(var,1,4)=="coho"
	replace stderr=coef[_n+1] if var=="neg_1_het_test"
	replace pval=coef[_n+2] if var=="neg_1_het_test"
	drop if var!="neg_1_het_test"
	keep depvar coef stderr pval
	rename stderr neg_2_het_test
	rename coef neg_1_het_test
	rename pval neg_combined_het_test
	drop if neg_combined_het_test==.
	save "results/clean_outcome_rolsa_neg_diff_`2'.dta",replace
	
end

rolsa_neg_diff 2 all
rolsa_neg_diff 1 female
rolsa_neg_diff 0 male

