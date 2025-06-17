data bard;
input y @@;
datalines;
.14 .18 .22 .25 .29 .32 .35 .39
.37 .58 .73 .96 1.34 2.10 4.39
;
proc optmodel;
set I = 1..15;
number y{I};
read data bard into [_n_] y;  
number v{k in I} = 16 - k;
number w{k in I} = min(k, v[k]);
var x{1..3} init 1; /* starting point (1,1,1) is used*/
min f = 0.5*
sum{k in I}
(y[k] - (x[1] + k /
(v[k]*x[2] + w[k]*x[3])))**2;
solve;
print x;
create data xdata from [i] xd=x;

quit;

/*The values for parameter y are read from the BARD data set.*/
