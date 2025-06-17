/*-------------------------------------------------------------*
 | Step 1: Input the sample household data                     |
 | Each row has a household ID, an inflation weight,          |
 | and its associated expenditure (e.g., monthly cost).        |
 *-------------------------------------------------------------*/
data hh_data;
   input hhid $ infl_wt expenditure;
   datalines;
HH001  1.1 1200
HH002  0.9 1400
HH003  1.3 1700
HH004  1.0 1600
HH005  0.7 1800
;
run;

/*-------------------------------------------------------------*
 | Step 2: Launch PROC OPTMODEL — the optimization engine in SAS|
 | We now declare all the elements required to optimize the    |
 | new weights w_new subject to some calibration constraints.  |
 *-------------------------------------------------------------*/
proc optmodel;

   /*----------------------------------------------------------*
    | Declare a string-indexed set HH to hold all HHIDs        |
    | Syntax:                                                  |
    |   set <str> SetName;                                     |
    | This tells OPTMODEL that we’ll be indexing by strings.   |
    *----------------------------------------------------------*/
   set <str> HH;

   /*----------------------------------------------------------*
    | Declare parameter arrays (indexed by HHIDs)              |
    | infl_wt: Original weights from data                      |
    | expenditure: The cost (used to calibrate the mean)       |
    | Syntax:                                                  |
    |   number paramName{IndexSet};                            |
    *----------------------------------------------------------*/
   number infl_wt{HH};
   number expenditure{HH};

   /*----------------------------------------------------------*
    | Read values from the SAS dataset 'hh_data'               |
    | into the set HH and param arrays                         |
    | Syntax:                                                  |
    |   read data ... into Set=[key] param1 param2;            |
    *----------------------------------------------------------*/
   read data hh_data into HH=[hhid] infl_wt expenditure;

   /*----------------------------------------------------------*
    | Decision variables: New weights we want to compute       |
    | Must be positive (≥ 0), indexed by HHID                  |
    | Syntax:                                                  |
    |   var varName{IndexSet} >= LowerBound;                   |
    *----------------------------------------------------------*/
   var w_new{HH} >= 0;

   /*----------------------------------------------------------*
    | Constraint 1: Normalization                              |
    | All new weights must sum to 1                            |
    | Syntax:                                                  |
    |   con ConstraintName: expression;                        |
    *----------------------------------------------------------*/
   con total: sum{h in HH} w_new[h] = 1;

   /*----------------------------------------------------------*
    | Constraint 2: Weighted mean of expenditure               |
    | We want the weighted average of expenditure to equal     |
    | a specific target, say 1500.                             |
    *----------------------------------------------------------*/
   number target_mean = 1500;
   con target_exp: sum{h in HH} expenditure[h] * w_new[h] = target_mean;

   /*----------------------------------------------------------*
    | Objective: Keep new weights close to original weights    |
    | Measured using squared Euclidean distance                |
    | Syntax:                                                  |
    |   minimize objName = sum{...} (w_new - infl_wt)**2       |
    *----------------------------------------------------------*/
   minimize dist = sum{h in HH} (w_new[h] - infl_wt[h])**2;

   /*----------------------------------------------------------*
    | Solve the problem using SAS's default solver             |
    | Since the objective is nonlinear (squares), SAS uses NLP |
    *----------------------------------------------------------*/
   solve;

   /*----------------------------------------------------------*
    | Display the optimized weights                            |
    | Syntax:                                                  |
    |   print varName;                                         |
    *----------------------------------------------------------*/
   print w_new;

quit;
