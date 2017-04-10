# A modern look at Stigler's diet problem
# Solution template

# The set of dishes
set dish;
param dishname{dish} symbolic;
param dishtype{dish};

set typefish := setof{d in dish: dishtype[d] == 0} d;
set typemeat := setof{d in dish: dishtype[d] == 1} d;
set typeveg := setof{d in dish: dishtype[d] == 2} d;

# The set of ingredience
set ingredient;

# The set of nutrients
set nutrient;

# Indicator to tell us that the dish is chosen
var x{dish} binary;

# Indicator to tell us that an ingredient is chosen
var y{ingredient} binary;

# A popularity measure for the dish
param aggregateLikes{dish};

# The price of a dish
param pricePerServing{dish};

# The time taken to make the dish
param readyInMinutes{dish};

# The amount if nutrients found in a dish
param dishnutrient{dish,nutrient} >= 0, default 0;
param daily_req{nutrient} default 0;

# The ingredients per dish and the number of them
param dishingredient{dish,ingredient} >= 0, default 0;
param numberofingredient{d in dish} := sum{i in ingredient: dishingredient[d,i] > 0} 1;

param aggregateLikes_max := max({d in dish}aggregateLikes[d]);
param pricePerServing_max := max({d in dish}pricePerServing[d]);
param readyInMinutes_max := 60;

# For example: select 5 dishes, plan for a week
subject to theplan: sum{d in dish} x[d] = 5;
subject to kaloriurmin: sum{d in dish} x[d] * dishnutrient[d, "Calories"] >= 5*1000;
subject to kaloriurmax: sum{d in dish} x[d] * dishnutrient[d, "Calories"] <= 5*1200;
subject to keinnmax{d in dish}: x[d] * dishnutrient[d, "Calories"] <= 1200;
subject to hamarkskostn{d in dish}: x[d] * pricePerServing[d] <= 400;
subject to hamarkstimi{d in dish}: x[d] * readyInMinutes[d] <= readyInMinutes_max;
subject to stillay{d in dish, i in ingredient}: y[i] = 0 ==> x[d] * dishingredient[d,i] = 0;
subject to b21min: sum{d in dish} x[d] * dishnutrient[d, "Vitamin_B12"] >= 20*2/3;
subject to amin: sum{d in dish} x[d] * dishnutrient[d, "Vitamin_A"] >= 20*900/3;
subject to cmin: sum{d in dish} x[d] * dishnutrient[d, "Vitamin_C"] >= 20*75/3;
subject to minfish: sum{d in typefish} x[d] >= 1;
subject to minmeat: sum{d in typemeat} x[d] >= 1;
subject to minveg: sum{d in typeveg} x[d] >= 1;

# The objective function, note that each objective should have a weight
# For example: here only two goals is given, the popularity and number of ingredients
minimize objfunction:
  - sum{d in dish} (aggregateLikes[d] * x[d]) / aggregateLikes_max * 2
  + 1000000 * (sum{i in ingredient} y[i])
  + sum{d in dish} (pricePerServing[d] * x[d]) / pricePerServing_max
  + sum{d in dish} (readyInMinutes[d] * x[d]) / readyInMinutes_max * 0.9;
