/**********************************************************************************
Georgetown Capstone Project
 Client: 			NewGlobe
 Project: 			Analysis of the Existing Data 
 Purpose: 			This .do cleans the exisiting data produced by NewGlobe's adapted TEACH teacher observation tool and plots the descriptive statistics.
				For usage of client presentation on November 10th, 2022.
 Author: 			Payal Soneja, Hailey Wellenstein, Cuong Pham Vu
 Date:  			10/25/2022
 Updated: 			11/06/2022
**********************************************************************************/

* initialize Stata
clear all
set more off

/*install color schemes
ssc install schemepack, replace
set scheme tab2   // change to newglobe's theme
*/

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
gl raw 			"$user/raw_data"
gl clean 		"$user/clean_data"
gl dofiles 		"$user/$main/do_files"	
gl output 		"$user/output"	
gl regressions 	"$output/regressions"
gl tempgraphs 	"$output/tempgraphs"	
cd 				"$user/$main"

********************************************************************************

				*************************************************************************************
				*****************************  Do File Outline  *************************************
				*************************************************************************************
				* 1. Label variables (if any) by section							*
				* 2. Generate means of 10 sections, 3 core areas and the overall TEACH				*
				* 3. Recode the scores into low, medium and high						*
				* 4. Reshapes data for visualizations								*																
				* 5. Plot the distributions of 10 sections, 3 core areas and the overall TEACH			*
				* 6. Generate diff-in-diff plots for 10 sections, 3 core areas and overall TEACH		*
				* 7. Combine graphs (wherever necessary) and explort all graphs					*
				* 8. Normalizes big four moves scores within districts    					*
				* 9. Plots the distribution of two big four moves by district.					*
				* 10. Plots the mean scores of each big four variable by gender and grades			*
				* 11. Plots the mean scores of each big four variable by treatment (Diff-in-Diff)		*
				
********************************************************************************
				
use "$clean/teach_newglobe.dta", clear

*******************************
*Cleaning for visualizations
*******************************

*label all sections 
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

*generate a unique id
egen id = group(teacher_id endline)

*add label values to endline and female variables for visualizations
label def endline 0 "Baseline" 1 "Endline"
label val endline endline

label def female 0 "Male" 1 "Female"
label val female female

***************************
*Generating means
***************************

**generate means of the 3 clusters/areas: 
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

	levelsof sections, local(sections) 
	local z: value label sections
	foreach l of local sections {
	local x: label `z' `l'
		graph bar (count) if sections == `l', over(section_round_average) over(endline, gap(*0.7) relabel(1 "Baseline" 2 "Endline")) over(sections, gap(*0.6) ///
		label(labsize(small))) percent stack asyvars bar(1, color(cranberry)) bar(2, color(dkorange)) bar(3, color(dkgreen)) legend(size(small) rows(1)) ///
		blabel(bar, position(inside) format(%3.2f) size(vsmall) color) ytitle(Percent (%), size(small)) title("`x'",  size(Medium)) outergap(*9) saving("$tempgraphs/section_`x'", replace)
	}
restore

