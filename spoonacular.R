# (tpr 13/2/2017)

# This code needs to be cleaned up, but works ;) Youn need to put YOURMASHKEY in two places.
# httr is a library in R with tools for working with URLs and HTTP. (install.packages('httr'))
library(httr)
# the base URL for getting recipies IDs from a search query, here just looking for one hundred fish type meals
url <- c('https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?query=fish&number=100&type=main+course')
# get the reponse from Spoonacular using your MASHKEY
resp <- GET(url, add_headers("X-Mashape-Key" = "YcOLNx4wu1mshRPWRyEydtl0BqRzp1HCuoljsnq04qkqz51rCe", "Accept" = "application/json"))
# the number of recipies received, the maximum you can request is 100
n <- length(content(resp)$results)
ID <- integer(n) # empty list on intergers of length n
recipe <- list() # an empty list to hold our n recipies
for (i in c(1:n)) {
  ID[i] <- content(resp)$results[[i]]$id # get ID from previous request (above), create request string:
  url <- paste0(c("https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/"),as.character(ID[i]),c("/information?includeNutrition=true"))
  recipe[[i]] <- GET(url, add_headers("X-Mashape-Key" = "YcOLNx4wu1mshRPWRyEydtl0BqRzp1HCuoljsnq04qkqz51rCe", "Accept" = "application/json")) # get recipe
}
# Save your data for future analysis, we don't want to request the same stuff more than once
save(file=c("fishdata.Rdata"), list=c("resp", "recipe"))
# Extract needed information from the json string, Spoonacular will give you these things:
# "vegetarian"               "vegan"                    "glutenFree"               "dairyFree"               
# "veryHealthy"              "cheap"                    "veryPopular"              "sustainable"             
# "weightWatcherSmartPoints" "gaps"                     "lowFodmap"                "ketogenic"               
# "whole30"                  "servings"                 "sourceUrl"                "spoonacularSourceUrl"    
# "aggregateLikes"           "spoonacularScore"         "healthScore"              "creditText"              
# "sourceName"               "extendedIngredients"      "id"                       "title"                   
# "readyInMinutes"           "image"                    "imageType"                "nutrition"               
# "cuisines"                 "dishTypes"                "pricePerServing"          "instructions"            
# "analyzedInstructions" 
# lets get some of these things, start by creating amty vector and lists:
healthScore <- integer(n); cookingMinutes <- integer(n); preparationMinutes <- integer(n);
readyInMinutes <- integer(n); pricePerServing <- numeric(n); aggregateLikes <- integer(n);
servings <- integer(n); cheap <- logical(n); ingredience <- list(); amount <- list();
unit <- list(); nutrients_name <- list(); nutrients_unit <- list(); nutrients_amount <- list();
allingredience <- NULL; allnutrients <- NULL; title <- NULL;
# now loop through all the recipies and extract the data from tje json object
for (i in c(1:n)) {
  healthScore[i] <- content(recipe[[i]])$healthScore
  title <- c(title,content(recipe[[i]])$title)
  cheap[i] <- content(recipe[[i]])$cheap
  servings[i] <- content(recipe[[i]])$servings
  if (length(content(recipe[[i]])$cookingMinutes) > 0) {
    cookingMinutes[i] <- content(recipe[[i]])$cookingMinutes
  }
  if (length(content(recipe[[i]])$preparationMinutes) > 0) {
    preparationMinutes[i] <- content(recipe[[i]])$preparationMinutes
  }
  # note: I find the price for some dishes to be rather high, shoule we divide by servings?
  # lets try to get a breakdown for the price from Spoonacular!?
  pricePerServing[i] <- content(recipe[[i]])$pricePerServing # / content(recipe[[i]])$servings
  readyInMinutes[i] <- content(recipe[[i]])$readyInMinutes
  aggregateLikes[i] <- content(recipe[[i]])$aggregateLikes
  # now for some messy work:
  str <- NULL;  astr <- NULL; ustr <- NULL;
  nutrname <- NULL; nutramount <- NULL; nutrunit <- NULL;
  for (j in c(1:length(content(recipe[[i]])$nutrition$ingredients))) {
    str <- gsub(" ","_",c(str,content(recipe[[i]])$nutrition$ingredients[[j]]$name),fixed=TRUE)
    astr <- c(astr, content(recipe[[i]])$nutrition$ingredients[[j]]$amount)
    ustr <- c(ustr, content(recipe[[i]])$nutrition$ingredients[[j]]$unit)
    if (length(content(recipe[[i]])$nutrition$ingredients[[j]]$nutrients) > 0) {
      for (k in c(1:length(content(recipe[[i]])$nutrition$ingredients[[j]]$nutrients))) {
        nutrname <- gsub(" ","_",c(nutrname, content(recipe[[i]])$nutrition$ingredients[[j]]$nutrients[[k]]$name),fixed=TRUE)
        nutramount <- c(nutramount, content(recipe[[i]])$nutrition$ingredients[[j]]$nutrients[[k]]$amount)
        nutrunit <- c(nutrunit, content(recipe[[i]])$nutrition$ingredients[[j]]$nutrients[[k]]$unit)
      }
    }
  }
  ingredience[[i]] <- gsub("&","",str)
  amount[[i]] <- astr
  unit[[i]] <- ustr
  nutrients_name[[i]] <- gsub("&","",nutrname)
  nutrients_amount[[i]] <- nutramount
  nutrients_unit[[i]] <- nutrunit
  allingredience <- (c(allingredience, ingredience[[i]]))
  allnutrients <- (c(allnutrients, nutrients_name[[i]]))
}
allnutrients <- sort(unique(allnutrients))
allingredience <- sort(unique(allingredience))

