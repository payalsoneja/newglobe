/******************************************************************************

Capstone Data Visualizations: Difference-in-Difference

Description: Difference-in-difference visualizations of data already collected by NewGlobe's adapted 
TEACH observation tool. For usage for slide deck of visualizations for 
presentation to newglobe.

Hailey Wellenstein
Created: 11/03/2022
Last updated: 11/03/2022
******************************************************************************/

*loading in file and setting working directory
cd "/Users/Hailey/Desktop/Georgetown/Year#2/Capstone"
use "/Users/Hailey/Desktop/Georgetown/Year#2/Capstone/Anonymized file - TEACH data_Updated (1).dta", clear

******************************************************************************
*Overall TEACH
******************************************************************************

egen overall_teach_score = rmean(section2_average section3_average section4_average section5_average section6_average section7_average section8_average section9_average section10_average)

gen treatXend = treatment*endline

reg overall_teach_score treatment endline treatXend
local coef1=_b[treatXend]

graph bar (mean) overall_teach_score, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(medsmall) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Classroom Behavior Difference-in-Difference", size(medsmall)) subtitle("Plot shows averaged scores across all observed behaviors", size(small)) asyvars caption("Improvements of score in the treatment group compared to control suggest a treatment effect of `coef1'", size(tiny))

******************************************************************************
*3 Categories: Classroom culture, socioemotional skills, instruction
******************************************************************************

*classroom culture
egen class_culture = rmean(section2_average section3_average)

reg class_culture treatment endline treatXend
local coef2=_b[treatXend]

graph bar (mean) class_culture, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(medsmall) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Classroom Culture Difference-in-Difference", size(medsmall)) subtitle("Plot shows averaged scores across all 'Classroom Culture' related behaviors", size(small)) asyvars caption("Improvements of score in the treatment group compared to control suggest a treatment effect of `coef2'", size(tiny))

*instruction
egen instruction = rmean(section4_average section5_average section6_average section7_average)

reg instruction treatment endline treatXend
local coef3=_b[treatXend]

graph bar (mean) instruction, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(medsmall) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Teacher Classroom Culture Difference-in-Difference", size(medsmall)) subtitle("Plot shows averaged scores across all 'Instruction' related behaviors", size(small)) asyvars caption("Improvements of score in the treatment group compared to control suggest a treatment effect of `coef3'", size(tiny))

*socioemotional
egen socioemotional = rmean(section8_average section9_average section10_average)

reg socioemotional treatment endline treatXend
local coef4=_b[treatXend]


graph bar (mean) socioemotional, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(medsmall) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(medsmall)) title("Teacher Classroom Culture Difference-in-Difference", size(medsmall)) subtitle("Plot shows averaged scores across all 'Socioemotional Skills' related behaviors", size(small)) asyvars caption("Improvements of score in the treatment group compared to control suggest a treatment effect of `coef4'", size(tiny))


******************************************************************************
*10 sections of behaviors
******************************************************************************
	

forvalues n = 1/10 {
	
local sectionnames: variable label section`n'_average


reg section`n'_average treatment endline treatXend
local coef`n'=_b[treatXend]	
	
graph bar (mean) section`n'_average, over(treatment) bargap(30) over(endline, relabel(1 "Baseline" 2 "Endline")) blabel(bar, size(medsmall) format(%3.2f)) ytitle("Average Teacher Rating", size(medsmall)) yscale(titlegap(*10)) ylabel(1 "Low" 2 "Medium" 3 "High", labsize(small)) title("Difference-in-Difference for `sectionnames'", size(medsmall)) asyvars saving(section_`n', replace) caption("Improvements of score in the treatment group compared to control suggest a treatment effect of `coef`n''", size(tiny))
}
