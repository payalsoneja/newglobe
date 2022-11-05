/*******************************************************************************
*																			   *
*  PURPOSE:  			Produce regression tables for all teacher behaviors	   *
*  Last time modified:  November 2022			                               *
*  Author: 						   		  									   *
*																			   *
********************************************************************************

	** Project:		NewGlobe Capstone 2022
	
	** Purpose:		Produce regression tables for all teacher behaviors using Anonymized file - TEACH data_Updated.dta
					This code creates a table for each section of the survey and imports them as separate sheets in the regression_tables.xlsx. It also provides a framework that produces regression tables in word format for easier formatting. 
						
	** Note:   		Folder structure:
						
	** Outputs:	   	$output/regression_tables.xlsx
					graphs in $output
 
*/


clear all
global directory "C:/Users/cuong/Documents/Capstone"
global data "$directory/data"
global output "$directory/output"
	global regressions "$output/regressions"
	
use "$data/teach_clean.dta"

// Setting up regression tables



gen treatend = treatment*endline
label var treatend "DID estimate"

local table big_four_moves time_on_learning supportive_learning_environment positive_behavioral_expectation lesson_facilitation checks_for_understanding feedback critical_thinking autonomy perseverance social_collaborative_skills

foreach table in `table' {
	
	if "`table'" == "big_four_moves" {
		local outcomevars q_13_motivation_pupils_z q_14_accurate_lessonplan_z q_15_checking_pupil_perf_z q_16_respond_pupil_perf_z
		local title "Table 0: Big Four moves"
		local controls
	}
	
	if "`table'" == "time_on_learning" {
		local outcomevars q_1_1_provide_activity q_1_2_pupil_ontask 				section1_average section1_round_average 
		local title "Table 1: Time on learning"
		local controls
	}
	
	if "`table'" == "supportive_learning_environment" {
		local outcomevars q_2_1_treats_respect q_2_2_pos_language  q_2_3_teacher_resp_needs q_2_4_teacher_no_gbias section2_average section2_round_average
		local title "Table 2: Supportive learning environment"
		local controls
	}
	
	if "`table'" == "positive_behavioral_expectation" {
		local outcomevars q_3_1_clear_behave_expectation q_3_2_acknowledge_positive_pupil q_3_3_focus_expected_behaviour section3_average section3_round_average
		local title "Table 3: Positive behavioral expectations"
		local controls
	}
	
	if "`table'" == "lesson_facilitation" {
		local outcomevars q_4_1_articulate_lessn_objective q_4_2_content_clarity q_4_3_connection_in_lessons q_4_4_teacher_enacting section4_average section4_round_average
		local title "Table 4: Lesson facilitation"
		local controls
	}
	
	if "`table'" == "checks_for_understanding" {
		local outcomevars q_5_1_determine_understanding q_5_2_teacher_moniter_pupils q_5_3_adjust_teaching section5_average section5_round_average
		local title "Table 5: Checks for understanding"
		local controls
	}
	
	if "`table'" == "feedback" {
		local outcomevars q_6_1_clarify_misunderstanding q_6_2_identify_pupil_success section6_average section6_round_average
		local title "Table 6: Feedback"
		local controls
	}
	
	if "`table'" == "critical_thinking" {
		local outcomevars q_7_1_ask_openended_ques q_7_2_provide_thinking_task q_7_3_pupil_perform_thinkingtask section7_average section7_round_average
		local title "Table 7: Critical thinking"
		local controls
	}
	
	if "`table'" == "autonomy" {
		local outcomevars q_8_1_teacher_provide_choices q_8_2_provide_pupil_opportunity q_8_3_pupil_volenteer section8_average section8_round_average
		local title "Table 8: Autonomy"
		local controls
	}
	
	if "`table'" == "perseverance" {
		local outcomevars q_9_1_acknowledge_pupil_effort q_9_2_positive_attitute q_9_3_encourage_goal_setting section9_average section9_round_average
		local title "Table 9: Perseverance"
		local controls
	}
	
	if "`table'" == "social_collaborative_skills" {
		local outcomevars q_10_1_promote_collaboration q_10_2_promote_pupil_skills q_10_3_Pupils_collaborate section10_average section10_round_average
		local title "Table 10: Social and collaborative skills"
		local controls
	}
	
	local panelA treatment endline treatend
	
	local panelB female subject_type number_pupils_attendance grade treatment endline treatend
	
	// Panel A
	
	est clear

	foreach outcome in `outcomevars' {

	eststo: reg `outcome' `panelA', vce(cluster school_id)

	*calculate control mean
	sum `outcome' if treatment == 0 & endline == 1 // endline control means for comparison
	estadd scalar control = `r(mean)'

	*add note if additional controls used
	estadd local controls "No"
	
	}
	
	
	esttab using "$regressions/`table'.csv", replace b(2) se(2) label star(* 0.10 ** 0.05 *** 0.01) se ar2 drop(_cons) refcat(treatment "Panel A", nolabel) interaction(" & ") title("`title'") scalars(control controls) stats(N r2_a control controls, labels ("Obs" "Adjusted R-Squared" "Mean Dep. Var in control group" "Additional controls added") fmt(%9.0fc %9.2fc)) nonotes

	// Panel B 
	
	est clear

	foreach outcome in `outcomevars' {

	eststo: reg `outcome' `panelB', vce(cluster school_id)

	*calculate control mean
	sum `outcome' if treatment == 0 & endline == 1 // endline control means for comparison
	estadd scalar control = `r(mean)'

	*add note if additional controls used
	estadd local controls "Yes"
	
	}
	
	esttab using "$regressions/`table'.csv", append b(2) se(2) label star(* 0.10 ** 0.05 *** 0.01) nomtitles nonumbers se ar2 drop(_cons) refcat(female "Panel B", nolabel) scalars(control controls) stats(N r2_a control controls, labels ("Obs" "Adjusted R-Squared" "Mean Dep. Var in control group" "Additional controls added") fmt(%9.0fc %9.2fc)) nonotes
	
}
	
