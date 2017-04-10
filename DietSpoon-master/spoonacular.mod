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

# For example: select 5 dishes, plan for a week
subject to theplan: sum{d in dish} x[d] = 5;
subject to kaloriurmin: sum{d in dish} x[d] * dishnutrient[d, "Calories"] >= 5*1000;
subject to kaloriurmax: sum{d in dish} x[d] * dishnutrient[d, "Calories"] <= 5*1200;
subject to keinnmax{d in dish}: x[d] * dishnutrient[d, "Calories"] <= 1200;
subject to hamarkskostn{d in dish}: x[d] * pricePerServing[d] <= 1000;
subject to stillay{d in dish, i in ingredient}: y[i] = 0 ==> x[d] * dishingredient[d,i] = 0;

# The objective function, note that each objective should have a weight
# For example: here only two goals is given, the popularity and number of ingredients
minimize objfunction:
  - sum{d in dish} aggregateLikes[d] * x[d]
  + sum{i in ingredient} y[i]
  + sum{d in dish} pricePerServing[d] * x[d]
  + sum{d in dish} readyInMinutes[d] * x[d];
