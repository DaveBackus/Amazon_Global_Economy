*******************************************************************************************************************;
*****************************************The Solow Growth Model****************************************************;
*This file creates the figures in the "The Solow Growth Model" chapter of "The Global Economy" textbook.;
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


*******************************Figure: Output, savings, and depreciation against capital*****************************;
*Set the parameter values.;
* delta = depreciation rate;
* s = savings rate;
* alpha = labor's share in Cobb-Douglas production function;
* L = size of population;
local delta = 0.1;
local s = 0.2;
local alpha = 0.33333;
local L = 100;

*Generate a grid from 1 to 500 for the capital stock.  Compute output, total savings and total depreciation.;
set obs  500;
gen K = _n; 
gen Y = K^`alpha' * `L'^(1-`alpha'); 
gen S = Y*`s';
gen D = K*`delta';

*Make the figure. The first 3 lines plot Y against K, S against K, and D against K.;
*The rest of the code formats the figure.;
twoway 	(scatter Y K, mstyle(none) connect(direct) lc(red)) 
		(scatter S K, mstyle(none) connect(direct) lc(blue))
		(scatter D K, mstyle(none) connect(direct) lc(black)),
		ylab(,nogrid tp(crossing))
		xlab(0(100)400)
		xti("Capital")
		yti("")
		text(110 180 "Output")
		text(25 50 "Savings")
		text(5 100 "Depreciation", place(e))
		legend(off)
		plotregion( lstyle(none) color(white) margin(medium) )
		graphregion(color(white) )
		name(solow1);
		
*Save the figure.  On a PC, you can't directly save to PDF.;
graph export solow1.eps, replace;


********************************Figure: The effect of a higher savings rate******************************************;
*In this figure we express everything in per-capita terms, so divide through by the population.;
*The variable "s2" is the total savings per capita at the new, higher, savings rate 0.25.;
gen d = D/`L';
gen s1 = S/`L';
gen s2 = Y*0.25/`L';
gen k = K/`L';

*Make the figure. The first 3 lines plot s1 against k, s2 against k, and d against k.;
*The rest of the code formats the figure.;
twoway 	(scatter s2 k, mstyle(none) connect(direct) lc(blue) lpattern(_####) ) 
		(scatter s1 k, mstyle(none) connect(direct) lc(blue))
		(scatter d k, mstyle(none) connect(direct) lc(black)),
		ylab(,nogrid tp(crossing)  format(%03.1f) angle(horizontal))
		xlab(,tp(crossing) ) 
		xti("Capital per worker")
		yti("")
		text(0.37 1 "Higher savings per worker",place(e))
		text(0.29 4.1 "Savings per worker")
		text(0.1 1.25 "Depreciation per worker", place(e))
		legend(off)
		plotregion( lstyle(none) color(white) margin(medium) )
		graphregion(color(white) )
		name(solow2);

*Save the figure.  On a PC, you can't directly save to PDF.;
graph export solow2.eps, replace;
