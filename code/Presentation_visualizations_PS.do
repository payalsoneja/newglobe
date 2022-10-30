/**********************************************************************************
 Client: 			NewGlobe
 Project: 			Capstone Data Visualizations for Presentation on 11/1/2022
 Purpose: 			This .do cleans Visualizations of data already collected by NewGlobe's adapted 
					TEACH teacher observation tool. For usage during in-class presentation on November 1st, 2022.
 Author: 			Payal Soneja
 Date:  			10/25/2022
 Updated: 			10/30/2022
**********************************************************************************/

clear all
set more off

*install color schemes
ssc install schemepack, replace
set scheme cblind1

********************************************************************************
*					   * Root folder globals
********************************************************************************

if c(os)=="MacOSX" {
	gl user "C:\Users\payal\Documents\Georgetown_MIDP\Academics\Sem III\PPOL 533 Impact Evaluation for Development\Problem Sets\PS3" //change user
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
label var  section7_round_average"Critical Thinking" 
label var  section8_round_average "Autonomy" 
label var  section9_round_average "Perseverance" 
label var section10_round_average "Social & Collaborative Skills"

label var section2_average "Support Learning Environment" 
label var section3_average "Positive Behavioral Expectation" 
label var section4_average "Lesson Facilitation" 
label var section5_average "Checks for Understanding" 
label var section6_average "Feedback" 
label var  section7_average"Critical Thinking" 
label var  section8_average "Autonomy" 
label var  section9_average "Perseverance" 
label var section10_average "Social & Collaborative Skills"

******************************************************************************
*Overall Distribution of Average Scores for each of the three core areas (use Rounded scores)
******************************************************************************

*Classroom Culture
foreach var of varlist section2_round_average section3_round_average {
	local z: variable label `var'
	graph bar, over(`var') blabel(bar, format(%9.1f) size(small)) ytitle(Percent (%)) title("`z'",  size(Medium)) saving("$output/`var'", replace) scheme(tab2)
}

graph combine "$output/section2_round_average.gph" "$output/section3_round_average.gph", title("Distribution of Scores - Classroom Culture") scheme(tab2)
graph export "$output/distribution_round_scores_class_culture.png", replace

*Instruction
foreach var of varlist section4_round_average section5_round_average section6_round_average section7_round_average {
	local z: variable label `var'
	graph bar if endline == 0, over(`var') blabel(total, format(%9.1f)) ytitle(Percent (%))  title("`z'",  size(Medium)) saving("$output/`var'") scheme(tab3) // use a foreach loop for all practices
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

******************************************************************************
*Difference in difference visualizations (2 per category)
******************************************************************************

*Category 1: Classroom culture
//Section 2: Supportive Learning Environment
graph bar (mean) section2_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(small)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Enabling Supportive Learning Environment", size(medsmall)) asyvars saving("$output/cat1_1", replace) scheme(tab2)

//Section 3: Positive Behavior Expectations
graph bar (mean) section3_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(small)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Setting Positive Behavior Expectations Rating", size(medsmall)) asyvars saving("$output/cat1_2", replace) scheme(tab2)

gr combine "$output/cat1_1.gph" "$output/cat1_2.gph", title("Difference-in-Difference Results for Classroom Culture", size(medsmall)) scheme(tab2)
graph export "$output/did_class_culture.png", replace


*Category 2: Instruction
//Section 5: Checks for Understanding
graph bar (mean) section5_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(small)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Checks for Student Understanding", size(medsmall)) asyvars saving("$output/cat2_1", replace) scheme(tab3) 

//Section 7: Critical Thinking
graph bar (mean) section7_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(small)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Facilitates Student Critical Thinking", size(medsmall)) asyvars saving("$output/cat2_2", replace) scheme(tab3) 

gr combine "$output/cat2_1.gph" "$output/cat2_2.gph", title("Difference-in-Difference Results for Instruction", size(medsmall)) scheme(tab3) 
graph export "$output/did_instruction.png", replace

*Category 3: Socio-Emotional Skills
//Section 9: Perseverance
graph bar (mean) section9_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(small)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Encourages Student Perseverance", size(medsmall)) asyvars saving("$output/cat3_1", replace) scheme(cblind1)


//Section 10: Social and Collaborative Skills
graph bar (mean) section10_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(small)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Promotes Student Social & Collaborative Skills", size(medsmall)) asyvars saving("$output/cat3_2", replace) scheme(cblind1)

gr combine "$output/cat3_1.gph" "$output/cat3_2.gph", title("Difference-in-Difference Results for Socioemotional Skills", size(medsmall)) scheme(cblind1)
graph export "$output/did_socioemotional.png", replace 

********************************************************************************

*Distribution of average scores at Baseline and Endline

label define endline 0 "Baseline" 1 "Endline"
label val endline endline

foreach var of varlist section6_round_average section7_round_average section8_round_average section9_round_average section10_round_average {
	local z: variable label `var'
	graph bar if endline == 0, over(`var') blabel(total, format(%9.1f)) ytitle(Percent (%))  title("`z'",  size(Medium)) saving(`var') // use a foreach loop for all practices
}
	graph bar if endline == 1, over(`var') blabel(total, format(%9.1f)) ytitle(Percent (%))  title("`z'",  size(Medium)) saving(`var') // use a foreach loop for all practices
}
	graph combine section4_round_average.gph section5_round_average.gph section6_round_average.gph section7_round_average.gph, title("Distribution of Scores - Instruction")


*Distribution of average scores for Sections 6-10 practices
*one-way
betterbar section6_average section7_average section8_average section9_average section10_average , barlab xlabel(0(0.5)3) format(%9.2f) legend(off)
graph export "$output/distribution_scores_practices.png", replace

*second way*
preserve
local macro = "section4_average section5_average section6_average section7_average section8_average section9_average section10_average" // add variables
collapse (mean) `macro'
gen id = _n // for reshape purposes
reshape long section@_average, i(id) j(section)
gen category = 1  if inlist(section,4,5,6,7)
replace category = 2 if inlist(section,8,9,10)
label def category 1 "Instruction" 2 "Socioeconomic skills"
label val category category
reshape wide section_average, i(section) j(category)	

rename section_average1 instruction
rename section_average2 socio_economic_skills
label var instruction "Instruction"
label var socio_economic_skills "Socio-Economic Skills"

label def section 4 "Lesson Facilitation" 5 "Checks for Understanding" 6 "Feedback" 7 "Critical Thinking" 8 "Autonomy" 9 "Perseverance" 10 "Social & Collaborative Skills"
label val section section

graph bar instruction socio_economic_skills , by(section) blabel(total, format(%9.1f))

betterbar socio_economic_skills , over(section) barlab xlabel(0(0.5)3) format(%9.2f)

restore

*means of section5-10 practices by Grade
preserve
local macro = "section5_average section6_average section7_average section8_average section9_average section10_average" // add variables
collapse (mean) `macro', by(grade)
drop if grade == 0 | grade == .
reshape long section@_average, i(grade) j(section)
rename section_average Grade
reshape wide Grade, i(section) j(grade)	
gen category = 1  if inlist(section,5,6,7)
replace category = 2 if inlist(section,8,9,10)
label def category 1 "Instruction" 2 "Socioeconomic skills"
label val category category

label var Grade1 "Grade 1"
label var Grade2 "Grade 2"
label var Grade3 "Grade 3"
label var Grade4 "Grade 4"
label var Grade5 "Grade 5"
label var Grade6 "Grade 6"

label def section 5 "Checks for Understanding" 6 "Feedback" 7 "Critical Thinking" 8 "Autonomy" 9 "Perseverance" 10 "Social & Collaborative Skills"
label val section section

graph bar (asis) Grade* ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.1f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Teacher Practices by Grade Level",  size(Medium)) legend(rows(1)) bargap(8) 
graph export "$output/mean_practices_grade.png", replace
*There is no significant difference among teachers responsible for different grade levels in XXX.

*by category
graph bar (asis) Grade* if category == 1 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.1f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Instruction by Grade Level",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/1")
graph bar (asis) Grade* if category == 2 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.1f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Classroom Culture by Grade Level",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/2")

