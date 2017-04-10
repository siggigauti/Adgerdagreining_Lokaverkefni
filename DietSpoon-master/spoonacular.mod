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

# Max values of the given datasets
param aggregateLikes_max := max({d in dish}aggregateLikes[d]);
param pricePerServing_max := max({d in dish}pricePerServing[d]);

# Constants
param readyInMinutes_max;
param numDish;
param min_cal;
param max_cal;
param max_cost;

# Constraints
subject to theplan: sum{d in dish} x[d] = numDish;
subject to kaloriurmin: sum{d in dish} x[d] * dishnutrient[d, "Calories"] >= numDish * min_cal;
subject to keinnmax{d in dish}: x[d] * dishnutrient[d, "Calories"] <= max_cal;
subject to hamarkskostn{d in dish}: x[d] * pricePerServing[d] <= max_cost;
subject to hamarkstimi{d in dish}: x[d] * readyInMinutes[d] <= readyInMinutes_max;
subject to stillay{d in dish, i in ingredient}: y[i] = 0 ==> x[d] * dishingredient[d,i] = 0;
subject to minnut{n in nutrient}: sum{d in dish} x[d] * dishnutrient[d,n] >= numDish * daily_req[n] / 3;
subject to minfish: sum{d in typefish} x[d] >= 1;
subject to minmeat: sum{d in typemeat} x[d] >= 1;
subject to minveg: sum{d in typeveg} x[d] >= 1;

# The objective function, note that each objective should have a weight
minimize objfunction:
  - 2 * sum{d in dish} (aggregateLikes[d] * x[d]) / aggregateLikes_max
  + 1000000 * (sum{i in ingredient} y[i])
  + 1 * sum{d in dish} (pricePerServing[d] * x[d]) / pricePerServing_max
  + 0.9 * sum{d in dish} (readyInMinutes[d] * x[d]) / readyInMinutes_max;
