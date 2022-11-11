
cd "/Users/Hailey/Desktop/Georgetown/Year#2/Capstone"
use "clean_data/teach_newglobe.dta", clear


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

********************************************************************************
*Treatment effect visualization
********************************************************************************
*genrate an interaction variable (diff-in-diff estimate) for regression
gen treatXend = treatment*endline
label var treatXend "Treatment*Endline"




***************PAYAL NEW CODE STARTS HERE*******************************
preserve

*keeping only the variables needed for this plot
keep id treatment endline treatXend section10_average section1_average section2_average section3_average section4_average section5_average section6_average section7_average section8_average section9_average

*calculating the treatment effect of each section and saving that value is TESection`n' (treatment effect for seciton n)
forvalues n = 1/10 {
	global outcomes section`n'_average
	global controls treatment endline treatXend
	
	**run regressions

	foreach var in $outcomes {

	local m=1
	reg `var' $controls
	local coef = round(_b[treatXend], .001) 

	gen TESection`n' = `coef'
	
}
}

*reshaping the saved values 
reshape long TE, i(id) j(section) string

*renaming the saved treatment effect variable
rename TE treatmenteffect
label var treatmenteffect "Treatment Effect"

*extracting the number of each section
replace section = substr(section, 1,7) + "_" + substr(section,8,.)
split section, p(_) limit(2)
rename section2 section_final
destring section_final, replace

*using the extracted number of each section to replace that variable with its label 
forvalues n = 1/10 {
	global sects section`n'_average

	foreach var in $sects {
	
	local z: variable label `var'

	replace section = "`z'" if `n' == section_final
	
}
}

*generating the bar plot
graph hbar (mean) treatmenteffect, over(section, sort(1) descending) ytitle("Treatment Effect") blabel(bar, format(%3.2f) size(small))

restore
