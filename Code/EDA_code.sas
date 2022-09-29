/**Creating a permanent library**/
libname custom '/home/u59397728/sasuser.v94/Assignment 2/Datasets';

/**Importing the 6 Datasets of 2016,2017,2018,2019,2020 and 2021**/
proc import datafile= "/home/u59397728/sasuser.v94/Assignment 2/CSV Files/AddisAbabaCentral_PM2.5_2016_YTD.csv"
                 out= custom.aac_2016(rename=('Date (LT)'n= DateLT 'NowCast Conc.'n = NowCastConc 
                 'AQI Category'n=AQI_Category 
                 'Raw Conc.'n=RawConc 'Conc. Unit'n= ConcUnit 'QC Name'n=QC_Name))
                 dbms=csv
                 replace;
                 guessingrows= max;
    run;   
    
proc import datafile= "/home/u59397728/sasuser.v94/Assignment 2/CSV Files/AddisAbabaCentral_PM2.5_2017_YTD.csv"
                 out= custom.aac_2017(rename=('NowCast Conc.'n = NowCastConc 'AQI Category'n=AQI_Category 
                 'Raw Conc.'n=RawConc 'Conc. Unit'n= ConcUnit 'QC Name'n=QC_Name 'Date (LT)'n= DateLT))
                 dbms=csv
                 replace;
                 guessingrows= max;
    run;  
    
proc import datafile= "/home/u59397728/sasuser.v94/Assignment 2/CSV Files/AddisAbabaCentral_PM2.5_2018_YTD.csv"
                 out= custom.aac_2018(rename=('NowCast Conc.'n = NowCastConc 'AQI Category'n=AQI_Category 
                 'Raw Conc.'n=RawConc 'Conc. Unit'n= ConcUnit 'QC Name'n=QC_Name 'Date (LT)'n= DateLT))
                 dbms=csv
                 replace;
                 guessingrows= max;
    run;    
    
proc import datafile= "/home/u59397728/sasuser.v94/Assignment 2/CSV Files/AddisAbabaCentral_PM2.5_2019_YTD.csv"
                 out= custom.aac_2019(rename=('NowCast Conc.'n = NowCastConc 'AQI Category'n=AQI_Category 
                 'Raw Conc.'n=RawConc 'Conc. Unit'n= ConcUnit 'QC Name'n=QC_Name 'Date (LT)'n= DateLT))
                 dbms=csv
                 replace;
                 guessingrows= max;
    run;    
    
proc import datafile= "/home/u59397728/sasuser.v94/Assignment 2/CSV Files/AddisAbabaCentral_PM2.5_2020_YTD.csv"
                 out= custom.aac_2020(rename=('NowCast Conc.'n = NowCastConc 'AQI Category'n=AQI_Category 
                 'Raw Conc.'n=RawConc 'Conc. Unit'n= ConcUnit 'QC Name'n=QC_Name 'Date (LT)'n= DateLT))
                 dbms=csv
                 replace;
                 guessingrows= max;
    run;    
    
proc import datafile= "/home/u59397728/sasuser.v94/Assignment 2/CSV Files/AddisAbabaCentral_PM2.5_2021_YTD.csv"
                 out= custom.aac_2021(rename=('NowCast Conc.'n = NowCastConc 'AQI Category'n=AQI_Category 
                 'Raw Conc.'n=RawConc 'Conc. Unit'n= ConcUnit 'QC Name'n=QC_Name 'Date (LT)'n= DateLT))
                 dbms=csv
                 replace;
                 guessingrows= max;
    run;   
    
    
/*Merging the 6 datasets*/    
data custom.aac_master (drop = Site Parameter ConcUnit Duration);
	set
	custom.aac_2016
	custom.aac_2017
	custom.aac_2018
	custom.aac_2019
	custom.aac_2020
	custom.aac_2021;     
    run;  
    
    
/*Checking for missing values*/ 
ods noproctitle;

proc format;
	value _nmissprint low-high="Non-missing";
	value $_cmissprint " "=" " other="Non-missing";
run;

proc freq data=CUSTOM.AAC_MASTER;
	title3 "Missing Data Frequencies";
	title4 h=2 "Legend: ., A, B, etc = Missing";
	format DateLT Year Month Day Hour NowCastConc AQI RawConc _nmissprint.;
	format AQI_Category QC_Name $_cmissprint.;
	tables DateLT Year Month Day Hour NowCastConc AQI AQI_Category RawConc QC_Name 
		/ missing nocum;
run;

proc freq data=CUSTOM.AAC_MASTER noprint;
	table DateLT * Year * Month * Day * Hour * NowCastConc * AQI * AQI_Category * 
		RawConc * QC_Name / missing out=Work._MissingData_;
	format DateLT Year Month Day Hour NowCastConc AQI RawConc _nmissprint.;
	format AQI_Category QC_Name $_cmissprint.;
run;

