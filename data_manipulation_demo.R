# ==================================================
# Introduction to Data Cleaning and Manipulation
# ==================================================
# This material was adapted from Ramnath Vaidyanathan 
# and Hadley Wickham

#### DATA CLEANING DEMO ####

# Load libraries
library(plyr)
library(dplyr)
library(reshape2)
library(ggplot2)

# Read in the PEW data
pew <- read.delim(
  file = "pew.txt",
  header = TRUE,
  check.names = F
)

# What is the size of this dataset?
dim(pew)

# Let's look at the raw data
View(pew)

# Check the class of each column variable
summary(pew)

# Tidy the PEW data
pew.tidy <- melt(
  data = pew,
  id = "religion",
  variable.name = "income",
  value.name = "frequency"
)

# What is the size of this dataset?
dim(pew.tidy)

# Let's look at the raw data
View(pew.tidy)

# Check the class of each column variable
summary(pew.tidy)

# Look at just the first few observations
head(pew.tidy)

# How might we clean data errors
pew.tidy$religion <- as.character(pew.tidy$religion)
# Add a fake error
pew.tidy$religion[1] <- "Agnosetic" # Fake error

# Inspect the different religion categories
sort(unique(pew.tidy$religion))
table(pew.tidy$religion)

pew.tidy$religion[pew.tidy$religion=="Agnosetic"] <- "Agnostic"

# What else might we want to do to clean this data?


#### DATA MANIPULATION DEMO ####

# Read in data
library(babynames)
dim(babynames)
head(babynames)

# Split - Apply - Combine

# Split
pieces <- split(babynames, list(babynames$name))
length(pieces)
pieces[[1]]
pieces[[2]]

# Apply
results <- vector("list", length(pieces))
for(i in seq_along(pieces)){
  piece <- pieces[[i]]
  results[[i]] <- summarise(piece, name = name[1], n = sum(n))
}
# Combine
result <- do.call("rbind", results)
head(result)

# Split - Apply - Combine - The New Way
counts <- ddply(babynames, "name", summarise, n = sum(n))
head(counts)

# How popular was the name emma over time?
# Subset
emma <- subset(babynames, name == "Emma")
head(emma)

# Preview of ggplot
qplot(x = year, y = prop, data = emma, geom = 'line')
qplot(x = year, y = prop, data = emma, geom = 'point')

# What is going on there?

#### ANSWER ####

qplot(x = year, y = prop, data = emma, geom = 'point', colour=sex)

#### CONTINUE ####

# Subset
emma <- subset(emma, sex == "girl")
qplot(x = year, y = prop, data = emma, geom = 'line')

#### The dplyr package ####

set.seed(6546)
nobs <- 1e+07
df <- data.frame(group = as.factor(sample(1:1e+05, nobs, replace = TRUE)), 
                 variable = rpois(nobs, 100))
print(object.size(df), units = "MB")
str(df)

# Calculate mean of variable within each group First, use ddply
system.time(grpmean <- ddply(df, .(group), summarise, 
                             grpmean = mean(variable)))
# user system elapsed 135.28 28.95 164.47

# Now, with dplyr
system.time(grpmean2 <- df %>% group_by(group) %>% 
              summarize(grpmean = mean(variable))) ### %>%  = apply some function
# user system elapsed 4.13 0.05 4.17

# 40X faster!











