---
  title: "Reproducible Research: Peer Assessment 1"
author: "Lebone"
date: "1/25/2021"
output: html_document
---
  
  ## Preparing the enviroment 
  
  Setting global option to turn warnings off and loading the packages needed to complete the tasks.

```{r}
knitr::opts_chunk$set(warning = FALSE)
library(ggplot2)
library(base)
```

## Downloading and unzipping files

This step downloads the data and unzips the files into the working directory; 

```{r, results='hide'}

download.file("https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip", "./Data.zip")
unzip("./Data.zip")

```

## Loading and prepping the data

This reads the csv files from the previous step into data frames. Also pulls a 6 number summary of the data.

```{r}

activity <- read.csv("./activity.csv")

activity$date <- as.POSIXct(activity$date, "%Y-%m-%d")
weekday <- weekdays(activity$date)
activity <- cbind(activity,weekday)

summary(activity)

```

## 1. What is the mean total number of steps taken per day?

```{r}
activity_total_steps <- with(activity, aggregate(steps, by = list(date), FUN = sum, na.rm = TRUE))
names(activity_total_steps) <- c("date", "steps")
hist(activity_total_steps$steps, main = "Total number of steps taken per day", xlab = "Total steps taken per day", col = "yellow", ylim = c(0,20), breaks = seq(0,25000, by=2500))
```

**Mean of the total number of steps taken per day:**
  
  ```{r}
mean(activity_total_steps$steps)
```

**Median of the total number of steps taken per day:**
  
  ```{r}
median(activity_total_steps$steps)
```

## 2. What is the average daily activity pattern?

Time series plot (i.e. type = “l”) of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)

```{r}
average_daily_activity <- aggregate(activity$steps, by=list(activity$interval), FUN=mean, na.rm=TRUE)
names(average_daily_activity) <- c("interval", "mean")
plot(average_daily_activity$interval, average_daily_activity$mean, type = "l", col="green", lwd = 2, xlab="Interval", ylab="Average number of steps", main="Average number of steps per intervals")
```

**Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?**
  
  ```{r}
average_daily_activity[which.max(average_daily_activity$mean), ]$interval
```

## 3. Imputing missing values.

There are a number of days/intervals where there are missing values (coded as NA). The presence of missing days may introduce bias into some calculations or summaries of the data.

**Calculation of total number of missing values in the dataset (i.e. _the total number of rows with NAs_ )**
  
  ```{r}
sum(is.na(activity$steps))
```

Strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.

```{r, results='hide'}
imputed_steps <- average_daily_activity$mean[match(activity$interval, average_daily_activity$interval)]
```

**New dataset similar to the original dataset but with the missing data filled in.**
  
  ```{r, results='hide'}
activity_imputed <- transform(activity, steps = ifelse(is.na(activity$steps), yes = imputed_steps, no = activity$steps))
total_steps_imputed <- aggregate(steps ~ date, activity_imputed, sum)
names(total_steps_imputed) <- c("date", "daily_steps")
```

A histogram of the total number of steps taken each day and Calculate and report the mean and median total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment? What is the impact of imputing missing data on the estimates of the total daily number of steps?
  
  ```{r}
hist(total_steps_imputed$daily_steps, col = "yellow", xlab = "Total steps per day", ylim = c(0,30), main = "Total number of steps taken each day", breaks = seq(0,25000,by=2500))
```

**Here is the mean of the total number of steps taken per day:**
  
  ```{r}
mean(total_steps_imputed$daily_steps)
```

**Here is the median of the total number of steps taken per day:**
  
  ```{r}
median(total_steps_imputed$daily_steps)
```

## 4. Are there differences in activity patterns between weekdays and weekends?

A new factor variable in the dataset with two levels – “weekday” and “weekend” indicating whether a given date is a weekday or weekend day.

```{r, results='hide'}
activity$date <- as.Date(strptime(activity$date, format="%Y-%m-%d"))
activity$datetype <- sapply(activity$date, function(x) {
  if (weekdays(x) == "Sábado" | weekdays(x) =="Domingo") 
  {y <- "Weekend"} else 
  {y <- "Weekday"}
  y
})
```

Panel plot containing a time series plot (i.e. type = “l”) of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis).

```{r}
activity_by_date <- aggregate(steps~interval + datetype, activity, mean, na.rm = TRUE)
plot<- ggplot(activity_by_date, aes(x = interval , y = steps, color = datetype)) +
  geom_line() +
  labs(title = "Average daily steps by type of date", x = "Interval", y = "Average number of steps") +
  facet_wrap(~datetype, ncol = 1, nrow=2)
print(plot)
```


