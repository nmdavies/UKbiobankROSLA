//Neil Davies 13/02/17
//This calculates the frequency of type of mortality by age

//Copy in mortality rate for those aged 40-44 for Clark and Royer

bys var3: egen total=total(var6)

drop var6 var4
duplicates drop

egen Total=total(total)
sort total

gen cancer=0

drop if total==0

replace cancer = 1 in 4
replace cancer = 1 in 5
replace cancer = 1 in 6
replace cancer = 1 in 9
replace cancer = 1 in 13
replace cancer = 1 in 17
replace cancer = 1 in 23
replace cancer = 1 in 24
replace cancer = 1 in 25
replace cancer = 1 in 26
replace cancer = 1 in 27
replace cancer = 1 in 34
replace cancer = 1 in 35
replace cancer = 1 in 39

egen total_cancer=total(total) if cancer==1
gen per_death=total/Total
replace per_death=per_death*100
format per_death %9.2f

//Copy in 2008 cause of death for 40-65 year olds
bys var3: egen total=total(var6)

drop var6 var4 var5
duplicates drop

egen Total=total(total)
sort total

gen cancer=0

drop if total==0

replace cancer = 1 in 4
replace cancer = 1 in 5
replace cancer = 1 in 6
replace cancer = 1 in 9
replace cancer = 1 in 13
replace cancer = 1 in 17
replace cancer = 1 in 23
replace cancer = 1 in 24
replace cancer = 1 in 25
replace cancer = 1 in 26
replace cancer = 1 in 27
replace cancer = 1 in 34
replace cancer = 1 in 35
replace cancer = 1 in 39

egen total_cancer=total(total) if cancer==1
gen per_death=total/Total
replace per_death=per_death*100
format per_death %9.2f
