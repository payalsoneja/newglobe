/**********************************************************************************
 Client: 			NewGlobe
 Project: 			Analysis of the Existing Data
 Purpose: 			This .do cleans sets global file paths and runs all .do files to produce visualizations and regression results
					For usage of client presentation on November 10th, 2022.
 Author: 			Payal Soneja, Hailey Wellenstein, Cuong Pham Vu
 Date:  			10/25/2022
 Updated: 			11/05/2022
**********************************************************************************/


********************************************************************************
*								Do-file outline
********************************************************************************

		* 1. Sets global file paths
		* 2. Runs all do-files 
		
********************************************************************************

* initialize Stata
clear all
set more off

*install required stata packages
ssc install schemepack, replace
set scheme tab2

ssc install estout, replace
ssc install asdoc, replace
ssc install xml_tab, replace

**************************************************
****** Global and locals you need to modify ******
**************************************************

**** USERS
* Payal: 			user_number 1
* Hailey:		 	user_number 2
* Cuong:		 	user_number 3
* NewGlobe: 		user_number 4
* Jacobus: 			user_number 5
* Julia:			user_number 6

*SET USER NUMBER

global user_number 3

*-------------------------------------------------------------------------------
**** SET ROOT FILE PATH BY USER   

if $user_number == 1 { 
  global user = "C:\Users\payal\Documents\Georgetown_MIDP\Academics\Capstone\2022-23\Data"
}

if $user_number == 2 { 
  global user = ""
}

if $user_number == 3 { 
  global user = "C:/Users/cuong/Documents/Capstone"
}

if $user_number == 4 {
  global user = "" // NewGlobe Team set your main file path here. This will need to follow the folder structure in the GitHub.
}

if $user_number == 5 {
  global user = "" // Jacobus set your main file path here. This will need to follow the folder structure in the GitHub.
}

if $user_number == 6 {
  global user = "" // Julia set your main file path here. This will need to follow the folder structure in the GitHub.
}


*Project folder globals
gl raw 		"$user/raw_data"
gl clean 	"$user/clean_data"
gl dofiles 	"$user/$main/do_files"	
gl output 	"$user/output"
		gl regressions "$output/regressions"
		gl tempgraphs "$output/tempgraphs"
cd 			"$user/$main"

**************************************************
******************* CLEANING  ********************
**************************************************

do "$dofiles/0. Cleaning for regressions.do"
	// INPUTS: $raw/Anonymized file - TEACH data_Updated.dta
	// OUTPUTS: $clean/teach_clean.dta

**************************************************
************ DESCRIPTIVE ANALYSIS  ***************
**************************************************

do "$dofiles/1. NewGlobe_Descriptive_Statistics.do"
	// INPUTS: $clean/teach_newglobe.dta
	// OUTPUTS: Produces descriptive analysis graphs for overall TEACH scores, individual TEACH sections, and individual TEACH behaviors in output folder
	
do "$dofiles/1. BigFour_Visualizations.do"
	// INPUTS: $clean/teach_clean.dta
	// OUTPUTS: Produces descriptive analysis graphs for data on Big Four moves in output folder
	
**************************************************
************ DIFFERENCE-IN-DIFFERENCE ************
**************************************************

do "$dofiles/2. Regressions.do"
	// INPUTS: $clean/teach_clean.dta
	// OUTPUTS: $regressions/regression_table.xlsx

