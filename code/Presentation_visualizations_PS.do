/**********************************************************************************
 Client: 			NewGlobe
 Project: 			Capstone Data Visualizations for Presentation on 11/1/2022
 Purpose: 			This .do cleans Visualizations of data already collected by NewGlobe's adapted 
					TEACH teacher observation tool. For usage during in-class presentation on November 1st, 2022.
 Author: 			Payal Soneja
 Date:  			10/25/2022
 Updated: 			11/03/2022
**********************************************************************************/

* initialize Stata
clear all
set more off

/*install color schemes
ssc install schemepack, replace
set scheme tab2*/

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

use "$clean/teach_newglobe.dta", clear

*labeling sections 
label var section2_round_average "Support Learning Environment" 
label var section3_round_average "Positive Behavioral Expectation" 
label var section4_round_average "Lesson Facilitation" 
label var section5_round_average "Checks for Understanding" 
label var section6_round_average "Feedback" 
label var section7_round_average"Critical Thinking" 
label var section8_round_average "Autonomy" 
label var section9_round_average "Perseverance" 
label var section10_round_average "Social & Collaborative Skills"

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
egen area1 = rmean(section2_round_average section3_round_average)
*Instruction Area
egen area2 = rmean(section4_round_average section5_round_average section6_round_average section7_round_average) 
*SocioEmotional Area
egen area3 = rmean(section8_round_average section9_round_average section10_round_average) 
replace area3 = round(area3, 0.01)

**Generate mean of the overall TEACH score by taking the means of 3 clusters
egen overall = rmean(area1 area2 area3) // means of areas 1,2,3
replace overall = round(overall, 0.01)

**recode the average scores to low, medium, and high categories
foreach var of varlist area1-area3 overall {
recode `var' (1/1.5=1 "Low") (1.5/2.5=2 "Medium") (2.5/3=3 "High"), gen(`var'_round_average) label (`var'_round_average)
}

label area1 ""

**********************************************************************
*Distributions of the average scores (using Rounded scores)
**********************************************************************

**We first reshape the data to long format
preserve
	reshape long area@_round_average, i(id) j(areas)
	label def areas 1 "Classroom Culture" 2 "Instruction" 3 "Socioeconomic skills"
	label val areas areas
	
*1. Plot distribution of the overall score (using Rounded scores)
	graph bar (count), over(overall_round_average) over(endline, relabel(1 "Baseline" 2 "Endline")) percent stack asyvars  ///
	bar(1, color(cranberry)) bar(2, color(dkorange)) bar(3, color(dkgreen)) legend(size(small) rows(1)) ///
	blabel(bar,  position(inside) format(%9.1f) size(small)) ///
	ytitle(Percent (%)) title("Distribution of Average Overall Score", size(Medium)) subtitle("By Baseline and Endline", size(small)) outergap(*9) graphregion(color(white))
	graph export "$output/distribution_overall.png", replace

*2. Plot distribution of average scores of the 3 core areas
	*plot distribution
	graph bar (count), over(area_round_average) over(endline, gap(*0.7) relabel(1 "Baseline" 2 "Endline")) over(areas, gap(*0.6) label(labsize(small))) ///
	percent stack asyvars ///
	bar(1, color(cranberry)) bar(2, color(dkorange)) bar(3, color(dkgreen)) legend(size(small) rows(1)) ///
	blabel(bar,  position(inside) format(%9.1f) size(small)) ytitle(Percent (%)) title("Distribution of Average Scores for the Three Core Areas", size(Medium)) ///
	subtitle("By Baseline and Endline", size(small))outergap(*3)
	graph export "$output/distribution_areas.png", replace
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
	blabel(bar, position(inside) format(%9.1f) size(small)) ytitle(Percent (%)) title("`z'",  size(Medium)) outergap(*9)saving("$output/`l'", replace)
}
	
graph combine "$output/section2_round_average.gph" "$output/section3_round_average.gph", ///
title("Distribution of Average Scores by Baseline and Endline") subtitle("Classroom Culture")
graph export "$output/distribution_class_culture.png", replace

*Instruction
foreach var of varlist section4_round_average section5_round_average section6_round_average section7_round_average {
	local z: variable label `var'
	graph bar , over(`var') blabel(total, format(%9.1f)) ytitle(Percent (%))  title("`z'",  size(Medium)) saving("$output/`var'", replace) scheme(tab3) // use a foreach loop for all practices
}
	graph combine "$output/section4_round_average.gph" "$output/section5_round_average.gph" "$output/section6_round_average.gph" "$output/section7_round_average.gph", title("Distribution of Scores - Instruction") scheme(tab3)
	graph export "$output/distribution_round_scores_instruction.png", replace

// 15% of the teachers were rated as "Low" for section 5 practice

*Socioemotional skills
foreach var of varlist section8_round_average section9_round_average section10_round_average {
	local z: variable label `var'
	graph bar, over(`var') blabel(total, format(%9.1f)) ytitle(Percent (%)) title("`z'",  size(Medium)) saving("$output/`var'") scheme(cblind1)
}

graph combine "$output/section8_round_average.gph" "$output/section9_round_average.gph" "$output/section10_round_average.gph", title("Distribution of Scores - Socioemotional Skills") scheme(cblind1)
graph export "$output/distribution_round_scores_socioemotional.png", replace
