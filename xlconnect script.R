library(XLConnect)
library(dplyr)


ws <- loadWorkbook("Top-baby-names-1954-2015.xlsx")
names.ws <- getSheets(ws)

#read.names <- function(x){
#  readWorksheet(x, sheet)
#}


girlsdata <- readWorksheet(ws, "Girls' Names", startRow = 4, endRow = 107)
boysdata <- readWorksheet(ws, "Boys' Names", startRow = 4, endRow = 107)


## The excel spreadsheet is a mess for data analysis - the following works to clean 
## and tidy the data but is iterative and not the simplest script. Something to 
## revisit in the future.


### Tidy girls names data ======================================
girlsdata[1,95] <- girlsdata[1,96]

girlsdata <- tbl_df(girlsdata)
girlsdata <- girlsdata[-3,-2]
girlsdata[1,1] <- 1954

for (h in seq(1,186, by=3)){
  yearvec <- as.numeric(rep(girlsdata[1,h],100))
  girlsdata[3:102,h] <- yearvec
  girlsdata[2,h] <- "Year"
  girlsdata[2,h+1] <- "Name"
  girlsdata[2,h+2] <- "No."
}
rm(h)

colnames(girlsdata) <- girlsdata[2,]

girlsdata <- girlsdata[-c(1,2),]

girlsdata2 <- data.frame(Year = as.numeric(),
                         Name = as.character(),
                         No. = as.numeric())

for (i in seq(1,186, by=3)){
  girlsdata2 <- rbind(girlsdata2,girlsdata[,i:(i+2)])
}
girlsdata2$Sex <- rep("Girl", times = length(girlsdata2$Year))


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




