# delimit;
clear all;
set varabbrev off;
set more off;
cd "C:\Users\kruhl\GitHub\Amazon_Global_Economy\Tables";

local table_year = 2013;		/*Year of the data for the table*/


/*TABLE 18.1*/
/*Get the data from FRED, extract the year from the date.*/
freduse BOPXGSA BOPMGSA BOPXCA BOPMCA BOPXRA BOPMIA BOPGA BOPBCAA BOPOPDA BOPIPDA BOPOPSA BOPIOGA BOPIOOA BOPIPTA BOPIPGA BOPOA BOPIA BOPCATA BOPOA BOPIA BOPIPCA BOPERRA;
gen year = year(daten);

/*Open the file to write.  Each table gets a separate file*/
file open fout using "tab_bop.tex", write replace;

/*The table header*/
file write fout "\begin{tabular*}{0.80\textwidth}{l@{\extracolsep{\fill}}r}" _n;
file write fout "\toprule" _n;

/*Net Exports of Goods and Services*/

gen NET_EXP = BOPXGSA + BOPMGSA;
qui sum NET_EXP if year == `table_year';
	file write fout "Net Exports of Goods and Services     & $"  %8.1fc (r(mean)) "$ \\" _n;


/*Net Labor Income from ROW*/

gen NET_LABORINC = BOPXCA + BOPMCA;
qui sum NET_LABORINC if year == `table_year';
	file write fout "Net Labor Income from ROW     & $"  %8.1fc (r(mean)) "$ \\" _n;


/*Net Capital Income from ROW*/

gen NET_CAPINC = BOPXRA + BOPMIA;
qui sum NET_CAPINC if year == `table_year';
	file write fout "Net Capital Income from ROW     & $"  %8.1fc (r(mean)) "$ \\" _n;


/*Net Taxes and Transfers from ROW*/

gen NET_TAXESTRANS = BOPGA;
qui sum NET_TAXESTRANS if year == `table_year';
	file write fout "Unilateral Current Transfers from ROW     & $"  %8.1fc (r(mean)) "$ \\" _n;


/*Current Account*/

gen NET_CC = BOPBCAA;
qui sum NET_CC if year == `table_year';
	file write fout "\textbf{Current Account}     & $\mathbf{"  %8.1fc (r(mean)) "}$ \\" _n;
file write fout "\addlinespace" _n;

/*Net Direct Investment in US*/

gen NET_DI = BOPOPDA + BOPIPDA;
qui sum NET_DI if year == `table_year';
	file write fout "Net direct investment in US     & $"  %8.1fc (r(mean)) "$ \\" _n;


/*Net Purchase of Securities*/

gen NET_SECUR = BOPOPSA + BOPIOGA + BOPIOOA + BOPIPTA + BOPIPGA;
qui sum NET_SECUR if year == `table_year';
	file write fout "Net Purchase of Securities     & $"  %8.1fc (r(mean)) "$ \\" _n;


/*Net Loans and Other*/

gen NET_LOANS = BOPOA + BOPIA - (BOPOPDA + BOPIPDA) - (BOPOPSA + BOPIOGA + BOPIOOA + BOPIPTA + BOPIPGA) ;
qui sum NET_LOANS if year == `table_year';
	file write fout "Net loans and other     & $"  %8.1fc (r(mean)) "$ \\" _n;


/*Capital and Financial Account*/

gen NET_CAPITALFINACCOUNT = BOPCATA + BOPOA + BOPIA + BOPIPCA;
qui sum NET_CAPITALFINACCOUNT if year == `table_year';
	file write fout "\textbf{Capital and Financial Account (inflows)}     & $\mathbf{"  %8.1fc (r(mean)) "}$ \\" _n;
file write fout "\addlinespace" _n;

/*Statistical Discrepancy*/

gen NET_STATDISC =BOPERRA;
qui sum NET_STATDISC if year == `table_year';
	file write fout "\textbf{Statistical Discrepancy}     & $\mathbf{"  %8.1fc (r(mean)) "}$ \\" _n;


/*The bottom of the table*/	
file write fout "\bottomrule" _n;
file write fout "\addlinespace" _n;
file write fout "\end{tabular*}" _n; 

/*Close the file.*/
file close fout;
