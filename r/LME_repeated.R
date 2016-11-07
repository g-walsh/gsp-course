##===================================================
## Linear mixed-effect model (repeated measurements)
##===================================================

rm(list=ls())

library(lmerTest)
library(lsmeans)

load('Simulated_data.RData')

Treatments <- c('Tr1', 'Tr2') ## choose treatments to compare
Start_Day <- 6 ## first day number of the selected period
End_Day <- 20 ## last day number of the selected period
##-----------------------------------------------------------------
Data <- droplevels(subset(Data, is.element(Treatment, Treatments)))
Data <- droplevels(subset(Data, Timepoint >= Start_Day & Timepoint <= End_Day))
Data <- within(Data, Treatment <- relevel(Treatment, ref = 'Tr1')) ## choose Tr1 as baseline
Data <- transform(Data, Timepoint=as.factor(Timepoint))
##-----------------------------------------------------------------
Model <- lmer(Response ~ 1 + Timepoint * Treatment + (1|No), data=Data)
summary(Model)

##--------------------------------------------
## Effect sizes (table and plot):
LME_eff <- lsmeans (Model, ~ Treatment | Timepoint)
LME_eff_table <- data.frame(summary(LME_eff))
plot(LME_eff, xlab='Response')
