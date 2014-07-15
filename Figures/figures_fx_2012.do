*******************************************************************************************************************;
************************************************FX*****************************************************************;
*This file creates the figures in the "Foreign Exchange" chapter of "The Global Economy" textbook.;
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
**************************************************Figure: various exchange rates*** *******************************;
* EXUSEU = US-euro exchange rate (monthly);
* EXJPUS = US-yen exchange rate (monthly);
* EXCHUS = US-yuan exchange rate (monthly);
* EXUSAL = US-australian dollar exchange rate (monthly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse EXUSEU EXJPUS EXUSAL EXCHUS;
drop date;
gen date = mofd(daten);
tsset date, monthly;

*Drop the observations before 2001.  This makes it easy divide through by 2001m1's value to normalize the series;
drop if date < tm(2001m1);

*Invert the EU and Australian rates so they are all in the same unit.;
replace EXUSEU = 1/EXUSEU;
replace EXUSAL = 1/EXUSAL;

*Make an index iwth Jan 01 = 100.;
gen idx_eu = EXUSEU/EXUSEU[1]*100;
gen idx_jp = EXJPUS/EXJPUS[1]*100;
gen idx_ch = EXCHUS/EXCHUS[1]*100;
gen idx_al = EXUSAL/EXUSAL[1]*100;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(2007m6) directly as an arguement to "text".; 
local temp = m(2007m6);
local temp2 = m(2012m2);
local temp3 = m(2002m8);

*Make the figure.  The first 2 lines plot the 4 data series. The rest of the code formats the figure.;
*Note: if you name the graphs they will open as tabs in the viewer, rather than replace the previous graph.; 
graph twoway tsline idx_eu idx_jp  idx_ch idx_al if tin(2001m1, 2012m6), 
	lp(solid dash dash_dot longdash_dot ) lc(blue red black purple)
	ylab(,nogrid tp(outside))
	tlab(2001m1 2003m1 2005m1 2007m1 2009m1 2011m7,nogrid tp(outside))
	tti("")
	yti("{bf} January 2001 = 100", margin(medsmall))
	text(110 `temp' "Yen")
	text(47 `temp2' "Aus. dollar", place(w))
	text(90 `temp3' "Euro", place(w))
	text(82 `temp2' "Yuan", place(w))
	legend(off)
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white))
	name(exchange);

*Save the figure.  On a PC, you can't directly save to PDF.;		
graph export exchange.eps, replace;


*******************************************************************************************************************;
**************************************************Figure: Venezuela************************************************;
*Data on Venezuela are not available on FRED.  This data is in the file "ge_data.csv" which is available;
*at www.stern.nyu.edu/GEMatters.  Load the data and parse the date column.; 
insheet using ge_data.csv, clear;
gen date = date(daten,"MDY");
replace date = mofd(date);
format date %tm;
tsset date, monthly;

*Compute the inflation rates for the US and VEN.  Then take their difference.;
gen inf_us = ln(us_cpi/L12.us_cpi)*100;
gen inf_vn = ln(vn_cpi/L12.vn_cpi)*100;
gen inf_diff = inf_vn-inf_us;

*Compute the exchange rate growth rates;
gen vnb_per_usd = 1/usd_per_vnb*1000;
gen dep = ln(vnb_per_usd/L12.vnb_per_usd)*100;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(1998m6) directly as an arguement to "text".; 
local temp = m(1998m6);

*Make the figure.  The first line plots the 2 data series. The rest of the code formats the figure.;
*Note: if you name the graphs they will open as tabs in the viewer, rather than replace the previous graph.; 
graph twoway (tsline  dep inf_diff, lc(blue red) lp(solid dash)  
	ylab(0 20 40 60 80 100,nogrid tp(outside) axis(1))
	tti("")
	yti("{bf} Rate (percent)", margin(medsmall) axis(1))
	text(110 `temp' "Exchange rate depreciation", place(s))
	text(38 `temp' "Inflation" "differential", place(e) justification(left))
	legend(off)
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white)) 
	name(venezuela) );
	
*Save the figure.  On a PC, you can't directly save to PDF.;		
graph export venezuela.eps, replace;


*******************************************************************************************************************;
**************************************************Figure: Euro*****************************************************;
* CPIAUCSL = US cpi (monthly);
* CP0000EZ17M086NEST = Euro area cpi (monthly);
* EXUSEU = US-euro exchange rate (monthly);

*Load all the data we will need from FRED. It's easiest to grab all the annual, monthly and quarterly data separately;  
*Drop the FRED supplied string variable "date" and create a STATA date variable.; 
freduse CPIAUCSL CP0000EZ17M086NEST EXUSEU, clear;
drop date;
gen date = mofd(daten);
tsset date, monthly;
rename CPIAUCSL cpi_us;
rename CP0000EZ17M086NEST cpi_euro;

*Compute year-on-year inflation rates, then the inflation diferential;
gen inf_us = ln(cpi_us/L12.cpi_us)*100;
gen inf_euro = ln(cpi_euro/L12.cpi_euro)*100;
gen inf_diff = inf_euro-inf_us;

*Depreciation rate of the dollar.;
gen dep = ln(EXUSEU/L12.EXUSEU)*100;

*The temp variables hold STATA-specific dates. These are need to place the textbox.  STATA won't accept;
*entering q(2004m3) directly as an arguement to "text".; 
local temp = m(2004m3);

*Make the figure.  The first line plots the 2 data series. The rest of the code formats the figure.;
*Note: if you name the graphs they will open as tabs in the viewer, rather than replace the previous graph.; 
graph twoway (tsline  dep inf_diff  if tin(2000m1, 2011m6), lc(blue red) lp(solid dash)  
	ylab(,nogrid tp(outside) axis(1))
	tti("")
	yti("{bf} Rate (percent)", margin(medsmall) axis(1))
	legend(off)
	text(-4 `temp' "Inflation" "differential", justification(left))
	text(20 `temp' "Exchange rate depreciation", justification(left) place(e))
	plotregion( lstyle(none) color(white) margin(medium) )
	graphregion(color(white) )
	name(us_eruor) );

*Save the figure.  On a PC, you can't directly save to PDF.;		
graph export us_euro.eps, replace;

