*combine section graphs and export
**Time on Learning
graph combine "$tempgraphs/section_Time on Learning.gph", ///
title("Distribution of Average Scores of Time on Learning" , size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_time_on_learning.png", replace

**Classroom Culture
graph combine "$tempgraphs/section_Supportive Learning Environment.gph" "$tempgraphs/section_Positive Behavioral Expectation.gph", ///
title("Distribution of Average Scores of practices under Classroom Culture", size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_classculture.png", replace

**Instruction
graph combine "$tempgraphs/section_Lesson Facilitation.gph" "$tempgraphs/section_Checks for Understanding.gph" "$tempgraphs/section_Feedback.gph" "$tempgraphs/section_Critical Thinking.gph", ///
title("Distribution of Average Scores of practices under Instruction", size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_instruction.png", replace

**Socioemotional Skills
graph combine "$tempgraphs/section_Autonomy.gph" "$tempgraphs/section_Perseverance.gph" "$tempgraphs/section_Social & Collaborative Skills.gph", ///
title("Distribution of Average Scores of practices under Socioemotional Skills", size(Medium)) subtitle("By Baseline and Endline", size(small))
graph export "$output/distribution_socioemotional.png", replace
	
******************************************************************************************
*Difference-in-differences visualizations of the average scores (using non-rounded scores)
*******************************************************************************************

*genrate an interaction variable (diff-in-diff estimate) for regression
gen treatXend = treatment*endline
label var treatXend "Treatment*Endline"

*1. Difference-in-differences of the average scores of 3 core areas

**set globals for the basic regression
global outcomes area1 area2 area3 area4
global controls treatment endline treatXend

	**run regressions
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

*set globals for the basic regression
forvalues n = 1/10 {
	global outcomes section`n'_average
	global controls treatment endline treatXend

	**run regressions
	foreach var in $outcomes {
	local m=1
	reg `var' $controls
	local coef = round(_b[treatXend], .001) 

	local z: variable label `var'
	graph bar (mean) `var', over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) ///
	bar(1, color(maroon)) bar(2, color(navy)) legend(size(small) rows(1)) ///
	blabel(bar, format(%3.2f) size(small)) ytitle("Average Teacher Rating", size(medium)) ///
	yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("`z'", size(medsmall)) asyvars ///
	caption("Improvements of score in the treatment group compared to" "the control group suggest a treatment effect of `coef'", size(small) pos(6)) outergap(*3) saving("$tempgraphs/section`n'_average", replace) 
}
}

*combine section graphs and export
**Time on Learning
graph combine "$tempgraphs/section1_average.gph", title("Difference-in-Differences for practices under Time on Learning", size(medium)) 
graph export "$output/diff_in_diff_time_on_learning.png", replace

**Classroom Culture
graph combine "$tempgraphs/section2_average.gph" "$tempgraphs/section3_average.gph", title("Difference-in-Differences for practices under Classroom Culture", size(medium)) 
graph export "$output/diff_in_diff_classculture.png", replace

**Instruction
graph combine "$tempgraphs/section4_average.gph" "$tempgraphs/section5_average.gph" "$tempgraphs/section6_average.gph" "$tempgraphs/section7_average.gph", title("Difference-in-Differences for practices under Instruction", size(medium)) 
graph export "$output/diff_in_diff_instruction.png", replace

**Socioemotional Skills
graph combine "$tempgraphs/section8_average.gph" "$tempgraphs/section9_average.gph" "$tempgraphs/section10_average.gph", title("Difference-in-Differences for practices under Socioemotional Skills", size(medium)) 
graph export "$output/diff_in_diff_socioemotional.png", replace
	
*****************************************************************
*Big Four Moves
*****************************************************************

*rename "big four skills" variables
ren q_13_motivation_pupils q_13
ren q_14_accurate_lessonplan q_14
ren q_15_checking_pupil_performance q_15
ren q_16_respond_pupil_performances q_16

label var q_15 "How well is the teacher checking on pupils"

*normalize big four moves scores within districts
local bfour q_13 q_14 q_15 q_16 // q_13-q_16 practices are the big four moves

foreach j in `bfour'{
	gen `j'_z = 0
}
levelsof lgea_id  // lega_id is district
local district `r(levels)'

* Within each district, calculate the z-score of each big four variable
foreach i in `district' {
	foreach j in `bfour' {
		sum `j' if lgea_id == `i'
		replace `j'_z = (`j' - `r(mean)')/`r(sd)' if lgea_id == `i'
	}
}

*label the normalized "big four moves" variables
label var q_13_z "Motivating students z-score"
label var q_14_z "Using the lesson plan z-score"
label var q_15_z "Checking performance z-score"
label var q_16_z "Responding z-score"

*plot the distribution of two big four moves by district.
global bfour q_13 q_14  // add big four moves variables here
levelsof lgea_id
local district `r(levels)'
	foreach i in `district' {
	foreach var in $bfour {
	kdensity `var' if lgea_id == `i', saving("$tempgraphs/`var'_`i'", replace) xscale(off) title("District `i'", size(small))
	}
	}

**combine section graphs and export
**Distribution of Lesson Plan scores by district
gr combine "$tempgraphs/q_14_109.gph" "$tempgraphs/q_14_190.gph" "$tempgraphs/q_14_271.gph" "$tempgraphs/q_14_352.gph" "$tempgraphs/q_14_433.gph" "$tempgraphs/q_14_514.gph"  "$tempgraphs/q_14_595.gph" "$tempgraphs/q_14_676.gph", title("Distribution of Lesson Plan scores by district", size(medsmall))
graph export "$output/lesson_plan_distribution_district.png", replace

