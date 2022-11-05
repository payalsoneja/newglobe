/*******************************************************************************
*																			   *
*  PURPOSE:  			Simple cleaning for visualizations and regressions	   *
*  Last time modified:  November 2022			                               *
*  Author: 						   		  									   *
*																			   *
********************************************************************************

	** Project:		NewGlobe Capstone 2022
	
	** Purpose:		Simple cleaning using Anonymized file - TEACH data_Updated.dta
						
	** Note:   		Folder structure:
						
	** Outputs:	   	$data/teach_clean.dta
 
*/

clear all
global directory "C:/Users/cuong/Documents/Capstone"
global data "$directory/data"
global output "$directory/output"
	global regression "$output/regressions"

use "$data/Anonymized file - TEACH data_Updated.dta"

ren q_15_checking_pupil_performance q_15_checking_pupil_perf
ren q_16_respond_pupil_performances q_16_respond_pupil_perf

ren q_1_1_provide_learn_activity q_1_1_provide_activity

ren q_2_1_treats_respectfully q_2_1_treats_respect
ren q_2_2_positive_language q_2_2_pos_language 
ren q_2_3_teacher_responds_needs q_2_3_teacher_resp_needs 
ren q_2_4_teacher_not_genderbias q_2_4_teacher_no_gbias

label define endline 1 "Endline" 0 "Baseline"
label val endline endline

label define female 1 "Female" 0 "Male"
label val female female

label var q_15_checking_pupil_perf "How well is the teacher checking on pupils"

label var section1_average "Time on Learning"
label var section2_average "Supportive Learning Environment" 
label var section3_average "Positive Behavioral Expectation" 
label var section4_average "Lesson Facilitation" 
label var section5_average "Checks for Understanding" 
label var section6_average "Feedback" 
label var section7_average "Critical Thinking" 
label var section8_average "Autonomy" 
label var section9_average "Perseverance" 
label var section10_average "Social & Collaborative Skills"

// Normalizing big four moves scores within district

local bfour q_13_motivation_pupils q_14_accurate_lessonplan q_15_checking_pupil_perf q_16_respond_pupil_perf

foreach j in `bfour'{
	gen `j'_z = 0
}

levelsof lgea_id 
local district `r(levels)'

foreach i in `district' {
	foreach j in `bfour' {
		sum `j' if lgea_id == `i'
		replace `j'_z = (`j' - `r(mean)')/`r(sd)' if lgea_id == `i'
	}
}

label var q_13_motivation_pupils_z "Motivation z-score"
label var q_14_accurate_lessonplan_z "Lesson Plan z-score"
label var q_15_checking_pupil_perf_z "Checking performance z-score"
label var q_16_respond_pupil_perf_z "Responding z-score"

save "$data/teach_clean.dta", replace