graph combine "$output/1" "$output/2"
graph export "$output/mean_practices_grade_catergory.png", replace

restore

*means of section5-10 practices by T and C
preserve
local macro = "section5_average section6_average section7_average section8_average section9_average section10_average" // add variables
collapse (mean) `macro', by(treatment)
reshape long section@_average, i(treatment) j(section)
reshape wide section_average, i(section) j(treatment)	
gen category = 1  if inlist(section,5,6,7)
replace category = 2 if inlist(section,8,9,10)
label def category 1 "Instruction" 2 "Socioeconomic skills"
label val category category

rename section_average0 control
rename section_average1 treatment
label var control "Control"
label var treatment "Treatment"

label def section 5 "Checks for Understanding" 6 "Feedback" 7 "Critical Thinking" 8 "Autonomy" 9 "Perseverance" 10 "Social & Collaborative Skills"
label val section section

graph bar (asis) treatment control  ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.1f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Teacher Practices by Treatment",  size(Medium)) legend(rows(1)) bargap(8) 
graph export "$output/mean_practices_treatment.png", replace
*There is no significant difference among teachers responsible for different grade levels in XXX.

*by category
graph bar (asis) treatment control if category == 1 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.1f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Instruction by Treatment",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/1_T")

graph bar (asis) treatment control if category == 2 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.1f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Classroom Culture by Treatment",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/2_T")

graph combine "$output/1_T" "$output/2_T"
graph export "$output/mean_practices_treatment_catergory.png", replace

restore


*means of section5-10 practices by Teacher's gender
preserve
local macro = "section5_average section6_average section7_average section8_average section9_average section10_average" // add variables
collapse (mean) `macro', by(female)
reshape long section@_average, i(female) j(section)
reshape wide section_average, i(section) j(female)	
gen category = 1  if inlist(section,5,6,7)
replace category = 2 if inlist(section,8,9,10)
label def category 1 "Instruction" 2 "Socioeconomic skills"
label val category category

