/*======================================================================
   Example of survey data 
 ======================================================================*/
data work.survey;            /* respondents + base weight + income */
   input hh_id base_wt income;  /*hh_id : household id*/
   datalines;
1 10.80 52000
2 11.10 61000
3 10.90 45000
4 11.30 70000
5 10.70 39000
;
run;

data work.bench;             /* admin (population) moments          */
   mean_income = 55000;      /* µ1: Assumed known population mean */  
   var_income  = 1.2e8;      /* µ2 ˜ (11 000)**2  : Assumed population variance */
run;

title "Current Mean estimate of income before EBW using Base Weights ";
proc means data=work.survey mean var nway;  
   var income;
   weight base_wt;  /* DESIGN-Weighted mean and variance */
run;

/*======================================================================
   ENTROPY-BALANCING WITH PROC OPTMODEL
 ======================================================================*/
/* Unlike in datasteps where set is used to read data ,
In the proc optmodel set HH;: Declares a set named HH to hold the identifiers for 
each respondent (household). This will be POPULATED from hh_id 
LATER IN THE READ DATA STATEMENT!!!.*/

proc optmodel printlevel=2; 
/*--------------------------------------------------------------
  1. index set and parameters
 --------------------------------------------------------------*/
   set HH;                                   /* respondent IDs         */

   num base_wt {HH};  /* Declares a numeric parameter base_wt indexed 
                         by the set HH this will store the base survey weights    */
   num inc      {HH};                        /* respondent income      */
   num mu1 , mu2;  /* Declares two numeric parameters mu1 and mu2 to store the 
                     target population mean and variance of income, 
                     respectively.*/

/*--------------------------------------------------------------
  2. decision variables & helper expressions
   This section defines what the optimizer will change 
   and how it will calculate intermediate values.
 --------------------------------------------------------------*/
   var w {HH} >= 0;     /* Declares a decision variable named w indexed by HH.
                            They will be the output calibrated weights !!! 
                             Produced for each household */

   impvar totW  = sum{i in HH} w[i]; /* Declares an implicit variable totW (total weight),
                                        This is an "implicit" variable because its value is 
                                        derived directly from the decision variables w[i].*/
   impvar meanW = (sum{i in HH} w[i]*inc[i]) / totW; /*weighted average */
   impvar varW  = (sum{i in HH} w[i]*(inc[i]-mu1)**2) / totW; /*weighted variance */

   min Entropy = sum{i in HH} w[i]*log(w[i]/base_wt[i]);  /* This is the punch line; 
                                                             This is the objective function 
                                                             of the optimiztion problem 
                                                             Kullback-Leibler (KL) divergence 
                                                             or relative entropy.*/

/*--------------------------------------------------------------
  3. load data
 --------------------------------------------------------------*/
   read data work.survey
        into HH=[hh_id] base_wt inc = income;

   read data work.bench
        into  mu1 = mean_income mu2 = var_income;

/*--------------------------------------------------------------
  4. constraints
 --------------------------------------------------------------*/
   con MeanMatch: meanW = mu1;
   con VarMatch : varW  = mu2;

/*--------------------------------------------------------------
  5. PROBLEM 1 - match the mean only
 --------------------------------------------------------------*/
   problem EBW_Mean
           include Entropy MeanMatch w;

   use problem EBW_Mean;
   solve with nlp / alg=interiorpoint;

   create data work.ebw_mean
          from [hh_id]=HH 
		       income=inc
               w 
               meanW varW Entropy;

/*--------------------------------------------------------------
  6. PROBLEM 2 - match mean + variance
 --------------------------------------------------------------*/
   problem EBW_MeanVar
           include Entropy MeanMatch VarMatch w ;

   use problem EBW_MeanVar;
   solve with nlp;

   create data work.ebw_meanvar
          from [hh_id]=HH income=inc w meanW varW Entropy;
quit;

/*======================================================================
   Quick verification
 ======================================================================*/
title "Mean-only calibration";
proc means data=work.ebw_mean mean var nway;
   var income;
   weight w;
run;



/*** This is the corrected code ***/

data red1 qc ;
  retain count 0 countw 0 ;
 set work.ebw_mean end=eof;
 count =count+w*(income-meanWincome)**2;
 countw=counw+w;
 if eof then do; 
         estimated_var_after_ebw = count/countw;
         output qc ;
 end;
 output red1;
 run;


data red1  /* full detail, one row per record                          */
     qc    /* one-row summary with weighted variance after EBW         */;
   set work.ebw_mean end=eof;
   retain sum_wx2 sum_w;

   /* Running totals (sum-statement syntax automatically retains) */
   sum_wx2 + w*(income - meanW)**2;   /* S w_i (x_i - µ)^2 */
   sum_w   + w;                       /* S w_i              */
   if eof then do;
      estimated_var_after_ebw = sum_wx2 / sum_w;
      output qc;                       /* write one row      */
   end;
  output red1;                       /* keep every record  */

run;


title "Mean + variance calibration";
proc means data=work.ebw_meanvar mean var nway;
   var income;
   weight w;
run;
