//Neil Davies 26/01/17
//This estimates the optimal bandwidth using the Calonico, Cattaneo and Titunik for each outcome


use "working data/cleaned_biobank_outcomes_ENGLISH" if male!=`gender',clear

ds out_*
foreach i in `r(varlist)'{
	rdbwselect `i' rosla
	}
