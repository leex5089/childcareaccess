*#=========================#*
*Calculating access measure*
*#=========================#*
/*Summary steps
Create family-provider pair
step 1. Calculate provider-household pair within 30 (or X miles depending on your need) miles straight line radius (ArcGIS neartable tool).
*Export the neartables in step 1, in addition to the family and Provider geocodes (with unique ids) file as csv format.

step 2. open csv files in step 1 in Stata and modify the data structure for the osrmtime (you can also use any preferred software to calculate driving time from point x to y, osrmtime is convenient because it doesn’t have the query limit like google map).
step 3. process osrmtime (calculate driving time between point x to y).
step 4. Analysis using the post-osrmtime file.
a.  With the file produced from step 11, you can limit the providers within x minutes of driving time radius for each synthetic family i. 
b.  2-stage catchment area method (demand-adjusted supply) is calculates as follows:
1.  Count number of families within x minutes of driving time radius for each provider j.
2.  Divide the capacity of provider j by the total number of families located within x min of provider j (this is termed capacity-to-population ratio)
3.  Sum up all the capacity-to-population ratios, for all provider j within the x minutes of driving time radius for each family i (This is the demand-adjusted supply).
*You can also apply distance decay weights to discount capacity of providers that are further away from family i.   
*You can calculate demand-adjusted supply for certain types or rating levels as need for the study objective.
*/

*define working directory 
global directory G:\My Drive\MinnCCAccess\Analysis\PDG\Data\

*===================*    
*Pre-processing data*
*===================*    
*create fake provider data for the purpose of exercise.
clear
set obs 10000 
gen providerid = char(runiformint(65,90)) +char(runiformint(65,90)) +char(runiformint(65,90)) +string(runiformint(0,9)) + char(runiformint(65,90)) +char(runiformint(65,90)) + string(runiformint(0,9)) + char(runiformint(65,90))
gen uid=_n
tempvar var1
gen `var1'=runiform()
gen caretype="family" if `var1'<0.7
replace caretype="center" if caretype==""

gen price = runiformint(100, 500) if caretype=="center"
replace price = runiformint(0, 300) if caretype=="family"&price==.

gen capacity = runiformint(20, 100) if caretype=="center"
replace capacity = runiformint(0, 50) if caretype=="family"&capacity==.

gen quality = runiformint(1, 4)  

*bring randome geocode
merge 1:1 uid using  "${directory}\raw\example_geocode.dta"
keep if _merge==3
drop _merge

rename x provider_long
rename y provider_lat

keep providerid uid caretype price capacity quality provider_long provider_lat
save "${directory}\raw\provider_data.dta",replace // simulated provider data saved in the working directory
export delimited using "${directory}\raw\provider_data.csv", replace // export as csv for use in the ArcGIS.

*==================================================================================================================*    
*Step 1: Calculate provider-household pair within 30 (or X miles depending on your need) miles straight line radius*
*==================================================================================================================* 
*Next step is to get the family-provider pairs based on the straight line distance. 
/*For this purpose, I opened both provider_data and family_data (already created in Step 1) in ArcGIS and used neartable tool (https://pro.arcgis.com/en/pro-app/tool-reference/analysis/generate-near-table.htm)
to find paird within 30 miles (straight-line) radius. I used two files in this step:

1. "${directory}\raw\provider_data.csv"
2. "${directory}\raw\family_data.csv" 

After opening in ArcGIS, each rows get unique "fid":

1. "${directory}\intermediate\family_data_with_fid.txt"
2. "${directory}\intermediate\provider_data_with_fid.csv" 


The output file after neartable tool processing in ArcGIS should look something like this:

"${directory}\intermediate\neartable_example_pair_10closest.csv" 

*/

*preparing data from ArcGIS to have osrmtime ready, which is a command in Stata that calculates driving time from point a to b. 
*with your ArcGIS expertise, this step can be done in ArcGIS, which could be more efficient. 


*===================================================================================================*    
*Step 2: open csv files in step 1 in Stata and modify the data structure for osrmtime ready in Stata 
*===================================================================================================* 


import delimited "${directory}\intermediate\family_data_with_fid.txt", clear 
rename fid in_fid
save "${directory}\intermediate\family_data_with_fid.dta", replace

import delimited "${directory}\intermediate\provider_data_with_fid.txt", clear 
rename fid near_fid
rename provider_l provider_long
rename provider_1 provider_lat
save "${directory}\intermediate\provider_data_with_fid.dta", replace

