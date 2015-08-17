*******************************************************************************************************************;
*****************************************Business Cycle Indicators*************************************************;
*This file creates the figures in the "Business Cycle Indicators" chapter of "The Global Economy" textbook.;
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

***************************Figure: US GDP and Industrial Production growth rates************************************;
* GDPC1 = real GDP (quarterly);
* INDPRO = industrial production index (monthly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
*The GDP data is quarterly, but the industrial production data is monthly. We will save the data to a temporary file;
*so that we can transform the monthly data, then merge the two variables into one dataset.;
freduse GDPC1 ;		
drop date;
gen date = qofd(daten);
save temp.dta, replace;

*Load the data from FRED.;
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
*The collapse command tranforms the monthly data into quarterly, by averaging the monthly observations.;
freduse INDPRO, clear;
drop date;
gen date = qofd(daten);
collapse (mean) INDPRO, by(date);

*Merge the industrial production data with the temp file containing the GDP data.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp.dta, nogen;
tsset date, quarterly;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;
gen ind_gr = S4.INDPRO/L4.INDPRO * 100;
gen gdp_gr = S4.GDPC1/L4.GDPC1 * 100;

*This block of code creates (x1,y1) and (x2,y2): the endpoint coordinates of the arrow in the figure.;   
gen x1=.; gen x2=.; gen y1=.; gen y2=.;
replace x1 = q(1986q1) in 1; replace y1 = -5 in 1;
replace x2 = q(1986q1) in 1; replace y2 = 3 in 1;


*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(1986q1) directly as an arguement to "text".; 
local temp = q(1986q1);
local temp2 = q(2008q1);


*Make the figure.  The first line plots the 2 data series. The date range is specified in the "tin" statement.;
*The second line plots the arrow.  The rest of the code formats the figure. Note: if you name the graphs;
*they will open as tabs in the viewer, rather than replace the previous graph.;  
twoway  (tsline gdp_gr ind_gr if tin(1960q1, 2015q2), lp(solid dash) lc(blue red))
		(pcarrow y1 x1 y2 x2, lc(black) mc(black)),
		ylab(,nogrid tp(outside))
		tlab(1960q1(40)2020q1,nogrid tp(outside))
		tti("")
		yti("{bf} Growth rate (annual)", margin(medsmall))
		text(-5 `temp' "GDP", place(s))
		text(-15 `temp2' "Industrial production", place(w))
		legend(off)
		plotregion( lstyle(none) color(white) margin(medium) )
		graphregion(color(white) )
		name(us_gdp_indprod);

*Save the figure.;
graph export us_gdp_indprod.pdf, replace fontface(Times);


************************Figure: Cross-correlation plot S&P 500 and industrial production****************************;
* SP500 = S&P 500 price index (daily);
* INDPRO = industrial production index (monthly);

*FRED doesn't carry historical S&P500 data anymore.  (Thanks, lawyers.);
insheet using sp500.csv, clear;
rename date temp;
*Turn the string into a date;
gen temp2 = date(temp, "MDY");	format temp2 %td;
*Extract the monthly dates;		
gen date = mofd(temp2); 			format date %tm;
rename close SP500;
save temp.dta, replace;


*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  

*Old code;
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
*freduse SP500, clear;
*drop date;
*format daten %td;
*gen date = mofd(daten);
*format date %tm;
*The collapse command tranforms the daily data into monthly by averaging the daily observations.;
*We will save the data to a temporary file so that we can transform the monthly data, then;
*merge the two variables into one dataset.;
*collapse (mean) SP500, by(date);
*save temp.dta, replace;

*Load the data from FRED.;
*Drop the FRED supplied string variable "date" and create a STATA date variable.;
freduse INDPRO, clear;
drop date;
format daten %td;
gen date = mofd(daten);
format date %tm;

*Merge the industrial production data with the temp file containing the GDP data.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp.dta, nogen;
tsset date;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;
gen ind_gr = (S12.INDPRO/L12.INDPRO)*100;
gen sp5_gr = (S12.SP500/L12.SP500)*100;

*Make the figure. The date range is specified in the "tin" statement. The yline and xline commands draw;
*horizontal and vertical lines in the plot. The rest of the code formats the figure.;  
xcorr ind_gr sp5_gr if tin(1960m1, 2015m6),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("")
	tti("Lag in months relative to industrial production")
	yti("Cross-correlation with industrial production")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xcsp500);

*Save the figure. ;
graph export xcsp500.pdf, replace fontface(Times);


**********Figure: 4-panel cross-correlation plot of employment indicators and industrial procution *****************;
* INDPRO = industrial production index (monthly);
* PAYEMS = nonfarm payroll (monthly);
* LNS14100000 = obviously, the unemployment rate (monthly);
* AWHMAN = average weekly hours worked in manufacturing (monthly);
* ICSA = intital unemployment claims;

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
*We will save the data to a temporary file so that we can transform the weekly data, then;
*merge the two variables into one dataset.;
freduse PAYEMS LNS14100000 AWHMAN INDPRO, clear;
drop date;
format daten %td;
gen date = mofd(daten);
format date %tm;
save temp.dta, replace;

*Load the data from FRED.;
*Drop the FRED supplied string variable "date" and create a STATA date variable.;
*Set date to month/year of the observation. The collapse command tranforms the weekly data;
*into Monthly, by averaging the weekly observations.;
freduse ICSA, clear;
drop date;
format daten %td;
gen date = mofd(daten);
format date %tm;
collapse (mean) ICSA, by(date);

*Merge the data with the temp file containing the monthly variables.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp.dta, nogen;
tsset date;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;
gen ind_gr = (S12.INDPRO/L12.INDPRO)*100;
gen emp_gr = (S12.PAYEMS/L12.PAYEMS)*100;
gen une_gr = (S12.LNS14100000/L12.LNS14100000)*100;
gen clm_gr = (S12.ICSA/L12.ICSA)*100;
gen hrs_gr = (S12.AWHMAN/L12.AWHMAN)*100;

*The 4 blocks of code below each compute a cross-correlation figure with a variable against industrial production.;
*These 4 graphs are saved into memory using the name() option.  They will be combined later.;
*The date range is specified in the "tin" statement. The yline and xline commands draw;
*horizontal and vertical lines in the plot. The rest of the code formats the figure.; 
local start_date "1968m1";
local end_date "2015m6";
xcorr ind_gr emp_gr if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("Employment",c(black))
	tti("Lag in months relative to IP")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xemp);

