/******************************************************************************

Capstone Data Visualizations for Presentation on 11/1/2022

Description: Visualizations of data already collected by NewGlobe's adapted 
TEACH teacher observation tool. For usage during in-class presentation on November
1st, 2022.

Hailey Wellenstein
Created: 10/21/22
Last updated: 10/28/22
******************************************************************************/
*loading in file and setting working directory
cd "/Users/Hailey/Desktop/Georgetown/Year#2/Capstone"
use "/Users/Hailey/Desktop/Georgetown/Year#2/Capstone/Anonymized file - TEACH data_Updated (1).dta", clear

******************************************************************************
*set graphics preferences
set graphics on
set scheme cblind1

******************************************************************************
*Difference in difference visualizations (2 per category)
******************************************************************************

*Category 1: Classroom culture
//Section 2: Supportive Learning Environment
graph bar (mean) section2_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Enabling Supportive Learning Environment", size(medsmall)) asyvars saving(cat1_1, replace)

//Section 3: Positive Behavior Expectations
graph bar (mean) section3_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Setting Positive Behavior Expectations Rating", size(medsmall)) asyvars saving(cat1_2, replace)

gr combine cat1_1.gph cat1_2.gph, title("Difference-in-Difference Results for Classroom Culture", size(medsmall))



*Category 2: Instruction
//Section 5: Checks for Understanding
graph bar (mean) section5_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Checks for Student Understanding", size(medsmall)) asyvars saving(cat2_1, replace)

//Section 7: Critical Thinking
graph bar (mean) section7_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Facilitates Student Critical Thinking", size(medsmall)) asyvars saving(cat2_2, replace)

gr combine cat2_1.gph cat2_2.gph, title("Difference-in-Difference Results for Checks for Understanding", size(medsmall))



*Category 3: Socio-Emotional Skills
//Section 9: Perseverance
graph bar (mean) section9_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Encourages Student Perseverance", size(medsmall)) asyvars saving(cat3_1, replace)


//Section 10: Social and Collaborative Skills
graph bar (mean) section10_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Promotes Student Social and Collaborative Skills", size(medsmall)) asyvars saving(cat3_2, replace)

gr combine cat3_1.gph cat3_2.gph, title("Difference-in-Difference Results for Socio-Emotional Skills", size(medsmall))

********************************************************************************
*Focusing on the least score practices (critical thinking and social/collaborative skills)
********************************************************************************



*1. Critical thinking

//GENDER: baseline vs. endline section rating by gender and treatment
graph bar (mean) section7_average, over(treatment) over(female, relabel(1 "Male"  2 "Female")) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Differences in 'Teacher Facilitates Student Critical Thinking' by Gender", size(medsmall) span)

//GRADE: baseline vs. endline section rating by grade
gen section7_base = section7_average if endline == 0
gen section7_end = section7_average if endline == 1
preserve
drop if grade == 0
graph dot section7_base section7_end, over(grade, label(labsize(vsmall))) over(treatment, label(labsize(small))) title("Differences in Teacher Enables Student Critical Thinking", size(medlarge) span) subtitle("Teachers are rated on their facilitation of 'Critical Thinking' on a 3-point scale of low to high.", size(vsmall) span) legend(label(1 "Baseline") label(2 "Endline")) ylabel(1 2 3) exclude0
restore

//SUBJECT: 
graph bar (mean) section7_average, over(treatment, label(labsize(vsmall))) bargap(50) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(vsmall) format(%3.2f)) by(subject_type, title("Teacher Facilitates Student Critical Thinking", size(medium))) ytitle(Time Spent Learning Rating) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(vsmall)) asyvars
	
	
	
	
*2. Social Collaborative Skills
//GENDER: baseline vs. endline section rating by gender and treatment
graph bar (mean) section10_average, over(treatment) over(female, relabel(1 "Male"  2 "Female")) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(small) format(%3.2f)) ytitle("Average Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Differences in 'Teacher Promotes Student Social and Collaborative Skills' by Gender", size(medsmall) span)

//GRADE: baseline vs. endline section rating by grade
gen section10_base = section10_average if endline == 0
gen section10_end = section10_average if endline == 1
preserve
drop if grade == 0
graph dot section10_base section10_end, over(grade, label(labsize(vsmall))) over(treatment, label(labsize(small))) title("Differences in 'Teacher Promotes Student Social and Collaborative Skills' by Grade", size(medlarge) span) subtitle("Teachers are rated on their facilitation of 'Social/Collaborative Skills' on a 3-point scale of low to high.", size(vsmall) span) legend(label(1 "Baseline") label(2 "Endline")) ylabel(1 2 3) exclude0
restore

//SUBJECT: 
graph bar (mean) section7_average, over(treatment, label(labsize(vsmall))) bargap(50) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(vsmall) format(%3.2f)) by(subject_type, title("Teacher Promotes Student Social and Collaborative Skills", size(medium))) ytitle(Time Spent Learning Rating) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(vsmall)) asyvars
	