rename section_average0 male
rename section_average1 female
label var male "Male"
label var female "Female"

label def section 5 "Checks for Understanding" 6 "Feedback" 7 "Critical Thinking" 8 "Autonomy" 9 "Perseverance" 10 "Social & Collaborative Skills"
label val section section

graph bar (asis) female male  ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.2f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Teacher Practices by Teacher's Gender",  size(Medium)) legend(rows(1)) bargap(8) 
graph export "$output/mean_practices_gender.png", replace

*by category
graph bar (asis) female male if category == 1 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.2f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Instruction by Teacher's Gender",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/1_G")

graph bar (asis) female male if category == 2 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.2f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Classroom Culture by Teacher's Gender",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/2_G")

graph combine "$output/1_G" "$output/2_G"
graph export "$output/mean_practices_gender_catergory.png", replace

*means of section5-10 practices by Subejct Type
preserve
local macro = "section5_average section6_average section7_average section8_average section9_average section10_average" // add variables
collapse (mean) `macro', by(subject_type)
reshape long section@_average, i(subject_type) j(section)
reshape wide section_average, i(section) j(subject_type)	
gen category = 1  if inlist(section,5,6,7)
replace category = 2 if inlist(section,8,9,10)
label def category 1 "Instruction" 2 "Socioeconomic skills"
label val category category

rename section_average0 others
rename section_average1 language
rename section_average2 math

label var other "Others"
label var language "Language"
label var math "Math"

label def section 5 "Checks for Understanding" 6 "Feedback" 7 "Critical Thinking" 8 "Autonomy" 9 "Perseverance" 10 "Social & Collaborative Skills"
label val section section

graph bar (asis) language math others  ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.2f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Teacher Practices by Subject Type",  size(Medium)) legend(rows(1)) bargap(8) 
graph export "$output/mean_practices_sub_type.png", replace

*by category
graph bar (asis) language math others if category == 1 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.2f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Instruction by Subject Type",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/1_S")

graph bar (asis) language math others if category == 2 ,over(section, lab(labsize(vsmall))) blabel(total, format(%9.2f) size(tiny)) ylabel(, labsize(vsmall)) ytitle("Average Score", size(vsmall)) title("Classroom Culture by Subject Type",  size(Medium)) legend(rows(1)) bargap(8) saving("$output/2_S")

graph combine "$output/1_S" "$output/2_S"
graph export "$output/mean_practices_sub_type_catergory.png", replace
