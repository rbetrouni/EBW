proc optmodel;
   var x >= 0, y >= 0;
   maximize obj = 3*x + 4*y;
   con constraint1: 2*x + y <= 100;
   con constraint2: x + 2*y <= 80;
   solve;
   print x y;
quit;


proc optmodel;
   set PRODUCTS = {'A','B'};
   number profit{PRODUCTS} = [3 4];
   var x{PRODUCTS} >= 0;
   maximize total_profit = sum{i in PRODUCTS} profit[i]*x[i];
   con limit: x['A'] + 2*x['B'] <= 80;
   solve;
   print x;
quit;


proc optmodel;
   set O = 1..2;
   set D = 1..2;
   number c{O,D} = [30 20
                    40 10];
   print c;
quit;




proc optmodel;
   var x >= 0;
   maximize obj = x;
   solve with lp;
   print x;
quit;



proc optmodel;
   var x >= 0, y >= 0;
   maximize obj = x + 2*y;
   con c1: x + y <= 10;
   solve with lp;
   print x y;
quit;


proc optmodel;
   set <string> I = {'A','B','C'};
   var x{I} >= 0;
   maximize obj = sum{i in I} x[i];
   con total: sum{i in I} x[i] <= 100;
   solve with lp;
   print x;
quit;