import delimited "${directory}\intermediate\neartable_example_pair_10closest.txt", clear //This is the output file from neartable tool in ArcGIS. I chose 10closest provider for each family for the purpose of illustration, but you can set the threshold to 30 miles or others.
save "${directory}\intermediate\neartable_example_pair_10closest.dta", replace

 
use "${directory}\intermediate\neartable_example_pair_10closest.dta",clear
merge m:1 in_fid using "${directory}\intermediate\family_data_with_fid.dta"
drop _merge
merge m:1 near_fid using "${directory}\intermediate\provider_data_with_fid.dta"
keep if _merge==3
drop _merge
save "${directory}\intermediate\osrmtime_ready.dta", replace  //this file is adequately formatted and ready for osrmtime command below.


*======================================================================*    
*Step 3: process osrmtime (calculate driving time between point x to y).
*======================================================================*    
 


*in order to use the osrmtime command, you have to install the module described in https://www.uni-regensburg.de/wirtschaftswissenschaften/vwl-moeller/medien/huber/osrm_paper_online.pdf
/*use "${directory}\intermediate\osrmtime_ready.dta",clear
osrmtime family_lat family_lon provider_lat provider_long  ,mapfile("C:\osrm_map\minnesota-latest.osrm") osrmdir("C:\osrm")  ports(2) threads(6) progress nocleanup // osrmtime command, mapfile() should contain area of interest which can be downloaded from http://download.geofabrik.de/
gen osrm_distance_mile=distance*0.000621371 // unit conversion
gen osrm_time_mins=duration*0.0166667 // unit conversion
save "${directory}\intermediate\osrmtime_done.dta", replace  
*/

 
*=============================================*    
*Step 4: Analysis using the post-osrmtime file.
*=============================================*    
 
use  "${directory}\intermediate\osrmtime_done.dta",clear
egen mint=min(osrm_time_mins),by(in_fid)
*keep if osrm_time_mins<=20|(mint==osrm_time_mins) //keep only the family-provider observations that are less than 20 min driving time, or the closest pair, if the cloeset provider is out of 20 driving time. you can also modify the threshold
merge m:1 in_fid using  "${directory}\intermediate\family_data_with_fid_gisjoin.dta" // add block group unique identifier
keep if _merge==3
drop _merge
rename gisjoin bg_gisjoin
merge m:1 bg_gisjoin using  "${directory}\intermediate\acs2015_avg_bg_N_c_u5_per_fam.dta" // add a variable average number of children under age 5.
keep if _merge==3
drop _merge   
gen N_pop_child_u5= 4*avg_bg_N_c_u5_per_fam // To calculate population-level number of children under 5, multiply average N of children by 4 because syn family is 25% sample.  
egen N_children_around_provider=total(N_pop_child_u5),by(providerid) // number of chlidren around provider.
 
*g-gaussian decay function
forval i=3(1)5{ 
gen gaus_w_beta`i'=exp(((-osrm_time_mins^`i')/1000)) 
egen N_children_around_prov_weighted`i'=total(N_pop_child_u5*gaus_w_beta`i'),by(providerid)
}  
 
gen fcc = caretype=="family"  
 
gen osrm_time_hour=osrm_time_mins/60 
gen expenditure =  price + 10*10*osrm_time_hour
gen travel_cost=10*10*osrm_time_hour 
  
*-------------------------------------------*
*Demand adjusted supply (das) , not weighted
*-------------------------------------------*
*provider-to-population ratio (PPR_y), not weighted
gen prov_pop_ratio=capacity/N_children_around_provider
egen das_notweighted=total(prov_pop_ratio)  ,by(in_fid) //Demand adjusted supply (das), not weighted

*provider-to-population ratio (PPR_y), weighted
forval i=4/5{ 
  gen prov_pop_ratio_weighted`i'=capacity/N_children_around_prov_weighted`i'
} 
  
*--------------------------------------------------*
*Average price, cost, total capacity , not weighted
*--------------------------------------------------*


egen avg_expenditure=mean(expenditure)  ,by(in_fid)
egen avg_price=mean(price)  ,by(in_fid)
egen totcap=total(capacity)  ,by(in_fid)  

tempvar totcap_fcc
egen `totcap_fcc'=total(capacity) if fcc==1  ,by(in_fid)
egen totcap_fcc=mean(`totcap_fcc'),by(in_fid) 
gen s_totcap_fcc=totcap_fcc/totcap //share of fcc from family i

tempvar totcap_ccc
egen `totcap_ccc'=total(capacity) if fcc==0  ,by(in_fid)
egen totcap_ccc=mean(`totcap_ccc'),by(in_fid) 
gen s_totcap_ccc=totcap_ccc/totcap //share of ccc from family i

