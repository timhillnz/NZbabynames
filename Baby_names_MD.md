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
  geom_line(aes(colour = Name)) + 
  scale_color_brewer(palette = "Set2") +
  theme_bw() + 
  labs(title = "Plot 1 - Number of babies with selected names", y = "Babies named") +
  theme(legend.key = element_blank())
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-3-1.png) 

Plot 2 shows the ranking of the selected names (rank 1 = most popular name)


```r
ggplot(data = selnames, aes(x = Year, y = Rank, colour = Name)) +
  geom_line(aes(colour = Name)) + 
  scale_color_brewer(palette = "Set2") +
  theme_bw() + 
  scale_y_reverse(breaks = seq(0,100,15)) + 
  labs(title = "Plot 2 - Ranking of selected names", y = "Name Rank") + 
  scale_x_continuous(breaks = seq(0, 2015, 10)) + 
  theme(legend.key = element_blank())
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-4-1.png) 

From the two plots above, you can probably guess what generation each of the names come from.


Now we'll dig into the data a bit deeper.  What are the most popular names in the period 1955 - 2015?

```r
### Boys names
topboynames <- babynames %>% 
  filter(Sex == "Boy") %>% 
  group_by(Name) %>% 
  summarise(Number = sum(No.)) %>% 
  arrange(-Number) %>% 
  slice(1:10) %>% 
  mutate(Name = reorder(Name, -Number, sum)) 

ggplot(topboynames, aes(x = Name, y = Number)) + 
  geom_bar(stat="identity") +
  labs(title="Plot 3 - Most popular boys names 1955-2015", y = "Number of babies")
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-5-1.png) 

```r
### Girls names
topgirlnames <- babynames %>% 
  filter(Sex == "Girl") %>% 
  group_by(Name) %>% 
  summarise(Number = sum(No.)) %>% 
  arrange(-Number) %>% 
  slice(1:10) %>% 
  mutate(Name = reorder(Name, -Number, sum))

ggplot(topgirlnames, aes(x = Name, y = Number)) + 
  geom_bar(stat="identity") +
  labs(title="Plot 4 - Most popular girls names 1955-2015", y = "Number of babies")
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-5-2.png) 


So how have those top names faired on a year by year basis?
For a cleaner plot, we'll only look at the top 6 for each sex.

```r
### Top boys names

# Create vector of names
top6boysvec <- topboynames %>% select(Name) %>% slice(1:6) %>% droplevels() %>% .$Name

# Create df
top6boysdata <- babynames %>% filter(Name %in% top6boysvec & Sex == "Boy") %>% droplevels()

# Create plot  
ggplot(data = top6boysdata, aes(x = Year, y = Rank, colour = Name)) +
  geom_line(aes(colour = Name)) + 
  scale_color_brewer(palette = "Set2") +
  theme_bw() + 
  scale_y_reverse(breaks = c(1,10,20,30,40,50,60,70,80,90,100)) + 
  labs(title = "Plot 5 - Ranking of top boys names", y = "Name Rank") + 
  scale_x_continuous(breaks = seq(0, 2015, 10)) + 
  theme(legend.key = element_blank())
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-6-1.png) 

```r
### Top girls names

# Create vector of required names
top6girlsvec <- topgirlnames %>% select(Name) %>% slice(1:6) %>% droplevels() %>% .$Name

# Create df 
top6girlsdata <- babynames %>% filter(Name %in% top6girlsvec & Sex == "Girl") %>% droplevels()

# Create plot  
ggplot(data = top6girlsdata, aes(x = Year, y = Rank, colour = Name)) +
  geom_line(aes(colour = Name)) + 
  scale_color_brewer(palette = "Set2") +
  theme_bw() + 
  scale_y_reverse(breaks = c(1,10,20,30,40,50,60,70,80,90,100)) + 
  labs(title = "Plot 6 - Ranking of girls names", y = "Name Rank") + 
  scale_x_continuous(breaks = seq(0, 2015, 10)) + 
  theme(legend.key = element_blank())
```

![](Baby_names_MD_files/figure-html/unnamed-chunk-6-2.png) 

