# delimit;
clear all;
set varabbrev off;
set more off;
cd "C:\Users\kruhl\GitHub\Amazon_Global_Economy\Tables";

local table_year = 2013;		/*Year of the data for the table*/

/*--------------------------------------------------------------------------------------------------*/
/*TABLE 2.4*/
/*Get the data from FRED, extract the year from the date.*/
freduse PCECA PCDGA GDPA PCNDA PCESVA GPDIA PNFIA PRFIA CBIA GCEA A019RC1A027NBEA EXPGSA IMPGSA GDPA ;
gen year = year(daten);

/*Open the file to write.  Each table gets a separate file*/
file open fout using "tab_nipa_expenditure.tex", write replace;

/*The table header*/
file write fout "\begin{tabular*}{1.0\textwidth}{l@{\extracolsep{\fill}}rrr}" _n;
file write fout "\toprule" _n;
file write fout        "&        & \\$ billions & Percent of GDP \\" _n;
file write fout "\midrule" _n;


/*Total Consumption*/
qui sum PCECA if year == `table_year';
	file write fout "Consumption     & "  %8.1fc (r(mean)) ;

gen PCECA_share = PCECA/GDPA*100;
qui sum PCECA_share if year == `table_year';
	file write fout "&             & " %4.1f (r(mean)) "\%    \\" _n;	

/*Durable Consumption*/

qui sum PCDGA if year == `table_year';
	file write fout "\hspace{.5cm}Durable goods      &  & "  %8.1fc (r(mean)) " & \\" _n;

/*Nondurable Consumption*/

qui sum PCNDA if year == `table_year';
	file write fout "\hspace{.5cm}Nondurable goods     &  & "  %8.1fc (r(mean)) " & \\" _n;

/*Services*/

qui sum PCESVA if year == `table_year';
	file write fout "\hspace{.5cm}Services     &  & "  %8.1fc (r(mean)) " & \\" _n;

/*Total Investment*/
qui sum GPDIA if year == `table_year';
	file write fout "Gross private investment     & "  %8.1fc (r(mean)) ;

gen GPDIA_share = GPDIA/GDPA*100;
qui sum GPDIA_share if year == `table_year';
	file write fout "&             & " %4.1f (r(mean)) "\%    \\" _n;	


/*Nonresidential*/

qui sum PNFIA if year == `table_year';
	file write fout "\hspace{.5cm}Nonresidential      &  & "  %8.1fc (r(mean)) " & \\" _n;


/*Residential*/

qui sum PRFIA if year == `table_year';
	file write fout "\hspace{.5cm}Residential      &  & "  %8.1fc (r(mean)) " & \\" _n;


/*Change in inventories*/

qui sum CBIA if year == `table_year';
	file write fout "\hspace{.5cm}Change in inventories      &  & "  %8.1fc (r(mean)) " & \\" _n;


/*Government Consumption*/
qui sum GCEA if year == `table_year';
	file write fout "Government consumption     & "  %8.1fc (r(mean)) ;

gen GCEA_share = GCEA/GDPA*100;
qui sum GCEA_share if year == `table_year';
	file write fout "&             & " %4.1f (r(mean)) "\%    \\" _n;	


/*Net exports of goods and services*/
qui sum A019RC1A027NBEA if year == `table_year';
	file write fout "Net exports of goods and services     & " "$" %8.1fc (r(mean)) "$" ;

gen A019RC1A027NBEA_share = A019RC1A027NBEA/GDPA*100;
qui sum A019RC1A027NBEA_share if year == `table_year';
	file write fout "&             & " "$" %4.1f (r(mean)) "\%  $   \\" _n;	


/*Exports*/
qui sum EXPGSA if year == `table_year';
	file write fout "\hspace{.5cm}Exports     & & "  %8.1fc (r(mean)) " \\" _n;

/*Imports*/
qui sum IMPGSA if year == `table_year';
	file write fout "\hspace{.5cm}Imports     & & "  %8.1fc (r(mean)) "\\" _n;

file write fout "\midrule" _n;

/*Gross Domestic Product*/
qui sum GDPA if year == `table_year';
	file write fout "Gross domestic product     & "  %8.1fc (r(mean)) " & & " %4.1f (100) "\%    \\" _n;	

	
/*The bottom of the table*/	
file write fout "\bottomrule" _n;
file write fout "\end{tabular*}" _n; 

/*Close the file.*/
file close fout;


*********************************************************************************************************;
*********************************************************************************************************;
/*TABLE 2.3*/
/*Get the data from FRED, extract the year from the date.*/
clear all;
freduse GDICOMPA A041RC1A027NBEA A445RC1A027NBEA A048RC1A027NBEA W272RC1A027NBEA GDITAXESA GDISUBSA B029RC1A027NBEA A108RC1A027NBEA GDICONSPA GDIA GDPA GDIA;
gen year = year(daten);

/*Open the file to write.  Each table gets a separate file*/
file open fout using "tab_nipa_income.tex", write replace;

/*The table header*/
file write fout "\begin{tabular*}{0.7\textwidth}{l@{\extracolsep{\fill}}r}" _n;
file write fout "\toprule" _n;

/*Compensation of employees*/

qui sum GDICOMPA if year == `table_year';
	file write fout "Compensation of employees     & "  %8.1fc (r(mean)) " \\" _n;

/*Proprietor's income*/

qui sum A041RC1A027NBEA if year == `table_year';
	file write fout "Proprietor's income     & "  %8.1fc (r(mean)) " \\" _n;

/*Corporate profits*/

qui sum A445RC1A027NBEA if year == `table_year';
	file write fout "Corporate profits     & "  %8.1fc (r(mean)) " \\" _n;

/*Rental Income*/

qui sum A048RC1A027NBEA if year == `table_year';
	file write fout "Rental income     & "  %8.1fc (r(mean)) " \\" _n;

/*Net Interest Income*/

qui sum W272RC1A027NBEA if year == `table_year';
	file write fout "Net interest income     & "  %8.1fc (r(mean)) " \\" _n;

/*Taxes and miscellaneous*/

gen TAXES_MISC = GDITAXESA - GDISUBSA + B029RC1A027NBEA +A108RC1A027NBEA;
qui sum TAXES_MISC if year == `table_year';
	file write fout "Taxes and miscellaneous     & "  %8.1fc (r(mean)) " \\" _n;

/*Depreciation*/

qui sum GDICONSPA if year == `table_year';
	file write fout "Depreciation     & "  %8.1fc (r(mean)) " \\" _n;



file write fout "\midrule" _n;



/*Gross Domestic Product*/

qui sum GDIA if year == `table_year';
	file write fout "Gross domestic product     & "  %8.1fc (r(mean)) " \\" _n;

/*Statistical Discrepancy*/

gen STAT_DISC = GDPA-GDIA;
qui sum STAT_DISC if year == `table_year';
	file write fout "Statistical discrepancy     & "  %8.1fc (r(mean)) " \\" _n;


/*The bottom of the table*/	
file write fout "\bottomrule" _n;
file write fout "\end{tabular*}" _n; 

/*Close the file.*/
file close fout;