*---------------------------------------*
*Demand adjusted supply (das) , weighted
*---------------------------------------*

forval i=4/5{ 
    egen N_children_around_fam_weighted`i'=total(N_pop_child_u5*gaus_w_beta`i'),by(in_fid)
    gen gs_2sfca_1st_b`i'=(prov_pop_ratio_weighted`i')*gaus_w_beta`i'
} 

forval i=4/5{
    egen das_weighted`i'  =total((prov_pop_ratio_weighted`i')*gaus_w_beta`i')   ,by(in_fid)  //Demand adjusted supply (das), weighted
}  
 
*----------------------------------------------*
*Average price, cost, total capacity , weighted
*----------------------------------------------*

forval i=4/5{

    tempvar das_weighted`i'_fcc
    egen `das_weighted`i'_fcc'=total((prov_pop_ratio_weighted`i')*gaus_w_beta`i') if fcc==1  ,by(in_fid) 
    egen das_weighted`i'_fcc=mean(`das_weighted`i'_fcc'),by(in_fid) 

    tempvar das_weighted`i'_ccc
    egen `das_weighted`i'_ccc'=total((prov_pop_ratio_weighted`i')*gaus_w_beta`i') if fcc==0  ,by(in_fid) 
    egen das_weighted`i'_ccc=mean(`das_weighted`i'_ccc'),by(in_fid) 

}

*access measures by quality rating

forval i=4/5{
  forval q=1/4{

    tempvar das_weighted`i'_q`q'
    egen `das_weighted`i'_q`q''=total((prov_pop_ratio_weighted`i')*gaus_w_beta`i') if quality==`q'  ,by(in_fid) 
    egen das_weighted`i'_q`q'=mean(`das_weighted`i'_q`q''),by(in_fid) 
     
  }
}

  
forval i=4/5{
  gen weight_for_avg_b`i'=gs_2sfca_1st_b`i'/das_weighted`i'
}
 


forval i=4/5{
   
  egen totcost_weighted`i' = wtmean(expenditure), weight(weight_for_avg_b`i') by(in_fid)
  egen avg_price_weighted`i' = wtmean(price), weight(weight_for_avg_b`i') by(in_fid)
    
  tempvar totcost_weighted`i'_fcc
  egen `totcost_weighted`i'_fcc'=wtmean(expenditure) if fcc==1, weight(weight_for_avg_b`i')    by(in_fid) 
  egen totcost_weighted`i'_fcc=mean(`totcost_weighted`i'_fcc'),by(in_fid) 

  tempvar totcost_weighted`i'_ccc
  egen `totcost_weighted`i'_ccc'=wtmean(expenditure) if fcc==0 , weight(weight_for_avg_b`i')   by(in_fid) 
  egen totcost_weighted`i'_ccc=mean(`totcost_weighted`i'_ccc'),by(in_fid) 

  tempvar avg_price_weighted`i'_fcc
  egen `avg_price_weighted`i'_fcc'=wtmean(price)  if fcc==1 , weight(weight_for_avg_b`i')  by(in_fid) 
  egen avg_price_weighted`i'_fcc=mean(`avg_price_weighted`i'_fcc'),by(in_fid) 

  tempvar avg_price_weighted`i'_ccc
  egen `avg_price_weighted`i'_ccc'=wtmean(price) if fcc==0, weight(weight_for_avg_b`i')   by(in_fid) 
  egen avg_price_weighted`i'_ccc=mean(`avg_price_weighted`i'_ccc'),by(in_fid) 


}

 forval i=4/5{
  forval q=1/4{

    tempvar avg_price_weighted`i'_q`q'
    egen `avg_price_weighted`i'_q`q''=wtmean(price) if quality==`q' , weight(weight_for_avg_b`i') by(in_fid) 
    egen avg_price_weighted`i'_q`q'=mean(`avg_price_weighted`i'_q`q''),by(in_fid) 
     

    tempvar totcost_weighted`i'_q`q'
    egen `totcost_weighted`i'_q`q''=wtmean(expenditure) if quality==`q', weight(weight_for_avg_b`i')   by(in_fid) 
    egen totcost_weighted`i'_q`q'=mean(`totcost_weighted`i'_q`q''),by(in_fid) 
      
  }
} 
 
duplicates drop in_fid,force // drop duplicates in terms of unique family id.
cap drop __*
keep in_fid near_fid income race family_lon family_lat das_* avg_* s_* totcost_*
order in_fid near_fid income race family_lon family_lat das_* avg_* s_* totcost_*
export delimited using "${directory}\output\das_measure_final.csv", replace
save "${directory}\output\das_measure_final.dta",replace 