xcorr ind_gr LNS14100000 if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("Unemployment rate",c(black))
	tti("Lag in months relative to industrial production")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xune);

xcorr ind_gr clm_gr if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("New claims",c(black))
	tti("Lag in months relative to IP")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xclm);

xcorr ind_gr hrs_gr if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("Hours worked",c(black))
	tti("Lag in months relative to IP")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xhrs);

*Combine the 4 plots into one plot.  Save the figure.;
graph combine xemp xune xclm xhrs,graphregion(color(white) ) name(xclabor);
graph export xclabor.pdf, replace fontface(Times);


**********Figure: 4-panel cross-correlation plot of employment indicators and industrial procution *****************;
* INDPRO = industrial production index (monthly);
* PERMIT = new private housing permits (monthly); 
* HOUST = new private housing starts (monthly);
* UMCSENT = U of M consumer sentiment (monthly);
* NAPM = purchasing managers index (monthly);

freduse PERMIT HOUST UMCSENT NAPM INDPRO, clear;
drop date;
format daten %td;
gen date = mofd(daten);
format date %tm;
tsset date;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;
gen ind_gr = (S12.INDPRO/L12.INDPRO)*100;
gen permit_gr = (S12.PERMIT/L12.PERMIT)*100;
gen start_gr = (S12.HOUST/L12.HOUST)*100;
gen sent_gr = (S12.UMCSENT/L12.UMCSENT)*100;
gen purch_gr = (S12.NAPM/L12.NAPM)*100;

*The 4 blocks of code below each compute a cross-correlation figure with a variable against industrial production.;
*These 4 graphs are saved into memory using the name() option.  They will be combined later.;
*The date range is specified in the "tin" statement. The yline and xline commands draw;
*horizontal and vertical lines in the plot. The rest of the code formats the figure.; 
local start_date "1961m1";
local end_date "2015m6";
xcorr ind_gr permit_gr if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("Building permits",c(black))
	tti("Lag in months relative to IP")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xpermit);

xcorr ind_gr start_gr if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("Housing starts",c(black))
	tti("Lag in months relative to industrial production")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xstart);

xcorr ind_gr sent_gr if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("Consumer sentiment",c(black))
	tti("Lag in months relative to IP")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xsent);

