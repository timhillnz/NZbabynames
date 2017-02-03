library(XLConnect)
library(tidyr)


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


### Tidy girls names data ======================================

#remove rows that start with NA

#add the year to every third column
year.vec <- girlsdata[1,grep("[0-9]{4}",girlsdata[1,])]   #get a vector of the years
num.yrs <- length(year.vec)   #find out how many years are included
yr.seq <- seq(1, ncol(girlsdata), by = 3)

girlsdata <- girlsdata[!is.na(girlsdata[,1]),]

#remove extraneous columns & rows
col.seq <- seq(1, ncol(girlsdata), by = 3)   #create an index of the columns (every third one) that are to contain the year
#girlsdata <- girlsdata[-c(1:3),-col.seq]   #remove extraneous rows/columns

for(i in 1:length(year.vec)) {   #loop through the column index and add the years
  girlsdata[,yr.seq[i]] <- year.vec[i]
}

#add column names
names(girlsdata) <- rep(c("year","name","number"), times = num.yrs)

#tidy the data

stack(girlsdata)


girlsdata2 <- gather(girlsdata, "year", "name", "number", 1:ncol(girlsdata))




### Tidy Boys data ==========================================
boysdata[1,56] <- boysdata[1,57]
boysdata <- tbl_df(boysdata)
boysdata <- boysdata[-3,-2]
boysdata[1,1] <- 1954

for (h in seq(1,186, by=3)){
  yearvec <- as.numeric(rep(boysdata[1,h],100))
  boysdata[3:102,h] <- yearvec
  boysdata[2,h] <- "Year"
  boysdata[2,h+1] <- "Name"
  boysdata[2,h+2] <- "No."
}
rm(h)

colnames(boysdata) <- boysdata[2,]

boysdata <- boysdata[-c(1,2),]

boysdata2 <- data.frame(Year = as.numeric(),
                         Name = as.character(),
                         No. = as.numeric())

for (i in seq(1,186, by=3)){
  boysdata2 <- rbind(boysdata2,boysdata[,i:(i+2)])
}
boysdata2$Sex <- rep("Boy", times = length(boysdata2$Year))

### Merge data and final tidy ==========================================

namedata <- rbind(boysdata2,girlsdata2)
namedata$Year <- as.numeric(namedata$Year)
namedata$No. <- as.numeric(namedata$No.)
namedata$Name <- as.factor(namedata$Name)
namedata$Sex <- as.factor(namedata$Sex)

namedata <- namedata %>% group_by(Sex, Year) %>% 
  mutate(Rank = rank(-No., ties.method = "min")) %>% ungroup()

# Final correction - Michael appears twice in 1988, I'm guessing that the lower ranked entry 
# should be 'Micheal'
namedata[3500,2] <- "Micheal"

write.csv(namedata, row.names = F, file = "NZnamedata.csv")


### Also process birth data from statistics.govt.nz

birthdata <- read_csv("~/Dropbox/R_files/names/Birth_data.csv",
                col_names = c("year","liveMaleMaori","liveMaleTotal","liveFemaleMaori","liveFemaleTotal","liveMaori",
                "liveTotal","stillbirthMaori","stillbirthTotal","totalBirthsMaori","totalBirths"),
                col_types = "iiiiiiiiiii",
                na = c("..","NA"),  skip = 3, n_max = 81)

birthdata <- birthdata %>% gather(type, number, -year)






