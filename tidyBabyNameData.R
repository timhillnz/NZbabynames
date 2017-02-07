library(XLConnect)
library(tidyr)
library(dplyr)
library(readr)


download.file("https://smartstart.services.govt.nz/assets/files/Top-baby-names-1954-2016.xlsx", "data/names.xlsx", mode = "wb")
ws <- loadWorkbook("data/names.xlsx")
names.ws <- getSheets(ws)

#read.names <- function(x){
#  readWorksheet(x, sheet)
#}


girlsdata <- readWorksheet(ws, "Girls' Names", startRow = 4, startCol = 2)
boysdata <- readWorksheet(ws, "Boys' Names", startRow = 4, startCol = 2)



## The excel spreadsheet is a mess for data analysis - the following works to clean 
## and tidy the data but is iterative and not the simplest script; something to 
## revisit in the future.

tidynames <- function(x, sex) {
  #add the year to every third column
  year.vec <- unique(unlist(x[1,grep("[0-9]{4}",x[1,])]))   #get a vector of the years
  num.yrs <- length(year.vec)   #find out how many years are included

  #remove extraneous cols & rows
  col.seq <- seq(1, ncol(x), by = 3)   #create an index of the columns (every third one) to be removed
  workdata <- x[!is.na(x[,1]),-col.seq]
  
  #add names to dataframe
  names(workdata) <- rep(c("name","number"), num.yrs)
  
  #create new dataframe in long format
  longdata <- data.frame(name = character(0), number = numeric(0))
  
  for (i in 1:num.yrs) {
    y <- i*2-1
    z <- i*2
    longdata <- rbind(longdata, workdata[,y:z])
  }
  
  #add year column
  year <- unlist(rep(year.vec, each = 100))
  longdata <- cbind(year, longdata)
  
  #add sex column
  babysex <- rep(sex, length(longdata))
  longdata <- cbind(sex, longdata)
  
  return(longdata)
}

girls <- tidynames(girlsdata, "girl")
boys <- tidynames(boysdata, "boy")

combinednames <- rbind(boys, girls)

write.csv(combinednames, row.names = F, file = "data/NZnamedata2016.csv")


### Also process birth data from statistics.govt.nz
min.year <- min(as.numeric(as.character(combinednames$year)))
max.year <- max(as.numeric(as.character(combinednames$year)))

birthdata <- read_csv("~/Dropbox/R_files/names/Birth_data.csv",
                col_names = c("year","liveMaleMaori","liveMaleTotal","liveFemaleMaori","liveFemaleTotal","liveMaori",
                "liveTotal","stillbirthMaori","stillbirthTotal","totalBirthsMaori","totalBirths"),
                col_types = "iiiiiiiiiii",
                na = c("..","NA"),  skip = 3, n_max = 81) %>%
  filter(year >= min.year & year <= max.year)

#the numbers of babies of each sex weren't recorded until 1971 - a simple linear model should suffice to impute 
#the missing data.

##split the data into training and prediction subsets
birthdata.complete <- birthdata[!is.na(birthdata$liveMaleTotal),]
birthdata.na  <- birthdata[is.na(birthdata$liveMaleTotal),]
  
##fit the lm
male.lm <- lm(liveMaleTotal ~ liveTotal, data = birthdata.complete)
male.lm$coefficients

##predict the male babies and calculate female babies
birthdata.na$liveMaleTotal <- round(predict(male.lm, birthdata.na))
birthdata.na <- mutate(birthdata.na, liveFemaleTotal = liveTotal - liveMaleTotal)

##recombine the subsets and plot the proportion of baby males
birthdata <- rbind(birthdata.na, birthdata.complete)
with(birthdata, plot(y = liveMaleTotal/liveTotal, x = year))