xcorr ind_gr purch_gr if tin(`start_date', `end_date'),
	yline(0, lc(black) lw(thin))
	xline(0, lc(black) lw(thin))
	lcolor(black) mcolor(black)
	ylab(,nogrid glc(black) tp(crossing))
	text(0.9 -10 "Leads IP",place(n))
	text(0.9 10 "Lags IP",place(n))
	title("Purchasing managers index",c(black))
	tti("Lag in months relative to IP")
	yti("Cross-correlation with IP")
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(xpurch);

*Combine the 4 plots into one plot.  Save the figure.;
graph combine xpermit xstart xsent xpurch,graphregion(color(white)) name(xcsurvey) ;
 
graph export xcsurvey.pdf, replace fontface(Times);


*****************************Figure: time series plots and standard deviation bands ********************************;
* PAYEMS = nonfarm payroll (monthly);
* HOUST = new private housing starts (monthly);
* INDPRO = industrial production index (monthly);
* IC4WSA = 4-week moving average of initial claims (weekly);

local start_date 1970m1;
local end_date 2015m6;

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
*We will save the data to a temporary file so that we can transform the weekly data, then;
*merge the two variables into one dataset.;
freduse PAYEMS INDPRO HOUST, clear;
drop date;
format daten %td;
gen date = mofd(daten);
format date %tm;
save temp.dta, replace;

*Load the data from FRED.;
*Drop the FRED supplied string variable "date" and create a STATA date variable.;
*Set date to month/year of the observation. The collapse command tranforms the weekly data;
*into Monthly, by averaging the weekly observations.;
freduse IC4WSA, clear;
drop date;
format daten %td;
gen date = mofd(daten);
format date %tm;
collapse (mean) IC4WSA, by(date);

*Merge the data with the temp file containing the monthly variables.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp.dta, nogen;
tsset date;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;
gen ind_gr = (S1.INDPRO/L1.INDPRO)*100*12;
gen emp_gr = (S1.PAYEMS/L1.PAYEMS)*100*12;
gen clm_gr = (S1.IC4WSA/L1.IC4WSA)*100*12;

*Compute the mean and standard deviation of the variable using the summary command. "Qui" means quietly.; 
*Then create "+ 1 s.d." and "- 1 s.d." to hold their values;
qui sum ind_gr;
local meanplus = `r(mean)'+`r(sd)';
local meanminus = `r(mean)'-`r(sd)';

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(1986q1) directly as an arguement to "text".; 
local temp = m(1990m1); 

*Make the figure.  The first line plots the data.  The yline commands draw horizontal lines at the;
*mean, mean+s.d., and mean-s.d.  The other lines are formatting.  Name the figure to save it to memory;
*we will combine figures later.;
twoway scatter ind_gr date if tin(`start_date', `end_date'), mstyle(none) connect(direct) lc(black)
	yline(`r(mean)', lc(black))
	yline(`meanplus', lc(black) lpattern(dash))
	yline(`meanminus', lc(black) lpattern(dash))
	ylab(-60(20)40,nogrid tp(crossing))
	yti("Growth rate (annual)")
	tti("")
	text(35 `temp' "mean plus 1 s.d.",place(e))
	text(-26 `temp' "mean minus 1 s.d.", place(e))
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	nodraw
	name(gind);
	
*Same as the block of code above, but for employment.;
qui sum emp_gr;
local meanplus = `r(mean)'+`r(sd)';
local meanminus = `r(mean)'-`r(sd)';
local temp = m(1992m1); 
twoway scatter emp_gr date if tin(`start_date', `end_date'),
	mstyle(none) connect(direct) lc(black)
	yline(`r(mean)', lc(black))
	yline(`meanplus', lc(black) lpattern(dash))
	yline(`meanminus', lc(black) lpattern(dash))
	ylab(-10(5)15,nogrid tp(crossing))
	yti("Growth rate (annual)")
	tti("")
	text(9.5 `temp' "mean plus 1 s.d.",place(e))
	text(-5 `temp' "mean minus 1 s.d.", place(e))
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	nodraw
	name(gemp);

*Combine the 2 plots into one plot.  Save the figure.;
graph combine gind gemp,cols(1) graphregion(color(white) ) name(scorecard_1);
graph export scorecard_1.pdf, replace fontface(Times);


*Same as above, but for new claims;
replace IC4WSA = IC4WSA/1000;
qui sum IC4WSA;
local meanplus = `r(mean)'+`r(sd)';
local meanminus = `r(mean)'-`r(sd)';
local temp = m(1988m6); 
local temp2 = m(1992m1);
twoway scatter IC4WSA date if tin(`start_date', `end_date'),
	mstyle(none) connect(direct) lc(black)
	yline(`r(mean)', lc(black))
	yline(`meanplus', lc(black) lpattern(dash))
	yline(`meanminus', lc(black) lpattern(dash))
	ylab(,nogrid tp(crossing))
	yti("New claims (1000s per week)")
	tti("")
	text(490 `temp2' "mean plus 1 s.d.",place(e))
	text(230 `temp' "mean minus 1 s.d.", place(e))
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	nodraw
	name(gclaim);

*Same as above, but for housing starts;
qui sum HOUST;
local meanplus = `r(mean)'+`r(sd)';
local meanminus = `r(mean)'-`r(sd)';
local temp = m(1996m1); 
local temp2 = m(1990m1);
twoway scatter HOUST date if tin(`start_date', `end_date'),
	mstyle(none) connect(direct) lc(black)
	yline(`r(mean)', lc(black))
	yline(`meanplus', lc(black) lpattern(dash))
	yline(`meanminus', lc(black) lpattern(dash))
	ylab(,nogrid tp(crossing))
	yti("Housing starts (1000s)")
	tti("")
	text(2050 `temp2' "mean plus 1 s.d.",place(e))
	text(900 `temp' "mean minus 1 s.d.", place(e))
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	nodraw
	name(gstarts);
	
*Combine the 2 plots into one plot.  Save the figure.;
graph combine gclaim gstarts,cols(1) graphregion(color(white) ) name(scorecard_2);
graph export scorecard_2.pdf, replace fontface(Times);
