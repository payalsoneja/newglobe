/**********************************************************************************
 Client: 			NewGlobe
 Project: 			Analysis of the Existing Data
 Purpose: 			This .do cleans the exisiting data produced by NewGlobe's adapted TEACH teacher observation tool and plots the descriptive statistics.
					For usage of client presentation on November 10th, 2022.
 Author: 			Payal Soneja, Hailey Wellenstein, Cuong Pham Vu
 Date:  			10/25/2022
 Updated: 			11/05/2022
**********************************************************************************/

* initialize Stata
clear all
set more off

*install color schemes
ssc install schemepack, replace
set scheme tab2

**************************************************
****** Global and locals you need to modify ******
**************************************************

if c(os)=="MacOSX" {
	gl user "C:\Users\payal\Documents\Georgetown_MIDP\Academics\Capstone\2022-23\Data" //change user
}
else if c(os)=="Windows" { 
	gl user "C:\Users\payal\Documents\Georgetown_MIDP\Academics\Capstone\2022-23\Data"  //change user
}

*Project folder globals
gl raw 		"$user/raw_data"
gl clean 	"$user/clean_data"
gl dofiles 	"$user/$main/do_files"	
gl output 	"$user/output"		
cd 			"$user/$main"


********************************************************************************

				*************************************************************************************
				*****************************  Do File Outline  *************************************
				*************************************************************************************
				* 1. Label variables (if any) by section											*
				* 2. Generate means of 10 sections, 3 core areas and the overall TEACH				*
				* 3. Recode the scores into low, medium and high									*
				* 4. Reshapes data for visualizations
				* 5. Plot the distributions of 10 sections, 3 core areas and the overall TEACH
				* 6. Generate diff-in-diff plots for 10 sections, 3 core areas and overall TEACH	*
				* 7. Combine graphs (wherever necessary) and explort all graphs						*											
********************************************************************************
				
use "$clean/teach_newglobe.dta", clear

*labeling all sections 
label var section1_round_average "Time on Learning"
label var section2_round_average "Support Learning Environment" 
label var section3_round_average "Positive Behavioral Expectation" 
label var section4_round_average "Lesson Facilitation" 
label var section5_round_average "Checks for Understanding" 
label var section6_round_average "Feedback" 
label var section7_round_average"Critical Thinking" 
label var section8_round_average "Autonomy" 
label var section9_round_average "Perseverance" 
label var section10_round_average "Social & Collaborative Skills"

label var section1_average "Time on Learning"
label var section2_average "Support Learning Environment" 
label var section3_average "Positive Behavioral Expectation" 
label var section4_average "Lesson Facilitation" 
label var section5_average "Checks for Understanding" 
label var section6_average "Feedback" 
label var section7_average"Critical Thinking" 
label var section8_average "Autonomy" 
label var section9_average "Perseverance" 
label var section10_average "Social & Collaborative Skills"

**generate a unique id
egen id = group(teacher_id endline)

***************************
*Generating means
***************************

**Generate means of the 3 clusters/areas: 
*Classroom Culture Area
egen area1 = rmean(section2_average section3_average) //change sections here
*Instruction Area
egen area2 = rmean(section4_average section5_average section6_average section7_average) 
*Socioemotional Area
egen area3 = rmean(section8_average section9_average section10_average) 
replace area3 = round(area3, 0.01)

**Generate mean of the overall TEACH score by taking the means of 3 clusters
egen area4 = rmean(area1 area2 area3) // means of areas 1,2,3
replace area4 = round(area4, 0.01)

** define label values for areas
foreach var of varlist area1-area4{
recode `var' (1/1.5=1 "Low") (1.5/2.5=2 "Medium") (2.5/3=3 "High"), gen(`var'_average) label (`var'_average)
}

*label all areas
label var area1 "Classroom Culture"
label var area2 "Instruction"
label var area3 "Socioemotional Skills"
label var area4 "Overall TEACH"

**********************************************************************
*Distributions of the average scores (using non-rounded scores)
**********************************************************************

**We first reshape the data to long format
preserve
	reshape long area@_average, i(id) j(areas)
	label def areas 1 "Classroom Culture" 2 "Instruction" 3 "Socioemotional skills" 4 "Overall"
	label val areas areas

