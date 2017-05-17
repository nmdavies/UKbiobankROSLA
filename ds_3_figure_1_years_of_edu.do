//Neil Davies 29/10/15
//This creates a figure that displays the change in educational attainment over time:

cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA"

use "working data/cleaned_biobank_outcomes_ENGLISH",clear

gen out_degree=.
ds n_6138_*
foreach i in `r(varlist)'{
	replace out_degree=1 if `i'==1 & (out_degree==.|out_degree==0)
	replace out_degree=0 if `i'!=-3  & out_degree==. & `i'!=.
	}

foreach i in less_edu_14 less_edu_15 less_edu_16 less_edu_21{
	replace `i'=0 if out_degree==1
	}
	
tabstat less_edu_*, by(year_q) stats(mean n)
