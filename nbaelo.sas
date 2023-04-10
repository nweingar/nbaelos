libname proj "/home/u59780635/STAT4120 Sp2023";

proc import 
  datafile='/home/u59780635/STAT4120 Sp2023/nba_elo.csv' 
  dbms=csv
  out=proj.nba
  replace;
run;

proc print data=proj.nba(obs=100);
run;

proc univariate data=proj.nba;
var elo1_post;
histogram;
run;

proc univariate data=proj.nba;
var quality;
histogram;
run;

proc freq data=proj.nba;
table quality;
run;

proc freq data=proj.nba;
table importance;
run;

proc freq data=proj.nba;
table total_rating;
run;

proc reg data=proj.nba;
model score1 = elo_prob1;
run;

proc univariate data=proj.nba;
var elo1_post;
histogram;
run;

proc univariate data=proj.nba;
var 'carm-elo1_post'n;
histogram;
run;

/*Making Binary Variable*/
data proj.nba;
set proj.nba;
if score1 > score2 then homewin = 1;
else homewin = 0;
run;

proc means data=proj.nba;
var homewin;
run;

proc freq data=proj.nba;
tables raptor1_pre;
run;

/*Making ELO Diff*/
data proj.nba;
set proj.nba;
elo_diff = elo1_pre - elo2_pre;
run;

proc logistic data=proj.nba descending plots=(oddsratio(cldisplay=serifarrow)roc);;
model homewin=elo_diff/lackfit aggregate scale=none;
output out=results p=predict l=lower u=upper xbeta=logit;

proc import 
  datafile='/home/u59780635/STAT4120 Sp2023/nba_elo_carmelos.csv' 
  dbms=csv
  out=proj.nbacarmelos
  replace;
run;

proc means data=proj.nbacarmelos;
var 'carm-elo1_pre'n;
run;

data proj.nbacarmelos;
set proj.nbacarmelos;
if score1 > score2 then homewin = 1;
else homewin = 0;
run;

proc logistic data=proj.nbacarmelos descending plots=(oddsratio(cldisplay=serifarrow)roc);;
model homewin='carm-elo_prob1'n/lackfit aggregate scale=none;
output out=results p=predict l=lower u=upper xbeta=logit;

proc import 
  datafile='/home/u59780635/STAT4120 Sp2023/nba_eloraptors.csv' 
  dbms=csv
  out=proj.nbaraptors
  replace;
run;

proc means data=proj.nbaraptors;
var raptor1_pre;
run;

data proj.nbaraptors;
set proj.nbaraptors;
if score1 > score2 then homewin = 1;
else homewin = 0;
run;

data proj.nbaraptors;
set proj.nbaraptors;
raptor_diff = raptor1_pre - raptor2_pre;
run;

proc logistic data=proj.nbaraptors descending plots=(oddsratio(cldisplay=serifarrow)roc);;
model homewin=raptor_diff/lackfit aggregate scale=none;
output out=results p=predict l=lower u=upper xbeta=logit;

proc freq data=proj.nba;
tables 'carm-elo1_pre'n;
run;

data proj.nbaplayed;
set proj.nba;
if season = 2023 then delete;
run;

data proj.nbaplayed;
set proj.nbaplayed;
if score1 > score2 then homewin = 1;
else homewin = 0;
run;

data proj.nbaplayed;
set proj.nbaplayed;
elo_diff = elo1_pre - elo2_pre;
run;

/*LOGISTIC 1 - ELO*/
title "Figure 1: ROC Curve for Logistic Regression Model of Elo Predicting Home Team Win";
proc logistic data=proj.nbaplayed descending plots=(oddsratio(cldisplay=serifarrow)roc);;
model homewin=elo_diff/lackfit aggregate scale=none;
output out=results p=predict l=lower u=upper xbeta=logit;

data proj.nbacarmelo;
set proj.nbacarmelos;
if season = 2023 then delete;
run;

/*LOGISTIC 2 - CARMELO*/
proc logistic data=proj.nbacarmelo descending plots=(oddsratio(cldisplay=serifarrow)roc);;
model homewin='carm-elo_prob1'n/lackfit aggregate scale=none;
output out=results p=predict l=lower u=upper xbeta=logit;

data proj.nbaraptor;
set proj.nbaraptors;
if season = 2023 then delete;
run;

/*LOGISTIC 3 - RAPTOR*/
proc logistic data=proj.nbaraptor descending plots=(oddsratio(cldisplay=serifarrow)roc);;
model homewin=raptor_diff/lackfit aggregate scale=none;
output out=results p=predict l=lower u=upper xbeta=logit;

data proj.nbaplayed;
set proj.nbaplayed;
scoretot = score1 + score2;
run;

/*SLR WITH QUALITY*/
proc reg data=proj.nbaplayed;
	id quality;
	model scoretot=quality; /*r CLM CLI;*/
run;

data proj.nba;
set proj.nba;
scoretot = score1 + score2;
run;

proc reg data=proj.nba;
	id quality;
	model scoretot=quality /r CLM CLI;
	output out=qualresults;
run;
	
/*BEGIN TWO WAY ANOVA TEST*/
proc freq data=proj.nbaplayed;
tables playoff*homewin;
run;

data proj.nbaplayed;
set proj.nbaplayed;
elo_change = elo1_post - elo1_pre;
run;

proc univariate data=proj.nbaplayed;
	class playoff homewin;
	var elo_change;
run;

