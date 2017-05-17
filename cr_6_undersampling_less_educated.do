//Neil Davies 05/05/17
//Checking the undersampling of the less educated

use "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA/working data/cleaned_biobank_outcomes_ENGLISH.dta"
tab n_6138_0_0
tab born_english
gen out_no_qual=((n_6138_0_0==-7|n_6138_0_0==.) & (n_6138_1_0==-7|n_6138_1_0==.))
tab out_no_qual 
tab n_6138_0_1
sum out_no_qual 
sum out_no_qual  if yob <1962&yob>1947
sum out_no_qual  if yob <1962&yob>1946
tab yob 
gen out_has_degree=(n_6138_0_0==1|n_6138_0_1==1|n_6138_0_2==1|n_6138_0_3==1|n_6138_0_4==1|n_6138_0_5==1|n_6138_1_0==1|n_6138_1_2==1|n_6138_1_3==1|n_6138_1_4==1|n_6138_1_4==1)
tab out_has_degree 
tab less_edu_21 
sum out_has_degree 
doedit
do "/var/folders/0w/0d04q56505n6gvmg0ghq11t80000gn/T//SD99818.000000"
do "/var/folders/0w/0d04q56505n6gvmg0ghq11t80000gn/T//SD99818.000000"
ktab n_20115
tab n_20115
gen born_english_welsh=((n_1647_0_0==1 |n_1647_0_0==2 )& n_20115_0_0==.)
tab born_english_welsh 
tab born_english
keep if born_english_welsh ==1
gen out_no_qual=((n_6138_0_0==-7|n_6138_0_0==.) & (n_6138_1_0==-7|n_6138_1_0==.))
gen out_has_degree=(n_6138_0_0==1|n_6138_0_1==1|n_6138_0_2==1|n_6138_0_3==1|n_6138_0_4==1|n_6138_0_5==1|n_6138_1_0==1|n_6138_1_2==1|n_6138_1_3==1|n_6138_1_4==1|n_6138_1_4==1)
sum out_has_degree 
sum out_no_qual 
sum out_has_degree   out_no_qual if ]
sum out_has_degree   out_no_qual if yob <1962&yob>1946
tab n_34_0_0
sum out_has_degree   out_no_qual if n_34_0_0  <1962& n_34_0_0 >1946
gen out_has_alevels=(n_6138_0_0==2|n_6138_0_1==2|n_6138_0_2==2|n_6138_0_3==2|n_6138_0_4==2|n_6138_0_5==2|n_6138_1_0==2|n_6138_1_2==2|n_6138_1_3==2|n_6138_1_4==2|n_6138_1_4==2)
sum out_has_degree  out_has_alevels  out_no_qual if n_34_0_0  <1962& n_34_0_0 >1946
gen out_alevel_highest=(out_has_alevels ==1& out_has_degree ==0)
sum out_has_degree  out_has_alevels out_alevel_highest  out_no_qual if n_34_0_0  <1962& n_34_0_0 >1946
gen out_has_nvq_profqual=(n_6138_0_0==5|n_6138_0_1==5|n_6138_0_2==5|n_6138_0_3==5|n_6138_0_4==5|n_6138_0_5==5|n_6138_1_0==5|n_6138_1_2==5|n_6138_1_3==5|n_6138_1_4==5|n_6138_1_4==5|n_6138_0_0==6|n_6138_0_1==6|n_6138_0_2==6|n_6138_0_3==6|n_6138_0_4==6|n_6138_0_5==6|n_6138_1_0==6|n_6138_1_2==6|n_6138_1_3==6|n_6138_1_4==6|n_6138_1_4==6)
gen out_has_cse_gcse=(n_6138_0_0==3|n_6138_0_1==3|n_6138_0_2==3|n_6138_0_3==3|n_6138_0_4==3|n_6138_0_5==3|n_6138_1_0==3|n_6138_1_2==3|n_6138_1_3==3|n_6138_1_4==3|n_6138_1_4==3|n_6138_0_0==4|n_6138_0_1==4|n_6138_0_2==4|n_6138_0_3==4|n_6138_0_4==4|n_6138_0_5==4|n_6138_1_0==4|n_6138_1_2==4|n_6138_1_3==4|n_6138_1_4==4|n_6138_1_4==4)
sum out_has_cse_gcse 
gen out_cse_gcse_highest=(out_has_cse_gcse ==1&out_has_degree==0&out_has_alevels==0&out_has_nvq_profqual==0)
sum out_cse_gcse_highest 
gen out_nvq_profqual_highest=(out_has_degree ==0&out_has_alevels ==0&out_has_nvq_profqual ==1)
sum out_nvq_profqual_highest 
sum n_6138*
egen out_miss=rowmin(n_6138*)
tab out_miss 
gen out_missing=(out_miss=-3|out_miss ==.)
gen out_missing=(out_miss==-3|out_miss ==.)
sum out_missing 
tabstat out_has_alevels ,by(out_has_degree )
sum out_missing if n_34_0_0  <1962& n_34_0_0 >1946
tabstat out_has_alevels if n_34_0_0  <1962& n_34_0_0 >1946,by(out_has_degree )
tabstat out_has_cse_gcse  if n_34_0_0  <1962& n_34_0_0 >1946,by(out_has_degree )
