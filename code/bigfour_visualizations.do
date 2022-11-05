/*******************************************************************************
*																			   *
*  PURPOSE:  			Create visualizations								   *
*  Last time modified:  November 2022			                               *
*  Author: 						   		  									   *
*																			   *
********************************************************************************

	** Project:		NewGlobe Capstone 2022
	
	** Purpose:		Create visualizations Anonymized file - TEACH data_Updated.dta
						
	** Note:   		Folder structure:
						
	** Outputs:	   	$output/regression_tables.xlsx
					graphs in $output
 
*/

clear all
global directory "C:/Users/cuong/Documents/Capstone"
global data "$directory/data"
global output "$directory/output"
	global regression "$output/regressions"

use "$data/teach_clean.dta"

local bfour q_13_motivation_pupils q_14_accurate_lessonplan q_15_checking_pupil_perf q_16_respond_pupil_perf

levelsof lgea_id

local district `r(levels)'

foreach i in `district' {
	
	kdensity q_14_accurate_lessonplan if lgea_id == `i', scheme(tab2) saving($output/tempgraphs/q_14_accurate_lessonplan_`i', replace) title("") xscale(off) title("District `i'", size(small))
	
	kdensity q_13_motivation_pupils if lgea_id == `i', scheme(tab2) saving($output/tempgraphs/q_13_motivation_pupils_`i', replace) title("") xscale(off) title("District `i'", size(small))
	
}


gr combine "$output/tempgraphs/q_14_accurate_lessonplan_109" "$output/tempgraphs/q_14_accurate_lessonplan_190" "$output/tempgraphs/q_14_accurate_lessonplan_271" "$output/tempgraphs/q_14_accurate_lessonplan_352" "$output/tempgraphs/q_14_accurate_lessonplan_433" "$output/tempgraphs/q_14_accurate_lessonplan_514"  "$output/tempgraphs/q_14_accurate_lessonplan_595" "$output/tempgraphs/q_14_accurate_lessonplan_676", title("Distribution of Lesson Plan scores by district", size(medsmall)) scheme(cblind1)

graph export "$output/lesson_plan_distribution_district.png", replace

gr combine "$output/tempgraphs/q_13_motivation_pupils_109" "$output/tempgraphs/q_13_motivation_pupils_190" "$output/tempgraphs/q_13_motivation_pupils_271" "$output/tempgraphs/q_13_motivation_pupils_352" "$output/tempgraphs/q_13_motivation_pupils_433" "$output/tempgraphs/q_13_motivation_pupils_514"  "$output/tempgraphs/q_13_motivation_pupils_595" "$output/tempgraphs/q_13_motivation_pupils_676", title("Distribution of Motivation scores by district", size(medsmall)) scheme(cblind1)

graph export "$output/motivation_distribution_district.png", replace


preserve 

drop if endline == 1

graph box q_13_motivation_pupils q_14_accurate_lessonplan q_15_checking_pupil_perf q_16_respond_pupil_perf, bargap(30) blabel(bar, size(small) format(%3.2f)) legend(label(1 "Motivation") label(2 "Lesson Plan") label(3 "Checking performance") label(4 "Responding")) yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) ytitle("", size(vsmall)) title("Baseline", size(medsmall)) asyvars scheme(tab2) saving($output/tempgraphs/bigfour_mean_b, replace)

restore

preserve

drop if endline == 0

graph box q_13_motivation_pupils q_14_accurate_lessonplan q_15_checking_pupil_perf q_16_respond_pupil_perf, bargap(30) blabel(bar, size(small) format(%3.2f)) legend(label(1 "Motivation") label(2 "Lesson Plan") label(3 "Checking performance") label(4 "Responding")) yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) ytitle("", size(small)) title("Endline", size(medsmall)) asyvars scheme(tab2) saving($output/tempgraphs/bigfour_mean_e, replace)

restore

gr combine "$output/tempgraphs/bigfour_mean_b" "$output/tempgraphs/bigfour_mean_e", title("Mean Big Four teacher scores by survey round", size(medsmall)) scheme(tab2)

graph export "$output/bigfour_mean.png", replace

preserve

drop if endline == 1

graph bar (mean) q_13_motivation_pupils q_14_accurate_lessonplan q_15_checking_pupil_perf q_16_respond_pupil_perf, over(female) bargap(30) blabel(bar, size(small) format(%3.2f)) legend(label(1 "Motivation") label(2 "Lesson Plan") label(3 "Checking performance") label(4 "Responding")) yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) ytitle("Mean teacher score (1-9)", size(small)) title("Baseline", size(medsmall)) scheme(tab2) saving($output/tempgraphs/bigfour_gender_b, replace)

restore

preserve

drop if endline == 0

graph bar (mean) q_13_motivation_pupils q_14_accurate_lessonplan q_15_checking_pupil_perf q_16_respond_pupil_perf, over(female) bargap(30) blabel(bar, size(small) format(%3.2f)) legend(label(1 "Motivation") label(2 "Lesson Plan") label(3 "Checking performance") label(4 "Responding")) yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) title("Endline", size(medsmall)) scheme(tab2) saving($output/tempgraphs/bigfour_gender_e, replace)

restore

gr combine "$output/tempgraphs/bigfour_gender_b" "$output/tempgraphs/bigfour_gender_e", title("Mean big four scores by gender", size(medsmall)) scheme(cblind1)

graph export "$output/bigfour_gender.png", replace

preserve

drop if grade == 0

foreach i in `bfour' {
	local z: variable label `i'
	
	if "`i'" == "q_13_motivation_pupils" | "`i'" == "q_14_accurate_lessonplan" {
		graph box `i', over(grade) bargap(30) blabel(bar, size(small) format(%3.2f)) ytitle("Mean Teacher Score", size(small)) yscale(titlegap(*10)) title("`z'", size(small)) asyvars scheme(tab2) yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) saving($output/tempgraphs/`i', replace) legend(off)
	}
	
	if "`i'" == "q_15_checking_pupil_perf" | "`i'" == "q_16_respond_pupil_perf" {
		graph box `i', over(grade) bargap(30) blabel(bar, size(small) format(%3.2f)) ytitle("Mean Teacher Score", size(small)) yscale(titlegap(*10)) title("`z'", size(small)) asyvars scheme(tab2) yscale(r(1 9)) ylabel(1(1)9, grid gmin gmax) saving($output/tempgraphs/`i', replace)
	}
}


gr combine "$output/tempgraphs/q_13_motivation_pupils" "$output/tempgraphs/q_14_accurate_lessonplan" "$output/tempgraphs/q_15_checking_pupil_perf" "$output/tempgraphs/q_16_respond_pupil_perf", title("Mean teacher scores for big four moves by grade", size(medsmall)) scheme(cblind1)

graph export "$output/bigfour_grade.png", replace

restore

foreach i in `bfour' {
	local z: variable label `i'_z
	graph bar (mean) `i'_z, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(vsmall) format(%3.2f)) ytitle("Mean Teacher Score", size(small)) yscale(titlegap(*10)) title("`z'", size(medsmall)) asyvars scheme(cblind1)
	graph export "$output/`i'.png", replace 
}