proc print data=Work._MissingData_ noobs label;
	title3 "Missing Data Patterns across Variables";
	title4 h=2 "Legend: ., A, B, etc = Missing";
	format DateLT Year Month Day Hour NowCastConc AQI RawConc _nmissprint.;
	format AQI_Category QC_Name $_cmissprint.;
	label count="Frequency" percent="Percent";
run;

title3;

/* Clean up */
proc delete data=Work._MissingData_;
run;    

/*checking for the count of missing values*/
PROC SQL;
Select count(*) as missing_values
FROM custom.aac_master
WHERE NowCastConc eq -999 OR RawConc eq -999 OR AQI eq -999;

/*code to fix missing values*/
PROC SQL;
delete from custom.aac_master 
WHERE NowCastConc eq -999 OR RawConc eq -999 OR AQI eq -999;

/*checking for accuracy of the variables in the master dataset*/
ods noproctitle;
ods graphics / imagemap=on;

proc means data=custom.aac_master chartype mean std min max n vardef=df;
	var Year Month Day Hour NowCastConc AQI RawConc;
	title 'Accuracy check for master Data set';
run;

/*checking for the count of out of range values*/
PROC SQL;
Select Count(*) as negative_values
FROM custom.aac_master
WHERE (NowCastConc<0 OR RawConc<0 OR AQI<0);
quit;

/*code to fix out of range values*/
PROC SQL;
delete from custom.aac_master
where (NowCastConc<0 OR RawConc<0 OR AQI<0);
quit;

/*checking for accuracy issues to spot any wrong labelling of AQI levels*/  
PROC SQL;
Select AQI, AQI_Category
from custom.aac_master
where AQI>=0 AND AQI<=50 AND NowCastConc >= 0 AND NowCastConc <= 12.0 AND 
AQI_Category ne 'Good';

Select AQI, AQI_Category
from custom.aac_master
where AQI>=51 AND AQI<=100 AND NowCastConc >= 12.1 AND NowCastConc <= 35.4 AND 
AQI_Category ne 'Moderate';

Select AQI, AQI_Category
from custom.aac_master
where AQI>=101 AND AQI<=150 AND NowCastConc >= 35.5 AND NowCastConc <= 55.4 AND 
AQI_Category ne 'Unhealthy for Sensitive Groups';

Select AQI, AQI_Category
from custom.aac_master
where AQI>=151 AND AQI<=200 AND NowCastConc >= 55.5 AND NowCastConc <= 150.4 AND 
AQI_Category ne 'Unhealthy'; 

Select AQI, AQI_Category
from custom.aac_master
where AQI>=201 AND AQI<=300 AND NowCastConc >= 150.5 AND NowCastConc <= 250.4 AND 
AQI_Category ne 'Very Unhealthy';

Select AQI, AQI_Category
from custom.aac_master
where AQI>=301 AND NowCastConc >= 250.5 and AQI_Category ne 'Hazardous';

Select AQI, AQI_Category
from custom.aac_master
where AQI>=301 AND NowCastConc >= 250.5 and AQI_Category ne 'Hazardous';
QUIT;

/*Code to find duplicate timestamp records*/
PROC SQL;
SELECT DateLT, COUNT(DateLT) as Count
FROM custom.aac_master
GROUP BY DateLT
HAVING COUNT(DateLT)>1;
Quit;

/*Code to delete multiple records with same timestamp*/
PROC SQL;
delete from custom.aac_master 
where Year = 2017 AND Month = 3 AND Day = 12 AND Hour = 3;

delete from custom.aac_master 
where Year = 2018 AND Month = 3 AND Day = 11 AND Hour = 3;

delete from custom.aac_master 
where Year = 2019 AND Month = 3 AND Day = 10 AND Hour = 3;
quit;  

/*Selecting values for every 6 hours*/
Data custom.aac_master;
set custom.aac_master;
where Hour IN (0,6,12,18);
run;

/*Monthly Boxplots to compare Air Pollution on yearly basis*/
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=CUSTOM.AAC_MASTER;
	vbox AQI / category=Month;
	where year eq 2016;
	yaxis grid;
	title '2016 monthly comparison';

proc sgplot data=CUSTOM.AAC_MASTER;
	vbox AQI / category=Month;
	where year eq 2017;
	yaxis grid;
	title '2017 monthly comparison';

proc sgplot data=CUSTOM.AAC_MASTER;
	vbox AQI / category=Month;
	where year eq 2018;
	yaxis grid;
	title '2018 monthly comparison';

proc sgplot data=CUSTOM.AAC_MASTER;
	vbox AQI / category=Month;
	where year eq 2019;
	yaxis grid;
	title '2019 monthly comparison';

proc sgplot data=CUSTOM.AAC_MASTER;
	vbox AQI / category=Month;
	where year eq 2020;
	yaxis grid;
	title '2020 monthly comparison';

proc sgplot data=CUSTOM.AAC_MASTER;
	vbox AQI / category=Month;
	where year eq 2021;
	yaxis grid;
	title '2021 monthly comparison';
run;
ods graphics / reset;
    
/*Boxplots to compare Air Pollution on yearly basis*/ 
PROC SGPLOT  DATA = custom.aac_master;
   VBOX AQI 
   / category = Year;

   title 'AQI Compared yearly';