*Distribution of Motivation scores by district
gr combine "$tempgraphs/q_13_109.gph" "$tempgraphs/q_13_190.gph" "$tempgraphs/q_13_271.gph" "$tempgraphs/q_13_352.gph" "$tempgraphs/q_13_433.gph" "$tempgraphs/q_13_514.gph"  "$tempgraphs/q_13_595.gph" "$tempgraphs/q_13_676.gph", title("Distribution of Motivation scores by district", size(medsmall)) 
graph export "$output/motivation_distribution_district.png", replace

*Box plot to see the distribution around the mean for each Big Four Move variable
levelsof endline, local(endline)
local z: value label endline
foreach l of local endline {
local x: label `z' `l'
graph box q_13 q_14 q_15 q_16 if endline == `l' , bargap(30) blabel(bar, size(small) format(%3.2f)) legend(label(1 "Motivation") label(2 "Lesson Plan") label(3 "Checking" "performance") label(4 "Responding")) yscale(r(1 9) titlegap(*10)) ylabel(1(1)9, grid gmin gmax) ytitle("Scale of Score 1-9", size(small)) title("`x'", size(medsmall)) asyvars saving("$tempgraphs/boxplot_`x'", replace)
}

**combine section graphs and export
gr combine "$tempgraphs/boxplot_Baseline.gph" "$tempgraphs/boxplot_Endline.gph", title("Mean Big Four teacher scores by survey round", size(medsmall)) 
graph export "$output/bigfour_mean_baseline_endline.png", replace

*Bar graph showing the mean scores of each big four variable by gender
levelsof endline, local(endline)
local z: value label endline
foreach l of local endline {
local x: label `z' `l'
graph bar (mean) q_13 q_14 q_15 q_16 if endline == `l' , over(female, relabel(1 "Male" 2 "Female")) bargap(30) blabel(bar, size(small) format(%3.2f)) legend(label(1 "Motivation") label(2 "Lesson Plan") label(3 "Checking" "performance") label(4 "Responding") size(vsmall)) yscale(r(1 9) titlegap(*10)) ylabel(1(1)9, grid gmin gmax) ytitle("Mean Teacher Score (1-9)", size(small)) title("`x'", size(medsmall)) saving("$tempgraphs/bigfour_gender_`x'", replace)
}

**combine section graphs and export
gr combine "$tempgraphs/bigfour_gender_Baseline" "$tempgraphs/bigfour_gender_Endline", title("Mean Scores of Big Four Moves by Gender", size(medsmall))
graph export "$output/bigfour_mean_gender.png", replace

*Box plot showing the distribution of each big four variable by grade
preserve
	drop if grade == 0 // drop the nursery grade and focus on grades 1-5, there is only one observation in the nursery grade
	local bfour q_13 q_14 q_15 q_16 // q_13-q_16 practices are the big four moves
	foreach i in `bfour' {
		local z: variable label `i'
		if "`i'" == "q_13" | "`i'" == "q_14" {
			graph box `i', over(grade) bargap(30) blabel(bar, size(small) format(%3.2f)) ytitle("Mean Teacher Score", size(small)) yscale(titlegap(*10)) title("`z'", size(small)) asyvars yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) saving("$tempgraphs/`i'", replace) legend(off)
		}
		
		if "`i'" == "q_15" | "`i'" == "q_16" {
			graph box `i', over(grade) bargap(30) blabel(bar, size(small) format(%3.2f)) ytitle("Mean Teacher Score", size(small)) yscale(titlegap(*10)) title("`z'", size(small)) asyvars yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) saving("$tempgraphs/`i'", replace)
		}
	}
restore

**combine section graphs and export
gr combine "$tempgraphs/q_13" "$tempgraphs/q_14" "$tempgraphs/q_15" "$tempgraphs/q_16", title("Mean Scores of Big Four Moves by Grade", size(medsmall))
graph export "$output/bigfour_grade.png", replace

*Big Four Moves by Treatment level - Difference-in-difference plot
local bfour q_13 q_14 q_15 q_16 // q_13-q_16 practices are the big four moves
foreach i in `bfour' {
	local z: variable label `i'_z
	graph bar (mean) `i'_z, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) ///
	bar(1, color(maroon)) bar(2, color(navy)) legend(size(small) rows(1)) ///
	blabel(bar, size(vsmall) format(%3.2f)) ytitle("Average Teacher Rating", size(small)) yscale(titlegap(*10)) title("`z'", size(medsmall)) asyvars 
	graph export "$output/`i'.png", replace 
}

	*****************************************************************************X**********************************************************************************