PROC GLM DATA = proj.nbaplayed;
   CLASS playoff homewin;     /*First one in the class statement is the x axis of the interaction plot.*/
   MODEL elo_change = playoff homewin playoff*homewin /SS3;
   means playoff homewin /tukey lines;
RUN;
quit;

/*STRATIFIED BOXPLOTS OF ELO*/
data proj.nbabox;
set proj.nbaplayed;
where team1="BOS" or team1="NYK" or team1="LAL" or team1="DET" or team1="PHI";
run;

title "Figure 3: Stratified Boxplots of Elo by 5 Most Active Teams";
proc sgplot data=proj.nbabox;
	vbox elo1_post / category=team1;
run;

data proj.nbabox2;
set proj.nbacarmelo;
where team1="BOS" or team1="NYK" or team1="LAL" or team1="DET" or team1="PHI";
run;

title "Figure 4: Stratified Boxplots of Carmelo by 5 Most Active Teams";
proc sgplot data=proj.nbabox2;
	vbox 'carm-elo1_post'n / category=team1;
run;

data proj.nbabox3;
set proj.nbaraptor;
where team1="BOS" or team1="NYK" or team1="LAL" or team1="DET" or team1="PHI";
run;

title "Figure 5: Stratified Boxplots of Raptor by 5 Most Active Teams";
proc sgplot data=proj.nbabox3;
	vbox raptor1_pre / category=team1;
run;

data proj.nbaplayed;
set proj.nbaplayed;
elo_change = elo1_post - elo1_pre;
run;

/*CHI-SQUARE*/
data proj.nbaplayed2;
set proj.nbaplayed;
if elo_change < -10 then elo_changecat = "Large loss";
else if -10 < elo_change < 0 then elo_changecat = "Small loss";
else if elo_change = 0 then elo_changecat = "No change";
else if 10 > elo_change > 0 then elo_changecat = "Small gain";
else elo_changecat = "Large gain";
run;

data proj.nbaplayed2;
set proj.nbaplayed2;
if (playoff="c" or playoff="p" or playoff="f" or playoff="q" or playoff="s" or playoff="t") then playoffstatus = "y";
else playoffstatus = "n";
run;

proc freq data=proj.nbaplayed2;
table elo_changecat*playoffstatus / CHISQ EXPECTED DEVIATION NOROW NOCOL NOPERCENT;
run;

data proj.nbaplayed2;
set proj.nbaplayed2;
if playoffstatus="y" then playoffstatusq = 1;
else playoffstatusq=0;
run;

/*SELECTION BY CP*/
proc reg data=proj.nbaplayed2;
model scoretot = elo1_pre elo_diff playoffstatusq season quality
/ selection = cp adjrsq cp best=20 vif b;
run;

proc corr data=proj.nbaplayed2;
var elo1_pre elo_diff playoffstatusq season quality;
run;

/*BEST MODEL WITH MULTICOLLINEARITY CONSIDERED*/
proc reg data=proj.nbaplayed2;
model scoretot = elo_diff playoffstatusq season quality
/ selection = cp adjrsq cp best=20 vif b;
run;

data proj.nbaraptor;
set proj.nbaraptor;
raptor_diff = raptor1_pre - raptor2_pre;
carmelo_diff = 'carm-elo1_pre'n - 'carm-elo2_pre'n;
elo_diff = elo1_pre - elo2_pre;
if (playoff="c" or playoff="p" or playoff="f" or playoff="q" or playoff="s" or playoff="t") then playoffstatus = 1;
else playoffstatus = 0;
scoretot = score1 + score2;
run;

/*BEST MODEL WITH MODERN GAMES ONLY (2019 SEASON+)*/
proc reg data=proj.nbaraptor;
model scoretot = elo1_pre elo_diff playoffstatus season quality carmelo_diff 'carm-elo1_pre'n raptor_diff raptor1_pre
/ selection = cp adjrsq cp best=20 vif b;
run;

data proj.nbacarmelo;
set proj.nbacarmelo;
carmelo_diff = 'carm-elo1_pre'n - 'carm-elo2_pre'n;
elo_diff = elo1_pre - elo2_pre;
if (playoff="c" or playoff="p" or playoff="f" or playoff="q" or playoff="s" or playoff="t") then playoffstatus = 1;
else playoffstatus = 0;
scoretot = score1 + score2;
run;

/*MODEL FOR 2015-2019*/
proc reg data=proj.nbacarmelo;
model scoretot = elo1_pre elo_diff playoffstatus season quality carmelo_diff 'carm-elo1_pre'n
/ selection = cp adjrsq cp best=20 vif b;
run;

/*MULTICOLLINEARITY CONSIDERED*/
proc reg data=proj.nbacarmelo;
model scoretot = elo_diff playoffstatus season quality carmelo_diff
/ selection = cp adjrsq cp best=20 vif b;
run;

/*LINE CHARTS*/
data warriors;
set proj.nbaplayed;
where team1 = "GSW";
run;

symbol1 value=none interpol=sm color=gold;
proc gplot data=warriors;
	plot elo1_post * date;
run;

data bulls;
set proj.nbaplayed;
where team1="CHI";
run;

symbol1 value=none interpol=sm color=red;
proc gplot data=bulls;
	plot elo1_post * date;
run;

data cavs;
set proj.nbaplayed;
where team1 = "CLE";
run;

data finals2016;
set warriors cavs;
where season=2016;
run;

proc sort data=finals2016;
by team1;
run;

proc sgplot data=finals2016;
	reg x=date y=elo1_post / clm group=team1;
run;



