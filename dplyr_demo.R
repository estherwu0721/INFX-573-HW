#############################################################
#                                                           #
# Introduction to dplyr for Faster Data Manipulation in R   #
#                                                           #
#############################################################

# Tutorial by Kevin Markham, Sept. 2014
# http://rpubs.com/justmarkham/dplyr-tutorial

#### intro to data and basic inspection ####

# load packages
library(tidyverse)
library(hflights)

# explore data
data(hflights)
head(hflights)

# get help on the data
?hflights

class(hflights$Year)
apply(hflights, 2, class)

# what data structure
class(hflights)

# what data types
summary(hflights)

# convert to local data frame
flights <- as_data_frame(hflights)

# tbl_df creates a “local data frame”, older version of as_data_frame
# Local data frame is simply a wrapper for a data frame that prints nicely

# printing only shows 10 rows and as many columns as can fit on your screen
flights

# you can specify that you want to see more rows
print(flights, n=20)

# convert to a normal data frame to see all of the columns
data.frame(head(flights))

#### filter: Keep rows matching criteria ####

# base R approach to view all flights on January 1
flights[flights$Month==1 & flights$DayofMonth==1, ]

# dplyr approach
# note: you can use comma or ampersand to represent AND condition
filter(flights, Month==1, DayofMonth==1)

# use pipe for OR condition
filter(flights, UniqueCarrier=="AA" | UniqueCarrier=="UA")

# you can also use %in% operator
filter(flights, UniqueCarrier %in% c("AA", "UA"))

#### select: Pick columns by name ####

# base R approach to select DepTime, ArrTime, and FlightNum columns
flights[, c("DepTime", "ArrTime", "FlightNum")]

# dplyr approach
select(flights, DepTime, ArrTime, FlightNum)

# use colon to select multiple contiguous columns, 
# and use `contains` to match columns by name# note: `starts_with`, `ends_with`, and `matches` (for regular expressions) 
# note: `starts_with`, `ends_with (for regular expressions) 
# can also be used to match columns by name
select(flights, Year:DayofMonth, contains("Taxi"), contains("Delay"))

#### chaining or piplining ####

# Usual way to perform multiple operations in one line is by nesting
# Can write commands in a natural order by using the %>% infix operator 
# (which can be pronounced as “then”)

# nesting method to select UniqueCarrier and DepDelay columns and filter for delays over 60 minutes
filter(select(flights, UniqueCarrier, DepDelay), DepDelay > 60)

# chaining method
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  filter(DepDelay > 60)

#### arrange: Reorder rows ####

# base R approach to select UniqueCarrier and DepDelay columns and sort by DepDelay
flights[order(flights$DepDelay), c("UniqueCarrier", "DepDelay")]

# dplyr approach
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(DepDelay)

# use `desc` for descending
flights %>%
  select(UniqueCarrier, DepDelay) %>%
  arrange(desc(DepDelay))

#### mutate: Add new variables ####

# base R approach to create a new variable Speed (in mph)
flights$Speed <- flights$Distance / flights$AirTime*60
flights[, c("Distance", "AirTime", "Speed")]

# dplyr approach (prints the new variable but does not store it)
flights %>%
  select(Distance, AirTime) %>%
  mutate(Speed = Distance/AirTime*60)

# store the new variable
flights <- flights %>% mutate(Speed = Distance/AirTime*60)

#### summarise: Reduce variables to values ####

# Primarily useful with data that has been grouped by one or more variables
# group_by creates the groups that will be operated on
# summarise uses the provided aggregation function to summarise each group

# base R approaches to calculate the average arrival delay to each destination
head(with(flights, tapply(ArrDelay, Dest, mean, na.rm=TRUE)))
head(aggregate(ArrDelay ~ Dest, flights, mean))

# dplyr approach: create a table grouped by Dest, and then summarise each group by taking the mean of ArrDelay
flights %>%
  group_by(Dest) %>%
  summarise(avg_delay = mean(ArrDelay, na.rm=TRUE),
            med_delay = median(ArrDelay, na.rm = TRUE))

# summarise_each allows you to apply the same summary function 
# to multiple columns at once

# for each carrier, calculate the percentage of flights cancelled or diverted
flights %>%
  group_by(UniqueCarrier) %>%
  summarise_each(funs(mean), Cancelled, Diverted)

# for each carrier, calculate the minimum and maximum arrival and departure delays
flights %>%
  group_by(UniqueCarrier) %>%
  summarise_each(funs(min(., na.rm=TRUE), max(., na.rm=TRUE)), matches("Delay"))


# Helper function n() counts the number of rows in a group
# Helper function n_distinct(vector) counts the number of unique items in that vector

# for each day of the year, count the total number of flights and sort in descending order
flights %>%
  group_by(Month, DayofMonth) %>%
  summarise(flight_count = n()) %>%
  arrange(desc(flight_count))

# for each destination, count the total number of flights and the number of distinct planes that flew there
flights %>%
  group_by(Dest) %>%
  summarise(flight_count = n(), plane_count = n_distinct(TailNum))

#### other useful functions ####

# randomly sample a fraction of rows, with replacement
flights %>% sample_frac(0.25, replace=TRUE)

