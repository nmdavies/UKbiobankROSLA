//Neil Davies 10/11/15
//This creates date of death

use "raw_data/biobank_phenotypes_nmd_150417.dta", clear

//Generate the placebo interventions:

gen yob=n_34_0_0
gen mob=n_52_0_0
gen dob=ym(yob,mob)

gen bw12=0 if dob>=-40 & dob<=-29
replace bw12=1 if dob>=-28 & dob<=-17

forvalues i=1(1)16{
	gen bw12_`i'=0 if dob>=`i'*12-52 & dob<=`i'*12-41
	replace bw12_`i'=1 if dob>=`i'*12-40 & dob<=`i'*12-29
	}
	
forvalues i=1(1)25{
	gen bw12_N`i'=0 if dob>=-`i'*12-28 & dob<=-`i'*12-17
	replace bw12_N`i'=1 if dob>=-`i'*12-16 & dob<=-`i'*12-5
	}

keep n_eid bw12* ts_40000_0_0 ts_40000_1_0 ts_53_0_0 ts_53_1_0

//Clean date of death
replace ts_40000_0_0=ts_40000_1_0 if ts_40000_0_0==.
rename ts_40000_0_0 out_date_death

//Clean date of attending assessment centre
replace ts_53_0_0= ts_53_1_0 if ts_53_0_0 ==.
rename ts_53_0_0 cov_date_assessment
drop ts_40000_1_0 ts_53_1_0
compress
save "working data/placebo_treatments",replace	

use "working data/cleaned_biobank_outcomes_ENGLISH",clear
joinby n_eid using  "working data/placebo_treatments",unmatched(master)

gen exp=bw12_N22

logit out_dead exp i.mob cov_male , cluster(mobi)
regsave exp using "results/mortality_placebo",detail(all) replace pval
	
forvalues i=21(-1)1{
	replace exp=bw12_N`i'
	logit out_dead exp i.mob cov_male , cluster(mobi)
	regsave exp using "results/mortality_placebo",detail(all) append pval
	}

forvalues i=1(1)16{
	replace exp=bw12_`i'
	logit out_dead exp i.mob cov_male , cluster(mobi)
	regsave exp using "results/mortality_placebo",detail(all) append pval
	}

replace out_date_death =19771 if out_date_death ==.	
