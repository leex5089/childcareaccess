*Creating probability density of families with children under age 5 using block level 2010 Census & block-group, tract level 2011-2015 ACS
*data used in this process are extracted from https://www.nhgis.org (data and codebooks available at "G:\My Drive\MinnCCAccess\Analysis\PDG\Data"
*technical explanation on how the probability density is derived can be found at pages 53-56 of IZA paper at http://ftp.iza.org/dp11396.pdf

*The summary of the procedure can be descired in 6 distinct steps.
*Step 1: using tract level ACS data, calculate joint density of family by categorical-poverty status, by race
*Step 2: using block-group level ACS data, calculate joint density of family by binary-poverty status
*Step 3: Combine data created in steps 1 and 2, and calculate joint density of family by categorical-poverty status, by race, down to the block-group level
*Step 4: using block level Census data, calculate joint density of family by race
*Step 5: Combine data created in steps 3 and 4, and calculate joint density of family by categorical-poverty status, by race, down to the block level
*Step 6: using family density from step 5, randomly populate families (points) within each blocks using tools from ArcGIS and GSM
**Step 6.a. open the "synth_HH_25pct_sample_block_level.csv" in Arcgis, merge to the block-level map (the map should have been processed so that it parsed out inhibitable areas such as river, lake, state parks, etc) save as shapefile.
**Step 6.b. open the shapefile with density information in Geospatial Modelling Tool (download and install from http://www.spatialecology.com/gme/)  
/*In GSM tool, use stratarandompoints function to randomly populate synth families within each block.
Using the density information, each synthetic family points can have race and income status assigned to them (or depending on your need, you can select
variables of your interest from ACS data).*/

*define working directory 
global directory G:\My Drive\MinnCCAccess\Analysis\PDG\Data\ // set your own working directory.


clear all

*============================================================================================================*    
*Step 1: using tract level ACS data, calculate joint density of family by categorical-poverty status, by race*
*============================================================================================================* 
import delimited "${directory}\nhgis0110_ds216_20155_2015_tract.csv", clear //data extracted from https://www.nhgis.org/
drop if statea !=27 //keep the state you want (27 is MN)
egen total_families=total( ad42e001 ) //  counts of total number of families in the state
egen total_families_u5=rowtotal(ad2ne005 ad2ne006 ad2ne012 ad2ne013  ad2ne018 ad2ne019 ad2ne025 ad2ne026 ad2ne032 ad2ne033 ad2ne038 ad2ne039 ad2ne045 ad2ne046 ad2ne052 ad2ne053  ad2ne058 ad2ne059  ad2ne065 ad2ne066 ad2ne072 ad2ne073 ad2ne078 ad2ne079) //count of families with children under age 5 in each CT.
egen grand_total_families_u5=total( total_families_u5) // counts of families with children in the state
gen share_fam_u5=grand_total_families_u5/total_families // share of families with children
*---------------------*
*Income status by race*
*---------------------*
*WHITE ALONE, non-hispanic(Poverty Status in the Past 12 Months of Families by Family Type by Presence of Related Children Under 18 Years by Age of Related Children (White Alone Householder))
*under 5
**below poverty
egen u5YesPovBelow_race1=rowtotal(ad14e005  ad14e012   ad14e018 ad14e006   ad14e013   ad14e019) // gives counts of families with young children below poverty
**above poverty
egen u5YesPovAbove_race1=rowtotal(ad14e025   ad14e032   ad14e038 ad14e026   ad14e033   ad14e039)

*BLACK ALONE( Poverty Status in the Past 12 Months of Families by Family Type by Presence of Related Children Under 18 Years by Age of Related Children (Black or African American Alone Householder)
*under 5
**below poverty
egen u5YesPovBelow_race2=rowtotal(ad1ye005   ad1ye012   ad1ye018  ad1ye006   ad1ye013   ad1ye019)
**above poverty
egen u5YesPovAbove_race2=rowtotal(ad1ye025   ad1ye032   ad1ye038 ad1ye026   ad1ye033   ad1ye039)

*Hispanic ALONE( Poverty Status in the Past 12 Months of Families by Family Type by Presence of Related Children Under 18 Years by Age of Related Children (Hispanic Alone Householder)
*under 5
**below poverty
egen u5YesPovBelow_race3=rowtotal(ad15e005   ad15e012   ad15e018 ad15e006   ad15e013   ad15e019)
**above poverty
egen u5YesPovAbove_race3=rowtotal(ad15e025   ad15e032   ad15e038 ad15e026   ad15e033   ad15e039)

*Aindian ALONE( Poverty Status in the Past 12 Months of Families by Family Type by Presence of Related Children Under 18 Years by Age of Related Children (Native American Alone Householder)
*under 5
**below poverty
egen u5YesPovBelow_race4=rowtotal(ad1ze005   ad1ze012   ad1ze018  ad1ze006   ad1ze013   ad1ze019)
**above poverty
egen u5YesPovAbove_race4=rowtotal(ad1ze025   ad1ze032   ad1ze038 ad1ze026   ad1ze033   ad1ze039)

*Asian(  Poverty Status in the Past 12 Months of Families by Family Type by Presence of Related Children Under 18 Years by Age of Related Children (Asian Alone Householder))
*under 5
**below poverty
egen u5YesPovBelow_race5=rowtotal(ad10e005   ad10e012   ad10e018  ad10e006   ad10e013   ad10e019)
**above poverty
egen u5YesPovAbove_race5=rowtotal(ad10e025   ad10e032   ad10e038 ad10e026   ad10e033   ad10e039)

*Other( native hawaian, pacific islander, some other race, two or more race)
*under 5
**below poverty
egen u5YesPovBelow_race6=rowtotal(ad11e005 ad12e005 ad13e005 ad11e012 ad12e012 ad13e012 ad11e018 ad12e018 ad13e018 ad11e006 ad12e006 ad13e006 ad11e013 ad12e013 ad13e013 ad11e019 ad12e019 ad13e019)
                                 
**above poverty
egen u5YesPovAbove_race6=rowtotal(ad11e025 ad12e025 ad13e025 ad11e032  ad12e032 ad13e032 ad11e038  ad12e038 ad13e038 ad11e026 ad12e026 ad13e026 ad11e033  ad12e033 ad13e033 ad11e039  ad12e039 ad13e039)
 
*create fraction variable by each income and race category
egen tt=rowtotal(u5YesPovBelow_race1 u5YesPovAbove_race1 u5YesPovBelow_race2 u5YesPovAbove_race2 u5YesPovBelow_race3 u5YesPovAbove_race3 u5YesPovBelow_race4 u5YesPovAbove_race4 u5YesPovBelow_race5 u5YesPovAbove_race5 u5YesPovBelow_race6 u5YesPovAbove_race6)
egen u5povbelow_all=rowtotal(u5YesPovBelow_race*)
egen u5povabove_all=rowtotal(u5YesPovAbove_race*)
forval i=1/6{
  gen s_u5povbelow_race`i'= u5YesPovBelow_race`i'/u5povbelow_all  
  gen s_u5povabove_race`i'= u5YesPovAbove_race`i'/u5povabove_all
}
gen s_u5povbelow_all= u5povbelow_all/tt
gen s_u5povabove_all= u5povabove_all/tt

forval i=1/6{
  gen s_fam_u5_race`i'=(u5YesPovBelow_race`i'+u5YesPovAbove_race`i')/tt
}
forval i=1/6{
  gen n_fam_u5_race`i'= u5YesPovBelow_race`i'+u5YesPovAbove_race`i'
}
forval i=1/6{
  egen state_n_fam_u5_race`i'= total(n_fam_u5_race`i')
}
egen sum=rowtotal(state_n_fam_u5_race*)
 
forval i=1/6{
  gen s_state_n_fam_u5_race`i'= state_n_fam_u5_race`i'/sum
}

*total families with kid u 5 by race.
forval i=1/6{
  egen total_pop_race`i'=rowtotal(u5YesPovBelow_race`i' u5YesPovAbove_race`i')
}

forval i=1/6{
  gen s_u5YesPovBelow_race`i'=u5YesPovBelow_race`i'/total_pop_race`i'
  gen s_u5YesPovAbove_race`i'=u5YesPovAbove_race`i'/total_pop_race`i'
}

sum s_u5YesPovBelow_race* //just check to see if share make sense

egen alt_u5YesPovBelow_race=rowtotal(ad2re002 ad2re003 ad2re004 )
egen  alt_u5YesPovAbove_race=rowtotal(ad2re005 ad2re006 ad2re007 ad2re008 ad2re009 ad2re010 ad2re011 ad2re012 ad2re013  )
 
gen  s_pov1_race=ad2re002/alt_u5YesPovBelow_race
gen  s_pov2_race=ad2re003/alt_u5YesPovBelow_race
gen  s_pov3_race=ad2re004/alt_u5YesPovBelow_race
**
gen  s_pov4_race=ad2re005/alt_u5YesPovAbove_race
gen  s_pov5_race=ad2re006/alt_u5YesPovAbove_race
gen  s_pov6_race=ad2re007/alt_u5YesPovAbove_race
gen  s_pov7_race=ad2re008/alt_u5YesPovAbove_race
gen  s_pov8_race=ad2re009/alt_u5YesPovAbove_race
gen  s_pov9_race=ad2re010/alt_u5YesPovAbove_race
gen  s_pov10_race=ad2re011/alt_u5YesPovAbove_race
gen  s_pov11_race=ad2re012/alt_u5YesPovAbove_race
gen  s_pov12_race=ad2re013/alt_u5YesPovAbove_race

 
forval i=1/6{
  gen s_pov1_race`i'=s_pov1_race*s_u5YesPovBelow_race`i'
  gen s_pov2_race`i'=s_pov2_race*s_u5YesPovBelow_race`i'
  gen s_pov3_race`i'=s_pov3_race*s_u5YesPovBelow_race`i'
  gen s_pov4_race`i'=s_pov4_race*s_u5YesPovAbove_race`i'
  gen s_pov5_race`i'=s_pov5_race*s_u5YesPovAbove_race`i'
  gen s_pov6_race`i'=s_pov6_race*s_u5YesPovAbove_race`i'
  gen s_pov7_race`i'=s_pov7_race*s_u5YesPovAbove_race`i'
  gen s_pov8_race`i'=s_pov8_race*s_u5YesPovAbove_race`i'
  gen s_pov9_race`i'=s_pov9_race*s_u5YesPovAbove_race`i'
  gen s_pov10_race`i'=s_pov10_race*s_u5YesPovAbove_race`i'
  gen s_pov11_race`i'=s_pov11_race*s_u5YesPovAbove_race`i'
  gen s_pov12_race`i'=s_pov12_race*s_u5YesPovAbove_race`i'
}
*keep the variables in need only
keep gisjoin year state  s_pov*_race county tracta   s_pov*_race*  total_families_u5 s_fam_u5_race* s_u5YesPovBelow_race* s_u5YesPovAbove_race* s_u5povbelow_race* s_u5povabove_race*
foreach var of varlist _all{
  rename `var' ct_`var' //add ct_ prefix to all variables to indicate that it comes from tract level data.
}
tostring ct_tracta,gen(ct_tracta_s)
gen uid=ct_county+ct_tracta_s // unique identifier
save "${directory}\intermediate\ACS2011_2015CTb_race.dta",replace
 
 
*====================================================================================================*    
*Step 2: using block-group level ACS data, calculate joint density of family by binary-poverty status*
*====================================================================================================*    
 
import delimited "${directory}\nhgis0110_ds215_20155_2015_blck_grp.csv", clear
drop if statea !=27 //keep the state you want (27 is MN)
*families at/above poverty by num of children
*families with children under 5

egen total_families_u5=rowtotal(adnfe005 adnfe012 adnfe018 adnfe025 adnfe032 adnfe038 adnfe006 adnfe013 adnfe019 adnfe026 adnfe033 adnfe039)
egen grand_total_families_u5=total( total_families_u5)

*under 5
**below poverty
egen u5YesPovBelow_all=rowtotal(adnfe005 adnfe006 adnfe012 adnfe013 adnfe018 adnfe019)
                                 
**above poverty
egen u5YesPovAbove_all=rowtotal(adnfe025 adnfe026 adnfe032 adnfe033 adnfe038 adnfe039)

keep gisjoin tracta county total_families_u5 grand_total_families_u5 u5YesPovBelow_all u5YesPovAbove_all
foreach var of varlist _all{
  rename `var' bg_`var'  //add bg_ prefix to all variables to indicate that it comes from block-group level data.
}
tostring bg_tracta,gen(bg_tracta_s)
gen uid=bg_county+bg_tracta_s // unique identifier
save "${directory}\intermediate\ACS2011_2015Block_Group.dta",replace


*==========================================================================================================================================================*    
*Step 3: Combine data created in steps 1 and 2, and calculate joint density of family by categorical-poverty status, by race, down to the block-group level*
*==========================================================================================================================================================*    

*--------------------------*
*merge CT and BG level data.
*--------------------------*
use "${directory}\intermediate\ACS2011_2015Block_Group.dta",clear
merge m:1 uid using "${directory}\intermediate\ACS2011_2015CTb_race.dta" // many to one merge
*using probability density (share) of families by race and by poverty status from CT, calcaulte counts of families by binary-poverty by race at the BG level.
forval i=1/6{
  gen bg_u5YesPovBelow_race`i'=bg_u5YesPovBelow_all*ct_s_u5povbelow_race`i'
  gen bg_u5YesPovAbove_race`i'=bg_u5YesPovAbove_all*ct_s_u5povabove_race`i'
}
*using probability density (share) of families by race and by categorical-poverty status from CT, calcaulte counts of families by categorical-poverty status by race at the BG level.
forval i=1/6{
  forval j=1/3{
    gen bg_fam_u5_pov`j'_race`i'=bg_u5YesPovBelow_race`i'*ct_s_pov`j'_race
  }
}
forval i=1/6{
  forval j=4/12{
    gen bg_fam_u5_pov`j'_race`i'=bg_u5YesPovAbove_race`i'*ct_s_pov`j'_race
  }
}
keep bg_fam_u5_pov*_race* uid ct_gisjoin ct_year ct_state ct_county ct_tracta bg_gisjoin bg_county bg_tracta bg_tracta_s bg_total_families_u5
save "${directory}\intermediate\ACS2011_2015Block_Group_CensusTract.dta",replace

*================================================================================*    
*Step 4: using block level Census data, calculate joint density of family by race*
*================================================================================*    
*--------------------------*
*merge CT and BG level data.
*--------------------------*
use "${directory}\intermediate\ACS2011_2015Block_Group.dta",clear
merge m:1 uid using "${directory}\intermediate\ACS2011_2015CTb_race.dta" // many to one merge
*using probability density (share) of families by race and by poverty status from CT, calcaulte counts of families by binary-poverty by race at the BG level.
forval i=1/6{
  gen bg_u5YesPovBelow_race`i'=bg_u5YesPovBelow_all*ct_s_u5povbelow_race`i'
  gen bg_u5YesPovAbove_race`i'=bg_u5YesPovAbove_all*ct_s_u5povabove_race`i'
}
*using probability density (share) of families by race and by categorical-poverty status from CT, calcaulte counts of families by categorical-poverty status by race at the BG level.
forval i=1/6{
  forval j=1/3{
    gen bg_fam_u5_pov`j'_race`i'=bg_u5YesPovBelow_race`i'*ct_s_pov`j'_race
  }
}
forval i=1/6{
  forval j=4/12{
    gen bg_fam_u5_pov`j'_race`i'=bg_u5YesPovAbove_race`i'*ct_s_pov`j'_race
  }
}
keep bg_fam_u5_pov*_race* uid ct_gisjoin ct_year ct_state ct_county ct_tracta bg_gisjoin bg_county bg_tracta bg_tracta_s bg_total_families_u5
save "${directory}\intermediate\ACS2011_2015Block_Group_CensusTract.dta",replace
 

import delimited "${directory}\nhgis0103_ds172_2010_block.csv", clear
drop if statea !=27
rename gisjoin b_gisjoin
merge m:1 b_gisjoin using "${directory}\MN_2010_Block_BG_CT_County.dta" //this is block-level data that contains unique ids on block, BG, CT and County.
keep if _merge==3
drop _merge 

*families at/above poverty by num of children
*families with children under 6
egen total_families_u6_r1=rowtotal(icr004 icr005 icr011 icr012 icr017 icr018)
egen total_families_u6_r2=rowtotal(ick004 ick005 ick011 ick012 ick017 ick018)
egen total_families_u6_r3=rowtotal(icq004 icq005 icq011 icq012 icq017 icq018)
egen total_families_u6_r4=rowtotal(icl004 icl005 icl011 icl012 icl017 icl018)
egen total_families_u6_r5=rowtotal(icm004 icm005 icm011 icm012 icm017 icm018)
egen total_families_u6_r6=rowtotal(icp004 icp005 icp011 icp012 icp017 icp018 icn004 icn005 icn011 icn012 icn017 icn018 ico004 ico005 ico011 ico012 ico017 ico018)
egen total_families_u6=rowtotal(total_families_u6_r1 total_families_u6_r2 total_families_u6_r3 total_families_u6_r4 total_families_u6_r5 total_families_u6_r6)

egen grand_total_families_u6=total(total_families_u6)
foreach v in total_families_u6_r1 total_families_u6_r2 total_families_u6_r3 total_families_u6_r4 total_families_u6_r5 total_families_u6_r6{
  egen bg_`v'=total(`v'),by(bg_gisjoin)
}
foreach v in total_families_u6_r1 total_families_u6_r2 total_families_u6_r3 total_families_u6_r4 total_families_u6_r5 total_families_u6_r6{
  gen s_b_`v'=`v'/bg_`v' //block level share of families with young children by race.
}
*block level count of total families by race
gen tot_pop_b_r1=icr001
gen tot_pop_b_r2=ick001
gen tot_pop_b_r3=icq001
gen tot_pop_b_r4=icl001
gen tot_pop_b_r5=icm001
gen tot_pop_b_r6=icn001+ico001+icp001
forval i=1/6{
  gen total_families_NOu6_r`i'=tot_pop_b_r`i'-total_families_u6_r`i' //*block level count of families without child u6 by race
}
 
keep b_gisjoin year state county blkgrpa ttracta name s_b_*
foreach var of varlist _all{
  rename `var' b_`var' //add b_ prefix to all variables to indicate that it comes from block level data.

}
rename b_b_gisjoin b_gisjoin // unique identifier
save "${directory}\intermediate\ACS2010_block_race.dta",replace 
*====================================================================================================================================================*    
*Step 5: Combine data created in steps 3 and 4, and calculate joint density of family by categorical-poverty status, by race, down to the block level*
*====================================================================================================================================================*    

*--------------------------------*
*merge B and BG and CT level data.
*--------------------------------*

use "${directory}\intermediate\ACS2010_block_race.dta",clear
 
merge m:1 b_gisjoin using "${directory}\MN_2010_Block_BG_CT_County.dta" //this is block-level data that contains unique ids on block, BG, CT and County.
keep if _merge==3
drop _merge
merge m:1 bg_gisjoin using "${directory}\intermediate\ACS2011_2015Block_Group_CensusTract.dta"
keep if _merge==3
drop _merge

forval i=1/6{
  forval j=1/12{
    gen b_fam_u5_pov`j'_race`i'=b_s_b_total_families_u6_r`i'*bg_fam_u5_pov`j'_race`i' // calculate block level joint probabbilty by categorical-poverty, by race.
  }
}

keep b_gisjoin b_fam_u5_pov*_race* //just keep the block-level unique identifier and counts of families under age 5 by poverty, by income.
order b_gisjoin,last
foreach v of  varlist *{
  capture confirm numeric variable `v'
    if !_rc {
      replace `v'=0 if `v'==. // replace missing with 0
    }
    else{
      continue
    }
}

reshape long b_fam_,i(b_gisjoin) j(kjs) string //reshape the data to long format.
egen tot=total( b_fam_)
 
gen share=b_fam_/tot //probability density
 
gsample 64875 [aw= share ] //generate block-level synthetic number of families according to the probability density we derived above (sum up to 64875 which is 25% of total families with children u5 in MN)
gen pov=.
gen race=.

forval j=1/6{
  forval i=1/12{
    replace pov=`i' if kjs=="u5_pov`i'_race`j'"
    replace race=`j' if kjs=="u5_pov`i'_race`j'"
  }
}


gen c=1
forval i=1/12{
  forval j=1/6{
    egen p`i'_r`j'=total(c) if pov==`i'&race==`j',by(b_gisjoin)
  }
}

collapse p*_r*, by( b_gisjoin)
order b_gisjoin,last
 
foreach v of  varlist *{
  capture confirm numeric variable `v'
    if !_rc {
      replace `v'=0 if `v'==. // replace missing with 0
    }
    else{
      continue
    }
}

save  "${directory}\intermediate\synth_HH_25pct_sample_block_level.dta",replace 
export delimited using  "${directory}\intermediate\synth_HH_25pct_sample_block_level.csv", replace


*======*    
*Step 6*
*======*  
*Next steps in ArcGIS and GSM
*Step 6: using family density from step 5, randomly populate families (points) within each blocks using tools from ArcGIS and GSM
**Step 6.a. open the "synth_HH_25pct_sample_block_level.csv" in Arcgis, merge to the block-level map (the map should have been processed so that it parsed out inhibitable areas such as river, lake, state parks, etc) save as shapefile.
**Step 6.b. open the shapefile with density information in Geospatial Modelling Tool (download and install from http://www.spatialecology.com/gme/)  
/*In GSM tool, use stratarandompoints function to randomly populate synth families within each block.
Using the density information, each synthetic family points can have race and income status assigned to them (or depending on your need, you can select
variables of your interest from ACS data).*/
