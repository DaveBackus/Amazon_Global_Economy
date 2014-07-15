*******************************************************************************************************************;
*****************************************Business Cycle Properties*************************************************;
*This file creates the figures in the "Business Cycle properties" chapter of "The Global Economy" textbook.;
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


*All the figures in this chapter cover the same timespan.;
local start_date "1960q1";
local end_date "2013q2";

*********************************Figure: US GDP levels and growth rates*********************************************;
* GDPC1 = real GDP (quarterly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse GDPC1;
drop date;
gen date = qofd(daten);
tsset date, quarterly;

*Make the LEVELS figure.  The first line plots the data series. The date range is specified in the "tin" statement.;
*The rest of the code formats the figure. These 4 graphs are saved into memory using the name() option.;
*They will be combined later.;  
graph twoway tsline GDPC1 if tin(`start_date', `end_date'), lp(solid) lc(blue)  
	ylab(,nogrid tp(crossing))
	tlab(,nogrid tp(crossing))
	tti("")
	yti("{bf} U.S. dollars (billions)", margin(medsmall))
	legend(bmargin(medium))
	plotregion(lstyle(none)color(white) margin(medium) )
	graphregion(color(white))
	name(gdp_graph);

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;	
gen gdp_gr = S4.GDPC1/L4.GDPC1*100;

*Make the GROWTH RATES figure.  The first line plots the data series. The date range is specified in the "tin" statement.;
*The rest of the code formats the figure. These 4 graphs are saved into memory using the name() option.;
*They will be combined later.;  
graph twoway tsline gdp_gr if tin(`start_date', `end_date'), lp(solid) lc(blue)  
	ylab(,nogrid tp(crossing))
	tlab(,nogrid tp(crossing))
	tti("")
	yti("{bf} Year-on-year growth rate", margin(medsmall))
	legend(bmargin(medium))
	plotregion(lstyle(none)color(white) margin(medium) )
	graphregion(color(white))
	name(gdp_gr_graph);

*Combine the 4 plots into one plot.  Save the figure.  On a PC, you can't directly save to PDF.;
graph combine gdp_graph gdp_gr_graph, cols(1) graphregion(color(white));
graph export us_gdp.eps, replace;


****************************Figure: US GDP, consumption, investment growth rates************************************;
* GDPC1 = real GDP (quarterly);
* PCECC96 = real PCE (quarterly);
* GDPIC96 = real gross private investment (quarterly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse GDPC1 PCECC96 GPDIC96, clear;
drop date;
gen date = qofd(daten);
tsset date, quarterly;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;	
gen gdp_gr = S4.GDPC1/L4.GDPC1*100;
gen con_gr = S4.PCECC96/L4.PCECC96*100;
gen inv_gr = S4.GPDIC96/L4.GPDIC96*100;

*These two blocks of code creates (x1,y1),(x2,y2),...: the endpoint coordinates of the arrows in the figure.;   
gen x1=.; gen x2=.; gen y1=.; gen y2=.;
replace x1 = q(1974q1) in 1; replace y1 = 30 in 1;
replace x2 = q(1975q1) in 1; replace y2 = 2 in 1;

gen x3=.; gen x4=.; gen y3=.; gen y4=.;
replace x3 = q(1977q1) in 1; replace y3 = -30 in 1;
replace x4 = q(1975q2) in 1; replace y4 = -3 in 1;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(1986q1) directly as an arguement to "text".; 
local temp = q(1977q1);
local temp2 = q(1974q1);
local temp3 = q(2007q4);

*Make the figure.  The first line plots the 2 data series. The date range is specified in the "tin" statement.;
*The next two lines plot the arrows.  The rest of the code formats the figure. Note: if you name the graphs;
*they will open as tabs in the viewer, rather than replace the previous graph.;  
graph twoway (tsline gdp_gr con_gr inv_gr if tin(`start_date', `end_date'), lp(solid dash solid) lc(blue red purple))  
	(pcarrow y1 x1 y2 x2, lc(black) mc(black))
	(pcarrow y3 x3 y4 x4, lc(black) mc(black)),  
	ylab(,nogrid tp(crossing))
	tlab(,nogrid tp(crossing))
	tti("")
	yti("{bf} Year-on-year growth rate", margin(medsmall))
	text(-30 `temp' "GDP", place(se))
	text(30 `temp2' "Consumption", place(nw))
	text(-30 `temp3' "Investment", place(nw))
	legend(off)
	plotregion(lstyle(none)color(white) margin(medium) )
	graphregion(color(white))
	name(us_inv_cons_gdp);

*Save the figure.  On a PC, you can't directly save to PDF.;
graph export us_inv_cons_gdp.eps, replace; 


****************************Figure: US GDP, consumption, investment growth rates************************************;
* GDPC1 = real GDP (quarterly);
* PAYEMS = nonfarm payroll (monthly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
*We will save the data to a temporary file so that we can transform the weekly data, then;
*merge the two variables into one dataset.;
freduse GDPC1,clear;
drop date;
gen date = qofd(daten);
save temp.dta, replace;

*Load all the data we will need from FRED. Drop the FRED supplied string variable "date";
*and create a STATA date variable.  The collapse command tranforms the monthly data;
*into quarterly, by averaging the monthly observations.;
freduse PAYEMS, clear;
drop date;
format daten %tm;
gen date = qofd(daten);
format date %tq;
collapse (mean) PAYEMS, by(date);

*Merge the data with the temp file containing the monthly variables.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp.dta, nogen;
tsset date;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;
gen gdp_gr = S4.GDPC1/L4.GDPC1*100;
gen emp_gr = S4.PAYEMS/L4.PAYEMS*100;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(1986q1) directly as an arguement to "text".; 
local temp = q(1985q1);
local temp2 = q(2005q1);

*Make the figure.  The first line plots the 2 data series. The date range is specified in the "tin" statement.;
*The rest of the code formats the figure. Note: if you name the graphs;
*they will open as tabs in the viewer, rather than replace the previous graph.;  
graph twoway tsline gdp_gr emp_gr if tin(`start_date', `end_date'), lp(solid dash ) lc(blue red)  
	ylab(,nogrid tp(crossing))
	tlab(,nogrid tp(crossing))
	tti("")
	yti("{bf} Year-on-year growth rate", margin(medsmall))
	legend(off)
	text(9.0 `temp' "GDP")
	text(-2 `temp2' "Employment", place(w))
	plotregion(lstyle(none)color(white) margin(medium) )
	graphregion(color(white))
	name(us_emp_gdp);

*Save the figure.  On a PC, you can't directly save to PDF.;
graph export us_emp_gdp.eps, replace;  

******************************Figure: US GDP, S&P 500 growth rates**************************************************;
* GDPC1 = real GDP (quarterly);
* SP500 = S&P 500 price index (daily);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
*We will save the data to a temporary file so that we can transform the weekly data, then;
*merge the two variables into one dataset.;
freduse SP500,clear;
drop date;
format daten %td;
gen date = qofd(daten);
format date %tq;

*The collapse command tranforms the daily data into quarterly by averaging the daily observations.;
*We will save the data to a temporary file so that we can merge it with the quarterly variables;
collapse (mean) SP500, by(date);
save temp.dta, replace;

*Load all the data we will need from FRED. Drop the FRED supplied string variable "date";
*and create a STATA date variable.;
freduse GDPC1,clear;
drop date;
gen date = qofd(daten);
format date %tq;

*Merge the data with the temp file containing the monthly variables.;
*The tsset operation declares the dataset to be a timeseries, indexed by the variable "date".;
merge 1:1 date using temp.dta, nogen;
tsset date;

*Compute the year-on-year growth rates.  The "S" operator is a difference operator, so S4 is x_t - x_{t-4},;
*and the "L" operator is the lag operator;
gen gdp_gr = S4.GDPC1/L4.GDPC1*100;
gen sp500_gr = S4.SP500/L4.SP500*100;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(1986q1) directly as an arguement to "text".; 
local temp = q(1998q1);
local temp2 = q(2007q4);

*These two blocks of code creates (x1,y1),(x2,y2),...: the endpoint coordinates of the arrow in the figure.; 
gen x1=.; gen x2=.; gen y1=.; gen y2=.;
replace x1 = q(1996q2) in 1; replace y1 = -5 in 1;
replace x2 = q(1998q2) in 1; replace y2 = 2 in 1;

*Make the figure.  The first line plots the 2 data series. The second line plots the arrow.;
*The date range is specified in the "tin" statement. The rest of the code formats the figure.;
*Note: if you name the graphs they will open as tabs in the viewer, rather than replace the previous graph.; 
twoway (tsline gdp_gr sp500_gr if tin(`start_date', `end_date'), lp(solid dash) lc(blue red))
		(pcarrow y1 x1 y2 x2, lc(black) mc(black)),  
		ylab(,nogrid tp(crossing))
		tlab(,nogrid tp(crossing))
		tti("")
		yti("{bf} Year-on-year growth rate", margin(medsmall))
		legend(off)
		text(-10 `temp' "GDP", place(w))
		text(-35 `temp2' "S&P 500", place(w))
		plotregion(lstyle(none)color(white) margin(medium) )
		graphregion(color(white));
		
*Save the figure.  On a PC, you can't directly save to PDF.;		
graph export us_gdp_sp500.eps, replace;