RUN;    
 
/*Scatterplots to compare Air Pollution on yearly basis*/ 
proc sgplot data=custom.aac_master;
	reg x=DateLT y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI /;
	where year = 2016;
	xaxis grid;
	yaxis grid;
	title 'AQI vs. DateLT Compared monthly for 2016';
	
proc sgplot data=custom.aac_master;
	reg x=DateLT y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI /;
	where year = 2017;
	xaxis grid;
	yaxis grid;
	title 'AQI vs. DateLT Compared monthly for 2017';
	
proc sgplot data=custom.aac_master;
	reg x=DateLT y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI /;
	where year = 2018;
	xaxis grid;
	yaxis grid;
	title 'AQI vs. DateLT Compared monthly for 2018';
	
proc sgplot data=custom.aac_master;
	reg x=DateLT y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI /;
	where year = 2019;
	xaxis grid;
	yaxis grid;
	title 'AQI vs. DateLT Compared monthly for 2019';
	
proc sgplot data=custom.aac_master;
	reg x=DateLT y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI /;
	where year = 2020;
	xaxis grid;
	yaxis grid;
	title 'AQI vs. DateLT Compared monthly for 2020';
	
proc sgplot data=custom.aac_master;
	reg x=DateLT y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI /;
	where year = 2021;
	xaxis grid;
	yaxis grid;
	title 'AQI vs. DateLT Compared monthly for 2021';
	
proc sgplot data=custom.aac_master;
	reg x=DateLT y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI / group=year;
	xaxis grid;
	yaxis grid;
	title 'AQI vs. DateLT Compared yearly';	
	
run;
	
/*Histograms to compare Air Pollution on yearly basis*/ 
proc sgplot data=custom.aac_master;
    histogram AQI / group=year transparency=0.3;
    where year = 2016;
    density AQI / type=kernel; 

proc sgplot data=custom.aac_master;
    histogram AQI/group=year transparency=0.3;
    where year = 2017;
    density AQI / type=kernel; 

proc sgplot data=custom.aac_master;
    histogram AQI / group=year transparency=0.3;
    where year = 2018;
    density AQI / type=kernel; 

proc sgplot data=custom.aac_master;
    histogram AQI / group=year transparency=0.3;
    where year = 2019;
    density AQI / type=kernel; 

proc sgplot data=custom.aac_master;
    histogram AQI / group=year transparency=0.3;
    where year = 2020;
    density AQI / type=kernel; 

proc sgplot data=custom.aac_master;
    histogram AQI / group=year transparency=0.3;
    where year = 2021;
    density AQI / type=kernel; 
    
proc sgplot data=custom.aac_master;
    histogram AQI / group=year transparency=0.5;    
run;

/*Systematic sampling to select 4 records per month*/ 
PROC SURVEYSELECT 
Method = sys
seed=103
data = custom.aac_master(where=(year = 2016))
out= custom.aac_sample16
sampsize= 4;
strata month;

PROC SURVEYSELECT 
Method = sys
seed=104
data = custom.aac_master(where=(year = 2017))
out= custom.aac_sample17
sampsize= 4;
strata month;

PROC SURVEYSELECT 
Method = sys
seed=105
data = custom.aac_master(where=(year = 2018))
out= custom.aac_sample18
sampsize= 4;
strata month;

PROC SURVEYSELECT 
Method = sys
seed=106
data = custom.aac_master(where=(year = 2019))
out= custom.aac_sample19
sampsize= 4;
strata month;

PROC SURVEYSELECT 
Method = sys
seed=107
data = custom.aac_master(where=(year = 2020))
out= custom.aac_sample20
sampsize= 4;
strata month;

PROC SURVEYSELECT 
Method = sys
seed=108
data = custom.aac_master(where = (year = 2021 & Month^=9))
out= custom.aac_sample21
sampsize= 4;
strata month;
run;

/*merging all the sampledatasets into one master sample dataset*/
data custom.aac_sample;
	set
	custom.aac_sample16
	custom.aac_sample17
	custom.aac_sample18
	custom.aac_sample19
	custom.aac_sample20
	custom.aac_sample21;     
    run; 
 
/*AQI category Comparison among all years*/ 
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=CUSTOM.AAC_SAMPLE;
	vbar AQI_Category / group=Year groupdisplay=cluster;
	yaxis grid;
run;

ods graphics / reset;

/*AQI Correlation among all years*/
/* 1. Scatter Plot*/
proc sgplot data=custom.aac_sample;
	reg x=DateLt y=AQI / nomarkers cli alpha=0.01;
	scatter x=DateLT y=AQI / group=year;
	xaxis grid;
	yaxis grid;
	title 'AQI Levels Compared yearly';	
	
run;

/* 2. AQI Correlation analysis*/
ods noproctitle;
ods graphics / imagemap=on;

proc corr data=CUSTOM.AAC_SAMPLE pearson nosimple noprob plots=none;
	var AQI;
	with Year;
run;

