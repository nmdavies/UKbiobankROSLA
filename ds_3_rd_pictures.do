//Neil Davies 08/07/15
//This creates a graphs of the discontinuity

cd "/Volumes/Height_BMI_and_schooling/UK Biobank - ROSLA"

use "working data/cleaned_biobank_outcomes_ENGLISH",clear

*Routine for creating graphics: here `v' represents any variable you wish to look at
*Requires the existing variable cov_male to be renamed

bys rosla cov_male: gen first=_n==1

rename out_highbloodpressure out_highbp

set scheme s2color    
graph set window fontface "Times New Roman"

cap prog drop rd_graph
prog def rd_graph
local x=2
foreach j in all female male{
	egen mean_`2'_`j'=mean(`2') if cov_male!=`x', by(rosla)
	tw 	(sc mean_`2'_`j' rosla if cov_male!=`x' & first==1 & (rosla>=-120 & rosla<=119), msize(small) ylabel(,format(%9.2fc) angle(horizontal))) ///
		(qfit mean_`2'_`j' rosla if cov_male!=`x' & (rosla>=-120 & rosla <=0) , lc(red)) ///
		(qfit mean_`2'_`j' rosla if cov_male!=`x' & (rosla>=0 & rosla <=119) ,lc(red)) , xtitle("Months from September 1957") ytitle("`1'") ///
		leg(off) graphregion(color(white)) saving("results/graph_`2'_`j'", replace ) 
	local x=`x'-1
	graph use "results/graph_`2'_`j'" 
	graph export "results/graph_`2'_`j'.png", replace
	drop mean_*
	}
end


rd_graph "Proportion who left school after age 15" more_edu_15
rd_graph "Average age left full-time education" eduyear
rd_graph "Proportion who have died" out_dead
rd_graph "Proportion with income over £31k" out_income_over_31k
rd_graph "Proportion with diabetes" out_diabetes
rd_graph "Proportion with vascular problems" out_vascular_prob
rd_graph "Average grip strength (pounds)" out_gripstrength
rd_graph "Hours spent watching TV" out_sedentary
rd_graph "Proportion with high blood pressure" out_highbp 
rd_graph "Proportion who have had a stroke" out_stroke
rd_graph "Proportion who have had a heart attack" out_heartattack
rd_graph "Average syst" out_sys_bp

//Generate indicator for no qualifications

forvalues i =0(1)5{
	replace n_6138_0_`i'=n_6138_1_`i' if n_6138_0_`i'==.
	}
	
gen out_no_quals=(n_6138_0_0==-7) if n_6138_0_0!=. &n_6138_0_0!=-3
replace out_no_quals=0 if n_6138_0_1!=. &  n_6138_0_1!=-7 
replace out_no_quals=0 if n_6138_0_2!=. &  n_6138_0_2!=-7
replace out_no_quals=0 if n_6138_1_0>0& n_6138_1_0!=.

rd_graph "Proportion with no qualifications" out_no_qual