*Put each regression result in XLSX, each in separate sheet 
*-----------------------------------------------------------

*import the .csvs back in
foreach file in "big_four_moves" "time_on_learning" "supportive_learning_environment" "positive_behavioral_expectation" "lesson_facilitation" "checks_for_understanding" "feedback" "critical_thinking" "autonomy" "perseverance" "social_collaborative_skills" {
	preserve
	import delimited  "$regressions/`file'.csv", stripquotes(yes) delimiters(",") clear 
	list, clean noobs
	foreach var of varlist * {
		replace `var' = substr(`var', 2, length(`var'))
	}
	
	*export back into .xlsx
	export excel using "$regressions/regression_table.xlsx", missing("") sheetmodify sheet("`file'")
	
	rm "$regressions/`file'.csv"
	
	restore
	
}


// Word version for regression tables

asdoc reg q_13_motivation_pupils_z treatment endline treatend, vce(cluster school_id) label nest save(big four regressions.rtf) replace add(Controls, No) cnames(Motivation z-score)
asdoc reg q_13_motivation_pupils_z treatment endline treatend female subject_type number_pupils_attendance grade, vce(cluster school_id) label nest save(big four regressions.rtf) append add(Controls, Yes) drop(female subject_type number_pupils_attendance grade) cnames(Motivation z-scores)

foreach var in q_14_accurate_lessonplan_z q_15_checking_pupil_perf_z q_16_respond_pupil_perf_z {
	local z: variable label `var'
	asdoc reg `var' treatment endline treatend, vce(cluster school_id) label nest save(big four regressions.rtf) append add(Controls, No) cnames(`z')
	asdoc reg `var' treatment endline treatend female subject_type number_pupils_attendance grade, vce(cluster school_id) label nest save(big four regressions.rtf) append add(Controls, Yes) drop(female subject_type number_pupils_attendance grade) cnames(`z')
}

asdoc reg section1_average treatment endline treatend female subject_type number_pupils_attendance grade, vce(cluster school_id) label nest save(section 1-5 score regressions.rtf) replace drop(female subject_type number_pupils_attendance grade) add(Controls, Yes) cnames(Time on Learning)

forvalues i = 2(1)5 {

	local z: variable label section`i'_average

	asdoc reg section`i'_average treatment endline treatend female subject_type number_pupils_attendance grade, vce(cluster school_id) label nest save(section 1-5 score regressions.rtf) append drop(female subject_type number_pupils_attendance grade) add(Controls, Yes) cnames(`z')
}

asdoc reg section6_average treatment endline treatend female subject_type number_pupils_attendance grade, vce(cluster school_id) label nest save(section 6-10 score regressions.rtf) replace drop(female subject_type number_pupils_attendance grade) add(Controls, Yes) cnames(Feedback)

forvalues i = 7(1)10 {

	local z: variable label section`i'_average
	
	asdoc reg section`i'_average treatment endline treatend female subject_type number_pupils_attendance grade, vce(cluster school_id) label nest save(section 6-10 score regressions.rtf) append drop(female subject_type number_pupils_attendance grade) add(Controls, Yes) cnames(`z')
}