*1. Plot distribution of average scores of the overall score and 3 core areas
	graph bar (count), over(area_average) over(endline, gap(*0.6) relabel(1 "Baseline" 2 "Endline")) over(areas, descending gap(*0.4) label(labsize(small))) ///
	percent stack asyvars ///
	bar(1, color(cranberry)) bar(2, color(dkorange)) bar(3, color(dkgreen)) legend(size(small) rows(1)) ///
	blabel(bar,  position(inside) format(%3.2f) size(vsmall) ytitle(Percent (%)) ///
	title("Distribution of Average Scores of the Overall and Three Core Areas", size(Medium)) subtitle("By Baseline and Endline", size(small)) outergap(*1) 	
	graph export "$output/distribution_overall_areas.png", replace
	
**a dummy code to see the distribution by treatment and time periods
	/*graph bar (count) if treatment == 1, over(area_average) over(endline, gap(*0.7) relabel(1 "Baseline" 2 "Endline")) ///
	over(areas, descending gap(*0.6) label(labsize(small))) ///
	percent stack asyvars ///
	bar(1, color(cranberry)) bar(2, color(dkorange)) bar(3, color(dkgreen)) legend(size(small) rows(1)) ///
	blabel(bar,  position(inside) format(%9.1f) size(small)) ytitle(Percent (%)) ///
	title("Distribution of Average Scores of the Overall and Three Core Areas", size(Medium)) subtitle("By Baseline and Endline", size(small)) outergap(*3) 	
	graph export "$output/distribution_areas.png", replace*/
restore 

*tabplot areas area, showval blcolor(blue) bfcolor(blue*0.2)*

*3. Plot distribution of average scores of the 10 behaviors/practices

**We first reshape the data to long format
preserve
	reshape long section@_round_average, i(id) j(sections)
	label def sections 1 "Time on Learning" 2 "Supportive Learning Environment" 3 "Positive Behavioral Expectation" 4 "Lesson Facilitation" 5 "Checks for Understanding" ///
	6 "Feedback" 7 "Critical Thinking" 8 "Autonomy" 9 "Perseverance" 10 "Social & Collaborative Skills" 
	label val sections sections

levelsof sections, local(levels) 
foreach l of local levels {
	*local z: variable label `l'
	graph bar (count) if sections == `l', over(section_round_average) over(endline, gap(*0.7) relabel(1 "Baseline" 2 "Endline")) over(sections, gap(*0.6) label(labsize(small))) ///
	percent stack asyvars /// 
	bar(1, color(cranberry)) bar(2, color(dkorange)) bar(3, color(dkgreen)) legend(size(small) rows(1)) ///
	blabel(bar, position(inside) format(%3.2f) size(small)) ytitle(Percent (%), size(small)) title("`z'",  size(Medium)) outergap(*9) saving("$output/section`l'", replace)
}
restore

*combine section graphs and export
**Time on Learning
graph combine "$output/section1.gph", ///
title("Distribution of Average Scores of Time on Learning" , size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_time_on_learning.png", replace

**Classroom Culture
graph combine "$output/section2.gph" "$output/section3.gph", ///
title("Distribution of Average Scores of practices under Classroom Culture", size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_classculture.png", replace

**Instruction
graph combine "$output/section4.gph" "$output/section5.gph" "$output/section6.gph" "$output/section7.gph", ///
title("Distribution of Average Scores of practices under Instruction", size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_instruction.png", replace

**Socioemotional Skills
graph combine "$output/section8.gph" "$output/section9.gph" "$output/section10.gph", ///
title("Distribution of Average Scores of practices under Socioemotional Skills", size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_socioemotional.png", replace
	
******************************************************************************
*Difference-in-differences visualizations of the average scores (using non-rounded scores)
******************************************************************************

*geenrate an interaction variable (diff-in-diff estimate) for regression
gen treatXend = treatment*endline
label var treatXend "Treatment*Endline"

*1. Difference-in-differences of the average scores of 3 core areas

**set globals for the basic regression
global outcomes area1 area2 area3 area4
global controls treatment endline treatXend

*run regressions
foreach var in $outcomes {
	local m=1
	reg `var' $controls
	local coef = round(_b[treatXend], .001) 
	
	local z: variable label `var'
	graph bar (mean) `var', over(treatment) bargap(30)  over(endline, relabel(1 "Baseline" 2 "Endline")) ///
	bar(1, color(maroon)) bar(2, color(navy)) legend(size(small) rows(1)) ///
	blabel(bar, format(%3.2f) size(small)) ytitle("Average Teacher Rating", size(small)) ///
	yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Difference-in-Differences for `z'", size(medsmall)) subtitle("Plot shows averaged scores across all observed behaviors", size(small)) asyvars ///
	caption("Improvements of score in the treatment group compared to" "the control group suggest a treatment effect of `coef'", size(small) pos(6)) outergap(*3) 
	*export graph
	graph export "$output/`var'_diff_in_diff.png", replace
}

*2. Difference-in-differences of the average scores of the 10 behaviors/practices

**set globals for the basic regression
forvalues n = 1/10 {
	global outcomes section`n'_average
	global controls treatment endline treatXend

	*run regressions
	foreach var in $outcomes {
	local m=1
	reg `var' $controls
	local coef = round(_b[treatXend], .001) 

	local z: variable label `var'
	graph bar (mean) `var', over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) ///
	bar(1, color(maroon)) bar(2, color(navy)) legend(size(medium) rows(1)) ///
	blabel(bar, format(%3.2f) size(small)) ytitle("Average Teacher Rating", size(medium)) ///
	yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("`z'", size(medsmall)) asyvars ///
	caption("Improvements of score in the treatment group compared to" "the control group suggest a treatment effect of `coef'", size(small) pos(6)) outergap(*3) saving("$output/section`n'_average", replace) 
}
}

*combine section graphs and export
**Time on Learning
graph combine "$output/section1_average.gph", title("Difference-in-Differences for practices under Time on Learning", size(medium)) 
graph export "$output/diff_in_diff_time_on_learning.png", replace

**Classroom Culture
graph combine "$output/section2_average.gph" "$output/section3_average.gph", title("Difference-in-Differences for practices under Classroom Culture", size(medium)) 
graph export "$output/diff_in_diff_classculture.png", replace

**Instruction
graph combine "$output/section4_average.gph" "$output/section5_average.gph" "$output/section6_average.gph" "$output/section7_average.gph", title("Difference-in-Differences for practices under Instruction", size(medium)) 
graph export "$output/diff_in_diff_instruction.png", replace

**Socioemotional Skills
graph combine "$output/section8_average.gph" "$output/section9_average.gph" "$output/section10_average.gph", title("Difference-in-Differences for practices under Socioemotional Skills", size(medium)) 
graph export "$output/diff_in_diff_socioemotional.png", replace
	

	********************************************************************************************************************

