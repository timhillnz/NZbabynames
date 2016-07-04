# NZ Baby Names
Tim Hill  
1 July 2016  


```r
library(dplyr)
library(ggplot2)
library(RColorBrewer)

babynames <- read.csv("NZnamedata.csv", header=T)
```

For the first couple of plots we'll look at three generations of my family - my parents, my sister and myself, and my two children.


```r
girlsnames <- c("Elizabeth","Amelia","Ann")
boysnames <- c("Timothy", "Charlie","Roger")
selnames <- filter(babynames, (Name %in% girlsnames & Sex =="Girl") | 
                     (Name %in% boysnames & Sex =="Boy"))
```

Plot 1 shows the number of babies with the given names for the period 1954 - 2015


```r
ggplot(data = selnames, aes(x = Year, y = No., colour = Name)) +
  geom_line(aes(colour = Name)) + scale_color_brewer(palette = "Set2") +
  theme_bw() + labs(title = "Number of babies with selected names", y = "Babies named") +
  theme(legend.key = element_blank())
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-3-1.png) 

Plot 2 shows the ranking of the selected names (rank 1 = most popular name)


```r
ggplot(data = selnames, aes(x = Year, y = Rank, colour = Name)) +
  geom_line(aes(colour = Name)) + scale_color_brewer(palette = "Set2") +
  theme_bw() + scale_y_reverse(breaks = seq(0,100,15)) + 
  labs(title = "Ranking of selected names", y = "Name Rank") + 
  scale_x_continuous(breaks = seq(0, 2015, 10)) + theme(legend.key = element_blank())
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-4-1.png) 

From the two plots above, you can probably guess what generation each of the names come from.
