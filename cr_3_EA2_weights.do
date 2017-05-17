//Neil Davies 08/10/15
//This creates the weights from the EA2 data

use "Documents/EduYears_pooled_Nweighted_excl_23andMe_singleGC.meta.dta",clear
keep rsid allele1 allele2 beta
compress 
joinby rsid using "/Volumes/Height_BMI_and_schooling/UK biobank/raw_data/EA2_rsids.dta"
drop chr
gen a=_n
save "raw_data/EA2_snp_weights.dta",replace

