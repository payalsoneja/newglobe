/**********************************************************************************
 Client: 			NewGlobe
 Project: 			Analysis of Existing Data
 Purpose: 			This .do cleans generates regression_table.xlsx
					For usage of client presentation on November 10th, 2022.
 Author: 			Payal Soneja, Hailey Wellenstein, Cuong Pham Vu
 Date:  			10/25/2022
 Updated: 			11/05/2022
**********************************************************************************/


********************************************************************************
*								Do-file outline
********************************************************************************

		* 1. Sets up table for each section of the survey
		* 2. Produces regression results for each tables
		* 3. Saves each table into a sheet and export to regression_table.xlsx
		
********************************************************************************

clear all

use "$clean/teach_clean.dta"

// Setting up regression tables

gen treatend = treatment*endline // generate interaction variable 
label var treatend "DID estimate"

local table big_four_moves time_on_learning supportive_learning_environment positive_behavioral_expectation lesson_facilitation checks_for_understanding feedback critical_thinking autonomy perseverance social_collaborative_skills
// Putting each section as table into a local to loop over

// Defining outcome variables for each table
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
	// local for regression specification without controls
	
	local panelB female subject_type number_pupils_attendance grade treatment endline treatend
	// local for regression specification with additional teacher-level controls
	
	// Panel A
	
	est clear

	foreach outcome in `outcomevars' {

	eststo: reg `outcome' `panelA', vce(cluster school_id) // cluster SEs at school level

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

	eststo: reg `outcome' `panelB', vce(cluster school_id) // cluster SEs at school level

	*calculate control mean
	sum `outcome' if treatment == 0 & endline == 1 // endline control means for comparison
	estadd scalar control = `r(mean)'

	*add note if additional controls used
	estadd local controls "Yes"
	
	}
	
	esttab using "$regressions/`table'.csv", append b(2) se(2) label star(* 0.10 ** 0.05 *** 0.01) nomtitles nonumbers se ar2 drop(_cons) refcat(female "Panel B", nolabel) scalars(control controls) stats(N r2_a control controls, labels ("Obs" "Adjusted R-Squared" "Mean Dep. Var in control group" "Additional controls added") fmt(%9.0fc %9.2fc)) nonotes
	
}
	
// Put each regression result in XLSX, each in separate sheet 
//-----------------------------------------------------------

// import the .csvs back in
foreach file in "big_four_moves" "time_on_learning" "supportive_learning_environment" "positive_behavioral_expectation" "lesson_facilitation" "checks_for_understanding" "feedback" "critical_thinking" "autonomy" "perseverance" "social_collaborative_skills" {
	preserve
	import delimited  "$regressions/`file'.csv", stripquotes(yes) delimiters(",") clear 
	list, clean noobs
	foreach var of varlist * {
		replace `var' = substr(`var', 2, length(`var'))
	}
	
	// export back into .xlsx
	export excel using "$regressions/regression_table.xlsx", missing("") sheetmodify sheet("`file'")
	
	rm "$regressions/`file'.csv"
	
	restore
	
}