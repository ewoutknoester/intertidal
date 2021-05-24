# loading libraries
library("readxl")
library("tidyverse")
library("lattice")
library("rstatix")
library("ggpubr")
library("lme4")
library("fitdistrplus")
library("lmerTest")

# loading xls files
my_data <- read_excel("ImageJ_R.xlsx", sheet = 2)

# combining relevant sheets of excel file
for (i in 3:19) {
  temp <- read_excel("ImageJ_R.xlsx", sheet = i)
  my_data <- rbind(my_data, temp)
  print(i)
}

# removing unnecessary columns
my_data <- my_data[c(1,3,5,18)]

startdate <- as.Date("2020-02-07","%Y-%m-%d")
my_data$Date2 <- as.numeric(difftime(my_data$Date,startdate ,units="days"), units="days")

my_data = my_data %>% 
  rename(
    Survival = `Survival (%)`
  )

# removing rows containing NAs (so the rows that don't contain the average values for brightness/Survival)
my_data <- na.omit(my_data)

# write.csv(my_data,"test.csv", row.names = FALSE)

## check repeated measures ANOVA requirements

# visualising data with box plots

boxplot(my_data$`Survival` ~ my_data$Date,
        data=my_data, 
        main="Survival", 
        xlab="Date", 
        ylab="Survival")

# normality tests
ggqqplot(my_data, x = "Survival")

hist(my_data$Survival)

shapiro_test(my_data$Survival)

# not normal -> sqrt transformation
my_data <- transform(my_data, `SQRT Survival`= sqrt(Survival))

ggqqplot(my_data, x = "SQRT.Survival")

hist(my_data$SQRT.Survival)

shapiro_test(my_data$SQRT.Survival)

# still not normal -> log10 transformation
my_data <- transform(my_data, LOG10.Survival= log(Survival))

ggqqplot(my_data, x = "LOG10.Survival")

hist(my_data$LOG10.Survival)

shapiro_test(my_data$LOG10.Survival)

# still not normal -> 1/x transformation
my_data <- transform(my_data, INVERSE.Survival= 1/Survival)

ggqqplot(my_data, x = "INVERSE.Survival")

hist(my_data$INVERSE.Survival)

shapiro_test(my_data$INVERSE.Survival)

# Testing which distribution fits the data best

test <- fitdist(my_data$Survival, "norm")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "lnorm")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "pois")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "exp")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "gamma")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "nbinom")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "geom")
plot(test)
test$aic

test <- fitdist((my_data$Survival/100), "beta", method = "mme")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "unif")
plot(test)
test$aic

test <- fitdist(my_data$Survival, "logis")
plot(test)
test$aic

# A beta distribution fits best, so this will be used in the model

# Generalized Linear Mixed Model with Repeated Measures

#Model <- glmer(Survival~Origin+Date2 + (1|Structure), family=gaussian, data=my_data)
#print(summary(Model),correlation=FALSE)

Model2 <- glmer(Survival~Origin+Date2 + (1|Structure), family=gaussian, data=my_data)
plot(Model2)
print(summary(Model2),correlation=FALSE)


