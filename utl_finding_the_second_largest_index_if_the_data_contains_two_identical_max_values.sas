Finding the second largest index if the data contains two identical max values

   WPS and SAS give the same results

   Two Solutions

      1. WPS/Proc R ot SAS/IML/R
      2. WPS/SAS datastep

   Note
      largest(2, of values[*]); cannot be used;


https://goo.gl/2YyzVu
https://communities.sas.com/t5/SAS-Enterprise-Guide/Finding-the-second-max-if-the-data-contains-two-identical-max/m-p/430348


INPUT
=====

 Algorithm
   1.  Identify the index of the largest (whichn(max_1, of values[*]);
   2.  Set the value of the lagest to the smallest possible value -1*constant('big');
   3.  Find the next maximum (whichn(max_1, of values[*]);

 WORK.HAVE total obs=3                  |  RULES
                                        |
  NAMES     SA     QU    COMP    LST    |
                                        |
   Ab      522    345     478    522    |  first(SA) and second largest(LST)
                                        |  are in column 2 and 5 respectively
   Bb      689    745     745    298    |
   cb      323    467     698    718    |


  NAMES    NAME_1  COLUMN_1 MAX_1      NAME_2  COLUMN_2  MAX_2

   Ab       SA         2     522        LST        5      522
   Bb       QU         3     745        COMP       4      745
   cb       LST        5     718                   .        .   * no second maximum



PROCESS (All the WPS Code)
==========================

   WPS/SAS

      %utl_submit_wps64('
      libname wrk sas7bdat "%sysfunc(pathname(work))";
      data wrk.wantwps(drop=sa qu comp lst);

         retain names name_1 column_1 max_1 name_2 column_2 max_2;
         length name_1 name_2 $32.;

         set wrk.have;
         array values SA QU COMP LST;

         max_1    = largest(1, of values[*]);
         column_1 = whichn(max_1, of values[*]);
         name_1   = vname(values[column_1]);
         values[column_1] = -constant("big");  * make lagest the smallest possible;

         max_2    = largest(1, of values[*]);
         column_2 = whichn(max_2, of values[*]);
         name_2   = vname(values[column_2]);

         column_1=column_1+1; * names is column 1 so add 1;
         column_2=column_2+1;

         if max_1 ne max_2 then call missing(max_2,column_2,name_2);

      run;quit;
      ');

   WPS/PROC R SAS/IML/R

      %utl_submit_wps64('
      libname sd1 sas7bdat "d:/sd1";
      options set=R_HOME "C:/Program Files/R/R-3.3.2";
      libname wrk sas7bdat "%sysfunc(pathname(work))";
      libname hlp sas7bdat "C:\Program Files\SASHome\SASFoundation\9.4\core\sashelp";
      proc r;
      submit;
      source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
      library(haven);
      have<-read_sas("d:/sd1/have.sas7bdat");
      want<-t(apply(have[,-1],1,function(x) tail( order(x), 2 )));
      want;
      endsubmit;
      import r=want data=wrk.wantr;
      run;quit;
      ');

      data want;
        merge sd1.have wantr;
        array values SA QU COMP LST;
        if values[v1] ne values[v2] then v2=.;
        name_1=vname(values[v1];
        name_2=vname(values[v3];
      run;quit;

OUTPUT
=====


  NAMES    NAME_1  COLUMN_1 MAX_1      NAME_2  COLUMN_2  MAX_2

   Ab       SA         2     522        LST        5      522
   Bb       QU         3     745        COMP       4      745
   cb       LST        5     718                   .        .   * no second maximum

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  input names $ sa qu comp lst;
cards4;
ab 522 345 478 522
bb 689 745 745 298
cb  323 467 698 718
;;;;
run;quit;

*
 ___  ___  ___   _ __  _ __ ___   ___ ___  ___ ___
/ __|/ _ \/ _ \ | '_ \| '__/ _ \ / __/ _ \/ __/ __|
\__ \  __/  __/ | |_) | | | (_) | (_|  __/\__ \__ \
|___/\___|\___| | .__/|_|  \___/ \___\___||___/___/
                |_|
;
