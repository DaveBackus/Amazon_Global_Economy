*******************************************************************************************************************;
************************************************Inflation**********************************************************;
*This file creates the figures in the "Inflation" chapter of "The Global Economy" textbook.;
*The latest version of this code, as well as the book, can be found at www.stern.nyu.edu/GEMatter.;  
*Send bug reports, feature requests, or advice on how to write better code to kruhl@stern.nyu.edu.;

*Kim J. Ruhl;
*September 7, 2012;
*******************************************************************************************************************;
*******************************************************************************************************************;

# delimit ;
clear all;
set mem 1g;
set varabbrev off;
set autotabgraphs on;
set more off;

*******************************************************************************************************************;
*********************************************Figure: quantity theory in the long run *******************************;
* GDPC1 = real GDP (quarterly);
* M2SL = M2 money stock (monthly);
* GDPDEF = GDP deflator (quarterly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse M2SL, clear;
drop date;
gen date = qofd(daten);

*The collapse command tranforms the monthly data into quarterly, by averaging the monthly observations.;
collapse (mean) M2SL, by(date);
save temp.dta, replace;

*Load the data from FRED.;
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse GDPC1 GDPDEF, clear;
drop date;
gen date = qofd(daten);

*Merge the industrial production data with the temp file containing the GDP data.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp, nogen;
tsset date, quarterly;

*Drop the observations before 1960.  This makes it easy divide through by 1960q1's value to normalize the series;
drop if date < tq(1960q1);

*Normalize the series and then take logs.;
gen m_y = ln((M2SL/GDPC1)/(M2SL[1]/GDPC1[1]));
gen price = ln(GDPDEF/GDPDEF[1]);
gen vel = ln( (GDPDEF*GDPC1/M2SL) / (GDPDEF[1]*GDPC1[1]/M2SL[1]) );

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(2000q1) directly as an arguement to "text".; 
local temp = q(2000q1);

*Make the figure.  The first line plots the 3 data series. The rest of the code formats the figure.;
*Note: if you name the graphs they will open as tabs in the viewer, rather than replace the previous graph.; 
graph twoway (tsline  m_y price vel, lc(blue red black) lp(solid dash dash_dot)  
	ylab(,nogrid tp(crossing) axis(1) format(%02.1f))
	tti("")
	yti("{bf} logarithms")
	text(1.22 `temp' "M/Y")
	text(1.7 `temp' "Price level",place(w))
	text(0.32 `temp' "Velocity",place(w))
	legend(off)
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(long_fig));

*Save the figure.  On a PC, you can't directly save to PDF.;	
graph export long.eps, replace;


*******************************************************************************************************************;
********************************************Figure: quantity theory in the short run *******************************;
* GDPC1 = real GDP (quarterly);
* M2SL = M2 money stock (monthly);
* GDPDEF = GDP deflator (quarterly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse M2SL, clear;
drop date;
gen date = qofd(daten);

*The collapse command tranforms the monthly data into quarterly, by averaging the monthly observations.;
collapse (mean) M2SL, by(date);
save temp.dta, replace;

*Load the data from FRED.;
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse GDPC1 GDPDEF, clear;
drop date;
gen date = qofd(daten);

*Merge the gdp data with the temp file containing the money supply data.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp, nogen;
tsset date, quarterly;

*Drop the observations before 1960.  This makes it easy divide through by 1960q1's value to normalize the series;
drop if date < tq(1960q1);

*Normalize the series and then take logs.;
gen m_y = ln((M2SL/GDPC1)/(M2SL[1]/GDPC1[1]));
gen price = ln(GDPDEF/GDPDEF[1]);
gen vel = ln( (GDPDEF*GDPC1/M2SL) / (GDPDEF[1]*GDPC1[1]/M2SL[1]) );

*Use the HP filter on money and velocity.  You may need to install the hpfilter package from ssc.;
hprescott m_y, stub(hp); 
hprescott vel, stub(hp); 

*Express the deviations as percentages;
replace hp_m_y_1 = hp_m_y_1*100;
replace hp_vel_1 = hp_vel_1*100;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(2008q1) directly as an arguement to "text".; 
local temp = q(2008q1);

*Make the figure.  The first line plots the 2 data series. The rest of the code formats the figure.;
*Note: if you name the graphs they will open as tabs in the viewer, rather than replace the previous graph.; 
graph twoway (tsline  hp_m_y_1 hp_vel_1, lc(blue red ) lp(solid dash ) yline(0)  
	ylab(-5.0 -2.5 0 2.5 5.0 7.5,nogrid tp(outside) axis(1) format(%02.1f))
	tti("")
	yti("{bf} Deviation from trend (percent)", margin(medsmall) axis(1))
	legend(off)
	text(6 `temp' "M/Y",place(w))
	text(-5.5 `temp' "Velocity",place(w))
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(short_1));

*Save the figure.  On a PC, you can't directly save to PDF.;	
graph export short_1.eps, replace;


*******************************************************************************************************************;
*****************************************Figure: inflation and interest rates in Greece*****************************;
* GRCCPIALLMINMEI = Greek consumer price index;

freduse GRCCPIALLMINMEI, clear;
drop date;
gen date = mofd(daten);
drop daten;
tsset date, monthly;
gen infl = ln( GRCCPIALLMINMEI/L12.GRCCPIALLMINMEI)*100;
save temp, replace;

*Data on greek interest rates are not available on FRED.  This data is in the file "ge_data.csv" which is available;
*at www.stern.nyu.edu/GEMatters.  Load the data and parse the data column.; 
insheet using ge_data.csv, clear;
gen date = date(daten,"MDY");
replace date = mofd(date);
format date %tm;

*Merge the rate data with the temp file containing the cpi data.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp, nogen;
tsset date, monthly;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(2008q1) directly as an arguement to "text".; 
local temp = m(1996m1);


graph twoway (tsline  greek_rate infl if tin(1985m1, 2005m12), lc(blue red ) lp(solid dash ) 
	ylab(,nogrid tp(crossing) axis(1) format(%2.0f))
	tti("")
	yti("{bf} Rate (percent)", margin(medsmall) axis(1))
	legend(off)
	plotregion( lstyle(none) color(white) margin(medium) )
	text(25 `temp' "Interest rate", place(e))
	text(6.5 `temp' "Inflation rate", place(w))
	graphregion(color(white) ));

*Save the figure.  On a PC, you can't directly save to PDF.;	
graph export greece.eps, replace;





































