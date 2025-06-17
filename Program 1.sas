/* invoke procedure */
proc optmodel;
var x, y; /* declare variables */
/* objective function */
min z=x**2 - x - 2*y - x*y + y**2;
/* now run the solver */
solve;
print x y z;
quit;


proc optmodel;
number alpha = 100; /* declare parameter */
var x {1..2}; /* declare variables */
/* objective function */
min f = alpha*(x[2] - x[1]**2)**2 +
(1 - x[1])**2;
/* now run the solver */
solve;
print x;
quit;



proc optmodel;
/* specify parameters */
set O={'Detroit','Pittsburgh'};
set D={'Boston','New York'};
number c{O,D}=[30 20
40 10];
number a{O}=[200 100];
number b{D}=[150 150];
/* model description */
var x{O,D} >= 0;
min total_cost = sum{i in O, j in D}c[i,j]*x[i,j];
constraint supply{i in O}: sum{j in D}x[i,j]=a[i];
constraint demand{j in D}: sum{i in O}x[i,j]=b[j];
/* solve and output */
solve;
print x;
quit;


proc optmodel;
var x, y;
number low;
con a: x+y >= low;

quit;


proc optmodel;
var x, y;
min q=(x+y)**2;
max l=x+2*y;
min z=q+l;
con c1: q<=4;
con c2: l>=2;
solve;
print x y;
quit;


proc optmodel;
problem prob1;
use problem prob1;
var x >= 0; /* included in prob1 */
min z1 = (x-1)**2; /* included in prob1 */
expand; /* prob1 contains x, z1 */
solve;
print x;
quit;

proc optmodel;
   /* 1. Define string-based sets */
   set <str> WH = {'Atlanta', 'Denver'};
   set <str> ST = {'Chicago', 'Boston'};

   /* 2. Define parameters: cost, supply, demand */
   number cost{WH, ST} = [30 20
                          40 10];
   number supply{WH} = [100 150];
   number demand{ST} = [80 170];

   /* 3. Decision variables: how much to ship */
   var ship{WH, ST} >= 0;

   /* 4. Objective: Minimize total shipping cost */
   minimize TotalCost = sum{i in WH, j in ST} cost[i,j] * ship[i,j];

   /* 5. Constraints */
   con SupplyLimit{i in WH}: sum{j in ST} ship[i,j] <= supply[i];
   con DemandMet{j in ST}:   sum{i in WH} ship[i,j] >= demand[j];

   /* 6. Solve and print solution */
   solve;
   print ship;
quit;