# Now put this all into an AMPL dat file called "spoonacular.dat":
cat("set dish := ", as.character(ID), file="spoonacular.dat",sep=" ",append=FALSE)
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)

cat("param dishname := ", file="spoonacular.dat",sep="\n",append=TRUE)
for (i in c(1:n)) {
  cat(as.character(ID[i]), " \"", title[i], "\"", file="spoonacular.dat",sep="",append=TRUE)
  cat("\n",file="spoonacular.dat",sep="",append=TRUE)
}
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)

cat("set nutrient := ", allnutrients, file="spoonacular.dat",sep=" ",append=TRUE)
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)

cat("set ingredient := ", allingredience, file="spoonacular.dat",sep=" ",append=TRUE)
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)

nutrients_recipe <- matrix(rep(n*length(allnutrients),0), nrow = n)
nutrients_recipe <- as.data.frame(nutrients_recipe,col.names<-sort(allnutrients))
cat("param dishnutrient := ",file="spoonacular.dat",sep="\n",append=TRUE)
for (i in c(1:n)) {
  for (j in allnutrients) {
    nutrients_recipe[i,j] <- sum(nutrients_amount[[i]][which(j==nutrients_name[[i]])])
    if (length(unique(nutrients_unit[[i]][which(j==nutrients_name[[i]])]))>1) {
      print(nutrients_unit[[i]][which(j==nutrients_name[[i]])])
    }
    if (nutrients_recipe[i,j] > 0) {
      cat(as.character(ID[i]),j,as.character(nutrients_recipe[i,j]),file="spoonacular.dat",sep=" ",append=TRUE)
      cat("\n",file="spoonacular.dat",sep="",append=TRUE)
    }
  }
}
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)
ingredience_recipe <- matrix(rep(n*length(allingredience),0), nrow = n)
ingredience_recipe <- as.data.frame(ingredience_recipe,col.names<-sort(allingredience))
cat("param dishingredient := ",file="spoonacular.dat",sep="\n",append=TRUE)
for (i in c(1:n)) {
  for (j in allingredience) {
    ingredience_recipe[i,j] <- sum(amount[[i]][which(j==ingredience[[i]])])
    if (length(unique(unit[[i]][which(j==unit[[i]])]))>1) {
      print(unit[[i]][which(j==unit[[i]])])
    }
    if (ingredience_recipe[i,j]>0) {
      cat(as.character(ID[i]),j,ingredience_recipe[i,j],file="spoonacular.dat",sep=" ",append=TRUE)
      cat("\n",file="spoonacular.dat",sep="",append=TRUE)
    }
  }
}
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)

# Popularity of the dish
cat("param aggregateLikes := ",file="spoonacular.dat",sep="\n",append=TRUE)
for (i in c(1:n)) {
  cat(as.character(ID[i]),aggregateLikes[i],file="spoonacular.dat",sep=" ",append=TRUE)
  cat("\n",file="spoonacular.dat",sep="",append=TRUE)
}
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)

# The price of a dish
cat("param pricePerServing := ",file="spoonacular.dat",sep="\n",append=TRUE)
for (i in c(1:n)) {
  cat(as.character(ID[i]),pricePerServing[i],file="spoonacular.dat",sep=" ",append=TRUE)
  cat("\n",file="spoonacular.dat",sep="",append=TRUE)
}
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)

# The time taken to make the dish
cat("param readyInMinutes := ",file="spoonacular.dat",sep="\n",append=TRUE)
for (i in c(1:n)) {
  cat(as.character(ID[i]),readyInMinutes[i],file="spoonacular.dat",sep=" ",append=TRUE)
  cat("\n",file="spoonacular.dat",sep="",append=TRUE)
}
cat(";\n\n",file="spoonacular.dat",sep="",append=TRUE)
