//Neil Davies 20/10/15
//This creates the genome-wide allele score from the EA2 coefficients.

//First we import all of the data and convert to stata format:

cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA"

forvalues i=1(1)22{
	if `i'<10{
		local i="0`i'"
		}
	import delimited "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA/results/score_`i'.txt.profile", ///
		delimiter(space, collapse) encoding(ISO-8859-1)clear
	keep fid score
	save "working data/genome_wide_EA2_score_`i'",replace
	}
rename score score_22
forvalues i=1(1)21{
	if `i'<10{
		local i="0`i'"
		}
	joinby fid using "working data/genome_wide_EA2_score_`i'",
	rename score score_`i'
	rm "working data/genome_wide_EA2_score_`i'.dta"
	}
	
egen cov_GW_EA2_score=rowtotal(score_*)
keep fid cov_GW_EA2_score
rename fid n_eid
egen cov_Z_GW_EA2_score=std(cov_GW_EA2_score)
save  "working data/genome_wide_EA2_score",replace

